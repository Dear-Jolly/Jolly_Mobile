import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_button.dart';

class WriteCompleteScreen extends StatelessWidget {
  const WriteCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      appBar: AppBar(
        backgroundColor: AppColors.ivory100,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: SvgPicture.asset(
              'assets/icons/ic_x.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.gray900,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/img_page_writefinish.png',
                width: 200,
                errorBuilder: (_, __, ___) => const SizedBox(height: 170),
              ),
              const SizedBox(height: 32),
              Text(
                '편지 작성 완료',
                style: AppTextTheme.head1B22.copyWith(color: AppColors.gray900),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray600),
                  children: [
                    const TextSpan(text: '지금 '),
                    TextSpan(
                      text: '검토를 진행 중',
                      style: AppTextTheme.body4B15.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    const TextSpan(text: '이에요.'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '검토 완료까지는 시간이 걸릴 수 있어요.',
                style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 40),
              JollyButton(
                text: '홈 화면으로 이동',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
