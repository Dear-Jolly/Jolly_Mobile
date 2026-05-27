import '../../entity/home_data.dart';
import '../../model/result.dart';
import '../../repository/letter_repository.dart';

class GetHomeDataUseCase {
  final LetterRepository _repository;

  const GetHomeDataUseCase(this._repository);

  Future<Result<HomeData>> execute() {
    return _repository.getHomeData();
  }
}
