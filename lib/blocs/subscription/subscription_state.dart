part of 'subscription_cubit.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

/// Before any status check has been performed.
class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

/// An async operation (redemption) is in progress.
class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

/// The student has a valid, active subscription.
///
/// [expiryDate] is the authoritative end timestamp to display countdowns.
class SubscriptionActive extends SubscriptionState {
  const SubscriptionActive({required this.expiryDate});

  final DateTime expiryDate;

  /// Remaining whole days until expiry.
  int get remainingDays =>
      expiryDate.difference(DateTime.now()).inDays.clamp(0, 9999);

  @override
  List<Object?> get props => [expiryDate];
}

/// The student has no subscription, or it has expired.
class SubscriptionExpired extends SubscriptionState {
  const SubscriptionExpired();
}

/// An error occurred during redemption or status check.
class SubscriptionFailure extends SubscriptionState {
  const SubscriptionFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
