import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entity/letter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class LetterCard extends StatelessWidget {
  final Letter letter;
  final VoidCallback? onTap;

  const LetterCard({
    super.key,
    required this.letter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            _buildStamp(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRow(),
                  const SizedBox(height: 4),
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
    if (letter.status == LetterStatus.sent) {
      return Container(
        width: 44,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Text(
            'soon',
            style: AppTextTheme.detail6Md12.copyWith(
              color: AppColors.gray400,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Image.asset(
      letter.stampImage ?? 'assets/images/stamp_flower.png',
      width: 44,
      height: 56,
      errorBuilder: (_, __, ___) => Container(
        width: 44,
        height: 56,
        color: AppColors.gray100,
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        if (letter.isNew) ...[
          SvgPicture.asset(
            'assets/icons/ic_new.svg',
            width: 6,
            height: 6,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          _formatDate(letter.createdAt),
          style: AppTextTheme.body9Md14.copyWith(
            color: AppColors.gray600,
          ),
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
            style: AppTextTheme.body3Md16.copyWith(
              color: AppColors.gray900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
