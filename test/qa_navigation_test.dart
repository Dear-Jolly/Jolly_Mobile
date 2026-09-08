import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jolly_mobile/features/onboarding/view/welcome_screen.dart';
import 'package:jolly_mobile/features/write/view/write_complete_screen.dart';

void main() {
  testWidgets(
    'onboarding advances with next and opens home on a small screen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.view.reset);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: Text('Home')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jolly 만나러 가기'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'completion content clears the status bar and preserves submitted letter',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 780);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      final submittedAt = DateTime(2026, 9, 8, 10);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                WriteCompleteScreen(letterId: 42, submittedAt: submittedAt),
          ),
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: Text('Home')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('편지 작성 완료')).dy, 199);
      await tester.tap(find.text('홈 화면으로 이동'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.queryParameters['letterId'],
        '42',
      );
      expect(
        router
            .routeInformationProvider
            .value
            .uri
            .queryParameters['submittedAt'],
        submittedAt.toIso8601String(),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
