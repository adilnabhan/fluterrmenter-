import 'package:mentor_mobile_app/imports_bindings.dart';

class SubscriptionPlanChooseCom extends StatelessWidget {
  const SubscriptionPlanChooseCom({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit(orgDetails: orgDetails),
      child: const _SubscriptionPlanChooseCom(),
    );
  }
}

class _SubscriptionPlanChooseCom extends StatefulWidget {
  const _SubscriptionPlanChooseCom();

  @override
  State<_SubscriptionPlanChooseCom> createState() =>
      __SubscriptionPlanChooseComState();
}

class __SubscriptionPlanChooseComState
    extends State<_SubscriptionPlanChooseCom> {
  late final SubscriptionCubit _cubit;
  late final OrganizationListingAndDetailsCubit _parentCubit;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    _cubit = context.read<SubscriptionCubit>();
    _parentCubit = context.read<OrganizationListingAndDetailsCubit>();
    _fetchPlans();
    super.initState();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
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
              context.pushAndRemoveUntil(const SubscriptionSuccessScreen());
            },
          );
        });
      },
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        buildWhen: (p, c) =>
            p.payment != c.payment ||
            p.plans != c.plans ||
            p.selectedSubscriptionModel != c.selectedSubscriptionModel ||
            p.appliedCoupon != c.appliedCoupon ||
            p.isCouponApplied != c.isCouponApplied ||
            p.couponDiscountAmount != c.couponDiscountAmount,
        builder: (context, state) {
          final isPaying = state.payment?.isNone() ?? false;
          return PopScope(
            canPop: !isPaying,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: Scaffold(
                backgroundColor: const Color(0xffF9FAFB),
                body: Stack(
                  children: [
                    // Background Icons
                    Positioned(
                      top: 40,
                      left: 20,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/shoe.svg',
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          const Color(0xffFFB2B2).withOpacity(0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 20,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/dumble.svg',
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          const Color(0xffFFB2B2).withOpacity(0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 170,
                      left: 40,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/hart.svg',
                        height: 35,
                        colorFilter: ColorFilter.mode(
                          const Color(0xffFFB2B2).withOpacity(0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 150,
                      right: 60,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/showing_power.svg',
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          const Color(0xffFFB2B2).withOpacity(0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: state.plans.fold(
                              () => ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                children: [
                                  const SizedBox(height: 10),
                                  _buildStepIndicator(),
                                  const SizedBox(height: 40),
                                  _buildPlanOptionShimmer(),
                                  const SizedBox(height: 16),
                                  _buildPlanOptionShimmer(),
                                ],
                              ),
                              (either) => either.fold(
                                (error) => Center(
                                  child: SizedBox(
                                    width: 100,
                                    child: Button.filled(
                                      title: 'Retry',
                                      ontap: _fetchPlans,
                                      buttonColor: AppColors.primary,
                                      style: AppStyles.text14Px.poppins.w600.light,
                                      raduis: 12,
                                    ),
                                  ),
                                ),
                                (plansModel) {
                                  final plans = plansModel.results ?? [];
                                  final selectedPlan = state.selectedSubscriptionModel;

                                  return ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    children: [
                                      const SizedBox(height: 10),
                                      _buildStepIndicator(),
                                      const SizedBox(height: 30),

                                      // Title
                                      Text(
                                        'Choose Your\nDiscipl Plan 🔥',
                                        style: AppStyles.text32Px.poppins.w700.dark.copyWith(height: 1.2),
                                      ),
                                      const SizedBox(height: 24),

                                      // Selector Chips if multiple
                                      if (plans.length > 1)
                                        _buildPlanSelector(plans, selectedPlan),

                                      // Main Pricing Card
                                      if (selectedPlan != null) ...[
                                        _buildPricingCard(selectedPlan),
                                        const SizedBox(height: 28),
                                        
                                        // Coupon & Total Pricing Section
                                        _buildCouponSection(state, selectedPlan),
                                      ],
                                      const SizedBox(height: 24),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          // Bottom Continue Button
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Button.filled(
                              title: state.selectedSubscriptionModel != null &&
                                      state.selectedSubscriptionModel!.totalPriceIncludeDiscount > 0
                                  ? 'Upgrade My Gym'
                                  : 'Continue',
                              isDisabled: state.selectedSubscriptionModel == null,
                              isLoading: isPaying,
                              ontap: () => _cubit.payment(),
                              buttonColor: AppColors.primary,
                              disabledButtonColor: AppColors.primary.withOpacity(0.5),
                              raduis: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(8, (index) {
        bool isActive = index <= 6;
        return Row(
          children: [
            Container(
              width: 15,
              height: 2,
              color: isActive ? AppColors.primary : AppColors.borderGrey,
            ),
            Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 6,
                height: 6,
                color: isActive ? AppColors.primary : AppColors.borderGrey,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPlanSelector(
    List<SubscriptionPlanModel> plans,
    SubscriptionPlanModel? selected,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: plans.map((plan) {
          final isSelected = plan.id == selected?.id;
          return GestureDetector(
            onTap: () {
              _couponController.clear();
              _cubit.selectSubscription(plan);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : const Color(0xffEEEEEE),
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                plan.name ?? '',
                style: AppStyles.text13Px.poppins.w600.copyWith(
                  color: isSelected ? Colors.white : AppColors.dark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).pOnly(bottom: 24);
  }

  Widget _buildPricingCard(SubscriptionPlanModel plan) {
    final hasDiscount =
        plan.totalPriceExcludeDiscount > plan.totalPriceIncludeDiscount;
    final isYearly = plan.period == 365;
    final billingSuffix =
        isYearly
            ? '/year'
            : (plan.period == 30 ? '/month' : '/${plan.period} days');
    final monthlySubtext =
        isYearly
            ? '(₹${plan.perMonthPriceIncludeDisount.toStringAsFixed(0)}/month billed annually)'
            : '(₹${plan.totalPriceIncludeDiscount.toStringAsFixed(0)}/month)';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffFFEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [Color(0xffFF8A8A), Color(0xffFFD6A4)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (hasDiscount && plan.totalPriceExcludeDiscount > 0) ...[
                        Text(
                          '₹${plan.totalPriceExcludeDiscount.toStringAsFixed(0)}',
                          style: AppStyles.text16Px.poppins.w400.copyWith(
                            color: const Color(0xff444444),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '₹${plan.totalPriceIncludeDiscount.toStringAsFixed(0)}',
                        style: AppStyles.text28Px.poppins.w700.dark,
                      ),
                      Text(
                        billingSuffix,
                        style: AppStyles.text14Px.poppins.w500.dark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthlySubtext,
                    style: AppStyles.text12Px.poppins.w400.dark.copyWith(
                      color: AppColors.dark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Benefits
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildBenefitRow(
                  'EMI facility for members',
                  'Increase conversions by offering\nflexible payment options.',
                ),
                const SizedBox(height: 16),
                _buildBenefitRow(
                  'Listing on Discipl Customer App.',
                  'Be discovered by serious fitness\nseekers across your region.',
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Color(0xffDC2626), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'And all upcoming features.',
                        style: AppStyles.text14Px.poppins.w600.dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Color(0xffDC2626), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.text14Px.poppins.w600.dark,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppStyles.text12Px.poppins.w400.textGrey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCouponSection(
    SubscriptionState state,
    SubscriptionPlanModel plan,
  ) {
    final baseAmount = plan.totalPriceIncludeDiscount.toDouble();
    final discount = state.isCouponApplied ? state.couponDiscountAmount : 0.0;
    final totalToPay = (baseAmount - discount).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have a Coupon Code?',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter Coupon Code to avail special discounts',
          style: AppStyles.text12Px.poppins.w400.textGrey,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                style: AppStyles.text14Px.poppins.w500.dark,
                decoration: InputDecoration(
                  hintText: 'Enter Coupon Code',
                  hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            state.isCouponApplied
                ? Button.outlined(
                  title: 'Remove',
                  size: const Size(100, 48),
                  ontap: () {
                    _couponController.clear();
                    _cubit.removeCoupon();
                  },
                  raduis: 8,
                )
                : Button.filled(
                  title: 'Apply',
                  size: const Size(100, 48),
                  ontap: () {
                    final code = _couponController.text.trim();
                    if (code.isNotEmpty) {
                      _cubit.applyCoupon(code);
                    }
                  },
                  buttonColor: AppColors.primary,
                  raduis: 8,
                ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Coupon Code Discount:',
              style: AppStyles.text14Px.poppins.w400.textGrey,
            ),
            Text(
              '₹${discount.toStringAsFixed(0)}/-',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount to Pay:',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            Text(
              '₹${totalToPay.toStringAsFixed(0)}/-',
              style: AppStyles.text16Px.poppins.w700.dark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanOptionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade300,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
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
