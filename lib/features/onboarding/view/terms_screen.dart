import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_checkbox.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _allAgreed = false;
  bool _termsAgreed = false;
  bool _privacyAgreed = false;

  bool get _canProceed => _termsAgreed && _privacyAgreed;

  void _toggleAll() {
    setState(() {
      _allAgreed = !_allAgreed;
      _termsAgreed = _allAgreed;
      _privacyAgreed = _allAgreed;
    });
  }

  void _toggleTerms() {
    setState(() {
      _termsAgreed = !_termsAgreed;
      _allAgreed = _termsAgreed && _privacyAgreed;
    });
  }

  void _togglePrivacy() {
    setState(() {
      _privacyAgreed = !_privacyAgreed;
      _allAgreed = _termsAgreed && _privacyAgreed;
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
                '서비스 이용을 위해\n약관에 동의해주세요',
                style: AppTextTheme.head1B22.copyWith(color: AppColors.gray900),
              ),
              const SizedBox(height: 30),
              // All agree
              JollyCheckbox(
                label: '전체 동의',
                isChecked: _allAgreed,
                onTap: _toggleAll,
                isAllAgree: true,
              ),
              const SizedBox(height: 16),
              // Terms of service
              JollyCheckbox(
                label: '서비스 이용약관 (필수)',
                isChecked: _termsAgreed,
                onTap: _toggleTerms,
                trailing: SvgPicture.asset(
                  'assets/icons/ic_more_sm.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Privacy policy
              JollyCheckbox(
                label: '개인정보 수집 및 이용 동의 (필수)',
                isChecked: _privacyAgreed,
                onTap: _togglePrivacy,
                trailing: SvgPicture.asset(
                  'assets/icons/ic_more_sm.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const Spacer(),
              // Next button
              JollyButton(
                text: '다음',
                enabled: _canProceed,
                onPressed: () => context.go('/onboarding/nickname'),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }

}
