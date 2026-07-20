// lib/pages/pastor/widgets/member_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/member_profile.dart';
import '../../../services/member_status_service.dart';
import '../../../theme/app_theme.dart';

class MemberDetailDialog extends StatefulWidget {
  final MemberProfile profile;
  const MemberDetailDialog({super.key, required this.profile});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  final _memberStatusService = MemberStatusService();
  late Future<MemberStatusInfo> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _memberStatusService.computeStatus(widget.profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final birthdateText = profile.birthdate != null
        ? DateFormat('MMMM dd, yyyy').format(profile.birthdate!)
        : '—';
    final memberSinceText =
        profile.memberSince != null ? DateFormat('yyyy').format(profile.memberSince!) : '—';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      const Center(
                        child: Text('UPC MEMBER PROFILE', style: AppTextStyles.heading2),
                      ),
                      Positioned(
                        right: -8,
                        top: -8,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isActive ? Colors.green : Colors.grey)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 8, color: isActive ? Colors.green : Colors.grey),
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
                            Text('Member since $memberSinceText', style: AppTextStyles.bodyMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Member ID', value: profile.id),
                  _InfoRow(label: 'Birthday', value: birthdateText),
                  if (profile.age != null) _InfoRow(label: 'Age', value: '${profile.age}'),
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
            );
          },
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