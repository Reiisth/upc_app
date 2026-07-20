import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { usher, member, pastor }

class AuthResult {
  final String uid;
  final UserRole role;
  final String name;
  AuthResult({required this.uid, required this.role, required this.name});
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Signs in with email/password, then fetches the user's role doc.
  /// Throws an [Exception] with a user-friendly message on failure.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          throw Exception('Incorrect email or password.');
        case 'invalid-email':
          throw Exception('That email address looks invalid.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Login failed. Please try again.');
      }
    }

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('No profile found for this account. Contact an admin.');
    }

    final data = doc.data()!;
    final roleString = data['role'] as String?;
    final role = _parseRole(roleString);

    if (role == null) {
      await _auth.signOut();
      throw Exception('Account has no valid role assigned.');
    }

    return AuthResult(
      uid: uid,
      role: role,
      name: data['name'] as String? ?? '',
    );
  }

  UserRole? _parseRole(String? value) {
    switch (value) {
      case 'usher':
        return UserRole.usher;
      case 'member':
        return UserRole.member;
      case 'pastor':
        return UserRole.pastor;
      default:
        return null;
    }
  }
}