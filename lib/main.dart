import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const App());
}
