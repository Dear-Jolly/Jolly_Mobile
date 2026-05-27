import '../../entity/letter.dart';
import '../../model/result.dart';
import '../../repository/letter_repository.dart';

class CreateLetterUseCase {
  final LetterRepository _repository;

  const CreateLetterUseCase(this._repository);

  Future<Result<Letter>> execute(String content) {
    return _repository.createLetter(content);
  }
}
