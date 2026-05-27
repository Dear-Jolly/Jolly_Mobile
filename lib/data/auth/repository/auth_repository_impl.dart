import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/entity/user.dart';
import '../../../domain/model/result.dart';
import '../../../domain/repository/auth_repository.dart';
import 'package:dio/dio.dart';

import '../data_source/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final SecureStorage _storage;

  const AuthRepositoryImpl(this._dataSource, this._storage);

  Future<Result<User>> _login(String provider, String token) async {
    try {
      final tokenDto = await _dataSource.login(
        provider: provider,
        token: token,
      );
      await _storage.saveAccessToken(tokenDto.accessToken);
      await _storage.saveRefreshToken(tokenDto.refreshToken);
      final userDto = await _dataSource.getUser();
      return Success(userDto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<User>> loginWithKakao() async {
    // TODO: 카카오 SDK에서 oauthToken 획득 후 전달
    const oauthToken = '';
    return _login('KAKAO', oauthToken);
  }

  @override
  Future<Result<User>> loginWithApple() async {
    // TODO: Apple 로그인 SDK에서 identityToken 획득 후 전달
    const identityToken = '';
    return _login('APPLE', identityToken);
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.logout();
      await _storage.clearTokens();
      return const Success(null);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      await _storage.clearTokens();
      return const Success(null);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<User>> registerNickname(String nickname) async {
    try {
      final userDto = await _dataSource.registerNickname(nickname);
      return Success(userDto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<User>> updateNickname(String nickname) async {
    try {
      final userDto = await _dataSource.updateNickname(nickname);
      return Success(userDto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
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
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
