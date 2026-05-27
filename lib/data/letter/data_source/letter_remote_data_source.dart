import 'package:dio/dio.dart';

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
    final response = await _dio.get('/letters');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => LetterDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LetterDto> getLetterDetail(int letterId) async {
    final response = await _dio.get('/letters/$letterId');
    return LetterDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LetterDto> createLetter(String content) async {
    final response = await _dio.post(
      '/letter',
      data: {'content': content},
    );
    return LetterDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LetterReviewDto> getLetterReview(int letterId) async {
    final response = await _dio.get('/letters/$letterId/review');
    return LetterReviewDto.fromJson(response.data as Map<String, dynamic>);
  }
}
