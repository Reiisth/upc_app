// lib/pages/member/member_home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/member_profile.dart';
import '../../services/member_status_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/member_qr_dialog.dart';
import 'attendance_history_page.dart';

class MemberHomePage extends StatefulWidget {
  final MemberProfile profile;
  const MemberHomePage({super.key, required this.profile});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  final _memberStatusService = MemberStatusService();
  late Future<MemberStatusInfo> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _memberStatusService.computeStatus(widget.profile.id);
  }

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final birthdateText = profile.birthdate != null
        ? DateFormat('MMMM dd, yyyy').format(profile.birthdate!)
        : '—';
    final memberSinceText =
        profile.memberSince != null ? DateFormat('yyyy').format(profile.memberSince!) : '—';

    return Scaffold(
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
            const Text('Member Portal', style: AppTextStyles.bodyMuted),
          ],
        ),
        actions: [
          Image.asset('assets/images/upc-logo.png', height: 40),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WELCOME BACK!', style: AppTextStyles.greetingsub),
                const SizedBox(height: 4),
                Text('Blessed day, ${profile.firstName}!',
                    style: AppTextStyles.herogreeting),
                const SizedBox(height: 20),

                // Profile card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                  ),
                  child: FutureBuilder<MemberStatusInfo>(
                    future: _statusFuture,
                    builder: (context, snapshot) {
                      final isLoading = snapshot.connectionState == ConnectionState.waiting;
                      final statusInfo = snapshot.data;
                      final isActive = statusInfo?.status != MemberStatus.inactive;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text('UPC MEMBER PROFILE', style: AppTextStyles.heading2),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                backgroundImage: profile.photoUrl.isNotEmpty
                                    ? NetworkImage(profile.photoUrl)
                                    : null,
                                child: profile.photoUrl.isEmpty
                                    ? Text(
                                        profile.fullName.isNotEmpty ? profile.fullName[0] : '?',
                                        style: AppTextStyles.heading1,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(profile.fullName, style: AppTextStyles.bodyh1),
                                    const SizedBox(height: 4),
                                    if (isLoading)
                                      const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isActive ? Colors.green : Colors.grey)
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle,
                                                size: 8,
                                                color: isActive ? Colors.green : Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              isActive ? 'Active Member' : 'Inactive Member',
                                              style: TextStyle(
                                                color: isActive ? Colors.green : Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text('Member since $memberSinceText',
                                        style: AppTextStyles.bodyMuted),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(label: 'Birthday', value: birthdateText),
                          if (profile.age != null)
                            _InfoRow(label: 'Age', value: '${profile.age}'),
                          if (profile.civilStatus.isNotEmpty)
                            _InfoRow(label: 'Civil Status', value: profile.civilStatus),
                          if (profile.address.isNotEmpty)
                            _InfoRow(label: 'Address', value: profile.address),
                          if (profile.ministry != null) ...[
                            const Divider(height: 24),
                            _InfoRow(label: 'Ministry', value: profile.ministry!),
                          ],
                          const Divider(height: 24),
                          _InfoRow(
                            label: 'Last Service Attended',
                            value: isLoading
                                ? 'Loading...'
                                : (statusInfo?.lastAttendedService != null
                                    ? '${statusInfo!.lastAttendedService!.name} (${DateFormat('MMM dd, yyyy').format(statusInfo.lastAttendedService!.startedAt)})'
                                    : 'No record yet'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.qr_code,
                        label: 'View QR Code',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => MemberQrDialog(profile: profile),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.history,
                        label: 'Attendance History',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AttendanceHistoryPage(memberId: profile.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Logout', style: AppTextStyles.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}