// lib/pages/usher/usher_home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../models/usher_profile.dart';
import '../../services/attendance_service.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';
import 'qr_scanner_page.dart';

class UsherHomePage extends StatefulWidget {
  final UsherProfile profile;
  const UsherHomePage({super.key, required this.profile});

  @override
  State<UsherHomePage> createState() => _UsherHomePageState();
}

class _UsherHomePageState extends State<UsherHomePage> {
  final _serviceService = ServiceService();
  final _attendanceService = AttendanceService();

  late Future<_UsherHomeData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_UsherHomeData> _loadData() async {
    final active = await _serviceService.getActiveService();
    if (active == null) {
      return _UsherHomeData(activeService: null, scannedByMe: 0, totalForService: 0);
    }
    final scannedByMe = await _attendanceService.countScannedByUsher(
      serviceId: active.id,
      usherId: widget.profile.id,
    );
    final total = await _attendanceService.countTotalForService(active.id);
    return _UsherHomeData(activeService: active, scannedByMe: scannedByMe, totalForService: total);
  }

  void _refresh() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

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
            const Text('Usher Portal', style: AppTextStyles.bodyMuted),
          ],
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WELCOME BACK!', style: AppTextStyles.greetingsub),
                const SizedBox(height: 4),
                Text('Blessed day, ${widget.profile.name}!',
                    style: AppTextStyles.herogreeting),
                const SizedBox(height: 20),

                FutureBuilder<_UsherHomeData>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    final isLoading = snapshot.connectionState == ConnectionState.waiting;
                    final data = snapshot.data;
                    final isActive = data?.activeService != null;

                    return Column(
                      children: [
                        // Date + status card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.primary, size: 28),
                              const SizedBox(height: 8),
                              Text(DateFormat('EEEE, dd MMMM yyyy').format(today),
                                  style: AppTextStyles.bodyh1),
                              const SizedBox(height: 8),
                              if (isLoading)
                                const SizedBox(
                                  height: 16,
                                  width: 16,
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
                                        isActive ? 'Service On-going' : 'No Active Service',
                                        style: TextStyle(
                                          color: isActive ? Colors.green : Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Two count cards
                        Row(
                          children: [
                            Expanded(
                              child: _CountCard(
                                label: 'Scanned by Me',
                                value: isLoading ? '—' : '${data?.scannedByMe ?? 0}',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _CountCard(
                                label: 'Total Attendees',
                                value: isLoading ? '—' : '${data?.totalForService ?? 0}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Record Attendance
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isActive
                                ? () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => QrScannerPage(usherId: widget.profile.id),
                                    ),
                                  );
                                  _refresh(); 
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                            label: Text('Record Attendance',
                                style: AppTextStyles.button.copyWith(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Add Member (placeholder — built later)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: build member registration flow
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Member'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _handleLogout,
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

class _UsherHomeData {
  final ServiceModel? activeService;
  final int scannedByMe;
  final int totalForService;

  _UsherHomeData({
    required this.activeService,
    required this.scannedByMe,
    required this.totalForService,
  });
}

class _CountCard extends StatelessWidget {
  final String label;
  final String value;
  const _CountCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading1),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}