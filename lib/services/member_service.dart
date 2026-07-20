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

  Future<MemberProfile?> fetchById(String memberId) async {
    final doc = await _firestore.collection('members').doc(memberId).get();
    if (!doc.exists) return null;
    return MemberProfile.fromDoc(doc.id, doc.data()!);
  }

  /// Fetches all registered members, sorted by last name then first name.
  /// Used for the pastor's member directory / search tab.
  Future<List<MemberProfile>> fetchAll() async {
    final snapshot = await _firestore.collection('members').get();
    final members = snapshot.docs
        .map((doc) => MemberProfile.fromDoc(doc.id, doc.data()))
        .toList();
    members.sort((a, b) {
      final byLast = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
      if (byLast != 0) return byLast;
      return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
    });
    return members;
  }
}