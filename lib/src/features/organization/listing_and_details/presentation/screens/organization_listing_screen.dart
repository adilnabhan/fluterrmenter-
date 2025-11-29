import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationListingScreen extends StatelessWidget {
  const OrganizationListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizationListingAndDetailsCubit(),
      child: BlocListener<
        OrganizationListingAndDetailsCubit,
        OrganizationListingAndDetailsState
      >(
        listenWhen: (p, c) => p.details != c.details,
        listener: (context, state) {
          state.details.fold(() {}, (either) {
            either.fold((error) {}, (orgDetails) {
              if (orgDetails.id == null) {
                Dialogs.showSnack(msg: 'Organization not found');
              }
              // else if (!(orgDetails.isOnFreeTrial ?? false) && !(orgDetails.isSubscribed ?? false)) {
              //   Dialogs.showSnack(msg: '${orgDetails.name} subscription expired. Please renew to continue.', duration: const Duration(seconds: 5));
              //   context.pushAndRemoveUntil(SubscriptionPlanChooseScreen(orgDetails: orgDetails));
              // }
            });
          });
        },
        child: const _OrganizationListingAndDetailsScreen(),
      ),
    );
  }
}

class _OrganizationListingAndDetailsScreen extends StatefulWidget {
  const _OrganizationListingAndDetailsScreen();

  @override
  State<_OrganizationListingAndDetailsScreen> createState() =>
      _OrganizationListingAndDetailsScreenState();
}

