import '../../../core/imports/imports.dart';
import 'leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirestoreLeaderboardService _service =
      FirestoreLeaderboardService.instance;

  @override
  FutureEither<LeaderboardPage> fetchPage({
    int limit = 20,
    LeaderboardPageCursor? cursor,
  }) async {
    final result = await _service.fetchPage(
      limit: limit,
      startAfter: cursor?.doc,
    );

    return result.fold(
      (failure) => left(failure),
      (page) {
        final nextCursor = page.lastDoc == null
            ? null
            : LeaderboardPageCursor(page.lastDoc!);
        return right(
          LeaderboardPage(entries: page.entries, nextCursor: nextCursor),
        );
      },
    );
  }
}
