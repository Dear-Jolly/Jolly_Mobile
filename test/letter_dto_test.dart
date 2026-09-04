import 'package:flutter_test/flutter_test.dart';
import 'package:jolly_mobile/data/letter/dto/letter_dto.dart';
import 'package:jolly_mobile/data/letter/dto/letter_review_dto.dart';
import 'package:jolly_mobile/domain/entity/letter.dart';

void main() {
  test('maps FEEDBACK_FAILED list item without unread red dot', () {
    final dto = LetterDto.fromSummaryJson({
      'letterId': 15,
      'date': '2026-08-30',
      'summary': 'I wrote a letter today...',
      'status': 'FEEDBACK_FAILED',
      'isRead': false,
      'stampImage': 'https://example.com/dear-jolly-stamps/stamp/fail.png',
    });

    final letter = dto.toEntity();

    expect(letter.status, LetterStatus.feedbackFailed);
    expect(letter.isFeedbackFailed, isTrue);
    expect(letter.hasFeedback, isFalse);
    expect(letter.isNew, isFalse);
    expect(
      letter.stampImage,
      'https://example.com/dear-jolly-stamps/stamp/fail.png',
    );
  });

  test('maps FEEDBACK_FAILED detail response with null feedback', () {
    final dto = LetterReviewDto.fromJson({
      'letterId': 15,
      'date': '2026-08-30',
      'originalContent': 'I wrote a letter today...',
      'status': 'FEEDBACK_FAILED',
      'stampImage': 'https://example.com/dear-jolly-stamps/stamp/fail.png',
      'feedback': null,
    });

    final review = dto.toEntity();

    expect(review.status, LetterStatus.feedbackFailed);
    expect(review.isFeedbackFailed, isTrue);
    expect(review.hasFeedback, isFalse);
    expect(
      review.stampImage,
      'https://example.com/dear-jolly-stamps/stamp/fail.png',
    );
  });

  test('keeps unread red dot only for completed feedback', () {
    final dto = LetterDto.fromSummaryJson({
      'letterId': 16,
      'date': '2026-08-30',
      'summary': 'Completed letter',
      'status': 'FEEDBACK_COMPLETED',
      'isRead': false,
      'stampImage': 'https://example.com/dear-jolly-stamps/stamp/flower.png',
    });

    final letter = dto.toEntity();

    expect(letter.status, LetterStatus.feedbackCompleted);
    expect(letter.isNew, isTrue);
  });
}