class _OrganizationListingAndDetailsScreenState
    extends State<_OrganizationListingAndDetailsScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _fetch(isRefresh: true);
  }

  void _fetch({bool isRefresh = false}) {
    _cubit.fetchList(isRefresh: isRefresh);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      OrganizationListingAndDetailsCubit,
      OrganizationListingAndDetailsState
    >(
      listenWhen: (p, c) => p.selectedOrganization != c.selectedOrganization,
      listener: (context, state) {
        if (state.selectedOrganization?.id != null) {
          _cubit.fetchOrg(orgId: state.selectedOrganization!.id!);
        }
      },
      child: BlocBuilder<
        OrganizationListingAndDetailsCubit,
        OrganizationListingAndDetailsState
      >(
        buildWhen: (p, c) => p.details != c.details || p.list != c.list,
        builder: (context, state) {
          final hasData =
              state.list.fold(
                () => false,
                (t) => t.fold((_) => false, (_) => true),
              ) &&
              state.details.fold(
                () => false,
                (t) => t.fold((_) => false, (_) => true),
              );
          return Scaffold(
            appBar:
                hasData
                    ? AppBar(
                      title: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          side: const BorderSide(color: Color(0xffDDDDDD)),
                        ),
                        onPressed: () {
                          const OrganizationSelectionSheet().show(
                            context,
                            _cubit,
                          );
                        },
                        label: const Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Color(0xff222222),
                          size: 20,
                        ),
                        icon: Text(
                          state.selectedOrganization?.name ?? '',
                          style: AppStyles.text14Px.poppins.copyWith(
                            color: const Color(0xff222222),
                          ),
                        ),
                      ),
                      centerTitle: false,
                      actions: [
                        InkWell(
                          borderRadius: BorderRadius.circular(999999),
                          onTap: () {
                            if (state.selectedOrganization?.id != null) {
                              context.push(
                                BlocProvider.value(
                                  value: _cubit,
                                  child: OrganizationDetailsScreen(
                                    orgId: state.selectedOrganization!.id!,
                                  ),
                                ),
                              );
                            } else {
                              Dialogs.showSnack(msg: 'Organization not found');
                            }
                          },
                          child: AbsorbPointer(
                            child: ProfileImage(
                              isEdit: false,
                              radius: 48,
                              url: state.selectedOrganization?.logo ?? '',
                            ),
                          ),
                        ).pOnly(right: 16),
                      ],
                    )
                    : null,
            body: BlocBuilder<
              OrganizationListingAndDetailsCubit,
              OrganizationListingAndDetailsState
            >(
              buildWhen:
                  (p, c) =>
                      p.homeData != c.homeData ||
                      p.selectedOrganization != c.selectedOrganization ||
                      p.details != c.details,
              builder: (context, state) {
                return state.details.fold(_onLoading, (either) {
                  return either.fold(_onError, (orgDetails) {
                    if (!(orgDetails.isOnFreeTrial ?? false) &&
                        !(orgDetails.isSubscribed ?? false)) {
                      return SubscriptionPlanChooseCom(orgDetails: orgDetails);
                    }
                    return state.homeData.fold(
                      _onLoading,
                      (either) => either.fold(_onError, (orgHomeData) {
                        final cards = [
                          (
                            title: 'Active Memberships',
                            color: const Color(0xff486CC2),
                            count: orgHomeData.activeCustomersCount ?? 0,
                            onTap: () {
                              if (state.selectedOrganization?.id != null) {
                                context.push(
                                  ActiveMembersListingScreen(
                                    orgId: state.selectedOrganization!.id!,
                                  ),
                                );
                              } else {
                                Dialogs.showSnack(
                                  msg: 'Organization not found',
                                );
                              }
                            },
                          ),
                          (
                            title: 'Total Members & Trainers',
                            color: const Color(0xff9C51BF),
                            count:
                                (orgHomeData.trainerCount ?? 0) +
                                (orgHomeData.expiredCustomersCount ?? 0) +
                                (orgHomeData.activeCustomersCount ?? 0),
                            onTap: () {
                              if (state.selectedOrganization?.id != null) {
                                context.push(
                                  MembersAndLeadsListingScreen(
                                    orgId: state.selectedOrganization!.id!,
                                  ),
                                );
                              } else {
                                Dialogs.showSnack(
                                  msg: 'Organization not found',
                                );
                              }
                            },
                          ),
                          (
                            title: 'Expired Memberships',
                            color: const Color(0xff527F50),
                            count: orgHomeData.expiredCustomersCount ?? 0,
                            onTap: () {
                              if (state.selectedOrganization?.id != null) {
                                context.push(
                                  ExpiredMembersListingScreen(
                                    orgId: state.selectedOrganization!.id!,
                                  ),
                                );
                              } else {
                                Dialogs.showSnack(
                                  msg: 'Organization not found',
                                );
                              }
                            },
                          ),
                          (
                            title: 'Upcoming Renewals',
                            color: const Color(0xffC85074),
                            count: orgHomeData.upcomingRenewalsCount ?? 0,
                            onTap: () {
                              if (state.selectedOrganization?.id != null) {
                                context.push(
                                  UpcomingRenewalsListingScreen(
                                    orgId: state.selectedOrganization!.id!,
                                  ),
                                );
                              } else {
                                Dialogs.showSnack(
                                  msg: 'Organization not found',
                                );
                              }
                            },
                          ),
                          (
                            title: 'Upcoming EMIs',
                            color: const Color(0xff486CC2),
                            count: orgHomeData.upcomingPaymentCount ?? 0,
                            onTap: () {
                              if (state.selectedOrganization?.id != null) {
                                context.push(
                                  PaymentUpcomingViewScreen(
                                    orgId: state.selectedOrganization!.id!,
                                  ),
                                );
                              } else {
                                Dialogs.showSnack(
                                  msg: 'Upcoming EMIs not found',
                                );
                              }
                            },
                          ),
                        ];
                        return RefreshIndicator(
                          onRefresh: () async => _fetch(isRefresh: true),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              ListView(
                                padding: const EdgeInsets.all(16),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          mainAxisExtent: 128,
                                        ),
                                    itemCount: cards.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final card = cards[index];
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: card.onTap,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: ColoredBox(
                                            color: card.color.withAlpha(25),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  card.count.toString(),
                                                  style: AppStyles
                                                      .text20Px
                                                      .poppins
                                                      .w800
                                                      .copyWith(
                                                        color: card.color,
                                                      ),
                                                ),
                                                const Spacer(),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: Text(
                                                          card.title,
                                                          style: AppStyles
                                                              .text14Px
                                                              .poppins
                                                              .w600
                                                              .copyWith(
                                                                color:
                                                                    card.color,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          card.color,
                                                      radius: 18,
                                                      child: const Icon(
                                                        Icons
                                                            .keyboard_arrow_right_outlined,
                                                        color: AppColors.light,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ).pad(16),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                  const AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                      child: ImageNetwork(
                                        'https://images.ctfassets.net/0k812o62ndtw/WE3fGLHIvifgzs7iBw9Le/e66c3a58d6558193a49c1eaac72b713d/Gym_-_Kayla_-_7108-1024x683-27c3a53.jpg',
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Customer Support Section
                                  // Container(
                                  //   padding: const EdgeInsets.all(16),
                                  //   decoration: BoxDecoration(
                                  //     color: AppColors.primary.withAlpha(25),
                                  //     borderRadius: BorderRadius.circular(16),
                                  //     border: Border.all(
                                  //       color: AppColors.primary.withAlpha(50),
                                  //     ),
                                  //   ),
                                  //   child: Column(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Row(
                                  //         children: [
                                  //           const Icon(
                                  //             Icons.support_agent,
                                  //             color: AppColors.primary,
                                  //             size: 20,
                                  //           ),
                                  //           const SizedBox(width: 8),
                                  //           Text(
                                  //             'Need Help?',
                                  //             style: AppStyles
                                  //                 .text16Px
                                  //                 .poppins
                                  //                 .w600
                                  //                 .copyWith(
                                  //                   color: AppColors.primary,
                                  //                 ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       const SizedBox(height: 12),
                                  //       Text(
                                  //         'Get instant support via WhatsApp or call us directly',
                                  //         style: AppStyles.text12Px.poppins.w400
                                  //             .copyWith(
                                  //               color: AppColors.dark.withAlpha(
                                  //                 150,
                                  //               ),
                                  //             ),
                                  //       ),
                                  //       const SizedBox(height: 16),
                                  //       Row(
                                  //         children: [
                                  //           Expanded(
                                  //             child: InkWell(
                                  //               onTap:
                                  //                   CustomerSupportServices
                                  //                       .whatsappChat,
                                  //               borderRadius:
                                  //                   BorderRadius.circular(12),
                                  //               child: Container(
                                  //                 padding:
                                  //                     const EdgeInsets.symmetric(
                                  //                       vertical: 12,
                                  //                       horizontal: 16,
                                  //                     ),
                                  //                 decoration: BoxDecoration(
                                  //                   color: const Color(
                                  //                     0xff25D366,
                                  //                   ),
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                         12,
                                  //                       ),
                                  //                 ),
                                  //                 child: Row(
                                  //                   mainAxisAlignment:
                                  //                       MainAxisAlignment
                                  //                           .center,
                                  //                   children: [
                                  //                     const Icon(
                                  //                       Icons.chat,
                                  //                       color: Colors.white,
                                  //                       size: 18,
                                  //                     ),
                                  //                     const SizedBox(width: 8),
                                  //                     Text(
                                  //                       'WhatsApp',
                                  //                       style: AppStyles
                                  //                           .text14Px
                                  //                           .poppins
                                  //                           .w600
                                  //                           .copyWith(
                                  //                             color:
                                  //                                 Colors.white,
                                  //                           ),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //           const SizedBox(width: 12),
                                  //           Expanded(
                                  //             child: InkWell(
                                  //               onTap:
                                  //                   CustomerSupportServices
                                  //                       .phoneCall,
                                  //               borderRadius:
                                  //                   BorderRadius.circular(12),
                                  //               child: Container(
                                  //                 padding:
                                  //                     const EdgeInsets.symmetric(
                                  //                       vertical: 12,
                                  //                       horizontal: 16,
                                  //                     ),
                                  //                 decoration: BoxDecoration(
                                  //                   color: AppColors.primary,
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                         12,
                                  //                       ),
                                  //                 ),
                                  //                 child: Row(
                                  //                   mainAxisAlignment:
                                  //                       MainAxisAlignment
                                  //                           .center,
                                  //                   children: [
                                  //                     const Icon(
                                  //                       Icons.phone,
                                  //                       color: Colors.white,
                                  //                       size: 18,
                                  //                     ),
                                  //                     const SizedBox(width: 8),
                                  //                     Text(
                                  //                       'Call Us',
                                  //                       style: AppStyles
                                  //                           .text14Px
                                  //                           .poppins
                                  //                           .w600
                                  //                           .copyWith(
                                  //                             color:
                                  //                                 Colors.white,
                                  //                           ),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                              ColoredBox(
                                color: const Color(0xffF7F7F7),
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 60),
                                      Text(
                                        'Did you know?',
                                        style:
                                            AppStyles
                                                .text14Px
                                                .poppins
                                                .w500
                                                .dark,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Strong Businesses',
                                        style: AppStyles.text26Px.titanOne.w400
                                            .copyWith(
                                              color: const Color(0xff878787),
                                            ),
                                      ),
                                      Text(
                                        'Made',
                                        style: AppStyles.text36Px.titanOne.w400
                                            .copyWith(
                                              color: const Color(0xff878787),
                                            ),
                                      ),
                                      Text(
                                        'Not Born',
                                        style: AppStyles.text26Px.titanOne.w400
                                            .copyWith(
                                              color: const Color(0xff878787),
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Built by fitness lovers 🧡',
                                        style: AppStyles.text14Px.poppins.w400
                                            .copyWith(
                                              color: const Color(0xff666666),
                                            ),
                                      ),
                                      const SizedBox(height: 132),
                                    ],
                                  ).pxy(x: 20),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  });
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _onLoading() {
    return Scaffold(
      appBar: AppBar(
        title: KShimmer(
          height: 36,
          width: context.width * .35,
          radius: 9999999,
        ),
        centerTitle: false,
        actions: [
          const KShimmer(
            height: 48,
            width: 48,
            radius: 9999999,
          ).pOnly(right: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetch(isRefresh: true),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 108,
                  ),
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColoredBox(
                        color: Colors.grey.shade100,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KShimmer(height: 24, width: 60, radius: 4),
                            Spacer(),
                            Row(
                              children: [
                                Flexible(
                                  child: KShimmer(
                                    height: 16,
                                    width: double.maxFinite,
                                    radius: 4,
                                  ),
                                ),
                                SizedBox(width: 8),
                                KShimmer(height: 36, width: 36, radius: 18),
                              ],
                            ),
                          ],
                        ).pad(16),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: KShimmer(),
                  ),
                ),
                const SizedBox(height: 40),
                // Customer Support Shimmer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          KShimmer(height: 20, width: 20, radius: 10),
                          SizedBox(width: 8),
                          KShimmer(height: 16, width: 80, radius: 4),
                        ],
                      ),
                      SizedBox(height: 12),
                      KShimmer(height: 12, width: double.maxFinite, radius: 4),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: KShimmer(
                              height: 44,
                              width: double.maxFinite,
                              radius: 12,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: KShimmer(
                              height: 44,
                              width: double.maxFinite,
                              radius: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
            ColoredBox(
              color: const Color(0xffF7F7F7),
              child: SizedBox(
                width: double.maxFinite,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60),
                    KShimmer(height: 16, width: 120, radius: 4),
                    SizedBox(height: 24),
                    KShimmer(height: 26, width: 200, radius: 4),
                    KShimmer(height: 36, width: 150, radius: 4),
                    KShimmer(height: 26, width: 180, radius: 4),
                    SizedBox(height: 24),
                    KShimmer(height: 16, width: 180, radius: 4),
                    SizedBox(height: 132),
                  ],
                ).pxy(x: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onError(ApiException error) =>
      error
          .maybeWhen(
            network: (e) => ErrorUi.network(onTap: _fetch),
            notFound: (e) => ErrorUi.notFound(onTap: _fetch),
            orElse: () => ErrorUi.server(onTap: _fetch),
          )
          .center;
}
