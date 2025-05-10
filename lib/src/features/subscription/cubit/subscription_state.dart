part of 'subscription_cubit.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({Option<Either<ApiException, PaymentSuccessResponse>>? payment}) = _SubscriptionState;
}
