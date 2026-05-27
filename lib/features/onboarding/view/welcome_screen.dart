import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/page_stepper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage(
                    imagePath: 'assets/images/img_onboarding1.png',
                    title: '영어로 편지를 작성하고\nAI 검토를 받아보세요',
                    subtitle: 'AI가 문법과 표현을 검토해\n더 나은 편지를 쓸 수 있도록 도와드려요',
                  ),
                  _buildPage(
                    imagePath: 'assets/images/img_onboarding2.png',
                    title: '검토가 완료되면\n우표가 도착해요',
                    subtitle: '다양한 우표를 모아보세요',
                  ),
                  _buildPage(
                    imagePath: 'assets/images/img_seal.png',
                    title: 'Dear Jolly와 함께\n영어 편지를 시작해볼까요?',
                    subtitle: '',
                  ),
                ],
              ),
            ),
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: PageStepper(
                totalSteps: 3,
                currentStep: _currentPage,
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: JollyButton(
                text: _currentPage < 2 ? '다음' : '시작하기',
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
            errorBuilder: (_, __, ___) => const SizedBox(height: 200),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextTheme.head1B22.copyWith(color: AppColors.gray900),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray600),
            ),
          ],
        ],
      ),
    );
  }
}
