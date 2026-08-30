import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../data/auth/data_source/auth_remote_data_source.dart';
import '../../data/auth/repository/auth_repository_impl.dart';
import '../../data/letter/data_source/letter_remote_data_source.dart';
import '../../data/letter/repository/letter_repository_impl.dart';
import '../../data/version/data_source/version_remote_data_source.dart';
import '../../data/version/repository/version_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/letter_repository.dart';
import '../../domain/repository/version_repository.dart';
import '../../domain/usecase/auth/delete_account_usecase.dart';
import '../../domain/usecase/auth/agree_terms_usecase.dart';
import '../../domain/usecase/auth/get_user_usecase.dart';
import '../../domain/usecase/auth/login_usecase.dart';
import '../../domain/usecase/auth/logout_usecase.dart';
import '../../domain/usecase/auth/register_nickname_usecase.dart';
import '../../domain/usecase/auth/update_nickname_usecase.dart';
import '../../domain/usecase/letter/create_letter_usecase.dart';
import '../../domain/usecase/letter/get_letter_detail_usecase.dart';
import '../../domain/usecase/letter/get_letter_review_usecase.dart';
import '../../domain/usecase/letter/get_home_data_usecase.dart';
import '../../domain/usecase/letter/get_letters_usecase.dart';
import '../../domain/usecase/version/check_version_usecase.dart';
import '../network/dio_client.dart';
import '../platform/app_info.dart';
import '../platform/device_time_zone.dart';
import '../storage/secure_storage.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Core
  locator.registerLazySingleton<SecureStorage>(() => SecureStorage());
  locator.registerLazySingleton<AppInfo>(() => const AppInfo());
  locator.registerLazySingleton<DeviceTimeZone>(() => const DeviceTimeZone());
  locator.registerLazySingleton<Dio>(
    () => DioClient.create(secureStorage: locator<SecureStorage>()),
  );

  // Data Sources
  locator.registerLazySingleton(() => AuthRemoteDataSource(locator<Dio>()));
  locator.registerLazySingleton(
    () => LetterRemoteDataSource(locator<Dio>(), locator<DeviceTimeZone>()),
  );
  locator.registerLazySingleton(() => VersionRemoteDataSource(locator<Dio>()));

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      locator<AuthRemoteDataSource>(),
      locator<SecureStorage>(),
    ),
  );
  locator.registerLazySingleton<LetterRepository>(
    () => LetterRepositoryImpl(locator<LetterRemoteDataSource>()),
  );
  locator.registerLazySingleton<VersionRepository>(
    () => VersionRepositoryImpl(
      locator<VersionRemoteDataSource>(),
      locator<AppInfo>(),
    ),
  );

  // Use Cases - Auth
  locator.registerFactory(() => LoginUseCase(locator<AuthRepository>()));
  locator.registerFactory(() => AgreeTermsUseCase(locator<AuthRepository>()));
  locator.registerFactory(() => LogoutUseCase(locator<AuthRepository>()));
  locator.registerFactory(
    () => DeleteAccountUseCase(locator<AuthRepository>()),
  );
  locator.registerFactory(
    () => RegisterNicknameUseCase(locator<AuthRepository>()),
  );
  locator.registerFactory(
    () => UpdateNicknameUseCase(locator<AuthRepository>()),
  );
  locator.registerFactory(() => GetUserUseCase(locator<AuthRepository>()));

  // Use Cases - Letter
  locator.registerFactory(
    () => GetHomeDataUseCase(locator<LetterRepository>()),
  );
  locator.registerFactory(() => GetLettersUseCase(locator<LetterRepository>()));
  locator.registerFactory(
    () => GetLetterDetailUseCase(locator<LetterRepository>()),
  );
  locator.registerFactory(
    () => CreateLetterUseCase(locator<LetterRepository>()),
  );
  locator.registerFactory(
    () => GetLetterReviewUseCase(locator<LetterRepository>()),
  );

  // Use Cases - Version
  locator.registerFactory(
    () => CheckVersionUseCase(locator<VersionRepository>()),
  );
}
