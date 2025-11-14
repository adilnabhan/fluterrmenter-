import 'package:mentor_mobile_app/imports_bindings.dart';

class PaymentUpcomingViewScreen extends StatelessWidget {
  const PaymentUpcomingViewScreen({required this.orgId, super.key});
  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: _PaymentUpComing(orgId: orgId),
    );
  }
}

class _PaymentUpComing extends StatefulWidget {
  const _PaymentUpComing({required this.orgId});
  final int orgId;

  @override
  State<_PaymentUpComing> createState() => _PaymentUpComingState();
}

class _PaymentUpComingState extends State<_PaymentUpComing> {
  late final MembersAndLeadsCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchExpiringMemberShip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        title: Text(
          'Upcoming EMIs',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        buildWhen: (p, c) => p.upComingPayments != c.upComingPayments,
        builder: (context, state) {
          return state.upComingPayments.fold(
            () => const Center(child: CircularProgressIndicator()),
            (either) => either.fold(
              (error) => error.maybeWhen(
                network: (e) => ErrorUi.network(onTap: _fetch),
                notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                orElse: () => ErrorUi.server(onTap: _fetch),
              ),
              (data) {
                if (data == null || data.results.isEmpty) {
                  return ErrorUi.empty().center;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔸 Filter chip row
                      // Text(
                      //   'Showing ${data.results} members',
                      //   style: AppStyles.text12Px.copyWith(
                      //     color: Colors.grey.shade600,
                      //   ),
                      // ),
                      const SizedBox(height: 10),

                      /// 🔸 Members list
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.results.length ?? 0,
                          itemBuilder: (context, index) {
                            final member = data.results[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(
                                      member.customerDetails.profilePicture ??
                                          '',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.customerDetails.name,
                                          style: AppStyles.text14Px.poppins.w600
                                              .copyWith(color: Colors.black87),
                                        ),
                                        Text(
                                          member.customerDetails.mobileNumber,
                                          style: AppStyles.text12Px.copyWith(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member
                                              .customerDetails
                                              .activePlans
                                              .planName,
                                          style: AppStyles.text12Px.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.6),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Expiring in ${member.daysUntilExpire} days',
                                          style: AppStyles.text12Px.poppins.w500
                                              .copyWith(
                                                color: Colors.orange.shade800,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// 🔸 Reusable Filter Chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.text12Px.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
