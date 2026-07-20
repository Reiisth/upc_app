// lib/pages/pastor/pastor_home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'pastor_home_tab.dart';
import 'members_tab.dart';

class PastorHomePage extends StatefulWidget {
  const PastorHomePage({super.key});

  @override
  State<PastorHomePage> createState() => _PastorHomePageState();
}

class _PastorHomePageState extends State<PastorHomePage> {
  int _selectedIndex = 0;

  Future<void> _handleBack() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) =>
                    AppGradients.logotypeGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Text('UPC CONNECT', style: AppTextStyles.barText),
              ),
              const Text('Pastor Portal', style: AppTextStyles.bodyMuted),
            ],
          ),
          actions: [
            Image.asset('assets/images/upc-logo.png', height: 40),
            const SizedBox(width: 16),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            PastorHomeTab(),
            _PlaceholderTab(label: 'Attendance Analytics — coming soon'),
            MembersTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.primary,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
      width: double.infinity,
      height: double.infinity,
      child: Center(child: Text(label, style: AppTextStyles.bodyMuted)),
    );
  }
}