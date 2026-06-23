import 'core/imports/imports.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final current = _buildMaterialApp(context);
    return ScreenUtilWrapper(child: current);
  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp.router(
      title: 'trivia_pulse',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#8079b4'),
      darkTheme: buildDarkTheme(primaryColorHex: '#8079b4'),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
