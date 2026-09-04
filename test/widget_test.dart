import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jolly_mobile/app/app.dart';
import 'package:jolly_mobile/core/di/providers.dart';
import 'package:jolly_mobile/domain/entity/version_status.dart';
import 'package:jolly_mobile/domain/model/result.dart';
import 'package:jolly_mobile/domain/repository/version_repository.dart';
import 'package:jolly_mobile/domain/usecase/version/check_version_usecase.dart';

void main() {
  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkVersionUseCaseProvider.overrideWith(
            (ref) => CheckVersionUseCase(_FakeVersionRepository()),
          ),
        ],
        child: const App(),
      ),
    );
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
