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

  /// 약관 원문을 여는 콜백. 지정하면 체크박스 앞에 '보기' 링크가 붙는다.
  final VoidCallback? onView;

  const JollyCheckbox({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onTap,
    this.isAllAgree = false,
    this.trailing,
    this.onView,
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
                  style: AppTextTheme.body6Md15.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ),
              if (onView != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onView,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      '보기',
                      style: AppTextTheme.detail3Md13.copyWith(
                        color: AppColors.gray600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.gray600,
                      ),
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
