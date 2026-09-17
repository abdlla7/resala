import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_entity.dart';

/// Encapsulates all reads and writes to Firestore.
///
/// Keeps Firebase imports out of BLoC/UI layers.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _colUsers = 'users';
  static const _colCodes = 'codes';

  // ────────────────────────────────────────────────────────────────────────
  // Users
  // ────────────────────────────────────────────────────────────────────────

  /// Returns the [UserEntity] for [uid], or `null` when the document doesn't
  /// exist yet (first Google Sign-In before profile completion).
  Future<UserEntity?> getUserDocument(String uid) async {
    final doc = await _db.collection(_colUsers).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    // data() is non-null here (guarded above); capture into a local variable
    // to avoid a forced-unwrap bang while satisfying the type system.
    final data = doc.data()!;
    return UserEntity.fromFirestore(data, uid);
  }

  /// Saves (or merges) the student's profile under `/users/{uid}`.
  Future<void> saveUserProfile({
    required String uid,
    required String fullName,
    required String studentPhone,
    required String parentPhone,
    required String academicGrade,
    String? email,
  }) async {
    final ref = _db.collection(_colUsers).doc(uid);
    final existing = await ref.get();

    await ref.set(<String, dynamic>{
      'full_name': fullName,
      'student_phone': studentPhone,
      'parent_phone': parentPhone,
      'academic_grade': academicGrade,
      'email': email,
      'is_profile_complete': true,
      if (!existing.exists) 'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ────────────────────────────────────────────────────────────────────────
  // Subscription
  // ────────────────────────────────────────────────────────────────────────

  /// Attempts to redeem [code] for [uid].
  ///
  /// Runs as a Firestore transaction so the code cannot be double-redeemed.
  ///
  /// Throws a [RedemptionException] on validation failure, or rethrows
  /// Firestore errors for the caller to handle.
  Future<UserEntity> redeemCode({
    required String uid,
    required String code,
  }) async {
    final codeRef = _db.collection(_colCodes).doc(code.trim().toUpperCase());
    final userRef = _db.collection(_colUsers).doc(uid);

    late UserEntity updatedUser;

    await _db.runTransaction((txn) async {
      // ── Read both documents inside the transaction ──────────────────
      final codeSnap = await txn.get(codeRef);
      final userSnap = await txn.get(userRef);

      // ── Validate code ───────────────────────────────────────────────
      if (!codeSnap.exists) {
        throw const RedemptionException(RedemptionFailure.invalidCode);
      }

      // codeSnap.exists was verified above; data() is non-null here.
      // Capture into a local variable to avoid the forced-unwrap bang.
      final codeData = codeSnap.data() ?? <String, dynamic>{};
      final isRedeemed = codeData['is_redeemed'] as bool? ?? false;
      if (isRedeemed) {
        throw const RedemptionException(RedemptionFailure.alreadyRedeemed);
      }

      final durationDays = (codeData['duration_days'] as num?)?.toInt() ?? 30;

      // ── Calculate new subscription end date ─────────────────────────
      // If user already has an active subscription, extend from its end date.
      // Otherwise start from now.
      final userData = userSnap.exists ? userSnap.data() : null;
      DateTime baseDate = DateTime.now();

      if (userData != null) {
        final existingEnd = userData['subscription_end_date'];
        if (existingEnd != null) {
          try {
            // ignore: avoid_dynamic_calls
            final existing = (existingEnd as dynamic).toDate() as DateTime;
            if (existing.isAfter(DateTime.now())) {
              baseDate = existing; // extend an active subscription
            }
          } catch (_) {}
        }
      }

      final newEndDate = baseDate.add(Duration(days: durationDays));
      final newEndTimestamp = Timestamp.fromDate(newEndDate);

      // ── Write code document ─────────────────────────────────────────
      txn.update(codeRef, {
        'is_redeemed': true,
        'redeemed_by': uid,
        'redeemed_at': FieldValue.serverTimestamp(),
      });

      // ── Write user document ─────────────────────────────────────────
      txn.set(userRef, {
        'subscription_active': true,
        'subscription_start_date': FieldValue.serverTimestamp(),
        'subscription_end_date': newEndTimestamp,
      }, SetOptions(merge: true));

      // Build the updated entity so the cubit can emit it immediately.
      final currentUser = userData != null
          ? UserEntity.fromFirestore(userData, uid)
          : UserEntity(
              uid: uid,
              fullName: '',
              studentPhone: '',
              parentPhone: '',
              academicGrade: '',
            );

      updatedUser = currentUser.copyWith(
        subscriptionActive: true,
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: newEndDate,
      );
    });

    return updatedUser;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Exception types
// ────────────────────────────────────────────────────────────────────────────

enum RedemptionFailure { invalidCode, alreadyRedeemed, transactionFailed }

class RedemptionException implements Exception {
  const RedemptionException(this.failure);
  final RedemptionFailure failure;

  @override
  String toString() => 'RedemptionException($failure)';
}
