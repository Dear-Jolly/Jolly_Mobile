import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/intro_pattern_background.dart';
import '../../../core/widgets/intro_splash_logo.dart';
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
                    child: Center(child: CircularProgressIndicator()),
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

  // 로그인 창을 앱 안에서 띄운다. Safari 앱으로 나갔다가 커스텀 스킴으로 돌아오는 방식은
  // 사용자가 앱으로 되돌아오지 못하면 그대로 막히기 때문에, 인증이 끝나면 스스로 닫히고
  // 콜백 URL 을 그대로 돌려주는 시스템 인증 세션(iOS ASWebAuthenticationSession)을 쓴다.
  Future<void> _startSocialLogin(SocialLoginType type) async {
    setState(() => _loadingType = type);

    final provider = type == SocialLoginType.apple
        ? LoginProvider.apple
        : LoginProvider.kakao;
    final loginUri = _loginUseCase.authorizationUri(provider);

    String? callbackUrl;
    try {
      callbackUrl = await FlutterWebAuth2.authenticate(
        url: loginUri.toString(),
        callbackUrlScheme: ApiConfig.authCallbackScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: false),
      );
    } on PlatformException {
      // 사용자가 인증 창을 직접 닫은 경우다. 오류로 알리지 않는다.
      if (!mounted) return;
      setState(() => _loadingType = null);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingType = null);
      JollyToast.show(context, message: '로그인 페이지를 열 수 없습니다.');
      return;
    }

    if (!mounted) return;

    final callbackUri = Uri.tryParse(callbackUrl);
    if (callbackUri == null || !_isAuthCallback(callbackUri)) {
      setState(() => _loadingType = null);
      JollyToast.show(context, message: '로그인 정보를 받지 못했습니다.');
      return;
    }

    await _handleAuthCallback(callbackUri);
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
    if (uri.scheme != ApiConfig.authCallbackScheme) {
      return false;
    }

    final params = uri.queryParameters;
    return params.containsKey('accessToken') &&
        params.containsKey('refreshToken');
  }
}
