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
  @override
  void initState() {
    _cubit = context.read<SubscriptionCubit>();
    _parentCubit = context.read<OrganizationListingAndDetailsCubit>();
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
              // ============ OLD NAVIGATION COMMENTED OUT ============
              // context.pushAndRemoveUntil(const OrganizationListingScreen());
              // ============ END OLD NAVIGATION COMMENTED OUT ============

              // ============ NEW NAVIGATION TO SUCCESS SCREEN ============
              context.pushAndRemoveUntil(const SubscriptionSuccessScreen());
              // ============ END NEW NAVIGATION TO SUCCESS SCREEN ============
            },
          );
        });
      },
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        buildWhen: (p, c) => p.payment != c.payment,
        builder: (context, state) {
          return PopScope(
            canPop: !(state.payment?.isNone() ?? false),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/debug/planbackground.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ============ COMMENTED OUT PROGRESS BAR ============
                          // const SizedBox(height: 10),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: List.generate(8, (index) {
                          //     bool isActive = index <= 5; // Example progress
                          //     return Row(
                          //       children: [
                          //         Container(
                          //           width: 25,
                          //           height: 1,
                          //           color: isActive ? const Color(0xFFE22121) : Colors.grey,
                          //         ),
                          //         Transform.rotate(
                          //           angle: 0.785398,
                          //           child: Container(
                          //             width: 8,
                          //             height: 8,
                          //             color: isActive ? const Color(0xFFE22121) : Colors.grey,
                          //           ),
                          //         ),
                          //       ],
                          //     );
                          //   }),
                          // ),
                          // ============ END COMMENTED OUT PROGRESS BAR ============
                          const SizedBox(height: 40),
                          Text(
                            'Choose Your\nDiscipl Plan 🔥',
                            style: AppStyles.text30Px.poppins.w600.light,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '30-day trial period is available for all\nsubscription plans.',
                            style: AppStyles.text14Px.poppins.w400.light
                                .copyWith(color: Colors.white.withOpacity(0.8)),
                          ),
                          const Spacer(flex: 2),
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
                                disabledButtonColor: Colors.white.withOpacity(
                                  0.5,
                                ),
                                loadingColor: Colors.black,
                                style: AppStyles.text16Px.poppins.w600.dark,
                                raduis: 12,
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============ OLD BUILD METHOD COMMENTED OUT ============
  /*
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
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white, // Background color
                body: Stack(
                  children: [
                    Positioned(
                      top: context.height * .08,
                      right: 32,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/dumble.svg',
                        fit: BoxFit.scaleDown,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          AppColors.dark,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: context.height * .28,
                      right: context.width * .25,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/hart.svg',
                        fit: BoxFit.scaleDown,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          AppColors.dark,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: context.height * .38,
                      left: 32,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/shoe.svg',
                        fit: BoxFit.scaleDown,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          AppColors.dark,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: context.height * .4,
                      right: 16,
                      child: SvgPicture.asset(
                        'assets/images/svg/vectors/showing_power.svg',
                        fit: BoxFit.scaleDown,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          AppColors.dark,
                          BlendMode.srcIn,
                        ),
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
                            style: AppStyles.text24Px.poppins.w700.dark,
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            text: TextSpan(
                              style: AppStyles.text14Px.poppins.w400.dark,
                              children: const [
                                TextSpan(
                                  text: '15-day',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                          buttonColor: AppColors.primary,
                                          style:
                                              AppStyles
                                                  .text14Px
                                                  .poppins
                                                  .w600
                                                  .light,
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
                                buttonColor: AppColors.primary,
                                disabledButtonColor: AppColors.primary
                                    .withAlpha(125),
                                loadingColor: Colors.white,
                                style: AppStyles.text14Px.poppins.w600.light,
                                raduis: 12,
                              );
                            },
                          ),
                          // const SizedBox(height: 20),
                          // Center(
                          //   child: InkWell(
                          //     onTap: () {
                          //       _parentCubit.skipSubscriptionCheck();
                          //     },
                          //     borderRadius: BorderRadius.circular(12),
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Text(
                          //         'Skip',
                          //         style: AppStyles.text14Px.poppins.w600
                          //             .copyWith(
                          //           color: AppColors.dark.withOpacity(0.7),
                          //           decoration: TextDecoration.underline,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const Spacer(),
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
  */

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
          // ============ NEW GRADIENT CODE ============
          gradient: const LinearGradient(
            colors: [
              Color(0xFF280C0C), // Darker red/brown from left
              Color(0xFF5E2323), // Lighter red/brown to right
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          // ============ END NEW GRADIENT CODE ============
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? const Color(
                      0xFFD9A6A6,
                    ) // Light pinkish border when selected
                    : const Color(
                      0xFFD9A6A6,
                    ).withOpacity(0.3), // Subtle border for non-selected
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan?.name ?? '',
                      style: AppStyles.text16Px.poppins.w600.light,
                    ),
                    const SizedBox(height: 8),
                    if ((plan?.discountedPrice?.isNotEmpty ?? false) &&
                        (plan?.regularPrice?.isNotEmpty ?? false) &&
                        plan?.regularPrice != plan?.discountedPrice)
                      Row(
                        children: [
                          Text(
                            'Total ₹${plan?.discountedPrice ?? 00}',
                            style: AppStyles.text12Px.poppins.w400.light
                                .copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff713E3E),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Save ₹${plan?.totalDiscount ?? 00}',
                              style: AppStyles.text12Px.poppins.w400.light,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppStyles.text16Px.poppins.w700.light,
                        children: [
                          if (plan?.discountedPrice?.isNotEmpty ?? false)
                            TextSpan(
                              text:
                                  '₹${plan?.perMonthPriceExcludeDiscount.toStringAsFixed(0)}',
                              style: AppStyles.text14Px.poppins.w300.light
                                  .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                            ),
                          if (plan?.regularPrice?.isNotEmpty ?? false)
                            const WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(
                            text:
                                '₹${plan?.perMonthPriceIncludeDisount.toStringAsFixed(0)}',
                            style: AppStyles.text18Px.poppins.w700.light,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'per month',
                      style: AppStyles.text12Px.poppins.w400.light,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ OLD _buildPlanOption COMMENTED OUT ============
  /*
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
          color: !isSelected ? Colors.grey.shade100 : null,
          gradient:
              !isSelected
                  ? null
                  : const LinearGradient(
                    colors: [Color(0xFF290F0F), Color(0xff581F1F)],
                  ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xffC39191) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan?.name ?? '',
                  style:
                      isSelected
                          ? AppStyles.text14Px.poppins.w500.light
                          : AppStyles.text14Px.poppins.w500.dark,
                ),
                RichText(
                  text: TextSpan(
                    style:
                        isSelected
                            ? AppStyles.text16Px.poppins.w700.light
                            : AppStyles.text16Px.poppins.w700.dark,
                    children: [
                      if (plan?.discountedPrice?.isNotEmpty ?? false)
                        TextSpan(
                          text:
                              '₹${plan?.perMonthPriceExcludeDiscount.toStringAsFixed(2)}',
                          style: (isSelected
                                  ? AppStyles.text14Px.poppins.w300.light
                                  : AppStyles.text14Px.poppins.w300.dark)
                              .copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      if (plan?.regularPrice?.isNotEmpty ?? false)
                        const WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(
                        text:
                            '₹${plan?.perMonthPriceIncludeDisount.toStringAsFixed(2)}',
                        style:
                            isSelected
                                ? AppStyles.text16Px.poppins.w700.light
                                : AppStyles.text16Px.poppins.w700.dark,
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
                        style:
                            isSelected
                                ? AppStyles.text12Px.poppins.w400.light
                                : AppStyles.text12Px.poppins.w400.dark,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xff713E3E)
                                  : AppColors.primary.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Save ₹${plan?.totalDiscount ?? 00}',
                          style:
                              isSelected
                                  ? AppStyles.text12Px.poppins.w400.light
                                  : AppStyles.text12Px.poppins.w400.dark
                                      .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
                // Text('per month', style: isSelected ? AppStyles.text12Px.poppins.w400.light : AppStyles.text12Px.poppins.w400.dark),
              ],
            ),
          ],
        ),
      ),
    );
  }
  */

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
