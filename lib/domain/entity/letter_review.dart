import 'letter.dart';

class LetterReview {
  final int letterId;
  final DateTime date;
  final String originalContent;
  final String? stampImage;
  final LetterStatus status;
  final String correctedContent;
  final List<String> tips;
  final List<CorrectionSegment> correctionSegments;

  const LetterReview({
    required this.letterId,
    required this.date,
    required this.originalContent,
    this.stampImage,
    required this.status,
    required this.correctedContent,
    required this.tips,
    required this.correctionSegments,
  });

  bool get hasFeedback => status == LetterStatus.feedbackCompleted;
}

enum CorrectionSegmentType { unchanged, modified }

class CorrectionSegment {
  final int sequence;
  final String originalText;
  final String correctedText;
  final CorrectionSegmentType type;

  const CorrectionSegment({
    required this.sequence,
    required this.originalText,
    required this.correctedText,
    required this.type,
  });

  bool get isModified => type == CorrectionSegmentType.modified;
}
