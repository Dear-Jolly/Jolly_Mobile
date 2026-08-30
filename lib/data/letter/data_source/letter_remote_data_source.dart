import 'package:dio/dio.dart';

import '../../../core/platform/device_time_zone.dart';
import '../dto/home_dto.dart';
import '../dto/letter_dto.dart';
import '../dto/letter_review_dto.dart';

class LetterRemoteDataSource {
  final Dio _dio;
  final DeviceTimeZone _deviceTimeZone;

  const LetterRemoteDataSource(this._dio, this._deviceTimeZone);

  Future<HomeDto> getHomeData() async {
    final response = await _dio.get('/home');
    return HomeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LetterListDto> getLetters({
    required int page,
    required int size,
    required String sort,
  }) async {
    final response = await _dio.get(
      '/letters',
      queryParameters: {'page': page, 'size': size, 'sort': sort},
    );
    return LetterListDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LetterDto> getLetterDetail(int letterId) async {
    final response = await _dio.get('/letters/$letterId');
    return LetterDto.fromDetailJson(response.data as Map<String, dynamic>);
  }

  Future<LetterDto> createLetter(String content) async {
    final now = DateTime.now();
    final timeZone = await _deviceTimeZone.currentIdentifier;
    final response = await _dio.post(
      '/letters',
      data: {
        'content': content,
        'writtenAt': _formatDateTime(now),
        'timeZone': timeZone,
      },
    );
    return LetterDto.fromCreateJson(
      response.data as Map<String, dynamic>,
      content: content,
    );
  }

  Future<LetterReviewDto> getLetterReview(int letterId) async {
    final response = await _dio.get('/letters/$letterId');
    return LetterReviewDto.fromJson(response.data as Map<String, dynamic>);
  }

  String _formatDateTime(DateTime dateTime) {
    final value = dateTime.toIso8601String();
    final dotIndex = value.indexOf('.');
    return dotIndex == -1 ? value : value.substring(0, dotIndex);
  }
}
