// lib/services/member_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_profile.dart';

class MemberService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<MemberProfile>> fetchProfilesForUser(String uid) async {
    final snapshot = await _firestore
        .collection('members')
        .where('linkedUid', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => MemberProfile.fromDoc(doc.id, doc.data()))
        .toList();
  }
}