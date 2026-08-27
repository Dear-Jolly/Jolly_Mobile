import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

enum SocialLoginType { kakao, apple }

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;

  const SocialLoginButton({super.key, required this.type, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isKakao = type == SocialLoginType.kakao;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isKakao
              ? AppColors.kakaoYellow
              : AppColors.appleBlack,
          foregroundColor: isKakao ? AppColors.kakaoBrown : AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              isKakao
                  ? 'assets/icons/ic_kakao.svg'
                  : 'assets/icons/ic_apple.svg',
              width: isKakao ? 16 : 15,
              height: 15,
            ),
            const SizedBox(width: 10),
            Text(
              isKakao ? '카카오로 로그인' : 'Apple로 로그인',
              style: AppTextTheme.body2Sb16.copyWith(
                color: isKakao ? AppColors.kakaoBrown : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
