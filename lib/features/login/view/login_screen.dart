import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../core/widgets/social_login_button.dart';
import '../../../domain/entity/user.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/auth/login_usecase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginUseCase = locator<LoginUseCase>();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  SocialLoginType? _loadingType;

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
      body: Stack(
        children: [
          const CheckPattern(),
          Positioned(
            left: 38,
            top: 140,
            child: Image.asset(
              'assets/images/img_splash_logo.png',
              width: 277,
              height: 369,
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: Platform.isIOS ? 95 : 31,
            child: SocialLoginButton(
              type: SocialLoginType.kakao,
              onPressed: _isLoading
                  ? null
                  : () => _startSocialLogin(SocialLoginType.kakao),
            ),
          ),
          if (Platform.isIOS)
            Positioned(
              left: 24,
              right: 24,
              bottom: 31,
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
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
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
    final loginUri = _loginUseCase.authorizationUri(provider);
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

    final result = await _loginUseCase.completeWithCallback(uri);
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
    final params = uri.queryParameters;
    return params.containsKey('accessToken') &&
        params.containsKey('refreshToken');
  }
}
