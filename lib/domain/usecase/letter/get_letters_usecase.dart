import '../../entity/letter.dart';
import '../../model/result.dart';
import '../../repository/letter_repository.dart';

class GetLettersUseCase {
  final LetterRepository _repository;

  const GetLettersUseCase(this._repository);

  Future<Result<List<Letter>>> execute() {
    return _repository.getLetters();
  }
}
