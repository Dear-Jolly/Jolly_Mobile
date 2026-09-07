import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jolly_mobile/core/di/providers.dart';
import 'package:jolly_mobile/domain/entity/home_data.dart';
import 'package:jolly_mobile/domain/entity/letter.dart';
import 'package:jolly_mobile/domain/entity/letter_page.dart';
import 'package:jolly_mobile/domain/entity/letter_review.dart';
import 'package:jolly_mobile/domain/model/result.dart';
import 'package:jolly_mobile/domain/repository/letter_repository.dart';
import 'package:jolly_mobile/domain/usecase/letter/create_letter_usecase.dart';
import 'package:jolly_mobile/features/write/view/write_letter_screen.dart';

void main() {
  testWidgets('shows error message and retry action when submit fails', (
    tester,
  ) async {
    final repository = _FakeLetterRepository(
      nextResult: const Failure('서버 오류가 발생했습니다.'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createLetterUseCaseProvider.overrideWith(
            (ref) => CreateLetterUseCase(repository),
          ),
        ],
        child: const MaterialApp(home: WriteLetterScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Hello Jolly');
    await tester.pump();

    await tester.tap(find.text('전달하기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('완료'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.createCalls, 1);
    expect(find.text('서버 오류가 발생했습니다.'), findsWidgets);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

class _FakeLetterRepository implements LetterRepository {
  final Result<Letter> nextResult;
  int createCalls = 0;

  _FakeLetterRepository({required this.nextResult});

  @override
  Future<Result<Letter>> createLetter(String content) {
    createCalls++;
    return Future.value(nextResult);
  }

  @override
  Future<Result<HomeData>> getHomeData() {
    throw UnimplementedError();
  }

  @override
  Future<Result<Letter>> getLetterDetail(int letterId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<LetterReview>> getLetterReview(int letterId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<LetterPage>> getLetters({
    required int page,
    required int size,
    required LetterSortOrder sort,
  }) {
    throw UnimplementedError();
  }
}
