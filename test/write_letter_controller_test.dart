import 'dart:async';

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
import 'package:jolly_mobile/features/write/state/write_letter_controller.dart';

void main() {
  test('submit changes state from loading to success', () async {
    final repository = _FakeLetterRepository(
      nextResult: Success(_letter(id: 1)),
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    final statuses = <WriteLetterSubmissionStatus>[];
    final subscription = container.listen(writeLetterControllerProvider, (
      _,
      next,
    ) {
      final value = next.value;
      if (value != null) {
        statuses.add(value.status);
      }
    }, fireImmediately: true);
    addTearDown(subscription.close);

    final submitFuture = container
        .read(writeLetterControllerProvider.notifier)
        .submit('Hello Jolly');

    expect(
      container.read(writeLetterControllerProvider).requireValue.status,
      WriteLetterSubmissionStatus.submitting,
    );

    final letter = await submitFuture;

    expect(letter?.id, 1);
    expect(repository.createCalls, 1);
    expect(statuses, [
      WriteLetterSubmissionStatus.idle,
      WriteLetterSubmissionStatus.submitting,
      WriteLetterSubmissionStatus.success,
    ]);
  });

  test(
    'submit exposes error state and keeps retry available on API failure',
    () async {
      final repository = _FakeLetterRepository(
        nextResult: const Failure(
          '서버 오류가 발생했습니다.',
          statusCode: 500,
          code: 'COMMON_001',
          requestId: 'request-1',
        ),
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      final letter = await container
          .read(writeLetterControllerProvider.notifier)
          .submit('Hello Jolly');
      final state = container.read(writeLetterControllerProvider).requireValue;

      expect(letter, isNull);
      expect(state.status, WriteLetterSubmissionStatus.error);
      expect(state.failure?.message, '서버 오류가 발생했습니다.');
      expect(state.failure?.requestId, 'request-1');
      expect(state.canRetry, isTrue);
    },
  );

  test(
    'submit prevents duplicate requests while a request is running',
    () async {
      final repository = _FakeLetterRepository()
        ..pendingResult = Completer<Result<Letter>>();
      final container = _container(repository);
      addTearDown(container.dispose);

      final firstSubmit = container
          .read(writeLetterControllerProvider.notifier)
          .submit('Hello Jolly');
      final secondSubmit = container
          .read(writeLetterControllerProvider.notifier)
          .submit('Hello Jolly again');

      expect(repository.createCalls, 1);
      expect(await secondSubmit, isNull);

      repository.pendingResult!.complete(Success(_letter(id: 2)));
      expect((await firstSubmit)?.id, 2);
      expect(repository.submittedContents, ['Hello Jolly']);
    },
  );

  test('submit does not update state after provider dispose', () async {
    final repository = _FakeLetterRepository()
      ..pendingResult = Completer<Result<Letter>>();
    final container = _container(repository);

    final submitFuture = container
        .read(writeLetterControllerProvider.notifier)
        .submit('Hello Jolly');

    container.dispose();
    repository.pendingResult!.complete(Success(_letter(id: 3)));

    expect(await submitFuture, isNull);
    expect(repository.createCalls, 1);
  });

  test('rate limit failure pauses retry and resumes after backoff', () async {
    final repository = _FakeLetterRepository(
      nextResult: const Failure(
        '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
        statusCode: 429,
        code: 'COMMON_004',
      ),
    );
    final container = _container(
      repository,
      retryBackoff: const Duration(milliseconds: 5),
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      writeLetterControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container
        .read(writeLetterControllerProvider.notifier)
        .submit('Hello Jolly');

    expect(
      container.read(writeLetterControllerProvider).requireValue.canRetry,
      isFalse,
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      container.read(writeLetterControllerProvider).requireValue.canRetry,
      isTrue,
    );
  });
}

ProviderContainer _container(
  _FakeLetterRepository repository, {
  Duration retryBackoff = const Duration(minutes: 1),
}) {
  return ProviderContainer(
    overrides: [
      createLetterUseCaseProvider.overrideWith(
        (ref) => CreateLetterUseCase(repository),
      ),
      writeLetterRetryBackoffProvider.overrideWith((ref) => retryBackoff),
    ],
  );
}

Letter _letter({required int id}) {
  return Letter(
    id: id,
    content: 'Hello Jolly',
    date: DateTime(2026, 8, 30),
    createdAt: DateTime(2026, 8, 30, 12),
  );
}

class _FakeLetterRepository implements LetterRepository {
  final Result<Letter>? nextResult;
  final submittedContents = <String>[];
  Completer<Result<Letter>>? pendingResult;
  int createCalls = 0;

  _FakeLetterRepository({this.nextResult});

  @override
  Future<Result<Letter>> createLetter(String content) {
    createCalls++;
    submittedContents.add(content);

    final pending = pendingResult;
    if (pending != null) {
      return pending.future;
    }
    return Future.value(nextResult ?? Success(_letter(id: 1)));
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
