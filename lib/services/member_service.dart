// lib/services/member_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_profile.dart';

class MemberService {
  final _firestore = FirebaseFirestore.instance;

  /// Generates a random 5-digit ID (10000–99999) not already in use.
  Future<String> _generateUniqueMemberId() async {
    final random = Random();
    for (int attempt = 0; attempt < 10; attempt++) {
      final candidate = (10000 + random.nextInt(90000)).toString();
      final doc = await _firestore.collection('members').doc(candidate).get();
      if (!doc.exists) return candidate;
    }
    throw Exception('Could not generate a unique member ID. Please try again.');
  }

  Future<void> createMember({
    required String firstName,
    required String lastName,
    String middleName = '',
    required DateTime birthdate,
    required Gender gender,
    required String civilStatus,
    required String address,
    required DateTime memberSince,
    required String linkedUid,
  }) async {
    final memberId = await _generateUniqueMemberId();

    await _firestore.collection('members').doc(memberId).set({
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'birthdate': Timestamp.fromDate(birthdate),
      'gender': gender == Gender.male ? 'male' : 'female',
      'civilStatus': civilStatus,
      'address': address,
      'memberSince': Timestamp.fromDate(memberSince),
      'photoUrl': '', // always empty — photo upload disabled (Storage plan limitation)
      'linkedUid': linkedUid,
    });
  }

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

  Future<void> deleteMember(String memberId) async {
    await _firestore.collection('members').doc(memberId).delete();
  }
}