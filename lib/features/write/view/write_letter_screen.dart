import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_dialog.dart';
import '../../../core/widgets/jolly_toast.dart';

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final _contentController = TextEditingController();
  bool _showKoreanWarning = false;

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
    final hasKorean = RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ]').hasMatch(text);
    if (hasKorean != _showKoreanWarning) {
      setState(() => _showKoreanWarning = hasKorean);
    }
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty;

  void _showConfirmDialog() async {
    final confirmed = await JollyDialog.show(
      context,
      title: '편지 작성을 완료할까요?',
      subtitle: '작성 완료 후에는 수정이 불가능해요',
      image: Image.asset(
        'assets/images/img_popup_writefinish.png',
        height: 120,
        errorBuilder: (_, __, ___) => const SizedBox(height: 120),
      ),
      confirmText: '완료',
    );
    if (confirmed == true && mounted) {
      context.go('/write/complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      appBar: JollyAppBar(
        title: '편지 쓰기',
        onBack: () => context.pop(),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _showConfirmDialog : null,
            child: Text(
              '완료',
              style: AppTextTheme.body2Sb16.copyWith(
                color: _canSubmit ? AppColors.burgundy : AppColors.gray400,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // TO and DATE (fixed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'TO.',
                      style: AppTextTheme.detail3Md13.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jolly',
                      style: AppTextTheme.detail3Md13.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'DATE.',
                      style: AppTextTheme.detail3Md13.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formattedDate(),
                      style: AppTextTheme.detail3Md13.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.gray200),
          // Letter content
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTextTheme.body3Md16.copyWith(
                color: AppColors.gray900,
                height: 1.8,
              ),
              decoration: InputDecoration(
                hintText: 'Dear Jolly,\nWrite your letter in English...',
                hintStyle: AppTextTheme.body3Md16.copyWith(
                  color: AppColors.gray400,
                  height: 1.8,
                ),
                contentPadding: const EdgeInsets.all(24),
                border: InputBorder.none,
              ),
            ),
          ),
          // Korean warning toast
          if (_showKoreanWarning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: JollyToast(
                message: '영어로 작성해 주세요. 이 편지는 영어만 검토돼요!',
                icon: Image.asset(
                  'assets/images/img_exclamation.png',
                  width: 16,
                  height: 16,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 16),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }
}
