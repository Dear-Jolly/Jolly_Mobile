import 'package:flutter_test/flutter_test.dart';

import 'package:jolly_mobile/app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
