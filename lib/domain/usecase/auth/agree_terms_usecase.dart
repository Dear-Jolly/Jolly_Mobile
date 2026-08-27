import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class AgreeTermsUseCase {
  final AuthRepository _repository;

  const AgreeTermsUseCase(this._repository);

  Future<Result<void>> execute({
    required bool serviceAgreed,
    required bool privacyAgreed,
    required bool marketingAgreed,
  }) {
    return _repository.agreeTerms(
      serviceAgreed: serviceAgreed,
      privacyAgreed: privacyAgreed,
      marketingAgreed: marketingAgreed,
    );
  }
}
