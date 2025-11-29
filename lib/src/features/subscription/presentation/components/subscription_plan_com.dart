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
