import '../../core/imports/core_imports.dart';
import '../../core/imports/packages_imports.dart';

import '../auth/providers/session_provider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final session = context.watch<SessionProvider>();
    final user = session.user;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppTopBar(
        title: 'Home',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppIcon(
                icon: Icons.home_rounded,
                size: 60.sp,
                color: colorScheme.primary,
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                user?.name ?? user?.email ?? ('Welcome Home!'),
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontSize: 28.sp,
                ),
              ),
                            SizedBox(height: AppSpacing.md.h),
              Text(
                user != null && user.name != null ? user.email : ('You have successfully completed the onboarding process.'),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),
                          ],
          ),
        ),
      ),
    );
  }
}
