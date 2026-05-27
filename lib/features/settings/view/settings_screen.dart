import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/jolly_app_bar.dart';
import '../../../core/widgets/jolly_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      appBar: JollyAppBar(
        title: '설정',
        onBack: () => context.pop(),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Profile section
          _buildSection(
            title: '프로필',
            children: [
              _buildSettingItem(
                label: '이름 변경',
                onTap: () => context.push('/settings/name'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Account section
          _buildSection(
            title: '계정',
            children: [
              _buildSettingItem(
                label: '로그인 정보',
                trailing: Text(
                  '카카오',
                  style: AppTextTheme.body9Md14.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
              _buildSettingItem(
                label: '로그아웃',
                onTap: () => _showLogoutDialog(context),
              ),
              _buildSettingItem(
                label: '회원 탈퇴',
                onTap: () => _showDeleteAccountDialog(context),
                textColor: AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // App info section
          _buildSection(
            title: '앱 정보',
            children: [
              _buildSettingItem(
                label: '버전',
                trailing: Text(
                  '1.0.0',
                  style: AppTextTheme.body9Md14.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
              _buildSettingItem(
                label: '이용약관',
                onTap: () {},
              ),
              _buildSettingItem(
                label: '개인정보 처리방침',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            title,
            style: AppTextTheme.detail6Md12.copyWith(color: AppColors.gray500),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem({
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextTheme.body3Md16.copyWith(
                color: textColor ?? AppColors.gray900,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await JollyDialog.show(
      context,
      title: '로그아웃 하시겠어요?',
      confirmText: '로그아웃',
    );
    if (confirmed == true && context.mounted) {
      context.go('/login');
    }
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await JollyDialog.show(
      context,
      title: '정말 탈퇴하시겠어요?',
      subtitle: '탈퇴 시 모든 데이터가 삭제되며\n복구할 수 없습니다.',
      confirmText: '탈퇴하기',
      confirmColor: AppColors.red,
    );
    if (confirmed == true && context.mounted) {
      // TODO: Delete account API call
      context.go('/login');
    }
  }
}
