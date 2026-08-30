import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/nickname_validator.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_text_field.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/auth/register_nickname_usecase.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
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
      backgroundColor: AppColors.ivory100,
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Jolly에게 당신의\n이름을 알려주세요',
                    style: AppTextTheme.head1B22.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 30),
                  JollyTextField(
                    controller: _controller,
                    hintText: '이름을 입력해주세요',
                    errorText: _errorText,
                    helperText: '공백,특수기호,한글 없이 작성해주세요',
                    counterText: '${_controller.text.length}/20',
                    maxLength: 20,
                  ),
                  const Spacer(),
                  JollyButton(
                    text: '다음',
                    enabled: _isValid && !_isSubmitting,
                    onPressed: _submitNickname,
                  ),
                  const SizedBox(height: 29),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitNickname() async {
    setState(() => _isSubmitting = true);

    final result = await locator<RegisterNicknameUseCase>().execute(
      _controller.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        context.go('/onboarding/welcome');
      case Failure(message: final message):
        JollyToast.show(context, message: message);
    }
  }
}
