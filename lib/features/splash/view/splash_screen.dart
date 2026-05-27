import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../view_model/splash_view_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<SplashViewModel>().initialize();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'D',
                    style: TextStyle(
                      fontFamily: 'LastChristmas',
                      fontSize: 53,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'ear',
                    style: TextStyle(
                      fontFamily: 'Selino',
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                  ),
                  TextSpan(
                    text: 'J',
                    style: TextStyle(
                      fontFamily: 'LastChristmas',
                      fontSize: 55,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'olly',
                    style: TextStyle(
                      fontFamily: 'Selino',
                      fontSize: 41,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'MADE Mirage',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.2,
                  color: AppColors.black,
                ),
                children: [
                  TextSpan(text: 'W'),
                  TextSpan(
                    text: 'rite to Jolly,',
                    style: TextStyle(
                      fontFamily: 'MADE Mirage',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'MADE Mirage',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.2,
                  color: AppColors.black,
                ),
                children: [
                  TextSpan(text: 'F'),
                  TextSpan(
                    text: 'eel  jolly',
                    style: TextStyle(
                      fontFamily: 'MADE Mirage',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
