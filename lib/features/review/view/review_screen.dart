import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/feedback_delivery_failure_dialog.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_letter_header.dart';
import '../../../core/widgets/jolly_loading_indicator.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../core/widgets/review_tip.dart';
import '../../../domain/entity/letter_review.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/letter/get_letter_review_usecase.dart';

class ReviewScreen extends StatefulWidget {
  final int letterId;

  const ReviewScreen({super.key, required this.letterId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  LetterReview? _review;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  @override
  Widget build(BuildContext context) {
    final review = _review;

    return Scaffold(
      backgroundColor: AppColors.ivory100,
      appBar: JollyAppBar(onBack: () => context.pop()),
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            top: false,
            child: _isLoading
                ? const Center(child: JollyLoadingIndicator())
                : review == null
                ? _buildError()
                : Column(
                    children: [
                      JollyLetterHeader(
                        to: 'Jolly',
                        date: _formatDate(review.date),
                        stampImage: review.stampImage,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                          child: _ReviewResultCard(review: review),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage ?? '편지를 불러오지 못했습니다.',
            textAlign: TextAlign.center,
            style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 16),
          JollyOutlinedButton(text: '다시 시도', onPressed: _loadReview),
        ],
      ),
    );
  }

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await locator<GetLetterReviewUseCase>().execute(
      widget.letterId,
    );

    if (!mounted) return;

    switch (result) {
      case Success(data: final review):
        if (!review.hasFeedback) {
          final message = review.isFeedbackFailed
              ? '피드백 배송에 실패했어요. 잠시 후 다시 확인해주세요.'
              : 'Jolly가 아직 편지를 검토하고 있어요.';
          setState(() {
            _review = null;
            _isLoading = false;
            _errorMessage = message;
          });
          if (review.isFeedbackFailed) {
            await FeedbackDeliveryFailureDialog.show(context);
          }
          return;
        }

        setState(() {
          _review = review;
          _isLoading = false;
        });
      case Failure(message: final message):
        setState(() {
          _review = null;
          _isLoading = false;
          _errorMessage = message;
        });
        JollyToast.show(context, message: message);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _ReviewResultCard extends StatelessWidget {
  final LetterReview review;

  const _ReviewResultCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewedLetterText(review: review),
          const SizedBox(height: 28),
          if (review.hasFeedback && review.tips.isNotEmpty)
            ReviewTip(tips: review.tips)
          else if (review.hasFeedback)
            const _NoReviewTipBox()
          else
            const _PendingFeedbackBox(),
        ],
      ),
    );
  }
}

class _ReviewedLetterText extends StatelessWidget {
  final LetterReview review;

  const _ReviewedLetterText({required this.review});

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextTheme.body3Md16.copyWith(
      color: AppColors.black,
      height: 1.85,
    );

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: review.hasFeedback
            ? _buildCorrectionSpans(textStyle)
            : [TextSpan(text: review.originalContent)],
      ),
    );
  }

  List<InlineSpan> _buildCorrectionSpans(TextStyle baseStyle) {
    return review.correctionSegments.map((segment) {
      if (!segment.isModified) {
        return TextSpan(text: segment.originalText);
      }

      return TextSpan(
        children: [
          ..._buildOriginalTextSpans(segment.originalText, baseStyle),
          ..._buildCorrectedTextSpans(segment.correctedText, baseStyle),
        ],
      );
    }).toList();
  }

  List<InlineSpan> _buildOriginalTextSpans(String text, TextStyle baseStyle) {
    final parts = _TextRunParts.from(text);
    if (!parts.hasContent) {
      return [TextSpan(text: text)];
    }

    return [
      if (parts.leadingWhitespace.isNotEmpty)
        TextSpan(text: parts.leadingWhitespace),
      TextSpan(
        text: parts.content,
        style: baseStyle.copyWith(
          color: AppColors.red,
          decoration: TextDecoration.lineThrough,
          decorationColor: AppColors.red,
        ),
      ),
      if (parts.trailingWhitespace.isNotEmpty)
        TextSpan(text: parts.trailingWhitespace),
    ];
  }

  List<InlineSpan> _buildCorrectedTextSpans(String text, TextStyle baseStyle) {
    if (text.isEmpty) {
      return const [];
    }

    final parts = _TextRunParts.from(text);
    if (!parts.hasContent) {
      return [TextSpan(text: text)];
    }

    return [
      if (parts.leadingWhitespace.isNotEmpty)
        TextSpan(text: parts.leadingWhitespace),
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: _CorrectionTextBadge(
          text: parts.content,
          textStyle: baseStyle.copyWith(height: 1.4),
          addLeadingGap: parts.leadingWhitespace.isEmpty,
        ),
      ),
      if (parts.trailingWhitespace.isNotEmpty)
        TextSpan(text: parts.trailingWhitespace),
    ];
  }
}

class _CorrectionTextBadge extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final bool addLeadingGap;

  const _CorrectionTextBadge({
    required this.text,
    required this.textStyle,
    required this.addLeadingGap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: addLeadingGap ? 4 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.green100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: textStyle.copyWith(color: AppColors.green200)),
    );
  }
}

class _TextRunParts {
  final String leadingWhitespace;
  final String content;
  final String trailingWhitespace;

  const _TextRunParts({
    required this.leadingWhitespace,
    required this.content,
    required this.trailingWhitespace,
  });

  bool get hasContent => content.isNotEmpty;

  factory _TextRunParts.from(String text) {
    final leadingWhitespace = RegExp(r'^\s+').firstMatch(text)?.group(0) ?? '';
    final remaining = text.substring(leadingWhitespace.length);
    final trailingWhitespace =
        RegExp(r'\s+$').firstMatch(remaining)?.group(0) ?? '';
    final contentStart = leadingWhitespace.length;
    final contentEnd = text.length - trailingWhitespace.length;

    return _TextRunParts(
      leadingWhitespace: leadingWhitespace,
      content: contentStart < contentEnd
          ? text.substring(contentStart, contentEnd)
          : '',
      trailingWhitespace: trailingWhitespace,
    );
  }
}

class _PendingFeedbackBox extends StatelessWidget {
  const _PendingFeedbackBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivory100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Jolly가 편지를 검토하고 있어요.',
        style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray900),
      ),
    );
  }
}

class _NoReviewTipBox extends StatelessWidget {
  const _NoReviewTipBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivory100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '고칠 부분이 없어요!',
        style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray500),
      ),
    );
  }
}
