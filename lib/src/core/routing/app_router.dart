import 'package:go_router/go_router.dart';
import '../../data/models/category_model.dart';
import '../../ui/quiz/quiz_customization_page.dart';
import '../../ui/quiz/quiz_question_page.dart';
import 'global_navigator.dart';
import 'app_routes.dart';

import '../../ui/auth/login_screen.dart';
import '../../ui/auth/signup_screen.dart';
import '../../ui/auth/forgot_password_screen.dart';

import '../../ui/bottom_nav/bottom_nav_page.dart';
import '../../ui/onboarding/onboarding_page.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (_, _) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (_, _) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (_, _) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.bottomNav,
      name: 'bottomNav',
      builder: (_, _) => const BottomNavPage(),
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
  ],
);
