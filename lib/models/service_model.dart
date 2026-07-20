// lib/models/service_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceStatus { active, ended }

class ServiceModel {
  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final ServiceStatus status;
  final String startedBy;

  ServiceModel({
    required this.id,
    required this.name,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.startedBy,
  });

  factory ServiceModel.fromDoc(String id, Map<String, dynamic> data) {
    return ServiceModel(
      id: id,
      name: data['name'] as String? ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      status: (data['status'] as String?) == 'ended'
          ? ServiceStatus.ended
          : ServiceStatus.active,
      startedBy: data['startedBy'] as String? ?? '',
    );
  }
}