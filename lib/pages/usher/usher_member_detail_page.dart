// lib/pages/usher/usher_member_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member_profile.dart';
import '../../services/member_service.dart';
import '../../services/member_status_service.dart';
import '../../theme/app_theme.dart';

class UsherMemberDetailPage extends StatefulWidget {
  final MemberProfile profile;
  const UsherMemberDetailPage({super.key, required this.profile});

  @override
  State<UsherMemberDetailPage> createState() => _UsherMemberDetailPageState();
}

class _UsherMemberDetailPageState extends State<UsherMemberDetailPage> {
  final _memberStatusService = MemberStatusService();
  final _memberService = MemberService();
  late Future<MemberStatusInfo> _statusFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _statusFuture = _memberStatusService.computeStatus(widget.profile.id);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member', style: AppTextStyles.bodyh1,),
        content: Text(
          'Are you sure you want to delete ${widget.profile.fullName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await _memberService.deleteMember(widget.profile.id);
      if (!mounted) return;
      Navigator.of(context).pop(true); // tells the caller a member was deleted
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
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
        title: const Text('Member Profile', style: AppTextStyles.bodyh1),
        actions: [
          Image.asset('assets/images/upc-logo.png', height: 40),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<MemberStatusInfo>(
              future: _statusFuture,
              builder: (context, snapshot) {
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                final statusInfo = snapshot.data;
                final isActive = statusInfo?.status != MemberStatus.inactive;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
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
                          _InfoRow(label: 'Member ID', value: profile.id),
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isDeleting ? null : _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.delete_outline),
                        label: const Text('Delete Member'),
                      ),
                    ),
                  ],
                );
              },
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
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}