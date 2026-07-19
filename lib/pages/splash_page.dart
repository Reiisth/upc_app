import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    //_goToLogin();
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/upc-logo.png'),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 4),
            const Text(
              'Church Management Made Simple',
              style: AppTextStyles.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}
