import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class JollyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const JollyAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.ivory100,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        icon: SvgPicture.asset(
          'assets/icons/ic_back.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.gray900,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTextTheme.head7Sb18.copyWith(color: AppColors.gray900),
      ),
      actions: actions,
    );
  }
}
