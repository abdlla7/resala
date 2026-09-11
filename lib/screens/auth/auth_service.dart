import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

/// Low-level Firebase Auth wrapper.
///
/// Google Sign-In is handled directly inside [AuthBloc] (using the
/// `google_sign_in` package) because the credential exchange is tightly
/// coupled to state transitions.  This class retains the email helpers for
/// legacy usage (e.g. the settings screen's delete-account flow).
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ── Email / Password (kept for account-management flows) ─────────────────

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return cred.user;
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return cred.user;
  }

  Future<void> signOut() async => _firebaseAuth.signOut();

  Future<void> sendPasswordResetEmail(String email) async =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  Future<void> updateusername(String displayName) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(displayName);
      await currentUser!.reload();
    }
  }

  Future<void> deleteaccount(String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPasswordFromCurrentPassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
