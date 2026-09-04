import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_toast.dart';

class ForceUpdateScreen extends ConsumerStatefulWidget {
  const ForceUpdateScreen({super.key});

  @override
  ConsumerState<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends ConsumerState<ForceUpdateScreen> {
  bool _isOpeningStore = false;

  Uri? get _storeUri => ref.read(appInfoProvider).storeUri;

  @override
  Widget build(BuildContext context) {
    final hasStoreUrl = _storeUri != null;

    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/img_splash_logo.png',
                    width: 190,
                    height: 253,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 34),
                  Text(
                    '업데이트가 필요해요',
                    textAlign: TextAlign.center,
                    style: AppTextTheme.head1B22.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '안정적인 사용을 위해\n최신 버전으로 업데이트해주세요.',
                    textAlign: TextAlign.center,
                    style: AppTextTheme.body6Md15.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const Spacer(),
                  JollyButton(
                    text: hasStoreUrl
                        ? (_isOpeningStore ? '이동 중' : '업데이트하기')
                        : '다시 확인',
                    enabled: !_isOpeningStore,
                    onPressed: hasStoreUrl
                        ? _openStore
                        : () => context.go('/splash'),
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

  Future<void> _openStore() async {
    final storeUri = _storeUri;
    if (storeUri == null) {
      context.go('/splash');
      return;
    }

    setState(() => _isOpeningStore = true);
    final launched = await launchUrl(
      storeUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;
    setState(() => _isOpeningStore = false);

    if (!launched) {
      JollyToast.show(context, message: '스토어를 열 수 없습니다.');
    }
  }
}
