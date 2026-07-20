// lib/services/attendance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/attendance_record.dart';
import '../models/service_model.dart';
import 'service_service.dart';

class AttendanceService {
  final _firestore = FirebaseFirestore.instance;
  final _serviceService = ServiceService();

  /// Records attendance for [memberId] against whichever service is
  /// currently active. Throws if no service is active (i.e. ended or
  /// never started) — this is what blocks scans after a service ends.
  Future<void> recordAttendance(String memberId) async {
    final ServiceModel? active = await _serviceService.getActiveService();
    if (active == null) {
      throw Exception('No active service. Scanning is closed.');
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    await _firestore.collection('attendance').add({
      'memberId': memberId,
      'serviceId': active.id,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'scannedBy': uid,
    });
  }

  /// A member's full attendance history, most recent first.
  Future<List<AttendanceRecord>> fetchHistory(String memberId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('memberId', isEqualTo: memberId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromDoc(doc.id, doc.data()))
        .toList();
  }

  /// All attendance records for a given service (for pastor's "present members" view).
  Future<List<AttendanceRecord>> fetchForService(String serviceId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('serviceId', isEqualTo: serviceId)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<int> countScannedByUserForService(String serviceId, String uid) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('serviceId', isEqualTo: serviceId)
        .where('scannedBy', isEqualTo: uid)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> countForService(String serviceId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('serviceId', isEqualTo: serviceId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}