import 'package:go_router/go_router.dart';

import '../features/home/view/home_screen.dart';
import '../features/login/view/login_screen.dart';
import '../features/onboarding/view/nickname_screen.dart';
import '../features/onboarding/view/terms_screen.dart';
import '../features/onboarding/view/welcome_screen.dart';
import '../features/review/view/review_screen.dart';
import '../features/settings/view/change_name_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/write/view/write_complete_screen.dart';
import '../features/write/view/write_letter_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding/terms',
      builder: (_, _) => const TermsScreen(),
    ),
    GoRoute(
      path: '/onboarding/nickname',
      builder: (_, _) => const NicknameScreen(),
    ),
    GoRoute(
      path: '/onboarding/welcome',
      builder: (_, _) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, _) => const HomeScreen(),
    ),
    GoRoute(
      path: '/write',
      builder: (_, _) => const WriteLetterScreen(),
    ),
    GoRoute(
      path: '/write/complete',
      builder: (_, _) => const WriteCompleteScreen(),
    ),
    GoRoute(
      path: '/review',
      builder: (_, _) => const ReviewScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/name',
      builder: (_, _) => const ChangeNameScreen(),
    ),
  ],
);
