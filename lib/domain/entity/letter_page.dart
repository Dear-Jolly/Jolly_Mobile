import 'letter.dart';

enum LetterSortOrder {
  latest('LATEST'),
  oldest('OLDEST');

  final String apiValue;

  const LetterSortOrder(this.apiValue);
}

class LetterPage {
  final List<Letter> letters;
  final bool hasNext;

  const LetterPage({required this.letters, required this.hasNext});
}
