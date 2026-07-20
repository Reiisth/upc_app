// lib/services/usher_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usher_profile.dart';

class UsherService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<UsherProfile>> fetchProfilesForUser(String uid) async {
    final snapshot = await _firestore
        .collection('ushers')
        .where('linkedUid', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => UsherProfile.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<UsherProfile?> fetchById(String usherId) async {
    final doc = await _firestore.collection('ushers').doc(usherId).get();
    if (!doc.exists) return null;
    return UsherProfile.fromDoc(doc.id, doc.data()!);
  }
}