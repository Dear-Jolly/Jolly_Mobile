import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/intro_pattern_background.dart';
import '../../../core/widgets/intro_splash_logo.dart';
import '../../../domain/usecase/auth/get_user_usecase.dart';
import '../../../domain/usecase/version/check_version_usecase.dart';
import '../view_model/splash_view_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(
        locator<SecureStorage>(),
        locator<GetUserUseCase>(),
        locator<CheckVersionUseCase>(),
      ),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final nextRoute = await context.read<SplashViewModel>().initialize();
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
