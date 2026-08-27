import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entity/letter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class LetterCard extends StatelessWidget {
  final Letter letter;
  final VoidCallback? onTap;

  const LetterCard({super.key, required this.letter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            _buildStamp(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDateRow(),
                  const SizedBox(height: 8),
                  _buildContentRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStamp() {
    if (!letter.hasFeedback) {
      return Image.asset(
        'assets/images/stamp_not_arrived.png',
        width: 44,
        height: 56,
      );
    }

    return _stampImage(letter.stampImage);
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        if (letter.isNew) ...[
          SvgPicture.asset('assets/icons/ic_new.svg', width: 6, height: 6),
          const SizedBox(width: 4),
        ],
        Text(
          _formatDate(letter.date),
          style: AppTextTheme.body9Md14.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }

  Widget _buildContentRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            letter.content,
            style: AppTextTheme.body3Md16.copyWith(color: AppColors.gray900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (letter.hasFeedback) ...[
          const SizedBox(width: 4),
          SvgPicture.asset(
            'assets/icons/ic_more_sm.svg',
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.gray400,
              BlendMode.srcIn,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Widget _stampImage(String? path) {
    final fallback = Container(width: 44, height: 56, color: AppColors.gray100);
    if (path == null || path.isEmpty) {
      return Image.asset(
        'assets/images/stamp_flower.png',
        width: 44,
        height: 56,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 44,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.asset(
      path,
      width: 44,
      height: 56,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
