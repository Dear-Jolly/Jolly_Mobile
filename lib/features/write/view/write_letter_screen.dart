import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_dialog.dart';
import '../../../core/widgets/jolly_letter_header.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/letter/create_letter_usecase.dart';

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final _contentController = TextEditingController();
  bool _showEnglishWarning = false;
  bool _canSubmit = false;
  bool _isSubmitting = false;

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
        characterCount <= 500;
    if (hasUnsupportedCharacter != _showEnglishWarning ||
        canSubmit != _canSubmit) {
      setState(() {
        _showEnglishWarning = hasUnsupportedCharacter;
        _canSubmit = canSubmit;
      });
    }
  }

  void _showConfirmDialog() async {
    final confirmed = await JollyDialog.show(
      context,
      title: '편지 작성을 완료할까요?',
      subtitle: '작성 완료 후에는 수정이 불가능해요',
      image: Image.asset(
        'assets/images/img_popup_writefinish.png',
        height: 120,
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox(height: 120),
      ),
      confirmText: '완료',
    );
    if (confirmed == true && mounted) {
      _submitLetter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      appBar: JollyAppBar(onBack: () => context.pop()),
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            top: false,
            child: Column(
              children: [
                JollyLetterHeader(to: 'Jolly', date: _formattedDate()),
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
                          maxLength: 500,
                          maxLines: null,
                          expands: true,
                          buildCounter:
                              (
                                BuildContext context, {
                                required int currentLength,
                                required bool isFocused,
                                required int? maxLength,
                              }) => const SizedBox.shrink(),
                          textAlignVertical: TextAlignVertical.top,
                          style: AppTextTheme.body3Md16.copyWith(
                            color: AppColors.gray900,
                            height: 1.8,
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_contentController.text.characters.length}/500',
                          style: AppTextTheme.detail3Md13.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_showEnglishWarning)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: JollyButton(
                    text: _isSubmitting ? '전달 중' : '전달하기',
                    enabled: _canSubmit && !_isSubmitting,
                    onPressed: _showConfirmDialog,
                  ),
                ),
                const SizedBox(height: 29),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLetter() async {
    setState(() => _isSubmitting = true);

    final result = await locator<CreateLetterUseCase>().execute(
      _contentController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        context.go('/write/complete');
      case Failure(message: final message):
        JollyToast.show(context, message: message);
    }
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  bool _hasUnsupportedCharacter(String text) {
    for (final rune in text.runes) {
      if (_isAllowedAscii(rune) || _isEmojiRune(rune)) {
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

  bool _isEmojiRune(int rune) {
    return rune == 0x200D ||
        rune == 0x20E3 ||
        rune == 0xFE0F ||
        (rune >= 0x2600 && rune <= 0x27BF) ||
        (rune >= 0x1F000 && rune <= 0x1FAFF);
  }
}
