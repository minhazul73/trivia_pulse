import '../../../core/imports/core_imports.dart';
import '../../../core/imports/packages_imports.dart';

import '../../../data/repositories/auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void login(
      {required BuildContext context,
      required String email,
      required String password}) async {
    _setLoading(true);

    final result = await _repository.login(email: email, password: password);

    _setLoading(false);
    result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
      },
      (user) {
        if (context.mounted) {
          context.go(AppRoutes.bottomNav);
        }
      },
    );
  }

  void loginWithGoogle({required BuildContext context}) async {
    _setLoading(true);

    final result = await _repository.signInWithGoogle();

    _setLoading(false);
    result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
      },
      (user) {
        if (context.mounted) {
          context.go(AppRoutes.bottomNav);
        }
      },
    );
  }

  void signUp(
      {required BuildContext context,
      required String name,
      required String email,
      required String password}) async {
    _setLoading(true);

    final result =
        await _repository.signUp(name: name, email: email, password: password);

    _setLoading(false);
    result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
      },
      (user) {
        if (context.mounted) {
          context.go(AppRoutes.bottomNav);
        }
      },
    );
  }

  void forgotPassword(
      {required BuildContext context, required String email}) async {
    _setLoading(true);

    final result = await _repository.forgotPassword(email: email);

    _setLoading(false);
    result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
      },
      (success) {
        showGlobalToast(
            message: 'Password reset link sent successfully',
            status: 'success');
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }

  void logout({required BuildContext context}) async {
    _setLoading(true);

    final result = await _repository.logout();

    _setLoading(false);
    result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
      },
      (success) {
        showGlobalToast(message: 'Logged out successfully', status: 'success');
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
