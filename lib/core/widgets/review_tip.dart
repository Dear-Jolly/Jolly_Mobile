import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class ReviewTip extends StatelessWidget {
  final List<String> tips;

  const ReviewTip({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivory100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildTipWidgets(),
      ),
    );
  }

  List<Widget> _buildTipWidgets() {
    final widgets = <Widget>[];
    for (int i = 0; i < tips.length; i++) {
      widgets.add(
        Text(
          tips[i],
          style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray900),
        ),
      );
      if (i < tips.length - 1) {
        widgets.add(const SizedBox(height: 12));
        widgets.add(const Divider(color: AppColors.ivory200, height: 1));
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }
}
