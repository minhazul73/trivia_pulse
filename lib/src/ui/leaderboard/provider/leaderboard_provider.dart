import '../../../core/imports/imports.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../data/repositories/leaderboard/leaderboard_repository.dart';

/// Manages the global leaderboard — fetches from Firestore with
/// cursor-based pagination, ordered by totalScore descending.
class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _repository;

  LeaderboardProvider({required LeaderboardRepository repository})
      : _repository = repository;

  // ── State ────────────────────────────────────────────────────────────────────

  List<LeaderboardEntry> _entries = [];

  /// Entries with rank injected (1-based, continuous across pages).
  List<LeaderboardEntry> get entries => List.unmodifiable(_entries);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  LeaderboardPageCursor? _cursor;

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> loadFirstPage() async {
    _entries = [];
    _cursor = null;
    _hasMore = true;
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _loadPage();
  }

  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    await _loadPage();
  }

  Future<void> refresh() => loadFirstPage();

  Future<void> _loadPage() async {
    final result = await _repository.fetchPage(
      limit: 20,
      cursor: _cursor,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('LeaderboardProvider fetch failed: ${failure.message}');
      },
      (page) {
        final offset = _entries.length;
        // Inject rank sequentially across pages.
        final ranked = page.entries.asMap().entries.map((e) {
          return e.value.copyWith(rank: offset + e.key + 1);
        }).toList();

        _entries = [..._entries, ...ranked];
        _cursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
