import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/imports/imports.dart';
import '../../models/result_model.dart';
import 'result_repository.dart';

/// Write-through implementation:
/// • Writes to Firestore (personal results + leaderboard) and Hive in parallel.
/// • Reads from Firestore first; on failure, falls back to local Hive cache.
class ResultRepositoryImpl implements ResultRepository {
  static const _hiveBoxName = 'app_box';
  static const _maxLocalEntries = 100;

  String _hiveKey(String uid) => 'results_$uid';

  final FirestoreResultService _resultService = FirestoreResultService.instance;
  final FirestoreLeaderboardService _leaderboardService =
      FirestoreLeaderboardService.instance;

  // ── save ────────────────────────────────────────────────────────────────────

  @override
  FutureEither<void> save(
    String uid,
    ResultModel result, {
    String? displayName,
    String? photoUrl,
  }) async {
    return runTask(() async {
      // Run Firestore writes in parallel; Hive is always attempted regardless.
      final futures = await Future.wait([
        _resultService.saveResult(uid, result),
        _leaderboardService.updateEntry(
          uid: uid,
          displayName: displayName ?? 'Anonymous',
          photoUrl: photoUrl,
          score: result.score,
        ),
      ]);

      // Log any Firestore failures but don't block the Hive write.
      for (final res in futures) {
        res.fold(
          (f) => AppLogger.warning('Firestore write failed: ${f.message}'),
          (_) {},
        );
      }

      // Hive — always store locally for offline access.
      await _saveToHive(uid, result);
    });
  }

  Future<void> _saveToHive(String uid, ResultModel result) async {
    try {
      final box = Hive.box<dynamic>(_hiveBoxName);
      final raw = box.get(_hiveKey(uid));
      final List<Map<String, dynamic>> list = raw == null
          ? []
          : (raw as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

      list.insert(0, result.toStorageMap()); // newest first

      // FIFO cap — keeps local storage bounded.
      if (list.length > _maxLocalEntries) {
        list.removeRange(_maxLocalEntries, list.length);
      }

      await box.put(_hiveKey(uid), list);
      AppLogger.info('Result saved to Hive (${list.length} entries)');
    } catch (e, st) {
      AppLogger.error('Hive write failed', [e, st]);
    }
  }

  // ── fetchPage ────────────────────────────────────────────────────────────────

  @override
  FutureEither<ResultPage> fetchPage(
    String uid, {
    int limit = 10,
    ResultPageCursor? cursor,
  }) async {
    // Try Firestore first.
    final onlineResult = await _resultService.fetchPage(
      uid,
      limit: limit,
      startAfter: cursor?.firestoreDoc as DocumentSnapshot?,
    );

    return onlineResult.fold(
      // Firestore failed → fall back to Hive.
      (_) => _fetchFromHive(uid, limit: limit, offset: cursor?.hiveOffset ?? 0),
      (page) {
        final nextCursor = page.lastDoc == null
            ? null
            : ResultPageCursor(firestoreDoc: page.lastDoc);
        return right(
          ResultPage(results: page.results, nextCursor: nextCursor),
        );
      },
    );
  }

  FutureEither<ResultPage> _fetchFromHive(
    String uid, {
    required int limit,
    required int offset,
  }) async {
    return runTask(() async {
      final box = Hive.box<dynamic>(_hiveBoxName);
      final raw = box.get(_hiveKey(uid));
      final List<Map<String, dynamic>> list = raw == null
          ? []
          : (raw as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

      final page = list.skip(offset).take(limit).toList();
      final results = page
          .map(ResultModel.fromStorageMap)
          .toList();

      final nextOffset = offset + results.length;
      final hasMore = nextOffset < list.length;

      AppLogger.info('Loaded ${results.length} results from Hive (offline)');

      return ResultPage(
        results: results,
        nextCursor:
            hasMore ? ResultPageCursor(hiveOffset: nextOffset) : null,
      );
    });
  }

  // ── clearLocal ───────────────────────────────────────────────────────────────

  @override
  FutureEither<void> clearLocal(String uid) async {
    return runTask(() async {
      final box = Hive.box<dynamic>(_hiveBoxName);
      await box.delete(_hiveKey(uid));
      AppLogger.info('Local result cache cleared for $uid');
    });
  }
}
