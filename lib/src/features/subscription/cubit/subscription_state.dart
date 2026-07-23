part of 'subscription_cubit.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(None()) Option<Either<ApiException, PlansModel>> plans,
    SubscriptionPlanModel? selectedSubscriptionModel,
    Option<Either<ApiException, PaymentSuccessResponse>>? payment,
    String? appliedCoupon,
    @Default(0.0) double couponDiscountAmount,
    @Default(false) bool isCouponApplied,
  }) = _SubscriptionState;
}
