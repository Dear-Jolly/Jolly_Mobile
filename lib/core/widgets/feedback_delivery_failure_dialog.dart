import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class FeedbackDeliveryFailureDialog extends StatelessWidget {
  const FeedbackDeliveryFailureDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.black70,
      builder: (_) => const FeedbackDeliveryFailureDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: SizedBox(
        width: 296,
        height: 323,
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
              top: 48,
              left: 88,
              child: SvgPicture.asset(
                'assets/images/img_error.svg',
                width: 120,
                height: 120,
              ),
            ),
            Positioned(
              top: 192,
              left: 0,
              right: 0,
              child: Text(
                '앗, 배송에 실패했어요',
                textAlign: TextAlign.center,
                style: AppTextTheme.head7Sb18.copyWith(color: AppColors.black),
              ),
            ),
            Positioned(
              top: 227,
              left: 0,
              right: 0,
              child: Text(
                '편지를 전달하는 과정에서 문제가 생겨\n'
                '검토하지 못했어요. 편지를 다시 잘 챙겨서\n'
                '빠른 시일 내에 찾아올게요!',
                textAlign: TextAlign.center,
                style: AppTextTheme.body9Md14.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
