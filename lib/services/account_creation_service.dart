// lib/services/account_creation_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountCreationService {
  final _firestore = FirebaseFirestore.instance;

  /// Creates a new email/password account WITHOUT signing out or replacing
  /// the currently signed-in user (e.g. the usher performing this action).
  ///
  /// If an account with this email already exists, attempts to sign in
  /// with the provided password instead — since multiple members can be
  /// registered under the same shared account (e.g. a family). Returns
  /// the resulting account's UID either way.
  ///
  /// Also ensures a corresponding /users/{uid} doc exists with [role],
  /// since Firestore security rules depend on it existing.
  Future<String> createAccount({
    required String email,
    required String password,
    String role = 'member',
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'secondaryApp_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    String uid;
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      try {
        final credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        uid = credential.user!.uid;
        await secondaryAuth.signOut();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          try {
            final credential = await secondaryAuth.signInWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );
            uid = credential.user!.uid;
            await secondaryAuth.signOut();
          } on FirebaseAuthException catch (signInError) {
            switch (signInError.code) {
              case 'wrong-password':
              case 'invalid-credential':
                throw Exception(
                    'This email is already registered under a different password. '
                    'Use the same password as the existing account to link this member.');
              case 'user-disabled':
                throw Exception('This account has been disabled.');
              default:
                throw Exception('Could not link to existing account: ${signInError.message}');
            }
          }
        } else {
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak (minimum 6 characters).');
        case 'invalid-email':
          throw Exception('That email address looks invalid.');
        default:
          throw Exception('Failed to create account: ${e.message}');
      }
    } finally {
      await secondaryApp.delete();
    }

    await _ensureUserDoc(uid, role);
    return uid;
  }

  /// Creates /users/{uid} with a role if it doesn't already exist.
  /// Won't overwrite an existing role — e.g. if this uid was already
  /// linked to another member with a role set previously.
  Future<void> _ensureUserDoc(String uid, String role) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'role': role,
        'createdAt': Timestamp.now(),
      });
    }
  }
}