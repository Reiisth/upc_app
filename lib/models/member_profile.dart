// lib/models/member_profile.dart
class MemberProfile {
  final String id;
  final String name;
  final String photoUrl;

  MemberProfile({required this.id, required this.name, required this.photoUrl});

  factory MemberProfile.fromDoc(String id, Map<String, dynamic> data) {
    return MemberProfile(
      id: id,
      name: data['name'] as String? ?? 'Unknown',
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }
}