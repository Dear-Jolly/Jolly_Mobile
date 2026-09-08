import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_dialog.dart';
import '../../../core/widgets/jolly_letter_header.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../state/write_letter_controller.dart';

class WriteLetterScreen extends ConsumerStatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  ConsumerState<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends ConsumerState<WriteLetterScreen> {
  static const _maxContentLength = 500;

  final _contentController = TextEditingController();
  bool _showEnglishWarning = false;
  bool _canSubmit = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_checkContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _checkContent() {
    final text = _contentController.text;
    final characterCount = text.characters.length;
    final hasUnsupportedCharacter = _hasUnsupportedCharacter(text);
    final canSubmit =
        text.trim().isNotEmpty &&
        !hasUnsupportedCharacter &&
        characterCount <= _maxContentLength;
    if (hasUnsupportedCharacter != _showEnglishWarning ||
        canSubmit != _canSubmit ||
        characterCount != _characterCount) {
      setState(() {
        _characterCount = characterCount;
        _showEnglishWarning = hasUnsupportedCharacter;
        _canSubmit = canSubmit;
      });
    }

    final submission = ref.read(writeLetterControllerProvider).value;
    if (submission?.hasError == true && submission?.isRetryPaused == false) {
      ref.read(writeLetterControllerProvider.notifier).clearFailure();
    }
  }

  void _showConfirmDialog() async {
    final submission =
        ref.read(writeLetterControllerProvider).value ??
        const WriteLetterSubmissionState.idle();
    if (!_canSubmit || submission.isSubmitting || submission.isRetryPaused) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final confirmed = await JollyDialog.show(
      context,
      title: '편지 작성을 완료할까요?',
      subtitle: '전달된 편지는 다시 고칠 수 없어요.',
      image: Image.asset(
        'assets/images/img_popup_writefinish.png',
        width: 140,
        height: 118,
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox(width: 140, height: 118),
      ),
      cancelText: '계속 쓰기',
      confirmText: '전달하기',
    );
    if (confirmed == true && mounted) {
      _submitLetter();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<WriteLetterSubmissionState>>(
      writeLetterControllerProvider,
      (previous, next) {
        final previousFailure = previous?.value?.failure;
        final currentFailure = next.value?.failure;
        if (currentFailure != null && currentFailure != previousFailure) {
          JollyToast.show(context, message: currentFailure.message);
        }
      },
    );

    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final submission =
        ref.watch(writeLetterControllerProvider).value ??
        const WriteLetterSubmissionState.idle();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.ivory100,
      appBar: JollyAppBar(onBack: () => context.pop()),
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        if (keyboardVisible)
                          const SizedBox(height: 20)
                        else
                          JollyLetterHeader(
                            to: 'Jolly',
                            date: _formattedDate(),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Container(
                                height: 362,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextField(
                                  controller: _contentController,
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  smartDashesType: SmartDashesType.disabled,
                                  smartQuotesType: SmartQuotesType.disabled,
                                  hintLocales: const [Locale('en')],
                                  maxLength: _maxContentLength,
                                  maxLines: null,
                                  expands: true,
                                  buildCounter:
                                      (
                                        BuildContext context, {
                                        required int currentLength,
                                        required bool isFocused,
                                        required int? maxLength,
                                      }) => null,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: AppTextTheme.body3Md16.copyWith(
                                    color: AppColors.gray900,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Please write your letter.',
                                    hintStyle: AppTextTheme.body3Md16.copyWith(
                                      color: AppColors.gray400,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (!keyboardVisible) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _buildCharacterCount(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (keyboardVisible)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.burgundy,
                          ),
                          child: const Text('키보드 닫기'),
                        ),
                        const Spacer(),
                        _buildCharacterCount(),
                      ],
                    ),
                  ),
                _SubmitSection(
                  showEnglishWarning: _showEnglishWarning,
                  canSubmit: _canSubmit,
                  submission: submission,
                  onSubmit: _showConfirmDialog,
                  showSubmitButton: !keyboardVisible,
                ),
                SizedBox(height: keyboardVisible ? 8 : 29),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCount() => Text(
    '$_characterCount/$_maxContentLength',
    style: AppTextTheme.detail3Md13.copyWith(color: AppColors.gray400),
  );

  Future<void> _submitLetter() async {
    final result = await ref
        .read(writeLetterControllerProvider.notifier)
        .submit(_contentController.text);

    if (!mounted || result == null) {
      return;
    }

    final submittedAt = result.createdAt ?? DateTime.now();
    context.go(
      Uri(
        path: '/write/complete',
        queryParameters: {
          'letterId': result.id.toString(),
          'submittedAt': submittedAt.toIso8601String(),
        },
      ).toString(),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  bool _hasUnsupportedCharacter(String text) {
    for (final rune in text.runes) {
      if (_isAllowedAscii(rune)) {
        continue;
      }
      return true;
    }
    return false;
  }

  bool _isAllowedAscii(int rune) {
    return rune == 0x09 ||
        rune == 0x0A ||
        rune == 0x0D ||
        (rune >= 0x20 && rune <= 0x7E);
  }
}

class _SubmitSection extends StatelessWidget {
  final bool showEnglishWarning;
  final bool canSubmit;
  final WriteLetterSubmissionState submission;
  final VoidCallback onSubmit;
  final bool showSubmitButton;

  const _SubmitSection({
    required this.showEnglishWarning,
    required this.canSubmit,
    required this.submission,
    required this.onSubmit,
    required this.showSubmitButton,
  });

  bool get _buttonEnabled =>
      canSubmit && !submission.isSubmitting && !submission.isRetryPaused;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showEnglishWarning)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: JollyToast(
              message: '영어로 작성해 주세요. 이 편지는 영어만 검토돼요!',
              icon: Image.asset(
                'assets/images/img_exclamation.png',
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(width: 16),
              ),
            ),
          ),
        if (submission.hasError) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _SubmitFailureBanner(
              failure: submission.failure!,
              retryEnabled: canSubmit && submission.canRetry,
              onRetry: onSubmit,
            ),
          ),
        ],
        if (showSubmitButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: JollyButton(
              text: '전달하기',
              enabled: _buttonEnabled,
              onPressed: onSubmit,
            ),
          ),
      ],
    );
  }
}

class _SubmitFailureBanner extends StatelessWidget {
  final WriteLetterSubmissionFailure failure;
  final bool retryEnabled;
  final VoidCallback onRetry;

  const _SubmitFailureBanner({
    required this.failure,
    required this.retryEnabled,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final requestId = failure.requestId;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  failure.message,
                  style: AppTextTheme.detail3Md13.copyWith(
                    color: AppColors.white,
                  ),
                ),
                if (requestId != null && requestId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '요청 ID $requestId',
                    style: AppTextTheme.detail3Md13.copyWith(
                      color: AppColors.gray300,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: retryEnabled ? onRetry : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              disabledForegroundColor: AppColors.gray500,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              retryEnabled ? '다시 시도' : '대기 중',
              style: AppTextTheme.detail3Md13,
            ),
          ),
        ],
      ),
    );
  }
}
