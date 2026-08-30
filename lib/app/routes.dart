import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/locator.dart';
import '../core/storage/secure_storage.dart';
import '../features/home/view/home_screen.dart';
import '../features/login/view/login_screen.dart';
import '../features/onboarding/view/nickname_screen.dart';
import '../features/onboarding/view/terms_screen.dart';
import '../features/onboarding/view/welcome_screen.dart';
import '../features/review/view/review_screen.dart';
import '../features/settings/view/change_name_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/update/view/force_update_screen.dart';
import '../features/write/view/write_complete_screen.dart';
import '../features/write/view/write_letter_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  redirect: _redirect,
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: '/force-update',
      builder: (_, _) => const ForceUpdateScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (_, _) => CustomTransitionPage(
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    ),
    GoRoute(path: '/onboarding/terms', builder: (_, _) => const TermsScreen()),
    GoRoute(
      path: '/onboarding/nickname',
      builder: (_, _) => const NicknameScreen(),
    ),
    GoRoute(
      path: '/onboarding/welcome',
      builder: (_, _) => const WelcomeScreen(),
    ),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/write', builder: (_, _) => const WriteLetterScreen()),
    GoRoute(
      path: '/write/complete',
      builder: (_, _) => const WriteCompleteScreen(),
    ),
    GoRoute(path: '/review', redirect: (_, _) => '/home'),
    GoRoute(
      path: '/review/:letterId',
      builder: (_, state) =>
          ReviewScreen(letterId: int.parse(state.pathParameters['letterId']!)),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(
      path: '/settings/name',
      builder: (_, _) => const ChangeNameScreen(),
    ),
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final path = state.uri.path;
  if (path == '/splash' || path == '/force-update') {
    return null;
  }

  final storage = locator<SecureStorage>();
  final accessToken = await storage.getAccessToken();
  final refreshToken = await storage.getRefreshToken();
  final isAuthenticated =
      accessToken != null &&
      accessToken.isNotEmpty &&
      refreshToken != null &&
      refreshToken.isNotEmpty;

  if (!isAuthenticated) {
    if ((accessToken?.isNotEmpty ?? false) ||
        (refreshToken?.isNotEmpty ?? false)) {
      await storage.clearAuthState();
    }
    return path == '/login' ? null : '/login';
  }

  final termsAgreed = await storage.getTermsAgreed();
  if (!termsAgreed) {
    return path == '/onboarding/terms' ? null : '/onboarding/terms';
  }

  final nicknameRegistered = await storage.getNicknameRegistered();
  if (!nicknameRegistered) {
    return path == '/onboarding/nickname' ? null : '/onboarding/nickname';
  }

  if (path == '/login' ||
      path == '/onboarding/terms' ||
      path == '/onboarding/nickname') {
    return '/home';
  }

  return null;
}
