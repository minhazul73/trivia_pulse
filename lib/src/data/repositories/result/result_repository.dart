import '../../../core/utils/utils.dart';
import '../../models/result_model.dart';

abstract class ResultRepository {
  /// Saves a result to Firestore (personal history) + Hive (offline cache)
  /// and upserts the global leaderboard entry.
  ///
  /// [displayName] and [photoUrl] are needed for the leaderboard upsert.
  FutureEither<void> save(
    String uid,
    ResultModel result, {
    String? displayName,
    String? photoUrl,
  });

  /// Fetches a paginated page of the user's personal history.
  /// Returns the results and a cursor object for the next page.
  /// Uses Firestore when online, falls back to Hive when offline.
  FutureEither<ResultPage> fetchPage(
    String uid, {
    int limit = 10,
    ResultPageCursor? cursor,
  });

  /// Clears the local Hive cache for [uid].
  FutureEither<void> clearLocal(String uid);
}

/// Pagination cursor — wraps either a Firestore DocumentSnapshot or
/// a Hive offset index, allowing the provider to stay cursor-agnostic.
class ResultPageCursor {
  final Object? firestoreDoc; // DocumentSnapshot
  final int hiveOffset;

  const ResultPageCursor({this.firestoreDoc, this.hiveOffset = 0});
}

/// Holds one page of results with the cursor for the next page.
class ResultPage {
  final List<ResultModel> results;
  final ResultPageCursor? nextCursor; // null when no more pages

  const ResultPage({required this.results, this.nextCursor});
}
