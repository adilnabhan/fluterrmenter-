import 'package:mentor_mobile_app/imports_bindings.dart';

class GymPackagesScreen extends StatelessWidget {
  const GymPackagesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => MembershipCubit(orgId: '${orgDetails.id!}'), child: _GymPackagesScreen(orgDetails: orgDetails));
  }
}

class _GymPackagesScreen extends StatefulWidget {
  const _GymPackagesScreen({required this.orgDetails});

  final OrganizationDetailsModel orgDetails;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text('Package', style: AppStyles.text16Px.poppins.w500)),
      body: Column(
        children: [
          Row(
            children: [
              Text('Current Packages', style: AppStyles.text16Px.poppins.w500.dark),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  if (widget.orgDetails.id == null) {
                    Dialogs.showSnack(msg: 'Organization is not available');
                    return;
                  }
                  context.push(BlocProvider.value(value: _cubit, child: const GymAddPackageScreen()));
                },
                label: const Text('Add'),
                icon: const Icon(Icons.add),
                style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.primary), backgroundColor: WidgetStatePropertyAll(Color(0xffFFEAEA))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<MembershipCubit, MembershipState>(
              buildWhen: (p, c) => p.membershipPackages != c.membershipPackages,
              builder: (context, state) {
                return state.membershipPackages.fold(
                  () => const Center(child: CircularProgressIndicator()),
                  (either) => either.fold((error) => Center(child: Text(error.msg)), (data) {
                    return RefreshIndicator(
                      onRefresh: _fetch,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: data.results?.length ?? 0,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 16);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final membership = data.results?[index];
                          return InkWell(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderGrey)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(membership?.name ?? '', style: AppStyles.text14Px.poppins.w600.dark),
                                      TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Edit')).pOnly(left: 8),
                                    ],
                                  ),
                                  const SizedBox(height: 1, child: Divider(thickness: 1, color: Color(0xffDDDDDD))).pOnly(bottom: 20, top: 12),
                                  if (membership?.offerPrice?.isNotEmpty ?? false)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Offer Price', style: AppStyles.text13Px.poppins.w400.dark),

                                        ///
                                        Text('₹${membership?.offerPrice}', style: AppStyles.text14Px.poppins.w500.dark),
                                      ],
                                    ).pOnly(bottom: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Actual Price', style: AppStyles.text13Px.poppins.w400.dark),

                                      ///
                                      Text(
                                        '₹${membership?.actualPrice}',
                                        style: AppStyles.text14Px.poppins.w500.dark.copyWith(decoration: membership?.offerPrice?.isNotEmpty ?? false ? TextDecoration.lineThrough : null),
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
                  }),
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
    );
  }
}
