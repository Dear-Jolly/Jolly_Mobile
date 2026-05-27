import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool showClearButton;
  final ValueChanged<String>? onChanged;

  const JollyTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.showClearButton = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextTheme.body3Md16.copyWith(color: AppColors.gray900),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextTheme.body3Md16.copyWith(color: AppColors.gray400),
        errorText: errorText,
        errorStyle: AppTextTheme.detail6Md12.copyWith(color: AppColors.red),
        helperText: helperText,
        helperStyle: AppTextTheme.detail6Md12.copyWith(
          color: AppColors.gray500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray900),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        suffixIcon: showClearButton && controller.text.isNotEmpty
            ? IconButton(
                onPressed: () => controller.clear(),
                icon: SvgPicture.asset(
                  'assets/icons/ic_x_circle.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray400,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
