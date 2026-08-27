import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/nickname_validator.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_text_field.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/auth/update_nickname_usecase.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _isValid = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    final text = _controller.text;
    setState(() {
      _errorText = NicknameValidator.validate(text);
      _isValid = NicknameValidator.isValid(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: JollyAppBar(
        onBack: () => context.pop(),
        backgroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '변경할 이름을 입력해주세요',
              style: AppTextTheme.head4Sb20.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: 28),
            JollyTextField(
              controller: _controller,
              hintText: '이름을 입력해주세요',
              errorText: _errorText,
              helperText: '공백,특수기호,한글 없이 작성해주세요',
              counterText: '${_controller.text.length}/20',
              maxLength: 20,
            ),
            const SizedBox(height: 207),
            JollyButton(
              text: _isSubmitting ? '처리 중' : '변경하기',
              enabled: _isValid && !_isSubmitting,
              onPressed: _submitNickname,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitNickname() async {
    setState(() => _isSubmitting = true);

    final result = await locator<UpdateNicknameUseCase>().execute(
      _controller.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        JollyToast.show(context, message: '닉네임을 변경했습니다.');
        context.pop();
      case Failure(message: final message):
        JollyToast.show(context, message: message);
    }
  }
}
