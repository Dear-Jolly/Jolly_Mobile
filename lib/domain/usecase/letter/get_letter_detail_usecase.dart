import '../../entity/letter.dart';
import '../../model/result.dart';
import '../../repository/letter_repository.dart';

class GetLetterDetailUseCase {
  final LetterRepository _repository;

  const GetLetterDetailUseCase(this._repository);

  Future<Result<Letter>> execute(int letterId) {
    return _repository.getLetterDetail(letterId);
  }
}
