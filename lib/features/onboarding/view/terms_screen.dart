import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/external_link.dart';
import '../../../core/widgets/intro_pattern_background.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_checkbox.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/auth/agree_terms_usecase.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _allAgreed = false;
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _marketingAgreed = false;
  bool _isSubmitting = false;

  bool get _canProceed => _termsAgreed && _privacyAgreed;

  void _toggleAll() {
    setState(() {
      _allAgreed = !_allAgreed;
      _termsAgreed = _allAgreed;
      _privacyAgreed = _allAgreed;
      _marketingAgreed = _allAgreed;
    });
  }

  void _toggleTerms() {
    setState(() {
      _termsAgreed = !_termsAgreed;
      _allAgreed = _termsAgreed && _privacyAgreed && _marketingAgreed;
    });
  }

  void _togglePrivacy() {
    setState(() {
      _privacyAgreed = !_privacyAgreed;
      _allAgreed = _termsAgreed && _privacyAgreed && _marketingAgreed;
    });
  }

  void _toggleMarketing() {
    setState(() {
      _marketingAgreed = !_marketingAgreed;
      _allAgreed = _termsAgreed && _privacyAgreed && _marketingAgreed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: Stack(
        children: [
          const Positioned.fill(child: IntroPatternBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '서비스 이용을 위해\n약관에 동의해주세요',
                      style: AppTextTheme.head1B22.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  JollyCheckbox(
                    label: '전체 동의',
                    isChecked: _allAgreed,
                    onTap: _toggleAll,
                    isAllAgree: true,
                  ),
                  const SizedBox(height: 24),
                  JollyCheckbox(
                    label: '[필수] 서비스 이용약관 동의',
                    isChecked: _termsAgreed,
                    onTap: _toggleTerms,
                    onView: () => ExternalLink.open(
                      context,
                      ApiConfig.termsOfServiceUri,
                      failureMessage: '이용약관을 열 수 없습니다.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  JollyCheckbox(
                    label: '[필수] 개인정보 처리방침 동의',
                    isChecked: _privacyAgreed,
                    onTap: _togglePrivacy,
                    onView: () => ExternalLink.open(
                      context,
                      ApiConfig.privacyPolicyUri,
                      failureMessage: '개인정보처리방침을 열 수 없습니다.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  JollyCheckbox(
                    label: '[선택] 마케팅 정보 수신 동의',
                    isChecked: _marketingAgreed,
                    onTap: _toggleMarketing,
                    onView: ApiConfig.marketingConsentUri == null
                        ? null
                        : () => ExternalLink.open(
                            context,
                            ApiConfig.marketingConsentUri,
                            failureMessage: '안내를 열 수 없습니다.',
                          ),
                  ),
                  const Spacer(),
                  JollyButton(
                    text: '다음',
                    enabled: _canProceed && !_isSubmitting,
                    onPressed: _submitTerms,
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

  Future<void> _submitTerms() async {
    setState(() => _isSubmitting = true);

    final result = await locator<AgreeTermsUseCase>().execute(
      serviceAgreed: _termsAgreed,
      privacyAgreed: _privacyAgreed,
      marketingAgreed: _marketingAgreed,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        context.go('/onboarding/nickname');
      case Failure(message: final message):
        JollyToast.show(context, message: message);
    }
  }
}
