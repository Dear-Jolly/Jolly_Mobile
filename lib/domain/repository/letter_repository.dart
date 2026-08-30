import '../entity/home_data.dart';
import '../entity/letter.dart';
import '../entity/letter_page.dart';
import '../entity/letter_review.dart';
import '../model/result.dart';

abstract class LetterRepository {
  Future<Result<HomeData>> getHomeData();
  Future<Result<LetterPage>> getLetters({
    required int page,
    required int size,
    required LetterSortOrder sort,
  });
  Future<Result<Letter>> getLetterDetail(int letterId);
  Future<Result<Letter>> createLetter(String content);
  Future<Result<LetterReview>> getLetterReview(int letterId);
}
