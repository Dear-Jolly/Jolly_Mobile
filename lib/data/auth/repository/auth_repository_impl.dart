import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/entity/auth_session.dart';
import '../../../domain/entity/user.dart';
import '../../../domain/model/result.dart';
import '../../../domain/repository/auth_repository.dart';

import '../data_source/auth_remote_data_source.dart';
import '../dto/token_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final SecureStorage _storage;

  const AuthRepositoryImpl(this._dataSource, this._storage);

  @override
  Uri getAuthorizationUri(LoginProvider provider) {
    return _dataSource.authorizationUri(_providerValue(provider));
  }

  @override
  Future<Result<AuthSession>> completeSocialLogin(Uri callbackUri) async {
    try {
      final session = AuthSessionDto.fromUri(callbackUri).toEntity();
      await _storage.saveAuthSession(session);
      return Success(session);
    } on FormatException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> agreeTerms({
    required bool serviceAgreed,
    required bool privacyAgreed,
    required bool marketingAgreed,
  }) async {
    try {
      final dto = await _dataSource.agreeTerms(
        serviceAgreed: serviceAgreed,
        privacyAgreed: privacyAgreed,
        marketingAgreed: marketingAgreed,
      );
      await _storage.saveTermsAgreed(dto.termsAgreed);
      return const Success(null);
    } on DioException catch (e) {
      return _failureFromDioException(e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.logout();
      await _storage.clearAuthState();
      return const Success(null);
    } on DioException catch (e) {
      final exception = ApiException.fromDioException(e);
      if (_shouldClearLocalAuth(exception)) {
        await _storage.clearAuthState();
        return const Success(null);
      }
      return _failureFromApiException(exception);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      await _storage.clearAuthState();
      return const Success(null);
    } on DioException catch (e) {
      final exception = ApiException.fromDioException(e);
      if (_shouldClearLocalAuth(exception)) {
        await _storage.clearAuthState();
        return const Success(null);
      }
      return _failureFromApiException(exception);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<User>> registerNickname(String nickname) async {
    try {
      await _dataSource.updateNickname(nickname);
      await _storage.saveNicknameRegistered(true);
      final userDto = await _dataSource.getUser();
      return Success(userDto.toEntity());
    } on DioException catch (e) {
      return _failureFromDioException(e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<User>> updateNickname(String nickname) async {
    try {
      await _dataSource.updateNickname(nickname);
      final userDto = await _dataSource.getUser();
      return Success(userDto.toEntity());
    } on DioException catch (e) {
      return _failureFromDioException(e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<User>> getUser() async {
    try {
      final userDto = await _dataSource.getUser();
      return Success(userDto.toEntity());
    } on DioException catch (e) {
      return _failureFromDioException(e);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  String _providerValue(LoginProvider provider) {
    return switch (provider) {
      LoginProvider.apple => 'APPLE',
      LoginProvider.kakao => 'KAKAO',
    };
  }

  bool _shouldClearLocalAuth(ApiException exception) {
    return exception.statusCode == 401 || exception.code == 'AUTH_007';
  }

  Failure<T> _failureFromDioException<T>(DioException e) {
    final exception = ApiException.fromDioException(e);
    return _failureFromApiException(exception);
  }

  Failure<T> _failureFromApiException<T>(ApiException exception) {
    return Failure(
      exception.message,
      statusCode: exception.statusCode,
      code: exception.code,
      requestId: exception.requestId,
    );
  }
}
