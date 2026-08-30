import '../../../domain/entity/letter_review.dart';
import 'letter_dto.dart';

class LetterReviewDto {
  final LetterDto letter;
  final int letterId;
  final DateTime date;
  final String originalContent;
  final String? stampImage;
  final String status;
  final String correctedContent;
  final List<String> tips;
  final List<CorrectionSegmentDto> correctionSegments;

  const LetterReviewDto({
    required this.letter,
    required this.letterId,
    required this.date,
    required this.originalContent,
    this.stampImage,
    required this.status,
    required this.correctedContent,
    required this.tips,
    required this.correctionSegments,
  });

  factory LetterReviewDto.fromJson(Map<String, dynamic> json) {
    final letter = LetterDto.fromDetailJson(json);
    final feedback = json['feedback'] as Map<String, dynamic>?;
    final rawSegments = feedback?['correctionSegments'] as List<dynamic>?;
    final segments =
        rawSegments
            ?.map(
              (e) => CorrectionSegmentDto.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [
          CorrectionSegmentDto(
            sequence: 1,
            originalText: letter.content,
            correctedText: letter.content,
            type: 'UNCHANGED',
          ),
        ];
    segments.sort((a, b) => a.sequence.compareTo(b.sequence));

    return LetterReviewDto(
      letter: letter,
      letterId: letter.id,
      date: letter.date,
      originalContent: letter.content,
      stampImage: letter.stampImage,
      status: json['status'] as String? ?? 'SUBMITTED',
      correctedContent:
          feedback?['correctedContent'] as String? ?? letter.content,
      tips: (feedback?['tips'] as List<dynamic>? ?? [])
          .whereType<String>()
          .where((tip) => tip.trim().isNotEmpty)
          .toList(),
      correctionSegments: segments,
    );
  }

  LetterReview toEntity() {
    return LetterReview(
      letterId: letterId,
      date: date,
      originalContent: originalContent,
      stampImage: stampImage,
      status: letter.toEntity().status,
      correctedContent: correctedContent,
      tips: tips,
      correctionSegments: correctionSegments.map((e) => e.toEntity()).toList(),
    );
  }
}

class CorrectionSegmentDto {
  final int sequence;
  final String originalText;
  final String correctedText;
  final String type;

  const CorrectionSegmentDto({
    required this.sequence,
    required this.originalText,
    required this.correctedText,
    required this.type,
  });

  factory CorrectionSegmentDto.fromJson(Map<String, dynamic> json) {
    return CorrectionSegmentDto(
      sequence: json['sequence'] as int? ?? 0,
      originalText: json['originalText'] as String? ?? '',
      correctedText: json['correctedText'] as String? ?? '',
      type: json['type'] as String? ?? 'UNCHANGED',
    );
  }

  CorrectionSegment toEntity() {
    return CorrectionSegment(
      sequence: sequence,
      originalText: originalText,
      correctedText: correctedText,
      type: type == 'MODIFIED'
          ? CorrectionSegmentType.modified
          : CorrectionSegmentType.unchanged,
    );
  }
}
