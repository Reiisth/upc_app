// lib/models/attendance_record.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String memberId;
  final String serviceId;
  final DateTime timestamp;

  AttendanceRecord({
    required this.id,
    required this.memberId,
    required this.serviceId,
    required this.timestamp,
  });

  factory AttendanceRecord.fromDoc(String id, Map<String, dynamic> data) {
    return AttendanceRecord(
      id: id,
      memberId: data['memberId'] as String? ?? '',
      serviceId: data['serviceId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}