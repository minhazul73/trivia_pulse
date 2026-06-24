import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../utils/utils.dart';
import '../../data/models/result_model.dart';

/// Handles all Firestore operations for personal quiz results.
///
/// Collection path: `users/{uid}/results`  (per-user subcollection)
class FirestoreResultService {
  FirestoreResultService._();
  static final FirestoreResultService instance = FirestoreResultService._();

  FirebaseFirestore get _db => AppConfig.firestore;

  CollectionReference<Map<String, dynamic>> _resultsRef(String uid) =>
      _db.collection('users').doc(uid).collection('results');

  /// Saves a result document and returns the new Firestore doc ID.
  FutureEither<String> saveResult(String uid, ResultModel result) async {
    return runTask(() async {
      final data = result.toJson();
      // Let Firestore handle Timestamp conversion from DateTime.
      final ref = await _resultsRef(uid).add(data);
      AppLogger.info('Result saved to Firestore: ${ref.id}');
      return ref.id;
    }, requiresNetwork: true);
  }

  /// Fetches a page of results ordered by timestamp descending.
  /// Returns a record with the results list and the last document snapshot
  /// to use as the pagination cursor for the next page.
  FutureEither<({List<ResultModel> results, DocumentSnapshot? lastDoc})>
  fetchPage(
    String uid, {
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    return runTask(() async {
      Query<Map<String, dynamic>> query = _resultsRef(uid)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final results = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        // Convert Firestore Timestamp → DateTime
        final ts = data['timestamp'];
        if (ts is Timestamp) {
          data['timestamp'] = ts.toDate();
        }
        return ResultModel.fromJson(data);
      }).toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return (results: results, lastDoc: lastDoc);
    }, requiresNetwork: true);
  }
}
