import '../../../domain/entity/letter.dart';

class LetterListDto {
  final List<LetterDto> letters;
  final bool hasNext;

  const LetterListDto({required this.letters, required this.hasNext});

  factory LetterListDto.fromJson(Map<String, dynamic> json) {
    return LetterListDto(
      letters: (json['letters'] as List<dynamic>? ?? [])
          .map((e) => LetterDto.fromSummaryJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}

class LetterDto {
  final int id;
  final String content;
  final DateTime date;
  final DateTime? createdAt;
  final String? stampImage;
  final String status;
  final bool isNew;

  const LetterDto({
    required this.id,
    required this.content,
    required this.date,
    this.createdAt,
    this.stampImage,
    required this.status,
    this.isNew = false,
  });

  factory LetterDto.fromSummaryJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'SUBMITTED';

    return LetterDto(
      id: json['letterId'] as int? ?? json['id'] as int,
      content: json['summary'] as String? ?? json['content'] as String? ?? '',
      date: _parseDate(json['date'] as String?),
      stampImage: json['stampImage'] as String?,
      status: status,
      isNew:
          status == 'FEEDBACK_COMPLETED' && !(json['isRead'] as bool? ?? true),
    );
  }

  factory LetterDto.fromDetailJson(Map<String, dynamic> json) {
    return LetterDto(
      id: json['letterId'] as int? ?? json['id'] as int,
      content:
          json['originalContent'] as String? ??
          json['content'] as String? ??
          json['summary'] as String? ??
          '',
      date: _parseDate(json['date'] as String?),
      stampImage: json['stampImage'] as String?,
      status: json['status'] as String? ?? 'SUBMITTED',
      isNew: false,
    );
  }

  factory LetterDto.fromCreateJson(
    Map<String, dynamic> json, {
    required String content,
  }) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');

    return LetterDto(
      id: json['letterId'] as int? ?? json['id'] as int,
      content: content,
      date: _parseDate(json['date'] as String?),
      createdAt: createdAt,
      status: 'SUBMITTED',
    );
  }

  Letter toEntity() {
    return Letter(
      id: id,
      content: content,
      date: date,
      createdAt: createdAt,
      stampImage: stampImage,
      status: switch (status) {
        'FEEDBACK_COMPLETED' => LetterStatus.feedbackCompleted,
        'FEEDBACK_IN_PROGRESS' => LetterStatus.feedbackInProgress,
        _ => LetterStatus.submitted,
      },
      isNew: isNew,
    );
  }

  static DateTime _parseDate(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
