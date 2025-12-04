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
                : null,
        body: Column(
          children: [
            if (widget.progress != 0)
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 20),
                  OrganizationCreationCompletionStatusCard(
                    progress: widget.progress ?? 0,
                  ),
                  const SizedBox(height: 28),
                ],
              )
            else
              const SizedBox(),
            Row(
              children: [
                Text(
                  widget.progress == 0 ? 'Current Packages' : 'Add Packages',
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
                                      Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              membership?.name ?? '',
                                              style:
                                                  AppStyles
                                                      .text14Px
                                                      .poppins
                                                      .w600
                                                      .dark,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
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
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ).pOnly(left: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
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
                                              // _cubit.deleteMembershipPackage(
                                              //   id: data.results?[index].id,
                                              // );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ).pOnly(left: 8),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 1,
                                        child: Divider(
                                          thickness: 1,
                                          color: Color(0xffDDDDDD),
                                        ),
                                      ).pOnly(bottom: 20, top: 12),
                                      // if (membership?.offerPrice?.isNotEmpty ??
                                      //     false)
                                      //   Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Text(
                                      //         'Offer Price',
                                      //         style:
                                      //             AppStyles
                                      //                 .text13Px
                                      //                 .poppins
                                      //                 .w400
                                      //                 .dark,
                                      //       ),
                                      //
                                      //       ///
                                      //       Text(
                                      //         '₹${membership?.offerPrice}',
                                      //         style:
                                      //             AppStyles
                                      //                 .text14Px
                                      //                 .poppins
                                      //                 .w500
                                      //                 .dark,
                                      //       ),
                                      //     ],
                                      //   ).pOnly(bottom: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Duration',
                                            style:
                                                AppStyles
                                                    .text13Px
                                                    .poppins
                                                    .w400
                                                    .dark,
                                          ),
                                          Text(
                                            // '${(membership?.durationDays ?? 0) ~/ 30} months',
                                            '${membership?.durationDays ?? 0} days',
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w500
                                                    .dark,
                                          ),
                                        ],
                                      ).pOnly(bottom: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            // 'Actual Price',
                                            'Amount',
                                            style:
                                                AppStyles
                                                    .text13Px
                                                    .poppins
                                                    .w400
                                                    .dark,
                                          ),

                                          ///
                                          Text(
                                            '₹${membership?.actualPrice}',
                                            style: AppStyles
                                                .text14Px
                                                .poppins
                                                .w500
                                                .dark
                                                .copyWith(
                                                  // decoration:
                                                  //     membership
                                                  //                 ?.offerPrice
                                                  //                 ?.isNotEmpty ??
                                                  //             false
                                                  //         ?
                                                  //     TextDecoration
                                                  //             .lineThrough
                                                  //         : null,
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

                                    context.pushAndRemoveUntil(
                                      const OrganizationCreationSuccessScreen(),
                                    );

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
