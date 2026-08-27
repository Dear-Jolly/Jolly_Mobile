import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool showBottomBorder;

  const JollyAppBar({
    super.key,
    this.title,
    this.onBack,
    this.actions,
    this.backgroundColor = AppColors.ivory100,
    this.showBottomBorder = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 56,
      leading: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 56, height: 56),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        icon: SvgPicture.asset(
          'assets/icons/ic_back.svg',
          width: 48,
          height: 48,
          colorFilter: const ColorFilter.mode(
            AppColors.gray900,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: title == null
          ? null
          : Text(
              title!,
              style: AppTextTheme.head7Sb18.copyWith(color: AppColors.black),
            ),
      actions: actions,
      bottom: showBottomBorder
          ? const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: AppColors.gray200),
            )
          : null,
    );
  }
}
