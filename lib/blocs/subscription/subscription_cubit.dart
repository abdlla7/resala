import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_entity.dart';
import '../../services/firestore_service.dart';
import '../../constants/app_strings.dart';

part 'subscription_state.dart';

/// Manages scratch-code redemption and subscription status.
///
/// Depends only on [FirestoreService] and [UserEntity]; no Firebase imports
/// here so the cubit is fully unit-testable.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required FirestoreService firestoreService,
  })  : _firestoreService = firestoreService,
        super(const SubscriptionInitial());

  final FirestoreService _firestoreService;

  // ── Public methods ────────────────────────────────────────────────────────

  /// Evaluates the subscription from a [UserEntity] that has already been
  /// loaded by [AuthBloc] — no extra Firestore read needed.
  void checkSubscriptionStatus(UserEntity user) {
    // hasActiveSubscription already guarantees subscriptionEndDate is non-null
    // and in the future. We capture it into a local variable so the type system
    // sees a non-nullable DateTime without a forced-unwrap bang operator.
    final endDate = user.subscriptionEndDate;
    if (user.hasActiveSubscription && endDate != null) {
      emit(SubscriptionActive(expiryDate: endDate));
    } else {
      emit(const SubscriptionExpired());
    }
  }

  /// Attempts to redeem [code] on behalf of [user].
  ///
  /// Emits [SubscriptionLoading] → [SubscriptionActive] on success, or
  /// [SubscriptionFailure] with a localised message on any error.
  Future<void> redeemCode({
    required UserEntity user,
    required String code,
  }) async {
    if (code.trim().isEmpty) {
      emit(SubscriptionFailure(AppStrings.enterScratchCode));
      return;
    }

    emit(const SubscriptionLoading());

    try {
      final updatedUser = await _firestoreService.redeemCode(
        uid: user.uid,
        code: code,
      );

      // Guard against a partial Firestore write where subscriptionEndDate was
      // not populated; treat that as a transaction failure rather than crashing.
      final endDate = updatedUser.subscriptionEndDate;
      if (endDate == null) {
        emit(SubscriptionFailure(AppStrings.redemptionTransactionFailed));
        return;
      }

      emit(SubscriptionActive(expiryDate: endDate));
    } on RedemptionException catch (e) {
      switch (e.failure) {
        case RedemptionFailure.invalidCode:
        case RedemptionFailure.alreadyRedeemed:
          emit(SubscriptionFailure(AppStrings.invalidOrUsedCode));
        case RedemptionFailure.transactionFailed:
          emit(SubscriptionFailure(AppStrings.redemptionTransactionFailed));
      }
    } catch (_) {
      emit(SubscriptionFailure(AppStrings.errorOccurred));
    }
  }

  /// Resets to initial state (e.g. after sign-out).
  void reset() => emit(const SubscriptionInitial());
}
