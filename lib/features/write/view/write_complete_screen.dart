import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';

class WriteCompleteScreen extends StatelessWidget {
  final int? letterId;
  final DateTime? submittedAt;

  const WriteCompleteScreen({super.key, this.letterId, this.submittedAt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            right: 24,
            top: 20,
            child: GestureDetector(
              onTap: () => _goHome(context),
              child: SvgPicture.asset(
                'assets/icons/ic_x.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Text(
              '편지 작성 완료',
              textAlign: TextAlign.center,
              style: AppTextTheme.head1B22.copyWith(color: AppColors.black),
            ),
          ),
          Positioned(
            top: 175,
            left: 24,
            right: 24,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextTheme.body3Md16.copyWith(
                  color: AppColors.gray600,
                ),
                children: [
                  const TextSpan(text: '편지는 Jolly에게 전달되어\n'),
                  TextSpan(
                    text: '검토를 진행 중',
                    style: AppTextTheme.body3Md16.copyWith(
                      color: AppColors.burgundy,
                    ),
                  ),
                  const TextSpan(text: '이에요.\n'),
                  const TextSpan(text: '검토 완료까지는 시간이 걸릴 수 있어요.'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 293,
            child: Image.asset(
              'assets/images/img_page_writefinish.png',
              width: 203,
              height: 170,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 203, height: 170),
            ),
          ),
          Positioned(
            top: 515,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _goHome(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '홈 화면으로 이동',
                    style: AppTextTheme.body2Sb16.copyWith(
                      color: AppColors.gray800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    final id = letterId;
    final startedAt = submittedAt;

    if (id == null || startedAt == null) {
      context.go('/home');
      return;
    }

    context.go(
      Uri(
        path: '/home',
        queryParameters: {
          'letterId': id.toString(),
          'submittedAt': startedAt.toIso8601String(),
        },
      ).toString(),
    );
  }
}
