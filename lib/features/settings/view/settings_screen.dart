import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/legal_documents.dart';
import '../../../core/di/providers.dart';
import '../../../core/platform/open_legal_document.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_dialog.dart';
import '../../../core/widgets/jolly_loading_indicator.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../domain/entity/user.dart';
import '../../../domain/model/result.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  User? _user;
  bool _isLoading = true;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: JollyAppBar(
        title: '설정',
        onBack: () => context.pop(),
        backgroundColor: AppColors.white,
        showBottomBorder: true,
      ),
      body: _isLoading
          ? const Center(child: JollyLoadingIndicator())
          : Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _AccountInfoRow(
                        icon: Image.asset(
                          'assets/images/img_mini_letter.png',
                          width: 20,
                          height: 20,
                        ),
                        text: _user?.nickname ?? '닉네임 미등록',
                        buttonText: '변경하기',
                        onButtonTap: _isWorking
                            ? null
                            : () async {
                                await context.push('/settings/name');
                                if (mounted) {
                                  _loadUser();
                                }
                              },
                      ),
                      const SizedBox(height: 30),
                      _AccountInfoRow(
                        icon: _providerIcon(),
                        text: _accountText(),
                        buttonText: '로그아웃',
                        onButtonTap: _isWorking
                            ? null
                            : () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 8, color: AppColors.gray100),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _SettingsMenuItem(
                        label: '공지사항',
                        onTap: () {},
                        showMore: true,
                      ),
                      const SizedBox(height: 40),
                      _SettingsMenuItem(
                        label: '개인정보처리방침',
                        onTap: () => openLegalDocument(
                          context,
                          LegalDocument.privacyPolicy,
                        ),
                        showMore: true,
                      ),
                      const SizedBox(height: 40),
                      _SettingsMenuItem(
                        label: '회원탈퇴',
                        onTap: _isWorking
                            ? null
                            : () => _showDeleteAccountDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
                Text(
                  '현재 버전 1.0.0 (MVP)',
                  style: AppTextTheme.detail3Md13.copyWith(
                    color: AppColors.gray300,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _loadUser() async {
    final result = await ref.read(getUserUseCaseProvider).execute();
    if (!mounted) return;

    switch (result) {
      case Success(data: final user):
        setState(() {
          _user = user;
          _isLoading = false;
        });
      case Failure(message: final message):
        setState(() => _isLoading = false);
        JollyToast.show(context, message: message);
    }
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await JollyDialog.show(
      context,
      title: '로그아웃 하시겠어요?',
      subtitle: '편지는 잘 보관해 둘게요. 언제든 다시 와요!',
      cancelText: '취소',
      confirmText: '로그아웃',
    );
    if (confirmed == true && context.mounted) {
      await _runAccountAction(
        action: () => ref.read(logoutUseCaseProvider).execute(),
        onSuccess: () => context.go('/login'),
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await JollyDialog.show(
      context,
      title: '서비스를 탈퇴하시겠어요?',
      subtitle: '탈퇴하면 모든 편지와 계정 정보가 함께 삭제되며\n다시 복구할 수 없어요.',
      cancelText: '취소',
      confirmText: '탈퇴하기',
      confirmColor: AppColors.red,
    );
    if (confirmed == true && context.mounted) {
      await _runAccountAction(
        action: () => ref.read(deleteAccountUseCaseProvider).execute(),
        onSuccess: () => context.go('/splash'),
      );
    }
  }

  Future<void> _runAccountAction({
    required Future<Result<void>> Function() action,
    required VoidCallback onSuccess,
  }) async {
    setState(() => _isWorking = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _isWorking = false);

    switch (result) {
      case Success():
        onSuccess();
      case Failure(message: final message):
        JollyToast.show(context, message: message);
    }
  }

  Widget _providerIcon() {
    final iconPath = _user?.loginProvider == LoginProvider.apple
        ? 'assets/icons/ic_apple.svg'
        : 'assets/icons/ic_kakao.svg';
    return SvgPicture.asset(iconPath, width: 20, height: 20);
  }

  String _accountText() {
    final email = _user?.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return _user?.loginProvider == LoginProvider.apple ? 'Apple 계정' : '카카오 계정';
  }
}

class _AccountInfoRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final String buttonText;
  final VoidCallback? onButtonTap;

  const _AccountInfoRow({
    required this.icon,
    required this.text,
    required this.buttonText,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextTheme.body3Md16.copyWith(color: AppColors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onButtonTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              buttonText,
              style: AppTextTheme.body9Md14.copyWith(color: AppColors.gray700),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool showMore;

  const _SettingsMenuItem({
    required this.label,
    this.onTap,
    this.showMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextTheme.body3Md16.copyWith(color: AppColors.black),
              ),
            ),
            if (showMore)
              SvgPicture.asset(
                'assets/icons/ic_more_lg.svg',
                width: 18,
                height: 18,
              ),
          ],
        ),
      ),
    );
  }
}
