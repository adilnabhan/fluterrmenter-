import 'package:mentor_mobile_app/imports_bindings.dart';

part 'subscription_state.dart';
part 'subscription_cubit.freezed.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required this.orgDetails})
    : super(const SubscriptionState()) {
    _razorpay = Razorpay();
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  late final Razorpay _razorpay;
  final OrganizationDetailsModel orgDetails;

  Future<void> fetchSubscriptions() async {
    emit(state.copyWith(plans: none()));
    final res = await SubscriptionRepository().plans();
    res.fold((l) {}, (plans) {
      if (plans.results?.isNotEmpty ?? false) {
        emit(state.copyWith(selectedSubscriptionModel: plans.results!.first));
      }
    });
    emit(state.copyWith(plans: some(res)));
  }

  void selectSubscription(SubscriptionPlanModel model) {
    emit(state.copyWith(selectedSubscriptionModel: model));
  }

  Future<void> payment() async {
    emit(state.copyWith(payment: none()));
    if (state.selectedSubscriptionModel?.id == null) {
      emit(
        state.copyWith(
          payment: some(
            left(const ApiException.notFound(msg: 'Please select a plan!')),
          ),
        ),
      );
      return;
    } else if (orgDetails.id == null) {
      emit(
        state.copyWith(
          payment: some(
            left(const ApiException.notFound(msg: 'Organization not found!')),
          ),
        ),
      );
      return;
    }
    final res = await SubscriptionRepository().initiateRazorpayPayment(
      body: {
        'plan_id': state.selectedSubscriptionModel!.id,
        'organization_id': orgDetails.id,
      },
    );
    // await res.fold(
    //   (l) async => emit(state.copyWith(payment: some(left(l)))),
    //   (rozarpayOrder) async =>
    //       openRazorpayCheckout(rozarpayOrder: rozarpayOrder),
    // );
    await res.fold(
      (l) async {
        emit(state.copyWith(payment: some(left(l))));
      },
      (rozarpayOrder) async {
        final isFreePlan = rozarpayOrder.isFreePlan ?? false;

        if (isFreePlan) {
          final fakeResponse = PaymentSuccessResponse(
            'FREE_PLAN',
            'FREE_ORDER',
            'FREE_SIGNATURE',
            {},
          );
          emit(state.copyWith(payment: some(right(fakeResponse))));
          return;
        }

        // Only open Razorpay when NOT a free plan
        await openRazorpayCheckout(rozarpayOrder: rozarpayOrder);
      },
    );
  }

  Future<void> openRazorpayCheckout({
    required InitiateRazorpayPaymentModel rozarpayOrder,
  }) async {
    emit(state.copyWith(payment: none()));
    final razorpayApiKey = dotenv.get('RAZORPAY_API_KEY');
    try {
      final discountAmount =
          rozarpayOrder.disciplPlan?.discountedPrice?.toNum ?? 0;
      final rozarpayOrderId = rozarpayOrder.orderId;
      if (discountAmount <= 0) {
        emit(
          state.copyWith(
            payment: some(
              left(const ApiException.notFound(msg: 'Select a valid plan')),
            ),
          ),
        );
        return;
      } else if (rozarpayOrderId == null) {
        emit(
          state.copyWith(
            payment: some(
              left(
                const ApiException.notFound(
                  msg: 'Payment Failed! Please try again',
                ),
              ),
            ),
          ),
        );
        return;
      }
      final options = {
        'key': razorpayApiKey,
        'amount': discountAmount, //in paise.
        'name':
            '${rozarpayOrder.user?.firstName ?? ''} ${rozarpayOrder.user?.lastName ?? ''}'
                .trim(),
        'order_id': rozarpayOrderId, // Generate order_id using Orders API
        'description': rozarpayOrder.disciplPlan?.name,
        'timeout': 60, // in seconds
        'prefill': {
          'contact': rozarpayOrder.user?.mobileNumber ?? '',
          'email': rozarpayOrder.user?.email ?? '',
          //
        },
      };
      _razorpay.open(options);
    } catch (e) {
      emit(
        state.copyWith(
          payment: some(
            left(const ApiException.notFound(msg: 'Payment Failed')),
          ),
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    /// Do something when payment succeeds
    // fetchLastPaymentStatus(response);
    emit(state.copyWith(payment: some(right(response))));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    /// Do something when payment fails
    emit(
      state.copyWith(
        payment: some(
          left(
            ApiException.notFound(msg: response.message ?? 'Payment Failed'),
          ),
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    /// Do something when an external wallet is selected
    // emit(state.copyWith(payment: some(left(response))));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
