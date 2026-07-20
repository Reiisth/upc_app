// lib/pages/member/attendance_history_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_record.dart';
import '../../models/service_model.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_theme.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String memberId;
  const AttendanceHistoryPage({super.key, required this.memberId});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final _attendanceService = AttendanceService();
  late Future<List<MapEntry<AttendanceRecord, ServiceModel?>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistoryWithServices();
  }

  Future<List<MapEntry<AttendanceRecord, ServiceModel?>>> _loadHistoryWithServices() async {
    final records = await _attendanceService.fetchHistory(widget.memberId);
    final results = <MapEntry<AttendanceRecord, ServiceModel?>>[];

    for (final record in records) {
      final doc = await FirebaseFirestore.instance
          .collection('services')
          .doc(record.serviceId)
          .get();
      final service = doc.exists ? ServiceModel.fromDoc(doc.id, doc.data()!) : null;
      results.add(MapEntry(record, service));
    }

    return results;
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
            ShaderMask(
              shaderCallback: (Rect bounds) =>
                  AppGradients.logotypeGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: const Text('UPC CONNECT', style: AppTextStyles.barText),
            ),
            const Text('Attendance History', style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<List<MapEntry<AttendanceRecord, ServiceModel?>>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final entries = snapshot.data ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        Text('${entries.length}', style: AppTextStyles.heading1),
                        const SizedBox(height: 4),
                        const Text('Services Attended', style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(
                          child: Text('No attendance records yet.', style: AppTextStyles.bodyMuted),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final service = entries[index].value;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppShadows.card,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service?.name ?? 'Unknown Service',
                                          style: AppTextStyles.bodyh1,
                                        ),
                                        if (service != null)
                                          Text(
                                            DateFormat('MMMM dd, yyyy').format(service.startedAt),
                                            style: AppTextStyles.bodyMuted,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}