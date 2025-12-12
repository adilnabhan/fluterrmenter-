import 'package:mentor_mobile_app/imports_bindings.dart';

class GymPackagesScreen extends StatelessWidget {
  const GymPackagesScreen({
    required this.orgDetails,
    super.key,
    this.progress = 0,
  });

  final OrganizationDetailsModel orgDetails;
  final int? progress;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembershipCubit(orgId: '${orgDetails.id!}'),
      child: _GymPackagesScreen(orgDetails: orgDetails, progress: progress),
    );
  }
}

class _GymPackagesScreen extends StatefulWidget {
  const _GymPackagesScreen({required this.orgDetails, this.progress = 0});

  final OrganizationDetailsModel orgDetails;
  final int? progress;
  @override
  State<_GymPackagesScreen> createState() => __GymPackagesScreenState();
}

class __GymPackagesScreenState extends State<_GymPackagesScreen> {
  late final MembershipCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchMembershipPackages();
  }

  Future<void> _onDeletePackage({int? id}) async {
    if (id == null) return;

    await showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<MembershipCubit, MembershipState>(
          bloc: _cubit,
          builder: (context, state) {
            final isLoading = state.isDeleting;

            return PopScope(
              canPop: !isLoading,
              child: AlertDialog(
                title: const Text('Delete Package'),
                content: const Text(
                  'Are you sure you want to delete this package?',
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ),

                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              await _cubit.deleteMembershipPackage(id: id);
                              if (!mounted) return;
                              Navigator.of(
                                context,
                              ).pop(); // close dialog after deletion
                              _fetch();
                            },
                    child:
                        isLoading
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Deleting...',
                                  style: AppStyles.text14Px.poppins.w500
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            )
                            : Text(
                              'Delete',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: Colors.white,
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembershipCubit, MembershipState>(
      bloc: _cubit,
      listenWhen: (p, c) => p.createOrUpdatePackage != c.createOrUpdatePackage,
      listener: (context, state) {
        state.createOrUpdatePackage?.fold(
          () {},
          (either) => either.fold((error) {}, (success) {
            _fetch();
          }),
        );
      },
      child: Scaffold(
        appBar:
            widget.progress == 0
                ? AppBar(
                  leading: const PopButton().center,
                  title: Text(
                    'Package',
                    style: AppStyles.text16Px.poppins.w500,
                  ),
                )
                : AppBar(automaticallyImplyLeading: false),
        body: Column(
          children: [
            if (widget.progress != 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: MediaQuery.of(context).padding.top + 20),
                  // OrganizationCreationCompletionStatusCard(
                  //   progress: widget.progress ?? 0,
                  // ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      bool isActive = index <= 6; // Step 7 of 8
                      return Row(
                        children: [
                          Container(
                            width: 25,
                            height: 1,
                            color:
                                isActive
                                    ? AppColors.primary
                                    : AppColors.borderGrey,
                          ),
                          Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 8,
                              height: 8,
                              color:
                                  isActive
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Your Fitness \nPlans, Their \nChoices 💼',
                    textAlign: TextAlign.left,
                    style: AppStyles.text30Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add the membership packages users can subscribe to.',
                    style: AppStyles.text14Px.poppins.w400.textGrey,
                  ),
                  const SizedBox(height: 28),
                ],
              )
            else
              const SizedBox(),
            Row(
              children: [
                Text(
                  widget.progress == 0 ? 'Current Packages' : 'Packages',
                  style: AppStyles.text16Px.poppins.w500.dark,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    if (widget.orgDetails.id == null) {
                      Dialogs.showSnack(msg: 'Organization is not available');
                      return;
                    }
                    context.push(
                      BlocProvider.value(
                        value: _cubit,
                        child: const GymAddOrEditPackageScreen(),
                      ),
                    );
                  },
                  label: const Text('Add'),
                  icon: const Icon(Icons.add),
                  style: const ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(AppColors.primary),
                    backgroundColor: WidgetStatePropertyAll(Color(0xffFFEAEA)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MembershipCubit, MembershipState>(
                buildWhen:
                    (p, c) => p.membershipPackages != c.membershipPackages,
                builder: (context, state) {
                  return state.membershipPackages.fold(
                    () => const Center(child: CircularProgressIndicator()),
                    (either) => either.fold(
                      (error) => error.maybeWhen(
                        network: (e) => ErrorUi.network(onTap: _fetch),
                        notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                        orElse: () => ErrorUi.server(onTap: _fetch),
                      ),
                      (data) {
                        if (data.results?.isEmpty ?? true) {
                          return ErrorUi.empty().center;
                        }
                        return RefreshIndicator(
                          onRefresh: _fetch,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: data.results?.length ?? 0,
                            separatorBuilder: (
                              BuildContext context,
                              int index,
                            ) {
                              return const SizedBox(height: 16);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final membership = data.results?[index];
                              return InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.light,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.borderGrey,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // EXISTING CODE - COMMENTED OUT
                                      // Row(
                                      //   // mainAxisAlignment:
                                      //   //     MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Expanded(
                                      //       child: Text(
                                      //         membership?.name ?? '',
                                      //         style:
                                      //             AppStyles
                                      //                 .text14Px
                                      //                 .poppins
                                      //                 .w600
                                      //                 .dark,
                                      //       ),
                                      //     ),
                                      //     IconButton(
                                      //       icon: const Icon(Icons.edit),
                                      //       onPressed: () {
                                      //         if (widget.orgDetails.id ==
                                      //             null) {
                                      //           Dialogs.showSnack(
                                      //             msg:
                                      //                 'Organization is not available',
                                      //           );
                                      //           return;
                                      //         }
                                      //         context.push(
                                      //           BlocProvider.value(
                                      //             value: _cubit,
                                      //             child:
                                      //                 GymAddOrEditPackageScreen(
                                      //                   membershipPackage:
                                      //                       membership,
                                      //                 ),
                                      //           ),
                                      //         );
                                      //       },
                                      //       style: TextButton.styleFrom(
                                      //         foregroundColor: Colors.red,
                                      //       ),
                                      //     ).pOnly(left: 8),
                                      //     IconButton(
                                      //       icon: const Icon(Icons.delete),
                                      //       onPressed: () {
                                      //         if (widget.orgDetails.id ==
                                      //             null) {
                                      //           Dialogs.showSnack(
                                      //             msg:
                                      //                 'Organization is not available',
                                      //           );
                                      //           return;
                                      //         }
                                      //         _onDeletePackage(
                                      //           id: data.results?[index].id,
                                      //         );
                                      //         // _cubit.deleteMembershipPackage(
                                      //         //   id: data.results?[index].id,
                                      //         // );
                                      //       },
                                      //       style: TextButton.styleFrom(
                                      //         foregroundColor: Colors.red,
                                      //       ),
                                      //     ).pOnly(left: 8),
                                      //   ],
                                      // ),
                                      // const SizedBox(
                                      //   height: 1,
                                      //   child: Divider(
                                      //     thickness: 1,
                                      //     color: Color(0xffDDDDDD),
                                      //   ),
                                      // ).pOnly(bottom: 20, top: 12),
                                      // // if (membership?.offerPrice?.isNotEmpty ??
                                      // //     false)
                                      // //   Row(
                                      // //     mainAxisAlignment:
                                      // //         MainAxisAlignment.spaceBetween,
                                      // //     children: [
                                      // //       Text(
                                      // //         'Offer Price',
                                      // //         style:
                                      // //             AppStyles
                                      // //                 .text13Px
                                      // //                 .poppins
                                      // //                 .w400
                                      // //                 .dark,
                                      // //       ),
                                      // //
                                      // //       ///
                                      // //       Text(
                                      // //         '₹${membership?.offerPrice}',
                                      // //         style:
                                      // //             AppStyles
                                      // //                 .text14Px
                                      // //                 .poppins
                                      // //                 .w500
                                      // //                 .dark,
                                      // //       ),
                                      // //     ],
                                      // //   ).pOnly(bottom: 16),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //       'Duration',
                                      //       style:
                                      //           AppStyles
                                      //               .text13Px
                                      //               .poppins
                                      //               .w400
                                      //               .dark,
                                      //     ),
                                      //     Text(
                                      //       // '${(membership?.durationDays ?? 0) ~/ 30} months',
                                      //       '${membership?.durationDays ?? 0} days',
                                      //       style:
                                      //           AppStyles
                                      //               .text14Px
                                      //               .poppins
                                      //               .w500
                                      //               .dark,
                                      //     ),
                                      //   ],
                                      // ).pOnly(bottom: 16),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //       // 'Actual Price',
                                      //       'Amount',
                                      //       style:
                                      //           AppStyles
                                      //               .text13Px
                                      //               .poppins
                                      //               .w400
                                      //               .dark,
                                      //     ),
                                      //
                                      //     ///
                                      //     Text(
                                      //       '₹${membership?.actualPrice}',
                                      //       style: AppStyles
                                      //           .text14Px
                                      //           .poppins
                                      //           .w500
                                      //           .dark
                                      //           .copyWith(
                                      //             // decoration:
                                      //             //     membership
                                      //             //                 ?.offerPrice
                                      //             //                 ?.isNotEmpty ??
                                      //             //             false
                                      //             //         ?
                                      //             //     TextDecoration
                                      //             //             .lineThrough
                                      //             //         : null,
                                      //           ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // END OF EXISTING CODE

                                      // NEW UI DESIGN - MATCHING REFERENCE IMAGE
                                      // Header with Plan Name and Edit/Delete Icons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            membership?.name ?? '',
                                            style:
                                                AppStyles
                                                    .text16Px
                                                    .poppins
                                                    .w600
                                                    .dark,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  if (widget.orgDetails.id ==
                                                      null) {
                                                    Dialogs.showSnack(
                                                      msg:
                                                          'Organization is not available',
                                                    );
                                                    return;
                                                  }
                                                  context.push(
                                                    BlocProvider.value(
                                                      value: _cubit,
                                                      child:
                                                          GymAddOrEditPackageScreen(
                                                            membershipPackage:
                                                                membership,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                style: IconButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xff666666,
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xffF5F5F5,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  if (widget.orgDetails.id ==
                                                      null) {
                                                    Dialogs.showSnack(
                                                      msg:
                                                          'Organization is not available',
                                                    );
                                                    return;
                                                  }
                                                  _onDeletePackage(
                                                    id: data.results?[index].id,
                                                  );
                                                },
                                                style: IconButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  backgroundColor: const Color(
                                                    0xffF5F5F5,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // Offer Price (if available)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Actual Price',
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w400
                                                    .dark,
                                          ),
                                          Text(
                                            '₹${membership?.actualPrice}',
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w500
                                                    .dark,
                                          ),
                                        ],
                                      ),
                                      if (membership?.offerPrice?.isNotEmpty ??
                                          false)
                                        Column(
                                          children: [
                                            SizedBox(height: 10.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'offer Price',
                                                  style:
                                                      AppStyles
                                                          .text14Px
                                                          .poppins
                                                          .w400
                                                          .dark,
                                                ),
                                                if (membership
                                                        ?.offerPrice
                                                        ?.isNotEmpty ??
                                                    false)
                                                  Text(
                                                    '₹${membership?.offerPrice}',
                                                    style:
                                                        AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w500
                                                            .dark,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),

                                      // EMI Options Section (if available)
                                      if (membership?.isEmiAvailable == true &&
                                          (membership?.emiPlans.isNotEmpty ??
                                              false))
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffF8F8F8),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'EMI Option',
                                                    style:
                                                        AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w600
                                                            .dark,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  ...membership!.emiPlans.map((
                                                    emi,
                                                  ) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 8,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            '${emi.month} Month',
                                                            style:
                                                                AppStyles
                                                                    .text13Px
                                                                    .poppins
                                                                    .w400
                                                                    .dark,
                                                          ),
                                                          Text(
                                                            '₹${emi.price.toStringAsFixed(0)}',
                                                            style:
                                                                AppStyles
                                                                    .text13Px
                                                                    .poppins
                                                                    .w500
                                                                    .dark,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ).pad(16),
        // bottomNavigationBar: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        //   buildWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead || p.createOrUpdateMember != c.createOrUpdateMember,
        //   builder: (context, state) {
        //     return Button.filled(
        //       title: 'Save',
        //       // isLoading: widget.details?.fold((l) => state.createOrUpdateLead, (r) => state.createOrUpdateMember)?.isNone() ?? false,
        //       buttonColor: AppColors.primary,
        //       // ontap: _onContinue,
        //       ontap: () {},
        //     );
        //   },
        // ).pad(16).pxy(y: 16),
        bottomNavigationBar:
            widget.progress != 0
                ? BlocBuilder<MembershipCubit, MembershipState>(
                  buildWhen:
                      (p, c) => p.membershipPackages != c.membershipPackages,
                  builder: (context, state) {
                    return state.membershipPackages.fold(
                      () => const Center(child: CircularProgressIndicator()),
                      (either) => either.fold(
                        (error) => error.maybeWhen(
                          network: (e) => const SizedBox(),
                          notFound: (e) => const SizedBox(),
                          orElse: () => const SizedBox(),
                        ),
                        (data) {
                          return data.results!.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Button.filled(
                                  title: 'Continue',
                                  buttonColor: AppColors.primary,

                                  ontap: () {
                                    context.read<AppCubit>().onboardingUpdate(
                                      body: {'profile_completeness': 7},
                                      id: int.parse(_cubit.orgId),
                                    );

                                    // EXISTING CODE - COMMENTED OUT (Using BlocProvider.value which may not work properly)
                                    // final cubit =
                                    //     context
                                    //         .read<
                                    //           OrganizationListingAndDetailsCubit
                                    //         >();
                                    // context.pushAndRemoveUntil(
                                    //   BlocProvider.value(
                                    //     value: cubit,
                                    //     child: SubscriptionPlanChooseCom(
                                    //       orgDetails: OrganizationDetailsModel(
                                    //         id: widget.orgDetails.id,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // );

                                    // FIXED CODE - Using MultiBlocProvider pattern like other screens
                                    context.pushAndRemoveUntil(
                                      MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create:
                                                (_) =>
                                                    OrganizationListingAndDetailsCubit(),
                                          ),
                                        ],
                                        child: SubscriptionPlanChooseCom(
                                          orgDetails: OrganizationDetailsModel(
                                            id: widget.orgDetails.id,
                                          ),
                                        ),
                                      ),
                                    );

                                    // context.pushAndRemoveUntil(
                                    //   const OrganizationCreationSuccessScreen(),
                                    // );

                                    print(
                                      ' calimng save api--go to succes page',
                                    );
                                  },
                                ),
                              )
                              : const SizedBox();
                        },
                      ),
                    );
                  },
                )
                : const SizedBox(),
      ),
    );
  }
}
