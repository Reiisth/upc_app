// lib/pages/member/profile_selection_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/member_profile.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../login_page.dart';
import 'member_home_page.dart';

class ProfileSelectionPage extends StatefulWidget {
  final String uid;
  const ProfileSelectionPage({super.key, required this.uid});

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  final _memberService = MemberService();
  late Future<List<MemberProfile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _memberService.fetchProfilesForUser(widget.uid);
  }

  Future<void> _handleBack() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _selectProfile(MemberProfile profile) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MemberHomePage(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _handleBack,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Who's using this account?",
                  style: AppTextStyles.heading1),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<MemberProfile>>(
                future: _profilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final profiles = snapshot.data ?? [];
                  if (profiles.isEmpty) {
                    return const Center(child: Text('No profiles found for this account.'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return GestureDetector(
                        onTap: () => _selectProfile(profile),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                              backgroundImage: profile.photoUrl.isNotEmpty
                                  ? NetworkImage(profile.photoUrl)
                                  : null,
                              child: profile.photoUrl.isEmpty
                                  ? Text(profile.name.isNotEmpty ? profile.name[0] : '?',
                                      style: AppTextStyles.heading1)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(profile.name, style: AppTextStyles.bodyMuted),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}