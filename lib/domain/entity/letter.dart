enum LetterStatus { submitted, feedbackInProgress, feedbackCompleted }

class Letter {
  final int id;
  final String content;
  final DateTime date;
  final DateTime? createdAt;
  final String? stampImage;
  final LetterStatus status;
  final bool isNew;

  const Letter({
    required this.id,
    required this.content,
    required this.date,
    this.createdAt,
    this.stampImage,
    this.status = LetterStatus.submitted,
    this.isNew = false,
  });

  bool get hasFeedback => status == LetterStatus.feedbackCompleted;

  Letter copyWith({
    int? id,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    String? stampImage,
    LetterStatus? status,
    bool? isNew,
  }) {
    return Letter(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      stampImage: stampImage ?? this.stampImage,
      status: status ?? this.status,
      isNew: isNew ?? this.isNew,
    );
  }
}
