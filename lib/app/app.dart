import 'package:flutter/material.dart';

import 'routes.dart';
import '../core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
