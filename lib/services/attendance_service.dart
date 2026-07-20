// lib/services/attendance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';
import '../models/service_model.dart';
import 'service_service.dart';

class AttendanceService {
  final _firestore = FirebaseFirestore.instance;
  final _serviceService = ServiceService();

  /// Records attendance for [memberId] against whichever service is
  /// currently active, attributed to [usherId] (the ushers doc ID —
  /// NOT the shared auth uid). Throws if no service is active.
  Future<void> recordAttendance({
    required String memberId,
    required String usherId,
  }) async {
    final ServiceModel? active = await _serviceService.getActiveService();
    if (active == null) {
      throw Exception('No active service. Scanning is closed.');
    }

    await _firestore.collection('attendance').add({
      'memberId': memberId,
      'serviceId': active.id,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'scannedBy': usherId,
    });
  }

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

  Future<List<AttendanceRecord>> fetchForService(String serviceId) async {
    final snapshot =
        await _firestore.collection('attendance').where('serviceId', isEqualTo: serviceId).get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromDoc(doc.id, doc.data()))
        .toList();
  }

  /// Count of attendance records scanned by [usherId] for [serviceId].
  Future<int> countScannedByUsher({
    required String serviceId,
    required String usherId,
  }) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('serviceId', isEqualTo: serviceId)
        .where('scannedBy', isEqualTo: usherId)
        .get();
    return snapshot.docs.length;
  }


  /// Total attendance records for [serviceId], regardless of usher.
  Future<int> countTotalForService(String serviceId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('serviceId', isEqualTo: serviceId)
        .get();
    return snapshot.docs.length;
  }
}