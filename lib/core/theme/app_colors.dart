import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ivory
  static const Color ivory100 = Color(0xFFFBF9F4);
  static const Color ivory200 = Color(0xFFF5EDE0);

  // Gray Scale
  static const Color black = Color(0xFF010101);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F4);
  static const Color gray200 = Color(0xFFE9E9E9);
  static const Color gray300 = Color(0xFFD9D9D9);
  static const Color gray400 = Color(0xFFC4C4C4);
  static const Color gray500 = Color(0xFF9D9D9D);
  static const Color gray600 = Color(0xFF7B7B7B);
  static const Color gray700 = Color(0xFF555555);
  static const Color gray800 = Color(0xFF434343);
  static const Color gray900 = Color(0xFF262626);

  // Burgundy
  static const Color burgundy = Color(0xFF7F011F);

  // Red
  static const Color red = Color(0xFFFF1B1B);

  // Green
  static const Color green100 = Color(0xFFCCF1E4);
  static const Color green200 = Color(0xFF007D58);

  // Kakao
  static const Color kakaoYellow = Color(0xFFFAE100);
  static const Color kakaoBrown = Color(0xFF3C1E1E);

  // Apple
  static const Color appleBlack = Color(0xFF111111);

  // Transparency
  static const Color black70 = Color(0xB3000000);

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF010101),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFBF9F4),
    onPrimaryContainer: Color(0xFF262626),
    secondary: Color(0xFF7B7B7B),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF5EDE0),
    onSecondaryContainer: Color(0xFF555555),
    error: Color(0xFFFF1B1B),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEDED),
    onErrorContainer: Color(0xFFFF1B1B),
    surface: Color(0xFFFBF9F4),
    onSurface: Color(0xFF262626),
    outline: Color(0xFFD9D9D9),
    shadow: Color(0xFF000000),
  );
}
