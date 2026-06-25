import 'core/imports/imports.dart';
import 'ui/auth/providers/session_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Router is built exactly once from the stable SessionProvider instance.
  // Using `late` + `??=` pattern in didChangeDependencies ensures we only
  // ever construct it after the provider tree is ready.
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= buildRouter(context.read<SessionProvider>());
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilWrapper(child: _buildMaterialApp());
  }

  Widget _buildMaterialApp() {
    return MaterialApp.router(
      title: 'trivia_pulse',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#8079b4'),
      darkTheme: buildDarkTheme(primaryColorHex: '#8079b4'),
      themeMode: ThemeMode.system,
      routerConfig: _router!,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        return current;
      },
    );
  }
}
