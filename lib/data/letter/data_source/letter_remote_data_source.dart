import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../dto/home_dto.dart';
import '../dto/letter_dto.dart';
import '../dto/letter_review_dto.dart';

class LetterRemoteDataSource {
  final Dio _dio;

  const LetterRemoteDataSource(this._dio);

  Future<HomeDto> getHomeData() async {
    final response = await _dio.get('/home');
    return HomeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<LetterDto>> getLetters() async {
    final response = await _dio.get(
      '/letters',
      queryParameters: {'page': 0, 'size': 100, 'sort': 'date,desc'},
    );
    return LetterListDto.fromJson(
      response.data as Map<String, dynamic>,
    ).letters;
  }

  Future<LetterDto> getLetterDetail(int letterId) async {
    final response = await _dio.get('/letters/$letterId');
    return LetterDto.fromDetailJson(response.data as Map<String, dynamic>);
  }

  Future<LetterDto> createLetter(String content) async {
    final now = DateTime.now();
    final response = await _dio.post(
      '/letters',
      data: {
        'content': content,
        'writtenAt': _formatDateTime(now),
        'timeZone': ApiConfig.defaultTimeZone,
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
