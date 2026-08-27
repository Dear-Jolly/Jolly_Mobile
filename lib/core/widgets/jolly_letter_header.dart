import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyLetterHeader extends StatelessWidget {
  final String to;
  final String date;
  final String? stampImage;

  const JollyLetterHeader({
    super.key,
    required this.to,
    required this.date,
    this.stampImage,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextTheme.detail6Md12.copyWith(
      color: AppColors.burgundy,
    );
    final valueStyle = AppTextTheme.body3Md16.copyWith(
      color: AppColors.burgundy,
    );

    return SizedBox(
      height: 108,
      child: Stack(
        children: [
          Positioned(left: 28, top: 14, child: Text('TO:', style: labelStyle)),
          Positioned(left: 79, top: 10, child: Text(to, style: valueStyle)),
          Positioned(left: 28, top: 37, child: _MetaLine()),
          Positioned(
            left: 28,
            top: 49,
            child: Text('DATE:', style: labelStyle),
          ),
          Positioned(left: 79, top: 45, child: Text(date, style: valueStyle)),
          Positioned(left: 28, top: 72, child: _MetaLine()),
          Positioned(
            left: 190,
            top: 4,
            child: Image.asset(
              'assets/images/img_seal.png',
              width: 80,
              height: 44,
              opacity: const AlwaysStoppedAnimation(0.8),
            ),
          ),
          if (stampImage != null)
            Positioned(
              right: 24,
              top: 22,
              child: _StampImage(path: stampImage!),
            ),
        ],
      ),
    );
  }
}

class _StampImage extends StatelessWidget {
  final String path;

  const _StampImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 44,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox(width: 44, height: 56),
      );
    }

    return Image.asset(
      path,
      width: 44,
      height: 56,
      errorBuilder: (context, error, stackTrace) =>
          const SizedBox(width: 44, height: 56),
    );
  }
}

class _MetaLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 0.5,
      color: AppColors.burgundy.withValues(alpha: 0.5),
    );
  }
}
