import 'package:dio/dio.dart';

import '../dto/token_dto.dart';
import '../dto/user_dto.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Uri authorizationUri(String provider) {
    return Uri.parse('${_dio.options.baseUrl}/auth/$provider');
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/users');
  }

  Future<TermsAgreeDto> agreeTerms({
    required bool serviceAgreed,
    required bool privacyAgreed,
    required bool marketingAgreed,
  }) async {
    final response = await _dio.post(
      '/users/terms',
      data: {
        'agreements': [
          {'type': 'SERVICE', 'agreed': serviceAgreed},
          {'type': 'PRIVACY', 'agreed': privacyAgreed},
          {'type': 'MARKETING', 'agreed': marketingAgreed},
        ],
      },
    );
    return TermsAgreeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NicknameUpdateDto> updateNickname(String nickname) async {
    final response = await _dio.patch(
      '/users/nickname',
      data: {'nickname': nickname},
    );
    return NicknameUpdateDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserDto> getUser() async {
    final response = await _dio.get('/users');
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenDto> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/reissue',
      data: {'refreshToken': refreshToken},
    );
    return TokenDto.fromJson(response.data as Map<String, dynamic>);
  }
}
