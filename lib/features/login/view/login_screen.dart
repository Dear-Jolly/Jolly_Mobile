import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 38, top: 140),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/img_splash_logo.png',
                      width: 277,
                      height: 369,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SocialLoginButton(
                        type: SocialLoginType.kakao,
                        onPressed: () => context.go('/onboarding/terms'),
                      ),
                      if (Platform.isIOS) ...[
                        const SizedBox(height: 12),
                        SocialLoginButton(
                          type: SocialLoginType.apple,
                          onPressed: () => context.go('/onboarding/terms'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
