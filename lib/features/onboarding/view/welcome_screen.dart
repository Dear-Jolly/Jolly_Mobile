import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
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
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildPage(
                      imagePath: 'assets/images/img_onboarding1.png',
                      imageWidth: 158,
                      imageHeight: 152,
                      imageTop: 170,
                      title: '영어로 쓰는 나의 하루를\n편지에 담아보세요',
                      subtitle: '짧아도 틀려도 괜찮아요\nJolly가 서툰 영어도 다정하게 고쳐줄 거예요',
                    ),
                    _buildPage(
                      imagePath: 'assets/images/img_onboarding2.png',
                      imageWidth: 295,
                      imageHeight: 82,
                      imageTop: 234,
                      title: 'Jolly에게 편지를 쓰면\n나만의 우표가 생겨요',
                      subtitle: '달콤한 하루도, 힘든 순간도\n편지에 담긴 이야기마다 다른 우표가 생겨요',
                    ),
                    _buildPage(
                      imagePath: 'assets/images/img_page_writefinish.png',
                      imageWidth: 165,
                      imageHeight: 150,
                      imageTop: 178,
                      title: '준비가 됐다면 이제\nJolly를 만나러 가볼까요?',
                      subtitle: '첫 편지를 Jolly에게 건네보세요\n당신만의 영어 편지 일기가 시작돼요',
                    ),
                  ],
                ),
                Positioned(
                  top: 588,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: PageStepper(
                      totalSteps: 3,
                      currentStep: _currentPage,
                    ),
                  ),
                ),
                if (_currentPage == 2)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 29,
                    child: JollyButton(
                      text: 'Jolly 만나러 가기',
                      onPressed: () => context.go('/home'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String imagePath,
    required double imageWidth,
    required double imageHeight,
    required double imageTop,
    required String title,
    required String subtitle,
  }) {
    return Stack(
      children: [
        Positioned(
          top: imageTop,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  SizedBox(width: imageWidth, height: imageHeight),
            ),
          ),
        ),
        Positioned(
          top: 352,
          left: 24,
          right: 24,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextTheme.head4Sb20.copyWith(color: AppColors.gray900),
          ),
        ),
        Positioned(
          top: 416,
          left: 24,
          right: 24,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray600),
          ),
        ),
      ],
    );
  }
}
