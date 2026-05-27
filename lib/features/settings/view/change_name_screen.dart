import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/nickname_validator.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_text_field.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
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
      appBar: JollyAppBar(
        title: '이름 변경',
        onBack: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              '변경할 닉네임을\n입력해주세요',
              style: AppTextTheme.head4Sb20.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: 24),
            JollyTextField(
              controller: _controller,
              hintText: '닉네임을 입력해주세요',
              errorText: _errorText,
              helperText: '공백,특수기호,한글 없이 작성해주세요',
            ),
            const Spacer(),
            JollyButton(
              text: '완료',
              enabled: _isValid,
              onPressed: () {
                // TODO: Save name API call
                context.pop();
              },
            ),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }
}
