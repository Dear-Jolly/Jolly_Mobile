import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class JollyLoadingIndicator extends StatelessWidget {
  static const assetPath = 'assets/animations/loading.json';

  final double width;
  final double height;

  const JollyLoadingIndicator({super.key, this.width = 72, this.height = 101});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(assetPath, repeat: true, fit: BoxFit.contain),
    );
  }
}
