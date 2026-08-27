import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PageStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double dotSize;
  final double spacing;

  const PageStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.dotSize = 6,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index == totalSteps - 1 ? 0 : spacing,
          ),
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentStep
                  ? AppColors.burgundy
                  : AppColors.gray300,
            ),
          ),
        );
      }),
    );
  }
}
