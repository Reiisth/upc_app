// lib/pages/member/member_home_page.dart
import 'package:flutter/material.dart';
import '../../models/member_profile.dart';

class MemberHomePage extends StatelessWidget {
  final MemberProfile profile;
  const MemberHomePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Welcome, ${profile.name}')),
    );
  }
}