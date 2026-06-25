import '../../core/imports/imports.dart';
import '../../ui/auth/providers/session_provider.dart';

/// Displays a branded animated logo while the app initialises.
///
/// Navigation is driven by GoRouter's [redirect] callback. This screen uses a
/// two-phase handshake with [SessionProvider]:
///
/// 1. [SessionProvider._init] resolves → sets [SessionProvider.navigationPending]
///    true → calls [notifyListeners]. GoRouter's redirect sees [navigationPending]
///    and returns null (holds navigation).
/// 2. This screen observes the change via [didChangeDependencies], starts its
///    exit fade-out animation, then calls [SessionProvider.confirmNavigation].
/// 3. confirmNavigation clears the flag → notifyListeners → redirect fires →
///    smooth transition to Login / Bottom Nav.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Whether the logo exit fade-out has been triggered.
  bool _exitStarted = false;

  /// Total duration of the exit fade — must match [AnimatedOpacity.duration]
  /// plus a small buffer before we call confirmNavigation.
  static const _exitDuration = Duration(milliseconds: 600);
  static const _confirmDelay = Duration(milliseconds: 680);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.watch<SessionProvider>();

    // When provider signals navigation is ready (and exit hasn't started yet),
    // kick off the logo fade-out and schedule confirmNavigation after it ends.
    if (session.navigationPending && !_exitStarted) {
      _triggerExit(session);
    }
  }

  void _triggerExit(SessionProvider session) {
    setState(() => _exitStarted = true);

    // Let the fade-out animation finish, then tell the router it can navigate.
    Future.delayed(_confirmDelay, () {
      if (mounted) {
        context.read<SessionProvider>().confirmNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100E13),
      body: Center(
        child: AnimatedOpacity(
          opacity: _exitStarted ? 0.0 : 1.0,
          duration: _exitDuration,
          curve: Curves.easeInOut,
          // Entry animation: fade-in → scale → shimmer.
          // Exit is handled by AnimatedOpacity above so it can be triggered
          // on demand rather than on a fixed delay.
          child: Image.asset('assets/images/splash-logo.png', width: 200)
              .animate()
              .fadeIn(duration: 600.milliseconds, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 600.milliseconds,
                curve: Curves.easeOutBack,
              )
              .then(delay: 200.milliseconds)
              .shimmer(duration: 800.milliseconds, color: Colors.white24),
        ),
      ),
    );
  }
}
