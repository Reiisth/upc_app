import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';
import 'dart:ui';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    // TODO: replace with real init logic (Firebase init, auth check, etc.)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.bgGradient,
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: 6,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.2),
                              BlendMode.srcIn,
                            ),
                            child: Image.asset('assets/images/upc-logo.png', width: 400, height: 400),
                          ),
                        ),
                      ),
                      Image.asset('assets/images/upc-logo.png', width: 400, height: 400),
                    ],
                  ),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return AppGradients.logotypeGradient.createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'UPC CONNECT',
                      style: AppTextStyles.herotitle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Church Management Made Simple',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
            const Text('© 2026 UPC Batangas. All rights reserved.', style: AppTextStyles.footer),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
