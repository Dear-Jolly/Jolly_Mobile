import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/intro_pattern_background.dart';
import '../../../core/widgets/intro_splash_logo.dart';
import '../view_model/splash_view_model.dart';

final _splashViewModelProvider = Provider<SplashViewModel>((ref) {
  final viewModel = SplashViewModel(
    ref.watch(secureStorageProvider),
    ref.watch(getUserUseCaseProvider),
    ref.watch(checkVersionUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final nextRoute = await ref.read(_splashViewModelProvider).initialize();
    if (mounted) {
      context.go(nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: const Stack(
        children: [
          Positioned.fill(child: IntroPatternBackground()),
          Positioned.fill(child: IntroSplashLogo()),
        ],
      ),
    );
  }
}
