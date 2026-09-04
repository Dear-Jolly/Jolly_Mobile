import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth/data_source/auth_remote_data_source.dart';
import '../../data/auth/repository/auth_repository_impl.dart';
import '../../data/letter/data_source/letter_remote_data_source.dart';
import '../../data/letter/repository/letter_repository_impl.dart';
import '../../data/version/data_source/version_remote_data_source.dart';
import '../../data/version/repository/version_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/letter_repository.dart';
import '../../domain/repository/version_repository.dart';
import '../../domain/usecase/auth/agree_terms_usecase.dart';
import '../../domain/usecase/auth/delete_account_usecase.dart';
import '../../domain/usecase/auth/get_user_usecase.dart';
import '../../domain/usecase/auth/login_usecase.dart';
import '../../domain/usecase/auth/logout_usecase.dart';
import '../../domain/usecase/auth/register_nickname_usecase.dart';
import '../../domain/usecase/auth/update_nickname_usecase.dart';
import '../../domain/usecase/letter/create_letter_usecase.dart';
import '../../domain/usecase/letter/get_home_data_usecase.dart';
import '../../domain/usecase/letter/get_letter_detail_usecase.dart';
import '../../domain/usecase/letter/get_letter_review_usecase.dart';
import '../../domain/usecase/letter/get_letters_usecase.dart';
import '../../domain/usecase/version/check_version_usecase.dart';
import '../network/dio_client.dart';
import '../platform/app_info.dart';
import '../platform/device_time_zone.dart';
import '../storage/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final appInfoProvider = Provider<AppInfo>((ref) {
  return const AppInfo();
});

final deviceTimeZoneProvider = Provider<DeviceTimeZone>((ref) {
  return const DeviceTimeZone();
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(secureStorage: ref.watch(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final letterRemoteDataSourceProvider = Provider<LetterRemoteDataSource>((ref) {
  return LetterRemoteDataSource(
    ref.watch(dioProvider),
    ref.watch(deviceTimeZoneProvider),
  );
});

final versionRemoteDataSourceProvider = Provider<VersionRemoteDataSource>((
  ref,
) {
  return VersionRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

final letterRepositoryProvider = Provider<LetterRepository>((ref) {
  return LetterRepositoryImpl(ref.watch(letterRemoteDataSourceProvider));
});

final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  return VersionRepositoryImpl(
    ref.watch(versionRemoteDataSourceProvider),
    ref.watch(appInfoProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final agreeTermsUseCaseProvider = Provider<AgreeTermsUseCase>((ref) {
  return AgreeTermsUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(authRepositoryProvider));
});

final registerNicknameUseCaseProvider = Provider<RegisterNicknameUseCase>((
  ref,
) {
  return RegisterNicknameUseCase(ref.watch(authRepositoryProvider));
});

final updateNicknameUseCaseProvider = Provider<UpdateNicknameUseCase>((ref) {
  return UpdateNicknameUseCase(ref.watch(authRepositoryProvider));
});

final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.watch(authRepositoryProvider));
});

final getHomeDataUseCaseProvider = Provider<GetHomeDataUseCase>((ref) {
  return GetHomeDataUseCase(ref.watch(letterRepositoryProvider));
});

final getLettersUseCaseProvider = Provider<GetLettersUseCase>((ref) {
  return GetLettersUseCase(ref.watch(letterRepositoryProvider));
});

final getLetterDetailUseCaseProvider = Provider<GetLetterDetailUseCase>((ref) {
  return GetLetterDetailUseCase(ref.watch(letterRepositoryProvider));
});

final createLetterUseCaseProvider = Provider<CreateLetterUseCase>((ref) {
  return CreateLetterUseCase(ref.watch(letterRepositoryProvider));
});

final getLetterReviewUseCaseProvider = Provider<GetLetterReviewUseCase>((ref) {
  return GetLetterReviewUseCase(ref.watch(letterRepositoryProvider));
});

final checkVersionUseCaseProvider = Provider<CheckVersionUseCase>((ref) {
  return CheckVersionUseCase(ref.watch(versionRepositoryProvider));
});
