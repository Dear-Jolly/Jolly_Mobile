import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildLogo(),
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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'D',
                style: TextStyle(
                  fontFamily: 'LastChristmas',
                  fontSize: 53,
                  color: AppColors.black,
                ),
              ),
              TextSpan(
                text: 'ear',
                style: TextStyle(
                  fontFamily: 'Selino',
                  fontSize: 40,
                  color: AppColors.black,
                ),
              ),
              TextSpan(text: ' '),
              TextSpan(
                text: 'J',
                style: TextStyle(
                  fontFamily: 'LastChristmas',
                  fontSize: 55,
                  color: AppColors.black,
                ),
              ),
              TextSpan(
                text: 'olly',
                style: TextStyle(
                  fontFamily: 'Selino',
                  fontSize: 41,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Write to Jolly,',
          style: TextStyle(
            fontFamily: 'MADE Mirage',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: -0.2,
            color: AppColors.black,
          ),
        ),
        const Text(
          'Feel  jolly',
          style: TextStyle(
            fontFamily: 'MADE Mirage',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: -0.2,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
