class LetterReview {
  final int letterId;
  final String originalContent;
  final String correctedContent;
  final List<ReviewFeedback> feedbacks;

  const LetterReview({
    required this.letterId,
    required this.originalContent,
    required this.correctedContent,
    required this.feedbacks,
  });
}

class ReviewFeedback {
  final String category;
  final String original;
  final String suggestion;
  final String explanation;

  const ReviewFeedback({
    required this.category,
    required this.original,
    required this.suggestion,
    required this.explanation,
  });
}
