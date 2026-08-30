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
    final foregroundColor = isKakao ? AppColors.kakaoBrown : AppColors.white;

    return Opacity(
      opacity: onPressed == null ? 0.6 : 1,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: isKakao ? AppColors.kakaoYellow : AppColors.appleBlack,
          borderRadius: BorderRadius.circular(4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialLoginIcon(type: type),
                const SizedBox(width: 10),
                Text(
                  isKakao ? '카카오로 로그인' : 'Apple로 로그인',
                  style: AppTextTheme.body2Sb16.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginIcon extends StatelessWidget {
  final SocialLoginType type;

  const _SocialLoginIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      SocialLoginType.kakao => SvgPicture.asset(
        'assets/icons/ic_kakao.svg',
        width: 16,
        height: 15,
      ),
      SocialLoginType.apple => Image.asset(
        'assets/icons/ic_apple_login.png',
        width: 15,
        height: 15,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
          'assets/icons/ic_apple.svg',
          width: 15,
          height: 15,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      ),
    };
  }
}
