import '../../../domain/entity/letter.dart';

class LetterDto {
  final int id;
  final String content;
  final String createdAt;
  final String? stampImage;
  final String status;
  final bool isNew;

  const LetterDto({
    required this.id,
    required this.content,
    required this.createdAt,
    this.stampImage,
    required this.status,
    this.isNew = false,
  });

  factory LetterDto.fromJson(Map<String, dynamic> json) {
    return LetterDto(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      stampImage: json['stampImage'] as String?,
      status: json['status'] as String,
      isNew: json['isNew'] as bool? ?? false,
    );
  }

  Letter toEntity() {
    return Letter(
      id: id,
      content: content,
      createdAt: DateTime.parse(createdAt),
      stampImage: stampImage,
      status: switch (status) {
        'ARRIVED' => LetterStatus.arrived,
        'VIEWED' => LetterStatus.viewed,
        _ => LetterStatus.sent,
      },
      isNew: isNew,
    );
  }
}
