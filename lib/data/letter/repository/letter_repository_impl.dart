import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entity/home_data.dart';
import '../../../domain/entity/letter.dart';
import '../../../domain/entity/letter_review.dart';
import '../../../domain/model/result.dart';
import '../../../domain/repository/letter_repository.dart';
import '../data_source/letter_remote_data_source.dart';

class LetterRepositoryImpl implements LetterRepository {
  final LetterRemoteDataSource _dataSource;

  const LetterRepositoryImpl(this._dataSource);

  @override
  Future<Result<HomeData>> getHomeData() async {
    try {
      final dto = await _dataSource.getHomeData();
      return Success(dto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<Letter>>> getLetters() async {
    try {
      final dtos = await _dataSource.getLetters();
      return Success(dtos.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Letter>> getLetterDetail(int letterId) async {
    try {
      final dto = await _dataSource.getLetterDetail(letterId);
      return Success(dto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Letter>> createLetter(String content) async {
    try {
      final dto = await _dataSource.createLetter(content);
      return Success(dto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<LetterReview>> getLetterReview(int letterId) async {
    try {
      final dto = await _dataSource.getLetterReview(letterId);
      return Success(dto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
