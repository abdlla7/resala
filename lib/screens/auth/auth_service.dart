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
    // Capture once before any `await` so a concurrent sign-out between the
    // null-check and either async call cannot produce a null-dereference crash.
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
  }

  /// Reauthenticates with [password] then permanently deletes the account.
  ///
  /// Throws [StateError] if no user is signed in or if the account has no
  /// email address (e.g. anonymous accounts), allowing callers to show a
  /// safe error dialog without exposing internal Firebase details.
  Future<void> deleteaccount(String password) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('deleteaccount: no authenticated user.');
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('deleteaccount: user has no email address.');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();
  }

  /// Re-authenticates with [currentPassword] then updates to [newPassword].
  ///
  /// Throws [StateError] if no user is signed in or if the account has no
  /// email address, preventing force-unwrap crashes.
  Future<void> resetPasswordFromCurrentPassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('resetPasswordFromCurrentPassword: no authenticated user.');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
