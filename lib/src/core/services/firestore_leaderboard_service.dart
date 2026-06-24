import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../utils/utils.dart';
import '../../data/models/leaderboard_entry_model.dart';

/// Handles all Firestore operations for the global leaderboard.
///
/// Collection path: `leaderboard`  (one document per user, doc ID == uid)
///
/// Uses a Firestore **transaction** to safely increment totalScore / gamesPlayed
/// and update bestScore without read-write race conditions.
class FirestoreLeaderboardService {
  FirestoreLeaderboardService._();
  static final FirestoreLeaderboardService instance =
      FirestoreLeaderboardService._();

  FirebaseFirestore get _db => AppConfig.firestore;

  CollectionReference<Map<String, dynamic>> get _leaderboardRef =>
      _db.collection('leaderboard');

  /// Upserts the user's leaderboard document after a quiz.
  /// Atomically increments totalScore & gamesPlayed, and updates bestScore.
  FutureEither<void> updateEntry({
    required String uid,
    required String displayName,
    String? photoUrl,
    required int score,
  }) async {
    return runTask(() async {
      final docRef = _leaderboardRef.doc(uid);

      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        final data = snap.data() ?? {};

        final currentTotal = (data['totalScore'] as num?)?.toInt() ?? 0;
        final currentGames = (data['gamesPlayed'] as num?)?.toInt() ?? 0;
        final currentBest = (data['bestScore'] as num?)?.toInt() ?? 0;

        tx.set(
          docRef,
          {
            'uid': uid,
            'displayName': displayName,
            'photoUrl': photoUrl,
            'totalScore': currentTotal + score,
            'gamesPlayed': currentGames + 1,
            'bestScore': score > currentBest ? score : currentBest,
            'lastPlayedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });

      AppLogger.info('Leaderboard updated for user $uid (+$score)');
    }, requiresNetwork: true);
  }

  /// Fetches a paginated leaderboard page ordered by totalScore descending.
  FutureEither<({List<LeaderboardEntry> entries, DocumentSnapshot? lastDoc})>
  fetchPage({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    return runTask(() async {
      Query<Map<String, dynamic>> query = _leaderboardRef
          .orderBy('totalScore', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      // The rank offset depends on how many entries came before; caller
      // injects actual rank via LeaderboardProvider using list index.
      final entries = snapshot.docs.asMap().entries.map((e) {
        final data = Map<String, dynamic>.from(e.value.data());
        final ts = data['lastPlayedAt'];
        if (ts is Timestamp) {
          data['lastPlayedAt'] = ts.toDate();
        } else {
          data['lastPlayedAt'] = DateTime.now();
        }
        return LeaderboardEntry.fromJson(data);
      }).toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return (entries: entries, lastDoc: lastDoc);
    }, requiresNetwork: true);
  }
}
