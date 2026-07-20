// lib/models/member_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female }

class MemberProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String middleName;
  final DateTime? birthdate;
  final Gender? gender;
  final DateTime? memberSince;
  final String photoUrl;

  MemberProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName = '',
    this.birthdate,
    this.gender,
    this.memberSince,
    this.photoUrl = '',
  });

  /// Full display name, e.g. "Juan Dela Cruz" (middle name omitted from display).
  String get fullName => [firstName, lastName]
      .where((part) => part.trim().isNotEmpty)
      .join(' ');

  /// Age in whole years, based on birthdate. Null if birthdate is unknown.
  int? get age {
    if (birthdate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      years--;
    }
    return years;
  }

  /// Ministry derived from age + gender. Null if age or gender is unknown.
  String? get ministry {
    final a = age;
    if (a == null) return null;

    if (a <= 12) return "Sunday School";
    if (a <= 17) return "Youth";

    if (gender == null) return null;
    return gender == Gender.male ? "Men's Ministry" : "Women's Ministry";
  }

  factory MemberProfile.fromDoc(String id, Map<String, dynamic> data) {
    return MemberProfile(
      id: id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      middleName: data['middleName'] as String? ?? '',
      birthdate: (data['birthdate'] as Timestamp?)?.toDate(),
      gender: _parseGender(data['gender'] as String?),
      memberSince: (data['memberSince'] as Timestamp?)?.toDate(),
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }

  static Gender? _parseGender(String? value) {
    switch (value) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return null;
    }
  }
}