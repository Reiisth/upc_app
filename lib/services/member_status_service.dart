// lib/services/member_status_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

enum MemberStatus { active, inactive }

class MemberStatusInfo {
  final MemberStatus status;
  final ServiceModel? lastAttendedService;
  final int missedServiceCount;

  MemberStatusInfo({
    required this.status,
    this.lastAttendedService,
    required this.missedServiceCount,
  });
}

class MemberStatusService {
  final _firestore = FirebaseFirestore.instance;
  static const int _inactivityThreshold = 4;

  Future<MemberStatusInfo> computeStatus(String memberId) async {
    // Find the member's most recent attendance record.
    final attendanceSnap = await _firestore
        .collection('attendance')
        .where('memberId', isEqualTo: memberId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    ServiceModel? lastService;
    if (attendanceSnap.docs.isNotEmpty) {
      final serviceId = attendanceSnap.docs.first.data()['serviceId'] as String?;
      if (serviceId != null) {
        final doc = await _firestore.collection('services').doc(serviceId).get();
        if (doc.exists) {
          lastService = ServiceModel.fromDoc(doc.id, doc.data()!);
        }
      }
    }

    // All services that have already ended.
    final endedSnap =
        await _firestore.collection('services').where('status', isEqualTo: 'ended').get();
    final endedServices =
        endedSnap.docs.map((d) => ServiceModel.fromDoc(d.id, d.data())).toList();

    // Count ended services after the member's last attendance.
    // If they've never attended, every ended service counts as missed.
    final missedCount = lastService == null
        ? endedServices.length
        : endedServices.where((s) => s.startedAt.isAfter(lastService!.startedAt)).length;

    return MemberStatusInfo(
      status: missedCount > _inactivityThreshold ? MemberStatus.inactive : MemberStatus.active,
      lastAttendedService: lastService,
      missedServiceCount: missedCount,
    );
  }
}