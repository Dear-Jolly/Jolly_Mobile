import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jolly_mobile/core/config/legal_documents.dart';
import 'package:jolly_mobile/core/widgets/jolly_button.dart';
import 'package:jolly_mobile/core/widgets/jolly_checkbox.dart';
import 'package:jolly_mobile/features/onboarding/view/terms_screen.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final calls = <MethodCall>[];
  var failLaunch = false;

  setUp(() {
    calls.clear();
    failLaunch = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (failLaunch) throw PlatformException(code: 'unavailable');
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> showTerms(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TermsScreen())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reading each document does not grant consent', (tester) async {
    await showTerms(tester);
    final labels = [
      '[필수] 서비스 이용약관 동의',
      '[필수] 개인정보 수집·이용 동의',
      '[선택] 마케팅 정보 수신 동의',
    ];
    for (var i = 0; i < labels.length; i++) {
      await tester.tap(find.text(labels[i]));
      await tester.pumpAndSettle();
      expect(calls.last.arguments['url'], LegalDocument.values[i].url);
      expect(
        tester
            .widgetList<JollyCheckbox>(find.byType(JollyCheckbox))
            .every((checkbox) => !checkbox.isChecked),
        isTrue,
      );
    }
    expect(
      tester.widget<JollyButton>(find.byType(JollyButton)).enabled,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screens can scroll to Next without overflow', (
    tester,
  ) async {
    await showTerms(tester);
    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(JollyButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('다음').hitTestable(), findsOneWidget);
  });

  testWidgets('required checkboxes enable Next without marketing', (
    tester,
  ) async {
    await showTerms(tester);
    for (final index in [1, 2]) {
      final row = find.byType(JollyCheckbox).at(index);
      final checkbox = find
          .descendant(of: row, matching: find.byType(InkWell))
          .last;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
    }
    final items = tester
        .widgetList<JollyCheckbox>(find.byType(JollyCheckbox))
        .toList();
    expect(items[1].isChecked, isTrue);
    expect(items[2].isChecked, isTrue);
    expect(items[3].isChecked, isFalse);
    expect(
      tester.widget<JollyButton>(find.byType(JollyButton)).enabled,
      isTrue,
    );
    expect(calls, isEmpty);
  });

  testWidgets('launch failure falls back and shows a recoverable message', (
    tester,
  ) async {
    await showTerms(tester);
    failLaunch = true;
    await tester.tap(find.text('[필수] 서비스 이용약관 동의'));
    await tester.pumpAndSettle();
    expect(calls.length, 2);
    expect(find.text('문서를 열 수 없어요. 잠시 후 다시 시도해주세요.'), findsOneWidget);
    expect(
      tester.widget<JollyButton>(find.byType(JollyButton)).enabled,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
