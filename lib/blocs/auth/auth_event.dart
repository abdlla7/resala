part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Emitted on cold-start to check the persisted Firebase session.
class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

/// Triggers the Google OAuth flow.
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Submits the profile-completion form for a newly authenticated user.
class CompleteProfileSubmitted extends AuthEvent {
  const CompleteProfileSubmitted({
    required this.fullName,
    required this.studentPhone,
    required this.parentPhone,
    required this.academicGrade,
  });

  final String fullName;
  final String studentPhone;
  final String parentPhone;

  /// Standardised key, e.g. `'3rd_secondary'`.
  final String academicGrade;

  @override
  List<Object?> get props => [fullName, studentPhone, parentPhone, academicGrade];
}

/// Signs out from both Google and Firebase.
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
