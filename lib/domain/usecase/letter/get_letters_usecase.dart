import '../../entity/letter_page.dart';
import '../../model/result.dart';
import '../../repository/letter_repository.dart';

class GetLettersUseCase {
  final LetterRepository _repository;

  const GetLettersUseCase(this._repository);

  Future<Result<LetterPage>> execute({
    required int page,
    required int size,
    required LetterSortOrder sort,
  }) {
    return _repository.getLetters(page: page, size: size, sort: sort);
  }
}
