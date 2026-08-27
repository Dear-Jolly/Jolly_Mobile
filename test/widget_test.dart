import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jolly_mobile/app/app.dart';
import 'package:jolly_mobile/core/di/locator.dart';
import 'package:jolly_mobile/core/storage/secure_storage.dart';

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    if (!locator.isRegistered<SecureStorage>()) {
      setupLocator();
    }
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
