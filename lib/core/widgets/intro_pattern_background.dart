import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroPatternBackground extends StatelessWidget {
  const IntroPatternBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: SvgPicture.asset(
          'assets/images/bg_intro_line.svg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
