import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entity/letter.dart';
import '../../../domain/model/result.dart';

final writeLetterRetryBackoffProvider = Provider<Duration>((ref) {
  return const Duration(minutes: 1);
});

final writeLetterControllerProvider =
    AsyncNotifierProvider.autoDispose<
      WriteLetterController,
      WriteLetterSubmissionState
    >(WriteLetterController.new);

class WriteLetterController extends AsyncNotifier<WriteLetterSubmissionState> {
  Timer? _retryResumeTimer;
  bool _isDisposed = false;

  @override
  FutureOr<WriteLetterSubmissionState> build() {
    ref.onDispose(() {
      _isDisposed = true;
      _retryResumeTimer?.cancel();
    });
    return const WriteLetterSubmissionState.idle();
  }

  Future<Letter?> submit(String content) async {
    final current = state.value ?? const WriteLetterSubmissionState.idle();
    if (current.isSubmitting || current.isRetryPaused) {
      return null;
    }

    state = const AsyncData(WriteLetterSubmissionState.submitting());

    final result = await ref.read(createLetterUseCaseProvider).execute(content);
    if (_isDisposed) {
      return null;
    }

    switch (result) {
      case Success(data: final letter):
        _retryResumeTimer?.cancel();
        state = AsyncData(WriteLetterSubmissionState.success(letter));
        return letter;
      case Failure(
        message: final message,
        statusCode: final statusCode,
        code: final code,
        requestId: final requestId,
      ):
        final failure = WriteLetterSubmissionFailure(
          message: message,
          statusCode: statusCode,
          code: code,
          requestId: requestId,
        );
        final retryPausedUntil = failure.isRateLimited
            ? _scheduleRetryResume()
            : null;
        state = AsyncData(
          WriteLetterSubmissionState.error(
            failure,
            retryPausedUntil: retryPausedUntil,
          ),
        );
        return null;
    }
  }

  void clearFailure() {
    final current = state.value;
    if (current == null || !current.hasError || current.isRetryPaused) {
      return;
    }

    state = const AsyncData(WriteLetterSubmissionState.idle());
  }

  DateTime _scheduleRetryResume() {
    final backoff = ref.read(writeLetterRetryBackoffProvider);
    final retryPausedUntil = DateTime.now().add(backoff);
    _retryResumeTimer?.cancel();
    _retryResumeTimer = Timer(backoff, () {
      if (_isDisposed) {
        return;
      }

      final current = state.value;
      if (current == null ||
          current.retryPausedUntil == null ||
          current.retryPausedUntil != retryPausedUntil) {
        return;
      }

      state = AsyncData(current.withoutRetryPause());
    });
    return retryPausedUntil;
  }
}

enum WriteLetterSubmissionStatus { idle, submitting, success, error }

class WriteLetterSubmissionState {
  final WriteLetterSubmissionStatus status;
  final Letter? letter;
  final WriteLetterSubmissionFailure? failure;
  final DateTime? retryPausedUntil;

  const WriteLetterSubmissionState._({
    required this.status,
    this.letter,
    this.failure,
    this.retryPausedUntil,
  });

  const WriteLetterSubmissionState.idle()
    : this._(status: WriteLetterSubmissionStatus.idle);

  const WriteLetterSubmissionState.submitting()
    : this._(status: WriteLetterSubmissionStatus.submitting);

  const WriteLetterSubmissionState.success(Letter letter)
    : this._(status: WriteLetterSubmissionStatus.success, letter: letter);

  const WriteLetterSubmissionState.error(
    WriteLetterSubmissionFailure failure, {
    DateTime? retryPausedUntil,
  }) : this._(
         status: WriteLetterSubmissionStatus.error,
         failure: failure,
         retryPausedUntil: retryPausedUntil,
       );

  bool get isIdle => status == WriteLetterSubmissionStatus.idle;
  bool get isSubmitting => status == WriteLetterSubmissionStatus.submitting;
  bool get isSuccess => status == WriteLetterSubmissionStatus.success;
  bool get hasError => status == WriteLetterSubmissionStatus.error;
  bool get canRetry => hasError && !isRetryPaused;

  bool get isRetryPaused {
    final pausedUntil = retryPausedUntil;
    return pausedUntil != null && DateTime.now().isBefore(pausedUntil);
  }

  WriteLetterSubmissionState withoutRetryPause() {
    final currentFailure = failure;
    if (currentFailure == null) {
      return const WriteLetterSubmissionState.idle();
    }
    return WriteLetterSubmissionState.error(currentFailure);
  }
}

class WriteLetterSubmissionFailure {
  final String message;
  final int? statusCode;
  final String? code;
  final String? requestId;

  const WriteLetterSubmissionFailure({
    required this.message,
    this.statusCode,
    this.code,
    this.requestId,
  });

  bool get isRateLimited => statusCode == 429 || code == 'COMMON_004';
}
