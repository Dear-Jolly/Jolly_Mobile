import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entity/letter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_theme.dart';

class LetterCard extends StatelessWidget {
  static const feedbackWaitDuration = Duration(minutes: 5);

  final Letter letter;
  final DateTime? now;
  final DateTime? countdownStartedAt;
  final VoidCallback? onTap;

  const LetterCard({
    super.key,
    required this.letter,
    this.now,
    this.countdownStartedAt,
    this.onTap,
  });

  bool get _showCountdownBadge =>
      !letter.hasFeedback && countdownStartedAt != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildStamp(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: _showCountdownBadge ? 20 : 0,
                      ),
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
                  ),
                ],
              ),
            ),
            if (_showCountdownBadge)
              Positioned(
                top: 14,
                right: 12,
                child: _CountdownBadge(text: _countdownText()),
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

  String _countdownText() {
    final startedAt = countdownStartedAt;
    if (startedAt == null) {
      return '5:00';
    }

    final maxSeconds = feedbackWaitDuration.inSeconds;
    final current = now ?? DateTime.now();
    var remainingSeconds = maxSeconds - current.difference(startedAt).inSeconds;

    if (remainingSeconds < 0) {
      remainingSeconds = 0;
    } else if (remainingSeconds > maxSeconds) {
      remainingSeconds = maxSeconds;
    }

    final minutes = remainingSeconds ~/ 60;
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

class _CountdownBadge extends StatelessWidget {
  final String text;

  const _CountdownBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.green100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextTheme.detail6Md12.copyWith(
          color: AppColors.green200,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
