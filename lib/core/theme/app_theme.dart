import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTextTheme.textTheme,
    scaffoldBackgroundColor: AppColors.ivory100,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.ivory100,
      foregroundColor: AppColors.gray900,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
