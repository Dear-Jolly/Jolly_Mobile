import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyToast extends StatelessWidget {
  final String message;
  final Widget? icon;

  const JollyToast({super.key, required this.message, this.icon});

  static void show(
    BuildContext context, {
    required String message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  message,
                  style: AppTextTheme.detail3Md13.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.gray900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          duration: duration,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              message,
              style: AppTextTheme.detail3Md13.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
