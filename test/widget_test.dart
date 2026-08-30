import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jolly_mobile/app/app.dart';
import 'package:jolly_mobile/core/di/locator.dart';
import 'package:jolly_mobile/core/storage/secure_storage.dart';
import 'package:jolly_mobile/domain/entity/version_status.dart';
import 'package:jolly_mobile/domain/model/result.dart';
import 'package:jolly_mobile/domain/repository/version_repository.dart';
import 'package:jolly_mobile/domain/usecase/version/check_version_usecase.dart';

void main() {
  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues({});
    if (!locator.isRegistered<SecureStorage>()) {
      setupLocator();
    }
    if (locator.isRegistered<CheckVersionUseCase>()) {
      await locator.unregister<CheckVersionUseCase>();
    }
    locator.registerFactory(
      () => CheckVersionUseCase(_FakeVersionRepository()),
    );
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}

class _FakeVersionRepository implements VersionRepository {
  @override
  Future<Result<VersionStatus>> checkVersion() async {
    return const Success(
      VersionStatus(minSupportedVersion: '1.0.0', forceUpdate: false),
    );
  }
}
