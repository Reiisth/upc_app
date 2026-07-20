// lib/pages/member/widgets/member_qr_dialog.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/member_profile.dart';
import '../../../theme/app_theme.dart';

class MemberQrDialog extends StatelessWidget {
  final MemberProfile profile;
  const MemberQrDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'UPC MEMBER QR',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.primary), 
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(profile.fullName, style: AppTextStyles.bodyh1.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            QrImageView(
              data: profile.id,
              size: 220,
              backgroundColor: AppColors.white,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Member ID: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                  TextSpan(
                    text: '#${profile.id}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}