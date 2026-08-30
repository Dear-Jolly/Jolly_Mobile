import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? image;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Color confirmColor;

  const JollyDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.cancelText = '취소',
    this.confirmText = '확인',
    this.onCancel,
    this.onConfirm,
    this.confirmColor = AppColors.burgundy,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? image,
    String cancelText = '취소',
    String confirmText = '확인',
    Color confirmColor = AppColors.burgundy,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.black70,
      builder: (ctx) => JollyDialog(
        title: title,
        subtitle: subtitle,
        image: image,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
  }

  double? get _dialogHeight {
    if (image != null) {
      return null;
    }
    return subtitle?.contains('\n') == true ? 192.0 : 172.0;
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
        height: _dialogHeight,
        child: Padding(
          padding: image == null
              ? const EdgeInsets.fromLTRB(16, 30, 16, 16)
              : const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: image == null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (image != null) ...[image!, const SizedBox(height: 16)],
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextTheme.head7Sb18.copyWith(
                  color: AppColors.black,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTextTheme.body9Md14.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
              if (image == null)
                const Spacer()
              else
                const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DialogActionButton(
                      text: cancelText,
                      textColor: AppColors.gray700,
                      backgroundColor: AppColors.gray200,
                      onTap: onCancel,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _DialogActionButton(
                      text: confirmText,
                      textColor: AppColors.white,
                      backgroundColor: confirmColor,
                      onTap: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _DialogActionButton({
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: AppTextTheme.body2Sb16.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
