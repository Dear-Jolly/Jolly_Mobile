import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/review_tip.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      appBar: JollyAppBar(
        title: '검토하기',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Letter content (read-only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TO.',
                        style: AppTextTheme.detail3Md13.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jolly',
                        style: AppTextTheme.detail3Md13.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'DATE.',
                        style: AppTextTheme.detail3Md13.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2026.05.18',
                        style: AppTextTheme.detail3Md13.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.gray200),
                  const SizedBox(height: 16),
                  // TODO: Actual letter content from data
                  Text(
                    'Dear Jolly,\n\nThis is where the letter content will be displayed...',
                    style: AppTextTheme.body3Md16.copyWith(
                      color: AppColors.gray900,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Review tips section
            Text(
              'AI 검토 결과',
              style: AppTextTheme.head7Sb18.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: 16),
            // Tip card placeholder
            // TODO: Replace with real review data
            const ReviewTip(
              tips: [
                'AI가 문법, 표현을 검토하고 더 나은 표현을 제안해드려요.',
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
