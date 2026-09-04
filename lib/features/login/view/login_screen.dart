import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/api_config.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/intro_pattern_background.dart';
import '../../../core/widgets/intro_splash_logo.dart';
import '../../../core/widgets/jolly_loading_indicator.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../core/widgets/social_login_button.dart';
import '../../../domain/entity/user.dart';
import '../../../domain/model/result.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  SocialLoginType? _loadingType;

  static const _figmaFrameHeight = IntroSplashLogo.referenceFrameHeight;
  static const _buttonHeight = 52.0;
  static const _kakaoButtonTopIos = 633.0;
  static const _appleButtonTopIos = 697.0;
  static const _kakaoButtonTopAos = 697.0;
  static const _horizontalPadding = 24.0;

  bool get _isLoading => _loadingType != null;

  @override
  void initState() {
    super.initState();
    _listenForAuthCallback();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              const Positioned.fill(child: IntroPatternBackground()),
              const Positioned.fill(child: IntroSplashLogo()),
              Positioned(
                left: _horizontalPadding,
                right: _horizontalPadding,
                top: _buttonTop(
                  constraints,
                  Platform.isIOS ? _kakaoButtonTopIos : _kakaoButtonTopAos,
                ),
                child: SocialLoginButton(
                  type: SocialLoginType.kakao,
                  onPressed: _isLoading
                      ? null
                      : () => _startSocialLogin(SocialLoginType.kakao),
                ),
              ),
              if (Platform.isIOS)
                Positioned(
                  left: _horizontalPadding,
                  right: _horizontalPadding,
                  top: _buttonTop(constraints, _appleButtonTopIos),
                  child: SocialLoginButton(
                    type: SocialLoginType.apple,
                    onPressed: _isLoading
                        ? null
                        : () => _startSocialLogin(SocialLoginType.apple),
                  ),
                ),
              if (_isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(child: JollyLoadingIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _buttonTop(BoxConstraints constraints, double figmaTop) {
    final screenHeight = constraints.maxHeight;
    final maxTop = math.max(0.0, screenHeight - _buttonHeight - 29);
    return (screenHeight * figmaTop / _figmaFrameHeight)
        .clamp(0.0, maxTop)
        .toDouble();
  }

  Future<void> _listenForAuthCallback() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleAuthCallback(initialLink);
      }
    } catch (_) {
      // Plugin channels are unavailable in widget tests and some desktop runs.
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleAuthCallback,
      onError: (_) {
        if (!mounted) return;
        JollyToast.show(context, message: '로그인 연결에 실패했습니다.');
      },
    );
  }

  Future<void> _startSocialLogin(SocialLoginType type) async {
    setState(() => _loadingType = type);

    final provider = type == SocialLoginType.apple
        ? LoginProvider.apple
        : LoginProvider.kakao;
    final loginUri = ref.read(loginUseCaseProvider).authorizationUri(provider);
    bool launched;
    try {
      launched = await launchUrl(
        loginUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;

    setState(() => _loadingType = null);

    if (!launched) {
      JollyToast.show(context, message: '로그인 페이지를 열 수 없습니다.');
    }
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    if (!_isAuthCallback(uri)) return;

    if (mounted) {
      setState(() => _loadingType = SocialLoginType.kakao);
    }

    final result = await ref
        .read(loginUseCaseProvider)
        .completeWithCallback(uri);
    if (!mounted) return;

    switch (result) {
      case Success(data: final session):
        if (!session.termsAgreed) {
          context.go('/onboarding/terms');
        } else if (!session.nicknameRegistered) {
          context.go('/onboarding/nickname');
        } else {
          context.go('/home');
        }
      case Failure(message: final message):
        setState(() => _loadingType = null);
        JollyToast.show(context, message: message);
    }
  }

  bool _isAuthCallback(Uri uri) {
    if (uri.scheme != ApiConfig.authCallbackScheme) {
      return false;
    }

    final params = uri.queryParameters;
    return params.containsKey('accessToken') &&
        params.containsKey('refreshToken');
  }
}
