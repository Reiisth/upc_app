// lib/models/usher_profile.dart
class UsherProfile {
  final String id;
  final String name;
  final String photoUrl;

  UsherProfile({
    required this.id,
    required this.name,
    this.photoUrl = '',
  });

  factory UsherProfile.fromDoc(String id, Map<String, dynamic> data) {
    return UsherProfile(
      id: id,
      name: data['name'] as String? ?? 'Unknown',
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }
}