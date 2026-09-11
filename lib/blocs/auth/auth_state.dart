part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before any auth check has been performed (app just launched).
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An async operation is in progress (sign-in, sign-out, profile save…).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// No authenticated user — show the login screen.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// The user is authenticated with Firebase but has not yet completed their
/// profile in Firestore (`is_profile_complete == false` or doc missing).
///
/// Route the user to `/complete-profile`.
class ProfileIncomplete extends AuthState {
  const ProfileIncomplete({required this.uid, this.email});

  final String uid;
  final String? email;

  @override
  List<Object?> get props => [uid, email];
}

/// The user is fully authenticated and their profile is complete.
///
/// [user] is stored in global state so any screen can read
/// `academicGrade`, `fullName`, etc. without an extra Firestore call.
class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// An error occurred during an auth operation.
class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
