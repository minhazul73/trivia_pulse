import '../../../ui/auth/providers/session_provider.dart';
import '../../imports/core_imports.dart';
import '../../imports/packages_imports.dart';

class SessionListenerWrapper extends StatefulWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  State<SessionListenerWrapper> createState() => _SessionListenerWrapperState();
}

class _SessionListenerWrapperState extends State<SessionListenerWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = Provider.of<SessionProvider>(context);
    if (session.status != SessionStatus.unknown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (session.status == SessionStatus.authenticated) {
          appRouter.go(AppRoutes.bottomNav);
        } else if (session.status == SessionStatus.unauthenticated) {
          appRouter.go(AppRoutes.login);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
