import '../../../data/repositories/quiz/quiz_repository_impl.dart';
import '../../../ui/auth/providers/auth_provider.dart';
import '../../../ui/home/provider/quiz_provider.dart';
import '../../imports/imports.dart';
import '../../../data/repositories/auth/auth_repository_impl.dart';
import '../../../ui/auth/providers/session_provider.dart';

/// A wrapper to initialize the chosen State Management library.
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionProvider>(
          create: (_) => SessionProvider(repository: AuthRepositoryImpl()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(repository: AuthRepositoryImpl()),
        ),
        ChangeNotifierProvider<QuizProvider>(
          create: (_) => QuizProvider(repository: QuizRepositoryImpl()),
        ),
      ],
      child: child,
    );
  }
}
