import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/utils.dart';
import '../../models/leaderboard_entry_model.dart';

abstract class LeaderboardRepository {
  /// Fetches a paginated leaderboard page (totalScore desc).
  FutureEither<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardPageCursor? cursor,
  });
}

/// Pagination cursor wrapping a Firestore DocumentSnapshot.
class LeaderboardPageCursor {
  final DocumentSnapshot doc;
  const LeaderboardPageCursor(this.doc);
}

/// One page of leaderboard entries.
class LeaderboardPage {
  final List<LeaderboardEntry> entries;
  final LeaderboardPageCursor? nextCursor; // null when no more pages

  const LeaderboardPage({required this.entries, this.nextCursor});
}
