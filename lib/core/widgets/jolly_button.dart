import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double height;

  const JollyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.burgundy : AppColors.gray300,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          text,
          style: AppTextTheme.head7Sb18.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}

class JollyOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const JollyOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.gray300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          text,
          style: AppTextTheme.body2Sb16.copyWith(color: AppColors.gray700),
        ),
      ),
    );
  }
}
