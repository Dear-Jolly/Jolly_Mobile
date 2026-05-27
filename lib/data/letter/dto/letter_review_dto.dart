import '../../../domain/entity/letter_review.dart';

class LetterReviewDto {
  final int letterId;
  final String originalContent;
  final String correctedContent;
  final List<ReviewFeedbackDto> feedbacks;

  const LetterReviewDto({
    required this.letterId,
    required this.originalContent,
    required this.correctedContent,
    required this.feedbacks,
  });

  factory LetterReviewDto.fromJson(Map<String, dynamic> json) {
    return LetterReviewDto(
      letterId: json['letterId'] as int,
      originalContent: json['originalContent'] as String,
      correctedContent: json['correctedContent'] as String,
      feedbacks: (json['feedbacks'] as List<dynamic>)
          .map((e) => ReviewFeedbackDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  LetterReview toEntity() {
    return LetterReview(
      letterId: letterId,
      originalContent: originalContent,
      correctedContent: correctedContent,
      feedbacks: feedbacks.map((e) => e.toEntity()).toList(),
    );
  }
}

class ReviewFeedbackDto {
  final String category;
  final String original;
  final String suggestion;
  final String explanation;

  const ReviewFeedbackDto({
    required this.category,
    required this.original,
    required this.suggestion,
    required this.explanation,
  });

  factory ReviewFeedbackDto.fromJson(Map<String, dynamic> json) {
    return ReviewFeedbackDto(
      category: json['category'] as String,
      original: json['original'] as String,
      suggestion: json['suggestion'] as String,
      explanation: json['explanation'] as String,
    );
  }

  ReviewFeedback toEntity() {
    return ReviewFeedback(
      category: category,
      original: original,
      suggestion: suggestion,
      explanation: explanation,
    );
  }
}
