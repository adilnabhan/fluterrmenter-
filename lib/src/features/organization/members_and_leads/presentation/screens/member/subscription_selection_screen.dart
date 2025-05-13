import 'package:mentor_mobile_app/imports_bindings.dart';

class SubscriptionSelectionScreen extends StatefulWidget {
  const SubscriptionSelectionScreen({super.key});

  @override
  State<SubscriptionSelectionScreen> createState() => _SubscriptionSelectionScreenState();
}

class _SubscriptionSelectionScreenState extends State<SubscriptionSelectionScreen> {
  late final MembersAndLeadsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchMembershipPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Choose Subscription')),
      body: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        buildWhen: (p, c) => p.membershipPackages != c.membershipPackages,
        builder: (context, state) {
          return state.membershipPackages.fold(
            () => const Center(child: CircularProgressIndicator()),
            (either) => either.fold((error) => Center(child: Text(error.msg)), (data) {
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
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderGrey)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(membership?.name ?? '', style: AppStyles.text14Px.poppins.w600.dark),
                              const Icon(Icons.radio_button_unchecked, size: 24, color: Color(0xffCCCCCC)).pOnly(left: 8),
                            ],
                          ),
                          const Divider(thickness: 1, color: Color(0xffDDDDDD)).pxy(y: 16),
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
                    );
                  },
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
