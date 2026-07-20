import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/member_profile.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
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

  Future<void> _signOutAndPop() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _selectProfile(MemberProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberHomePage(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:(didPop, result) async {
        if (didPop) return;
        await _signOutAndPop(); 
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppGradients.logotypeGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Text(
                  'UPC CONNECT',
                  style: AppTextStyles.barText,
                  textAlign: TextAlign.center,
                ),
              ),
              const Text("MEMBER PORTAL", style: AppTextStyles.bodyMuted),
              const SizedBox(height: 4),
            ],
          ),
          actions: [
            Image.asset('assets/images/upc-logo.png', height: 40),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.bgGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("SELECT MEMBER PROFILE",
                      style: AppTextStyles.heading1, 
                      textAlign: TextAlign.center,),
                ),
                const SizedBox(height: 16),
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
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 152,
                        ),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return GestureDetector(
                            onTap: () => _selectProfile(profile),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppShadows.card,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: AppColors.darkBlue.withValues(alpha: 1),
                                    backgroundImage: profile.photoUrl.isNotEmpty
                                        ? NetworkImage(profile.photoUrl)
                                        : null,
                                    child: profile.photoUrl.isEmpty
                                        ? Text(profile.name.isNotEmpty ? profile.name[0] : '?',
                                            style: AppTextStyles.heading1.copyWith(color:Colors.white))
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    profile.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ],
                              ),
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
        ),
      ),
    );
  }
}