import 'dart:async';
import '../../../core/imports/imports.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth/auth_repository.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSub;

  SessionStatus _status = SessionStatus.unknown;
  AppUser? _user;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  /// True between auth resolution and the splash exit animation completing.
  /// GoRouter's redirect returns null while this is true, giving the splash
  /// time to animate out before the router fires.
  bool _navigationPending = false;
  bool get navigationPending => _navigationPending;

  /// Called by [SplashScreen] after its exit animation finishes.
  /// Clears the pending flag and re-triggers GoRouter's redirect.
  void confirmNavigation() {
    _navigationPending = false;
    notifyListeners();
  }

  SessionProvider({required AuthRepository repository})
    : _repository = repository {
    _init();
  }

  Future<void> _init() async {
    // Run auth check and minimum splash timer concurrently.
    // notifyListeners() is only called after both complete, so GoRouter's
    // redirect (and the splash → home/login transition) never fires in under
    // 2.5 s — regardless of how fast Firebase responds from cache.
    final authFuture = _repository.checkAuthState();
    final timerFuture = Future<void>.delayed(
      const Duration(milliseconds: 2500),
    );

    final result = await authFuture;
    await timerFuture; // no-op if auth took longer; waits out the rest if it was fast

    result.fold(
      (_) {
        _status = SessionStatus.unauthenticated;
      },
      (user) {
        if (user != null) {
          _user = user;
          _status = SessionStatus.authenticated;
        } else {
          _status = SessionStatus.unauthenticated;
        }
      },
    );
    // Signal splash to begin its exit animation; redirect is blocked until
    // SplashScreen calls confirmNavigation() after the animation completes.
    _navigationPending = true;
    notifyListeners();

    _authSub = _repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        _user = user;
        _status = SessionStatus.authenticated;
      } else {
        _user = null;
        _status = SessionStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
