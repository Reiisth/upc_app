// lib/pages/pastor/present_members_page.dart
import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';
import '../../models/member_profile.dart';
import '../../models/service_model.dart';
import '../../services/attendance_service.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';

class PresentMembersPage extends StatefulWidget {
  final ServiceModel service;
  const PresentMembersPage({super.key, required this.service});

  @override
  State<PresentMembersPage> createState() => _PresentMembersPageState();
}

class _PresentMembersPageState extends State<PresentMembersPage> {
  final _attendanceService = AttendanceService();
  final _memberService = MemberService();
  late Future<List<MemberProfile>> _presentMembersFuture;

  @override
  void initState() {
    super.initState();
    _presentMembersFuture = _loadPresentMembers();
  }

  Future<List<MemberProfile>> _loadPresentMembers() async {
    final records = await _attendanceService.fetchForService(widget.service.id);
    final profiles = <MemberProfile>[];
    for (final AttendanceRecord record in records) {
      final profile = await _memberService.fetchById(record.memberId);
      if (profile != null) profiles.add(profile);
    }
    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Present Members', style: AppTextStyles.heading2),
            Text(widget.service.name, style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<List<MemberProfile>>(
          future: _presentMembersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final members = snapshot.data ?? [];
            if (members.isEmpty) {
              return const Center(
                child: Text('No members recorded present yet.', style: AppTextStyles.bodyMuted),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = members[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage:
                            member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
                        child: member.photoUrl.isEmpty
                            ? Text(member.fullName.isNotEmpty ? member.fullName[0] : '?')
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(member.fullName, style: AppTextStyles.bodyh1),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}