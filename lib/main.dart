import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UpcConnectApp());
}

class UpcConnectApp extends StatelessWidget {
  const UpcConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPC Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
