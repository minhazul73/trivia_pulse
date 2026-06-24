import '../../../core/imports/imports.dart';
import '../../../data/models/result_model.dart';
import '../../../data/repositories/result/result_repository.dart';

/// Manages the user's personal quiz result history.
///
/// Provides paginated loading (Firestore online, Hive offline fallback)
/// and the write path that persists a result on quiz completion.
class ResultHistoryProvider extends ChangeNotifier {
  final ResultRepository _repository;

  ResultHistoryProvider({required ResultRepository repository})
      : _repository = repository;

  // ── State ────────────────────────────────────────────────────────────────────

  String? _uid;
  String? _displayName;
  String? _photoUrl;

  List<ResultModel> _results = [];
  List<ResultModel> get results => List.unmodifiable(_results);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  ResultPageCursor? _cursor;

  String? _error;
  String? get error => _error;

  // ── Init ─────────────────────────────────────────────────────────────────────

  /// Call when the authenticated user is known (e.g. from SessionProvider).
  /// Resets state and loads the first page.
  Future<void> init({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    if (_uid == uid) return; // already initialised for this user
    _uid = uid;
    _displayName = displayName;
    _photoUrl = photoUrl;
    _reset();
    await loadFirstPage();
  }

  void _reset() {
    _results = [];
    _cursor = null;
    _hasMore = true;
    _error = null;
  }

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> loadFirstPage() async {
    if (_uid == null) return;
    _reset();
    _isLoading = true;
    notifyListeners();
    await _loadPage();
  }

  Future<void> loadNextPage() async {
    if (_uid == null || _isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    await _loadPage();
  }

  Future<void> _loadPage() async {
    final result = await _repository.fetchPage(
      _uid!,
      limit: 10,
      cursor: _cursor,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('ResultHistoryProvider fetch failed: ${failure.message}');
      },
      (page) {
        _results = [..._results, ...page.results];
        _cursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // ── Save ─────────────────────────────────────────────────────────────────────

  /// Persists a completed result.
  /// • Idempotent: skips if result.id is already in the list.
  /// • Prepends to the local list immediately for instant UI feedback.
  Future<void> saveResult(ResultModel result) async {
    final uid = _uid;
    if (uid == null) {
      AppLogger.warning('ResultHistoryProvider.saveResult: no uid set');
      return;
    }

    // Idempotency guard — don't double-save if the page is hot-reloaded.
    if (result.id != null &&
        _results.any((r) => r.id == result.id)) {
      return;
    }

    _isSaving = true;
    notifyListeners();

    final saveResult = await _repository.save(
      uid,
      result,
      displayName: _displayName,
      photoUrl: _photoUrl,
    );

    saveResult.fold(
      (failure) {
        AppLogger.error('Failed to save result: ${failure.message}');
        showGlobalToast(message: 'Result saved locally only', status: 'warning');
      },
      (_) {
        // Prepend to the local list for instant feedback.
        _results = [result, ..._results];
        AppLogger.info('Result saved and prepended to history');
      },
    );

    _isSaving = false;
    notifyListeners();
  }

  // ── Logout cleanup ────────────────────────────────────────────────────────────

  void clearForLogout() {
    _uid = null;
    _displayName = null;
    _photoUrl = null;
    _reset();
    notifyListeners();
  }
}
