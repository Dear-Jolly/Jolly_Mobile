import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final String? counterText;
  final bool showClearButton;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const JollyTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.counterText,
    this.showClearButton = true,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final supportingText = errorText ?? helperText;
    final supportingColor = errorText == null
        ? AppColors.burgundy
        : AppColors.red;

    Widget? hiddenCounter(
      BuildContext context, {
      required int currentLength,
      required bool isFocused,
      required int? maxLength,
    }) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          maxLength: maxLength,
          buildCounter: maxLength == null ? null : hiddenCounter,
          onChanged: onChanged,
          style: AppTextTheme.body3Md16.copyWith(color: AppColors.gray900),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextTheme.body3Md16.copyWith(
              color: AppColors.gray400,
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.burgundy),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.burgundy),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            suffixIcon: showClearButton && controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
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
        ),
        if (supportingText != null || counterText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (supportingText != null)
                Expanded(
                  child: Text(
                    supportingText,
                    style: AppTextTheme.detail6Md12.copyWith(
                      color: supportingColor,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (counterText != null)
                Text(
                  counterText!,
                  style: AppTextTheme.detail6Md12.copyWith(
                    color: supportingColor,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
