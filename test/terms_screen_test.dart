import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jolly_mobile/core/widgets/jolly_checkbox.dart';
import 'package:jolly_mobile/features/onboarding/view/terms_screen.dart';

Set<String> _checkboxAssets(WidgetTester tester) {
  return tester
      .widgetList<SvgPicture>(find.byType(SvgPicture))
      .map((svg) => svg.bytesLoader)
      .whereType<SvgAssetLoader>()
      .map((loader) => loader.assetName)
      .where((name) => name.contains('ic_checkbox'))
      .toSet();
}

void main() {
  testWidgets('약관 동의 화면은 모든 항목이 해제된 상태로 시작한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TermsScreen()));
    await tester.pump();

    final assets = _checkboxAssets(tester);

    expect(
      assets.contains('assets/icons/ic_checkbox_selected.svg'),
      isFalse,
      reason: '처음 진입 시 선택된 체크박스가 있으면 사용자가 읽지 않은 약관에 동의한 것이 된다',
    );
    expect(assets, contains('assets/icons/ic_checkbox.svg'));
  });

  testWidgets('필수 약관에는 원문을 여는 보기 링크가 있다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TermsScreen()));
    await tester.pump();

    final requiredItems = tester
        .widgetList<JollyCheckbox>(find.byType(JollyCheckbox))
        .where((box) => box.label.startsWith('[필수]'));

    expect(requiredItems, hasLength(2));
    for (final item in requiredItems) {
      expect(item.onView, isNotNull, reason: '${item.label} 에 약관 열람 경로가 없다');
    }
  });

  testWidgets('전체 동의를 누르면 하위 항목이 모두 선택된다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TermsScreen()));
    await tester.pump();

    await tester.tap(find.text('전체 동의'));
    await tester.pump();

    final boxes = tester.widgetList<JollyCheckbox>(find.byType(JollyCheckbox));
    expect(boxes.every((box) => box.isChecked), isTrue);
  });
}
