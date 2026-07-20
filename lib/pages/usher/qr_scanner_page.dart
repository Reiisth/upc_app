// lib/pages/usher/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/member_profile.dart';
import '../../services/attendance_service.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import 'package:collection/collection.dart';

class QrScannerPage extends StatefulWidget {
  final String usherId;
  const QrScannerPage({super.key, required this.usherId});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _ScanResult {
  final MemberProfile member;
  final bool success;
  final String? errorMessage;
  final DateTime scannedAt;

  _ScanResult({
    required this.member,
    required this.success,
    this.errorMessage,
    required this.scannedAt,
  });
}

class _QrScannerPageState extends State<QrScannerPage> {
  final _controller = MobileScannerController();
  final _memberService = MemberService();
  final _attendanceService = AttendanceService();

  bool _isProcessing = false;
  final List<_ScanResult> _recentScans = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    try {
      final member = await _memberService.fetchById(code);
      if (member == null) {
        _showSnack('Unrecognized QR code. No matching member found.');
        _recordFailedScan(code);
        return;
      }

      if (!mounted) return;
      final confirmed = await _showConfirmationSheet(member);

      if (confirmed == true) {
        try {
          await _attendanceService.recordAttendance(
            memberId: member.id,
            usherId: widget.usherId,
          );
          setState(() {
            _recentScans.insert(
              0,
              _ScanResult(member: member, success: true, scannedAt: DateTime.now()),
            );
          });
          _showSnack('${member.fullName} marked present.');
        } catch (e) {
          setState(() {
            _recentScans.insert(
              0,
              _ScanResult(
                member: member,
                success: false,
                errorMessage: e.toString().replaceFirst('Exception: ', ''),
                scannedAt: DateTime.now(),
              ),
            );
          });
          _showSnack(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        await _controller.start();
      }
    }
  }

  void _recordFailedScan(String code) {
    // No matching member — nothing to add to history since we have no profile to show.
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool?> _showConfirmationSheet(MemberProfile member) {
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundImage:
                  member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
              child: member.photoUrl.isEmpty
                  ? Text(member.fullName.isNotEmpty ? member.fullName[0] : '?',
                      style: AppTextStyles.heading1)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(member.fullName, style: AppTextStyles.bodyh1),
            if (member.ministry != null)
              Text(member.ministry!, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder()),
                    child: const Text('Confirm Attendance',
                        style: TextStyle(color: Colors.white,),
                        textAlign: TextAlign.center,),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Member QR', style: AppTextStyles.bodyh1,),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _handleDetection,
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Scans', style: AppTextStyles.bodyh1),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _recentScans.isEmpty
                        ? const Center(
                            child: Text('No scans yet this session.',
                                style: AppTextStyles.bodyMuted),
                          )
                        : ListView.separated(
                            itemCount: _recentScans.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final scan = _recentScans[index];
                              return Row(
                                children: [
                                  Icon(
                                    scan.success ? Icons.check_circle : Icons.error,
                                    color: scan.success ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(scan.member.fullName,
                                            style: AppTextStyles.bodyh2),
                                        if (!scan.success && scan.errorMessage != null)
                                          Text(scan.errorMessage!,
                                              style: const TextStyle(
                                                  color: Colors.red, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${scan.scannedAt.hour.toString().padLeft(2, '0')}:${scan.scannedAt.minute.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}