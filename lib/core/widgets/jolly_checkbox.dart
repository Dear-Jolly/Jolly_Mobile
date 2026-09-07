import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyCheckbox extends StatelessWidget {
  final String label;
  final bool isChecked;
  final VoidCallback onTap;
  final bool isAllAgree;
  final Widget? trailing;
  final VoidCallback? onDetailsTap;

  const JollyCheckbox({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onTap,
    this.isAllAgree = false,
    this.trailing,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isAllAgree) {
      return _buildAllAgree();
    }
    return _buildItem();
  }

  Widget _buildAllAgree() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.burgundy),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextTheme.body2Sb16.copyWith(color: AppColors.burgundy),
            ),
            SvgPicture.asset(
              isChecked
                  ? 'assets/icons/ic_checkbox_selected.svg'
                  : 'assets/icons/ic_checkbox.svg',
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem() {
    if (onDetailsTap != null) {
      return Row(
        children: [
          Expanded(
            child: Semantics(
              link: true,
              label: '$label 전문 보기',
              onTap: onDetailsTap,
              excludeSemantics: true,
              child: InkWell(
                onTap: onDetailsTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Text(
                    label,
                    style: AppTextTheme.body3Md16.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            label: label,
            checked: isChecked,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                child: SvgPicture.asset(
                  isChecked
                      ? 'assets/icons/ic_checkbox_selected.svg'
                      : 'assets/icons/ic_checkbox.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: SizedBox(
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextTheme.body3Md16.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ),
              trailing ??
                  SvgPicture.asset(
                    isChecked
                        ? 'assets/icons/ic_checkbox_selected.svg'
                        : 'assets/icons/ic_checkbox.svg',
                    width: 24,
                    height: 24,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
