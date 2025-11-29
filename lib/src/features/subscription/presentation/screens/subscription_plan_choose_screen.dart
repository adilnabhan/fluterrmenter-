import 'package:mentor_mobile_app/imports_bindings.dart';

class SubscriptionPlanChooseScreen extends StatelessWidget {
  const SubscriptionPlanChooseScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit(orgDetails: orgDetails),
      child: const _SubscriptionPlanChooseScreen(),
    );
  }
}

class _SubscriptionPlanChooseScreen extends StatefulWidget {
  const _SubscriptionPlanChooseScreen();

  @override
  State<_SubscriptionPlanChooseScreen> createState() =>
      __SubscriptionPlanChooseScreenState();
}

class __SubscriptionPlanChooseScreenState
    extends State<_SubscriptionPlanChooseScreen> {
  late final SubscriptionCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<SubscriptionCubit>();
    _fetchPlans();
    super.initState();
  }

  Future<void> _fetchPlans() async {
    await _cubit.fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listenWhen: (p, c) => p.payment != c.payment,
      listener: (context, state) {
        state.payment?.fold(() {}, (either) {
          either.fold(
            (error) {
              Dialogs.showSnack(msg: error.msg);
            },
            (razorpayOrder) async {
              context.pushAndRemoveUntil(const OrganizationListingScreen());
            },
          );
        });
      },
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        buildWhen: (p, c) => p.payment != c.payment,
        builder: (context, state) {
          return PopScope(
            canPop: !(state.payment?.isNone() ?? false),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C1212), AppColors.dark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent, // Background color
                  body: Stack(
                    children: [
                      Positioned(
                        top: context.height * .08,
                        right: 32,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/dumble.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: context.height * .28,
                        right: context.width * .25,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/hart.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: context.height * .38,
                        left: 32,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/shoe.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: context.height * .4,
                        right: 16,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/showing_power.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Text(
                              'Choose\nSubscription plan',
                              style: AppStyles.text24Px.poppins.w700.light,
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                style: AppStyles.text14Px.poppins.w400.light,
                                children: const [
                                  TextSpan(
                                    text: '15-day',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' trial period is available for both\nsubscription plans',
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 4),
                            BlocBuilder<SubscriptionCubit, SubscriptionState>(
                              buildWhen:
                                  (p, c) =>
                                      p.plans != c.plans ||
                                      p.selectedSubscriptionModel !=
                                          c.selectedSubscriptionModel,
                              builder: (context, state) {
                                return state.plans.fold(
                                  () => Column(
                                    children: [
                                      _buildPlanOptionShimmer(),
                                      const SizedBox(height: 16),
                                      _buildPlanOptionShimmer(),
                                    ],
                                  ),
                                  (either) {
                                    return either.fold(
                                      (error) {
                                        return SizedBox(
                                          width: 100,
                                          child: Button.filled(
                                            title: 'Retry',
                                            ontap: _fetchPlans,
                                            buttonColor: Colors.white,
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w600
                                                    .dark,
                                            raduis: 10000,
                                          ),
                                        ).center;
                                      },
                                      (plans) {
                                        return ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: plans.results?.length ?? 0,
                                          separatorBuilder:
                                              (_, __) =>
                                                  const SizedBox(height: 16),
                                          itemBuilder:
                                              (
                                                context,
                                                index,
                                              ) => _buildPlanOption(
                                                plan: plans.results?[index],
                                                isSelected:
                                                    state
                                                        .selectedSubscriptionModel
                                                        ?.id ==
                                                    plans.results?[index].id,
                                              ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            BlocBuilder<SubscriptionCubit, SubscriptionState>(
                              buildWhen:
                                  (p, c) =>
                                      p.plans != c.plans ||
                                      p.selectedSubscriptionModel !=
                                          c.selectedSubscriptionModel ||
                                      p.payment != c.payment,
                              builder: (context, state) {
                                if (state.plans.fold(
                                  () => true,
                                  (t) => t.fold((l) => true, (r) => false),
                                )) {
                                  return const SizedBox(height: 40);
                                }
                                return Button.filled(
                                  title: 'Continue',
                                  isDisabled:
                                      state.selectedSubscriptionModel == null,
                                  isLoading: state.payment?.isNone() ?? false,
                                  ontap: () {
                                    if (state.payment?.isNone() ?? false) {
                                      return;
                                    }
                                    _cubit.payment();
                                  },
                                  buttonColor: Colors.white,
                                  disabledButtonColor: Colors.white.withAlpha(
                                    125,
                                  ),
                                  loadingColor: Colors.black,
                                  style: AppStyles.text14Px.poppins.w600.dark,
                                  raduis: 12,
                                );
                              },
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanOption({
    required SubscriptionPlanModel? plan,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (plan == null || isSelected) return;
        _cubit.selectSubscription(plan);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !isSelected ? const Color(0xFF270A0A).withAlpha(150) : null,
          gradient:
              !isSelected
                  ? null
                  : const LinearGradient(
                    colors: [Color(0xFF290F0F), Color(0xff581F1F)],
                  ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xffC39191) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan?.name ?? '',
                  style: AppStyles.text14Px.poppins.w500.light,
                ),
                RichText(
                  text: TextSpan(
                    style: AppStyles.text16Px.poppins.w700.light,
                    children: [
                      if (plan?.discountedPrice?.isNotEmpty ?? false)
                        TextSpan(
                          text:
                              '₹${plan?.perMonthPriceExcludeDiscount.toStringAsFixed(2)}',
                          style: AppStyles.text14Px.poppins.w300.light.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (plan?.regularPrice?.isNotEmpty ?? false)
                        const WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(
                        text:
                            '₹${plan?.perMonthPriceIncludeDisount.toStringAsFixed(2)}',
                        style: AppStyles.text16Px.poppins.w700.light,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if ((plan?.discountedPrice?.isNotEmpty ?? false) &&
                    (plan?.regularPrice?.isNotEmpty ?? false) &&
                    plan?.regularPrice != plan?.discountedPrice) ...[
                  Row(
                    children: [
                      Text(
                        'Total ₹${plan?.discountedPrice ?? 00}',
                        style: AppStyles.text12Px.poppins.w400.light,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xff713E3E),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Text(
                          'Save ₹${plan?.totalDiscount ?? 00}',
                          style: AppStyles.text12Px.poppins.w400.light,
                        ),
                      ),
                    ],
                  ),
                ],
                // Text('per month', style: AppStyles.text12Px.poppins.w400.light),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOptionShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF270A0A).withAlpha(150),
      highlightColor: const Color(0xFF581F1F),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF270A0A).withAlpha(150),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 90,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
