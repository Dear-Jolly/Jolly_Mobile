import '../../entity/letter_review.dart';
import '../../model/result.dart';
import '../../repository/letter_repository.dart';

class GetLetterReviewUseCase {
  final LetterRepository _repository;

  const GetLetterReviewUseCase(this._repository);

  Future<Result<LetterReview>> execute(int letterId) {
    return _repository.getLetterReview(letterId);
  }
}
