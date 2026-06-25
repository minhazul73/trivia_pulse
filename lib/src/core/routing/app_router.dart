import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/category_model.dart';
import '../../data/models/result_model.dart';
import '../../ui/auth/providers/session_provider.dart';
import '../../ui/quiz/quiz_customization_page.dart';
import '../../ui/quiz/quiz_question_page.dart';
import '../../ui/quiz/quiz_result_page.dart';
import '../../ui/splash/splash_screen.dart';
import 'global_navigator.dart';
import 'app_routes.dart';

import '../../ui/auth/login_screen.dart';
import '../../ui/auth/signup_screen.dart';
import '../../ui/auth/forgot_password_screen.dart';
import '../../ui/bottom_nav/bottom_nav_page.dart';

/// Fade + subtle upward slide used for routes that follow the splash screen.
Page<void> _fadePage({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Builds a [GoRouter] wired to [session] via [GoRouter.refreshListenable].
///
/// Every time [SessionProvider] calls [notifyListeners], GoRouter re-runs
/// [redirect] — which is the single source of truth for auth-based routing.
/// Call this once (e.g. in [State.didChangeDependencies] with `??=`) so the
/// router instance stays stable across rebuilds.
GoRouter buildRouter(SessionProvider session) => GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final status = session.status;

        // ── Still resolving ────────────────────────────────────────────────
        if (status == SessionStatus.unknown) {
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        }

        // ── Splash exit animation in progress ──────────────────────────────
        // SplashScreen is playing its fade-out. Hold here; it will call
        // confirmNavigation() when the animation finishes, which fires another
        // notifyListeners() and brings us back into redirect with pending=false.
        if (session.navigationPending) return null;

        // ── Leaving splash once resolved ───────────────────────────────────
        if (location == AppRoutes.splash) {
          return status == SessionStatus.authenticated
              ? AppRoutes.bottomNav
              : AppRoutes.login;
        }

        // ── Auth guard: unauthenticated → protected ────────────────────────
        const protectedRoutes = [AppRoutes.bottomNav];
        if (status == SessionStatus.unauthenticated &&
            protectedRoutes.contains(location)) {
          return AppRoutes.login;
        }

        // ── Reverse guard: authenticated → auth-only screens ───────────────
        const authOnlyRoutes = [
          AppRoutes.login,
          AppRoutes.signup,
          AppRoutes.forgotPassword,
        ];
        if (status == SessionStatus.authenticated &&
            authOnlyRoutes.contains(location)) {
          return AppRoutes.bottomNav;
        }

        return null; // no redirect needed
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (_, state) =>
              _fadePage(key: state.pageKey, child: const LoginScreen()),
        ),
        GoRoute(
          path: AppRoutes.signup,
          name: 'signup',
          pageBuilder: (_, state) =>
              _fadePage(key: state.pageKey, child: const SignupScreen()),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          pageBuilder: (_, state) =>
              _fadePage(key: state.pageKey, child: const ForgotPasswordScreen()),
        ),
        GoRoute(
          path: AppRoutes.bottomNav,
          name: 'bottomNav',
          pageBuilder: (_, state) =>
              _fadePage(key: state.pageKey, child: const BottomNavPage()),
        ),
        GoRoute(
          path: AppRoutes.quizCustomization,
          name: 'quizCustomization',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>;
            final category = extra['category'] as CategoryModel;
            return QuizCustomizationPage(category: category);
          },
        ),
        GoRoute(
          path: AppRoutes.quizQuestion,
          name: 'quizQuestion',
          builder: (_, _) => const QuizQuestionPage(),
        ),
        GoRoute(
          path: AppRoutes.quizResult,
          name: 'quizResult',
          builder: (_, state) {
            final result = state.extra! as ResultModel;
            return QuizResultPage(result: result);
          },
        ),
      ],
    );
