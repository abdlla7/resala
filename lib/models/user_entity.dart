import 'package:equatable/equatable.dart';

/// Domain model representing a user document stored at `/users/{uid}`.
///
/// Deliberately free of Firebase imports so widgets and BLoCs remain
/// testable without a Firebase dependency.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    this.email,
    required this.fullName,
    required this.studentPhone,
    required this.parentPhone,
    required this.academicGrade,
    this.isProfileComplete = false,
    this.subscriptionActive = false,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });

  final String uid;
  final String? email;
  final String fullName;
  final String studentPhone;
  final String parentPhone;

  /// Standardised grade key, e.g. `'3rd_secondary'`.
  final String academicGrade;
  final bool isProfileComplete;

  // ── Subscription fields ──────────────────────────────────────────────────

  /// Mirrors `subscription_active` in Firestore; kept for quick reads.
  final bool subscriptionActive;
  final DateTime? subscriptionStartDate;

  /// The authoritative field: subscription is valid only when this is in the
  /// future. Check [hasActiveSubscription] instead of [subscriptionActive]
  /// directly, since the Firestore flag may be stale.
  final DateTime? subscriptionEndDate;

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// `true` when [subscriptionEndDate] exists and has not yet passed.
  bool get hasActiveSubscription {
    final endDate = subscriptionEndDate;
    return endDate != null && endDate.isAfter(DateTime.now());
  }

  /// Remaining days until the subscription expires (0 when expired or absent).
  int get remainingDays {
    if (!hasActiveSubscription) return 0;
    // hasActiveSubscription guarantees subscriptionEndDate is non-null.
    final endDate = subscriptionEndDate;
    if (endDate == null) return 0; // defensive — unreachable in practice
    return endDate.difference(DateTime.now()).inDays;
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory UserEntity.fromFirestore(Map<String, dynamic> data, String uid) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      // Firestore Timestamps are returned as Timestamp objects; call toDate().
      try {
        // ignore: avoid_dynamic_calls
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return UserEntity(
      uid: uid,
      email: data['email'] as String?,
      fullName: data['full_name'] as String? ?? '',
      studentPhone: data['student_phone'] as String? ?? '',
      parentPhone: data['parent_phone'] as String? ?? '',
      academicGrade: data['academic_grade'] as String? ?? '',
      isProfileComplete: data['is_profile_complete'] as bool? ?? false,
      subscriptionActive: data['subscription_active'] as bool? ?? false,
      subscriptionStartDate: parseDate(data['subscription_start_date']),
      subscriptionEndDate: parseDate(data['subscription_end_date']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'full_name': fullName,
        'student_phone': studentPhone,
        'parent_phone': parentPhone,
        'academic_grade': academicGrade,
        'is_profile_complete': isProfileComplete,
        'subscription_active': subscriptionActive,
      };

  UserEntity copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? studentPhone,
    String? parentPhone,
    String? academicGrade,
    bool? isProfileComplete,
    bool? subscriptionActive,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentPhone: studentPhone ?? this.studentPhone,
      parentPhone: parentPhone ?? this.parentPhone,
      academicGrade: academicGrade ?? this.academicGrade,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        fullName,
        studentPhone,
        parentPhone,
        academicGrade,
        isProfileComplete,
        subscriptionActive,
        subscriptionStartDate,
        subscriptionEndDate,
      ];
}
