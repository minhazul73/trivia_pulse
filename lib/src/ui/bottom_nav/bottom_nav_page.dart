import '../../core/imports/core_imports.dart';
import '../../core/imports/packages_imports.dart';

import '../auth/providers/auth_provider.dart';
import '../auth/providers/session_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = session.user;

    const items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard_rounded),
        label: 'Leaderboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];

    final tabs = [const HomeTab(), const LeaderboardTab(), const ProfileTab()];

    return Scaffold(
      appBar: AppTopBar(
        title: 'Hello, ${user?.name}!',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(context: context),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
