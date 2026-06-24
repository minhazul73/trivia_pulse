import '../../core/imports/imports.dart';

import '../auth/providers/auth_provider.dart';
import '../home/home_tab.dart';
import '../home/provider/quiz_provider.dart';
import 'tabs/leaderboard_tab.dart';
import 'tabs/profile_tab.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().getCategories();
    });
  }

  int _currentIndex = 0;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.leaderboard_outlined),
      selectedIcon: Icon(Icons.leaderboard_rounded),
      label: 'Leaderboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // final session = context.watch<SessionProvider>();
    final authProvider = context.read<AuthProvider>();
    // final user = session.user;

    // HomeTab already has its own hero header — only show AppTopBar on other tabs.
    final showAppBar = _currentIndex != 0;

    final tabs = <Widget>[
      const HomeTab(),
      const LeaderboardTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: showAppBar
          ? AppTopBar(
              title: _currentIndex == 2
                  ? 'My Profile'
                  : _destinations[_currentIndex].label,
              centerTitle: false,
              actions: [
                if (_currentIndex == 2)
                  IconButton(
                    tooltip: 'Sign out',
                    icon: Icon(
                      Icons.logout_rounded,
                      size: 20.r,
                      color: context.colors.error,
                    ),
                    onPressed: () => authProvider.logout(context: context),
                  ),
              ],
            )
          : null,
      body: AnimatedSwitcher(
        duration: AppDurations.normal,
        switchInCurve: AppCurves.emphasized,
        switchOutCurve: AppCurves.emphasized,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _destinations,
        elevation: 0,
        height: 64.h,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: AppDurations.normal,
      ),
    );
  }
}
