import 'dart:math' as math;

import 'package:flutter/material.dart';

class IntroSplashLogo extends StatelessWidget {
  const IntroSplashLogo({super.key});

  static const referenceFrameWidth = 360.0;
  static const referenceFrameHeight = 780.0;
  static const referenceLogoWidth = 277.0;
  static const referenceLogoHeight = 369.0;
  static const referenceLogoLeft = 38.0;
  static const referenceLogoTop = 140.0;

  static const _logoCenterY = referenceLogoTop + referenceLogoHeight / 2;
  static const _logoCenterOffsetX =
      referenceLogoLeft + referenceLogoWidth / 2 - referenceFrameWidth / 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final scale = math.min(1.0, screenWidth / referenceFrameWidth);
        final logoWidth = referenceLogoWidth * scale;
        final logoHeight = referenceLogoHeight * scale;
        final left = (screenWidth - logoWidth) / 2 + _logoCenterOffsetX * scale;
        final rawTop =
            screenHeight * (_logoCenterY / referenceFrameHeight) -
            logoHeight / 2;
        final top = rawTop
            .clamp(0.0, math.max(0.0, screenHeight - logoHeight))
            .toDouble();

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Image.asset(
                'assets/images/img_splash_logo.png',
                width: logoWidth,
                height: logoHeight,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );
  }
}
