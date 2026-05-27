enum LetterStatus { sent, arrived, viewed }

class Letter {
  final int id;
  final String content;
  final DateTime createdAt;
  final String? stampImage;
  final LetterStatus status;
  final bool isNew;

  const Letter({
    required this.id,
    required this.content,
    required this.createdAt,
    this.stampImage,
    this.status = LetterStatus.sent,
    this.isNew = false,
  });

  Letter copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    String? stampImage,
    LetterStatus? status,
    bool? isNew,
  }) {
    return Letter(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      stampImage: stampImage ?? this.stampImage,
      status: status ?? this.status,
      isNew: isNew ?? this.isNew,
    );
  }
}
