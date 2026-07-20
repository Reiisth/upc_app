// lib/services/account_creation_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountCreationService {
  /// Creates a new email/password account WITHOUT signing out or replacing
  /// the currently signed-in user (e.g. the usher performing this action).
  /// Returns the new account's UID.
  Future<String> createAccount({
    required String email,
    required String password,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'secondaryApp_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await secondaryAuth.signOut();
      return uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account with this email already exists.');
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
  }
}