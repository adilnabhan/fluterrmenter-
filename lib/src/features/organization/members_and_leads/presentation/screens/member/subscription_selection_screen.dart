import 'package:mentor_mobile_app/imports_bindings.dart';

class SubscriptionSelectionScreen extends StatelessWidget {
  const SubscriptionSelectionScreen({
    required this.orgId,
    required this.memberDetails,
    super.key,
  });

  final MemberDetailsModel memberDetails;
  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembershipCubit(orgId: '$orgId'),
      child: _SubscriptionSelectionScreen(memberDetails: memberDetails),
    );
  }
}

class _SubscriptionSelectionScreen extends StatefulWidget {
  const _SubscriptionSelectionScreen({required this.memberDetails});

  final MemberDetailsModel memberDetails;

  @override
  State<_SubscriptionSelectionScreen> createState() =>
      __SubscriptionSelectionScreenState();
}

class __SubscriptionSelectionScreenState
    extends State<_SubscriptionSelectionScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final MembershipCubit _membershipCubit;
  MembershipPackageModel? _membershipPackageModel;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _membershipCubit = context.read<MembershipCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _membershipCubit.fetchMembershipPackages();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen:
          (p, c) =>
              p.memberOnboardedAnimationCompleted !=
              c.memberOnboardedAnimationCompleted,
      listener: (context, state) {
        if (state.memberOnboardedAnimationCompleted ?? false) {
          context.pop();
        }
      },
      child: BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
        listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
        bloc: _cubit,
        listener: (context, state) {
          state.createOrUpdateMember?.fold(() => null, (t) {
            return t.fold(
              (l) {
                Dialogs.showSnack(msg: l.msg);
              },
              (r) {
                if (widget.memberDetails.id != null) {
                  Dialogs.showSnack(
                    msg: 'Trainer details updated successfully',
                  );
                } else {
                  Dialogs.showSnack(msg: 'member added successfully');
                }
                context.push(
                  BlocProvider.value(
                    value: _cubit,
                    child: const MemberOnboardPaymentSuccessScreen(),
                  ),
                );
              },
            );
          });
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const PopButton().center,
            titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
            title: const Text('Choose Subscription'),
          ),
          body: BlocBuilder<MembershipCubit, MembershipState>(
            bloc: _membershipCubit,
            buildWhen: (p, c) => p.membershipPackages != c.membershipPackages,
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
                    return RefreshIndicator(
                      onRefresh: _fetch,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.results?.length ?? 0,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 16);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final membership = data.results?[index];
                          final isSelected =
                              _membershipPackageModel?.id == membership?.id;
                          return InkWell(
                            onTap: () {
                              if (!mounted) return;
                              setState(() {
                                _membershipPackageModel = membership;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xffFFEBEB)
                                        : AppColors.light,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.borderGrey,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        membership?.name ?? '',
                                        style:
                                            AppStyles
                                                .text14Px
                                                .poppins
                                                .w600
                                                .dark,
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        size: 24,
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : const Color(0xffCCCCCC),
                                      ).pOnly(left: 8),
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0xffDDDDDD),
                                  ).pxy(y: 16),
                                  if (membership?.offerPrice?.isNotEmpty ??
                                      false)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Offer Price',
                                          style:
                                              AppStyles
                                                  .text13Px
                                                  .poppins
                                                  .w400
                                                  .dark,
                                        ),

                                        ///
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
                                    ).pOnly(bottom: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Actual Price',
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
                                              decoration:
                                                  membership
                                                              ?.offerPrice
                                                              ?.isNotEmpty ??
                                                          false
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
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
          bottomNavigationBar:
              BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen:
                    (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
                builder: (context, state) {
                  return Button.filled(
                    title: 'Continue',
                    isLoading: state.createOrUpdateMember?.isNone() ?? false,
                    buttonColor: AppColors.primary,
                    ontap: () {
                      if (_cubit.state.createOrUpdateMember?.isNone() ??
                          false) {
                        Dialogs.showSnack(msg: 'Please wait');
                        return;
                      }
                      if (_membershipPackageModel == null) {
                        Dialogs.showSnack(
                          msg: 'Please select a membership package',
                        );
                        return;
                      } else {
                        _cubit.cerateOrUpdateMemberDetails(
                          memeberDetails: widget.memberDetails,
                          membershipPackageModel: _membershipPackageModel!,
                        );
                      }
                    },
                  );
                },
              ).pad(16).pxy(y: 16),
        ),
      ),
    );
  }
}
