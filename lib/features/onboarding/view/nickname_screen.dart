import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/nickname_validator.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_text_field.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _isValid = false;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                '사용하실 닉네임을\n입력해주세요',
                style: AppTextTheme.head1B22.copyWith(color: AppColors.gray900),
              ),
              const SizedBox(height: 30),
              // Nickname input
              JollyTextField(
                controller: _controller,
                hintText: '닉네임을 입력해주세요',
                errorText: _errorText,
                helperText: '공백,특수기호,한글 없이 작성해주세요',
              ),
              const Spacer(),
              // Complete button
              JollyButton(
                text: '완료',
                enabled: _isValid,
                onPressed: () => context.go('/onboarding/welcome'),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}
