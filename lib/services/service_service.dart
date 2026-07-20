// lib/services/service_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';

class ServiceService {
  final _firestore = FirebaseFirestore.instance;

  static const _weekdayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  /// Builds a default name like "Sunday Evening Service" from a date/time.
  static String generateDefaultName(DateTime dateTime) {
    final weekday = _weekdayNames[dateTime.weekday - 1];

    final String timeOfDay;
    final hour = dateTime.hour;
    if (hour < 12) {
      timeOfDay = 'Morning';
    } else if (hour < 18) {
      timeOfDay = 'Afternoon';
    } else {
      timeOfDay = 'Evening';
    }

    return '$weekday $timeOfDay Service';
  }

  Future<ServiceModel?> getActiveService() async {
    final snapshot = await _firestore
        .collection('services')
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return ServiceModel.fromDoc(doc.id, doc.data());
  }

  /// Starts a new service. If [name] is null or blank, a default name is
  /// generated from the current date/time (e.g. "Sunday Evening Service").
  Future<ServiceModel> startService({String? name}) async {
    final existing = await getActiveService();
    if (existing != null) {
      throw Exception('A service is already active: ${existing.name}');
    }

    
    final now = DateTime.now();
    final resolvedName =
        (name == null || name.trim().isEmpty) ? generateDefaultName(now) : name.trim();

    final docRef = await _firestore.collection('services').add({
      'name': resolvedName,
      'startedAt': Timestamp.fromDate(now),
      'endedAt': null,
      'status': 'active',
      'startedBy': 'Pastor John',
    });

    final doc = await docRef.get();
    return ServiceModel.fromDoc(doc.id, doc.data()!);
  }

  Future<void> endService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).update({
      'status': 'ended',
      'endedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}