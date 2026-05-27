import 'package:dio/dio.dart';

import '../dto/token_dto.dart';
import '../dto/user_dto.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Future<TokenDto> login({
    required String provider,
    required String token,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'provider': provider,
        'token': token,
      },
    );
    return TokenDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/auth/account');
  }

  Future<UserDto> registerNickname(String nickname) async {
    final response = await _dio.post(
      '/users/nickname',
      data: {'nickname': nickname},
    );
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserDto> updateNickname(String nickname) async {
    final response = await _dio.patch(
      '/users/nickname',
      data: {'nickname': nickname},
    );
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserDto> getUser() async {
    final response = await _dio.get('/users/me');
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenDto> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenDto.fromJson(response.data as Map<String, dynamic>);
  }
}
