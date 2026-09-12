import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user_entity.dart';
import '../../services/firestore_service.dart';
import '../../constants/app_strings.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirestoreService? firestoreService,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestoreService = firestoreService ?? FirestoreService(),
        super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<CompleteProfileSubmitted>(_onCompleteProfile);
    on<SignOutRequested>(_onSignOut);
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;

  // ────────────────────────────────────────────────────────────────────────
  // Handlers
  // ────────────────────────────────────────────────────────────────────────

  /// Cold-start check: if Firebase still has a session, verify the Firestore
  /// profile; otherwise emit [Unauthenticated].
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        emit(const Unauthenticated());
        return;
      }
      await _resolveUserState(firebaseUser, emit);
    } catch (e, st) {
      debugPrint('[AuthBloc] _onCheckAuthStatus error: $e\n$st');
      emit(const AuthFailure(AppStrings.errorOccurred));
    }
  }

  /// Runs the full Google OAuth flow, then checks Firestore.
  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        // User cancelled the picker.
        emit(const Unauthenticated());
        return;
      }

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        emit(const AuthFailure(AppStrings.googleSignInFailed));
        return;
      }

      await _resolveUserState(firebaseUser, emit);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('[AuthBloc] _onGoogleSignIn FirebaseAuthException: $e\n$st');
      emit(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e, st) {
      debugPrint('[AuthBloc] _onGoogleSignIn error: $e\n$st');
      emit(const AuthFailure(AppStrings.errorOccurred));
    }
  }

  /// Saves the profile form data to Firestore and emits [Authenticated].
  Future<void> _onCompleteProfile(
    CompleteProfileSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileIncomplete) return;

    emit(const AuthLoading());
    try {
      await _firestoreService.saveUserProfile(
        uid: currentState.uid,
        fullName: event.fullName,
        studentPhone: event.studentPhone,
        parentPhone: event.parentPhone,
        academicGrade: event.academicGrade,
        email: currentState.email,
      );

      final userEntity = UserEntity(
        uid: currentState.uid,
        email: currentState.email,
        fullName: event.fullName,
        studentPhone: event.studentPhone,
        parentPhone: event.parentPhone,
        academicGrade: event.academicGrade,
        isProfileComplete: true,
      );

      emit(Authenticated(userEntity));
    } catch (e, st) {
      debugPrint('[AuthBloc] _onCompleteProfile error: $e\n$st');
      // Return to ProfileIncomplete so the user can retry.
      emit(currentState);
      emit(const AuthFailure(AppStrings.errorOccurred));
    }
  }

  /// Signs the user out of both Google and Firebase.
  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      emit(const Unauthenticated());
    } catch (e, st) {
      debugPrint('[AuthBloc] _onSignOut error: $e\n$st');
      emit(const AuthFailure(AppStrings.errorOccurred));
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────────────────

  /// Queries Firestore for the user document and emits either
  /// [ProfileIncomplete] or [Authenticated] accordingly.
  Future<void> _resolveUserState(
    User firebaseUser,
    Emitter<AuthState> emit,
  ) async {
    final userDoc = await _firestoreService.getUserDocument(firebaseUser.uid);

    if (userDoc == null || !userDoc.isProfileComplete) {
      emit(ProfileIncomplete(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
      ));
    } else {
      emit(Authenticated(userDoc));
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return AppStrings.accountExistsDifferentCredential;
      case 'network-request-failed':
        return AppStrings.networkError;
      default:
        return AppStrings.errorOccurred;
    }
  }
}
