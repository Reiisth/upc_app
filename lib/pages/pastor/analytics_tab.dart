// lib/pages/pastor/analytics_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../services/attendance_service.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';

class _AnalyticsSummary {
  final int totalServices;
  final int recentAttendeeCount;
  final ServiceModel? recentService;

  _AnalyticsSummary({
    required this.totalServices,
    required this.recentAttendeeCount,
    required this.recentService,
  });
}

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  final _serviceService = ServiceService();
  final _attendanceService = AttendanceService();
  late Future<_AnalyticsSummary> _summaryFuture;

  // Decorative only — not derived from real data.
  static const _dummyWeeklyAttendance = [0.55, 0.7, 0.4, 0.85, 0.6, 0.9, 0.75];
  static const _dummyWeekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dummyAttendanceRate = 0.78;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<_AnalyticsSummary> _loadSummary() async {
    final services = await _serviceService.fetchAll();
    final recentService = services.isNotEmpty ? services.first : null;

    int recentAttendeeCount = 0;
    if (recentService != null) {
      final records = await _attendanceService.fetchForService(recentService.id);
      recentAttendeeCount = records.map((r) => r.memberId).toSet().length;
    }

    return _AnalyticsSummary(
      totalServices: services.length,
      recentAttendeeCount: recentAttendeeCount,
      recentService: recentService,
    );
  }

  Future<void> _refresh() async {
    setState(() => _summaryFuture = _loadSummary());
    await _summaryFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: FutureBuilder<_AnalyticsSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final summary = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('ATTENDANCE ANALYTICS', style: AppTextStyles.heading2, textAlign: TextAlign.center,),
                  const SizedBox(height: 16),

                  // Real stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.event_note,
                          label: 'Total Services',
                          value: '${summary.totalServices}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.groups,
                          label: 'Recent Attendees',
                          value: '${summary.recentAttendeeCount}',
                          sublabel: summary.recentService != null
                              ? summary.recentService!.name
                              : 'No services yet',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Decorative chart
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
                        const Text('Weekly Attendance', style: AppTextStyles.bodyh1),
                        const SizedBox(height: 2),
                        const Text('Sample overview',
                            style: AppTextStyles.bodyMuted),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_dummyWeeklyAttendance.length, (i) {
                              return _Bar(
                                heightFraction: _dummyWeeklyAttendance[i],
                                label: _dummyWeekdayLabels[i],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Decorative attendance-rate ring
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _dummyAttendanceRate,
                                strokeWidth: 8,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                              Text(
                                '${(_dummyAttendanceRate * 100).round()}%',
                                style: AppTextStyles.bodyh1.copyWith(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Avg. Attendance Rate', style: AppTextStyles.bodyh1),
                              SizedBox(height: 4),
                              Text(
                                'Sample metric',
                                style: AppTextStyles.bodyMuted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (summary.recentService != null)
                    Text(
                      'Last service: ${summary.recentService!.name} · '
                      '${DateFormat('MMM dd, yyyy').format(summary.recentService!.startedAt)}',
                      style: AppTextStyles.bodyMuted,
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodyMuted),
          if (sublabel != null) ...[
            const SizedBox(height: 2),
            Text(
              sublabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMuted.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double heightFraction; // 0.0 - 1.0
  final String label;
  const _Bar({required this.heightFraction, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 100 * heightFraction,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
      ],
    );
  }
}