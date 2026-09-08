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

    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('전달하기')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.createCalls, 1);
    expect(find.text('서버 오류가 발생했습니다.'), findsWidgets);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  for (final size in [const Size(360, 780), const Size(320, 568)]) {
    testWidgets('keyboard keeps count and warning visible at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WriteLetterScreen())),
      );
      await tester.enterText(find.byType(TextField), 'Hello 한글');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      final warning = find.text('영어로 작성해 주세요. 이 편지는 영어만 검토돼요!');
      final counter = find.text('8/500');
      expect(warning, findsOneWidget);
      expect(counter, findsOneWidget);
      expect(tester.getBottomRight(warning).dy, lessThan(size.height - 280));
      expect(tester.getBottomRight(counter).dy, lessThan(size.height - 280));
      expect(find.text('TO:'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('키보드 닫기'));
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();
      await tester.tap(find.text('전달하기'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);

      await tester.enterText(find.byType(TextField), 'Hello Jolly');
      await tester.pump();
      expect(warning, findsNothing);
      await tester.tap(find.text('전달하기'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      final image = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Image),
      );
      expect(
        tester.getBottomRight(find.text('전달된 편지는 다시 고칠 수 없어요.')).dy,
        lessThan(tester.getTopLeft(image).dy),
      );
      await tester.tap(find.text('계속 쓰기'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Hello Jolly',
      );
      expect(tester.takeException(), isNull);
    });
  }
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
