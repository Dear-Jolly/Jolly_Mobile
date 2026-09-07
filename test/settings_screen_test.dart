import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jolly_mobile/core/config/support_links.dart';
import 'package:jolly_mobile/core/di/providers.dart';
import 'package:jolly_mobile/core/platform/app_info.dart';
import 'package:jolly_mobile/domain/entity/user.dart';
import 'package:jolly_mobile/domain/model/result.dart';
import 'package:jolly_mobile/domain/usecase/auth/get_user_usecase.dart';
import 'package:jolly_mobile/features/settings/view/settings_screen.dart';

class _GetUser implements GetUserUseCase {
  @override
  Future<Result<User>> execute() async =>
      const Success(User(nickname: '테스트', loginProvider: LoginProvider.kakao));
}

class _AppInfo extends AppInfo {
  @override
  Future<String> get appVersion async => '1.0.0';
}

void main() {
  testWidgets('small settings screen opens the public inquiry form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final openedUrls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'launch') {
            openedUrls.add(call.arguments['url'] as String);
          }
          return true;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getUserUseCaseProvider.overrideWith((ref) => _GetUser()),
          appInfoProvider.overrideWith((ref) => _AppInfo()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('문의하기'));
    await tester.tap(find.text('문의하기'));
    await tester.pumpAndSettle();
    expect(openedUrls, [SupportLinks.inquiryForm]);
    await tester.ensureVisible(find.text('현재 버전 1.0.0'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
