import 'package:mentor_mobile_app/imports_bindings.dart';

class MemberDetialsScreen extends StatefulWidget {
  const MemberDetialsScreen({required this.memberData, super.key});

  final MemberDataModel memberData;

  @override
  State<MemberDetialsScreen> createState() => _MemberDetialsScreenState();
}

class _MemberDetialsScreenState extends State<MemberDetialsScreen> {
  late final MembersAndLeadsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchMemberDetails(memberId: widget.memberData.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
      listener: (context, state) {
        state.createOrUpdateMember?.fold(() => null, (t) {
          return t.fold((l) {}, (r) {
            _fetch();
          });
        });
      },
      child: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        buildWhen: (p, c) => p.memberDetails != c.memberDetails,
        builder: (context, state) {
          final data = state.memberDetails.fold(() => null, (either) => either.fold((l) => null, (r) => r));
          return Scaffold(
            appBar: AppBar(
              leading: const PopButton().center,
              titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
              title: const Text('Member Details'),
              actions: [
                if (data?.mobileNumber?.isNotEmpty ?? false)
                  IconButton(
                    onPressed: () {
                      if (data?.mobileNumber?.isNotEmpty ?? false) {
                        launchUrl(Uri.parse('tel:${data?.mobileNumber}'));
                      } else {
                        Dialogs.showSnack(msg: 'Phone number not available');
                      }
                    },
                    icon: SvgPicture.asset('assets/images/svg/icons/call.svg'),
                  ),
              ],
            ),
            backgroundColor: AppColors.grey,
            body: state.memberDetails.fold(
              _buildShimmerLoading,
              (either) => either.fold(
                (error) => error.maybeWhen(network: (e) => ErrorUi.network(onTap: _fetch), notFound: (e) => ErrorUi.notFound(onTap: _fetch), orElse: () => ErrorUi.server(onTap: _fetch)),
                (data) {
                  return KRefreshIndicator(
                    onRefresh: _fetch,
                    child: ListView(padding: const EdgeInsets.all(16), children: [_buildProfileDetails(data), _buildMembershipDetails(data), _buildContactDetails(data), _buildPersonalDetails(data)]),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileDetails(MemberDetailsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Details', style: AppStyles.text16Px.poppins.w600.dark).pOnly(bottom: 16),
        _card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (data.id == null) {
                Dialogs.showSnack(msg: 'Member not found');
              } else {
                context.push(BlocProvider.value(value: _cubit, child: UpdateBasicDetailsScreen(details: right(data))));
              }
            },
            child: Row(
              children: [
                AbsorbPointer(child: ProfileImage(isEdit: true, onChanged: (image) {}, radius: 80.w, url: '$data')),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${data.firstName ?? ''} ${data.lastName ?? ''}', style: AppStyles.text14Px.poppins.w500),
                    const SizedBox(height: 4),
                    Text('#${data.id}', style: AppStyles.text12Px.poppins.w400),
                    const Divider(thickness: 1, color: Color(0xffDDDDDD)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.dark).pOnly(left: 8),
              ],
            ),
          ),
        ).pOnly(bottom: 16),
      ],
    );
  }

  Widget _buildMembershipDetails(MemberDetailsModel data) {
    if (!(data.memberships?.isNotEmpty ?? false)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [const Icon(Icons.card_membership, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text('Memberships', style: AppStyles.text16Px.poppins.w600.dark)],
        ).pOnly(bottom: 16),

        // Membership Summary Cards with better styling
        Row(
          children: [
            Flexible(
              child: _buildSummaryCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: 'Active Plans',
                value: '${data.memberships?.where((m) => m.isActive ?? false).length ?? 0}',
                subtitle: 'Currently Active',
                gradient: [Colors.green.shade50, Colors.green.shade100],
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: _buildSummaryCard(
                icon: Icons.fitness_center,
                iconColor: AppColors.primary,
                title: 'Total Plans',
                value: '${data.memberships?.length ?? 0}',
                subtitle: 'All Time',
                gradient: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.2)],
              ),
            ),
          ],
        ).pOnly(bottom: 20),

        // Individual Membership Cards
        for (final membership in data.memberships ?? <MembershipDataModel>[]) _buildMembershipCard(membership).pOnly(bottom: 16),
      ],
    );
  }

  Widget _buildSummaryCard({required IconData icon, required Color iconColor, required String title, required String value, required String subtitle, required List<Color> gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const Spacer(),
                Text(value, style: AppStyles.text24Px.poppins.w700.dark),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: AppStyles.text14Px.poppins.w600.dark),
            const SizedBox(height: 4),
            Text(subtitle, style: AppStyles.text12Px.poppins.w400.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(MembershipDataModel membership) {
    final now = DateTime.now();

    // Check actual dates for accurate status
    final isActive = membership.isActive ?? false;
    final isTrial = membership.isTrial ?? false;
    final isTrialExpired = isTrial && (membership.trialEndAt?.isBefore(now) ?? false);
    final isMembershipExpired = membership.endDate?.isBefore(now) ?? false;
    final isExpired = membership.status?.toLowerCase() == 'expired' || isMembershipExpired;

    // Determine actual status based on dates
    final actualIsActive = isActive && !isMembershipExpired && !isTrialExpired;
    final actualIsTrial = isTrial && !isTrialExpired;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: actualIsActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    actualIsActive
                        ? [Colors.green.shade50, Colors.green.shade100]
                        : isExpired
                        ? [Colors.red.shade50, Colors.red.shade100]
                        : [Colors.orange.shade50, Colors.orange.shade100],
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        actualIsActive
                            ? Colors.green
                            : isExpired
                            ? Colors.red
                            : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    actualIsActive
                        ? Icons.fitness_center
                        : isExpired
                        ? Icons.cancel
                        : Icons.pending,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(membership.membershipName ?? 'Unknown Plan', style: AppStyles.text16Px.poppins.w600.dark),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            actualIsActive
                                ? Icons.check_circle
                                : isExpired
                                ? Icons.cancel
                                : Icons.schedule,
                            size: 14,
                            color:
                                actualIsActive
                                    ? Colors.green
                                    : isExpired
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            actualIsActive
                                ? 'Active'
                                : isExpired
                                ? 'Expired'
                                : membership.status?.toUpperCase() ?? 'Unknown',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color:
                                  actualIsActive
                                      ? Colors.green
                                      : isExpired
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (actualIsTrial)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text('TRIAL', style: AppStyles.text10Px.poppins.w600.copyWith(color: Colors.orange.shade700)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress indicator for active memberships
                if (actualIsActive && membership.startDate != null && membership.endDate != null) _buildMembershipProgress(membership),

                const SizedBox(height: 12),

                // Membership details in a grid layout
                Row(
                  children: [
                    Expanded(child: _buildDetailItem(icon: Icons.calendar_today, label: 'Start Date', value: membership.startDate?.format('dd MMM yyyy') ?? 'N/A', color: Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetailItem(icon: Icons.event_busy, label: 'End Date', value: membership.endDate?.format('dd MMM yyyy') ?? 'N/A', color: Colors.red)),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildDetailItem(icon: Icons.attach_money, label: 'Amount', value: membership.amount != null ? '\$${membership.amount}' : 'N/A', color: Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(icon: Icons.payment, label: 'Payment', value: membership.paymentStatus?.toUpperCase() ?? 'N/A', color: _getPaymentStatusColor(membership.paymentStatus)),
                    ),
                  ],
                ),

                // Trial information
                if (actualIsTrial && membership.trialStartAt != null && membership.trialEndAt != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text('Trial Period', style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.orange.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.play_circle_outline,
                                label: 'Trial Start',
                                value: membership.trialStartAt?.format('dd MMM yyyy') ?? 'N/A',
                                color: Colors.orange,
                                small: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.stop_circle_outlined,
                                label: 'Trial End',
                                value: membership.trialEndAt?.format('dd MMM yyyy') ?? 'N/A',
                                color: Colors.orange,
                                small: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Created date
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('Created: ${membership.createdAt?.format('dd MMM yyyy') ?? 'N/A'}', style: AppStyles.text12Px.poppins.w400.textGrey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipProgress(MembershipDataModel membership) {
    final startDate = membership.startDate!;
    final endDate = membership.endDate!;
    final now = DateTime.now();

    final totalDays = endDate.difference(startDate).inDays;
    final elapsedDays = now.difference(startDate).inDays;
    final progress = elapsedDays / totalDays;
    final remainingDays = endDate.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Membership Progress', style: AppStyles.text14Px.poppins.w600.dark),
            Text('${(progress * 100).toInt()}%', style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.green)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), minHeight: 8),
        const SizedBox(height: 8),
        Text(
          remainingDays > 0 ? '🕒 $remainingDays days remaining' : '✅ Membership completed',
          style: AppStyles.text12Px.poppins.w500.copyWith(color: remainingDays > 0 ? Colors.orange.shade700 : Colors.green),
        ),
      ],
    );
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value, required Color color, bool small = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: small ? 14 : 16, color: color),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: AppStyles.text12Px.poppins.w500.copyWith(color: color), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppStyles.text13Px.poppins.w600.dark, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildContactDetails(MemberDetailsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Details', style: AppStyles.text16Px.poppins.w600.dark).pOnly(bottom: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [TextSpan(text: 'Mobile : ', style: AppStyles.text14Px.poppins.w400.textGrey), TextSpan(text: data.mobileNumber ?? 'N/A', style: AppStyles.text13Px.poppins.w500.dark)],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [TextSpan(text: 'Email : ', style: AppStyles.text14Px.poppins.w400.textGrey), TextSpan(text: data.email ?? 'N/A', style: AppStyles.text13Px.poppins.w500.dark)],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 8,
                children: [
                  if (data.isActiveMember ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: Colors.green.shade700, radius: 3).pOnly(right: 8),
                          Text('Active', style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16)),
                    child: Text(data.gender?.pascalCase ?? 'N/A', style: AppStyles.text14Px.poppins.w400.dark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16)),
                    child: Text(data.bloodGroup ?? 'N/A', style: AppStyles.text14Px.poppins.w400.dark),
                  ),
                ],
              ),
            ],
          ),
        ).pOnly(bottom: 16),
      ],
    );
  }

  Widget _buildPersonalDetails(MemberDetailsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Details', style: AppStyles.text16Px.poppins.w600.dark).pOnly(bottom: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...[
                (
                  label: 'Date of Birth',
                  value: data.dateOfBirth?.format('dd MMM yyyy') ?? '',
                  onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateDOBScreen(details: right(data)))),
                ),
                (label: 'Height', value: '${data.height ?? ''} CM', onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateHeightScreen(details: data)))),
                (label: 'Weight', value: '${data.weight ?? ''} KG', onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateWeightScreen(details: data)))),
              ].map((e) {
                return InkWell(
                  onTap: e.onTap,
                  child: Row(
                    children: [
                      Text(e.label, style: AppStyles.text14Px.poppins.w400.textGrey),
                      const Spacer(),
                      Text(e.value, style: AppStyles.text14Px.poppins.w500.dark),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.dark).pOnly(left: 8),
                    ],
                  ).pxy(y: 12),
                );
              }),
            ],
          ),
        ).pOnly(bottom: 16),

        // Emergency Contact
        _card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Contact', style: AppStyles.text14Px.poppins.w400.textGrey),
                  const SizedBox(height: 8),
                  Text(data.emergencyContactNumber ?? 'N/A', style: AppStyles.text14Px.poppins.w500.dark),
                ],
              ),
              IconButton(
                onPressed: () {
                  if (data.emergencyContactNumber != null) {
                    launchUrl(Uri.parse('tel:${data.emergencyContactNumber}'));
                  } else {
                    Dialogs.showSnack(msg: 'Emergency contact number not found');
                  }
                },
                icon: SvgPicture.asset('assets/images/svg/icons/call.svg', colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),
              ),
            ],
          ),
        ).pOnly(bottom: 32),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(16)), child: child);
  }

  Widget _buildShimmerLoading() {
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(padding: const EdgeInsets.all(16), children: [_buildProfileDetailsShimmer(), _buildMembershipDetailsShimmer(), _buildContactDetailsShimmer(), _buildPersonalDetailsShimmer()]),
    );
  }

  Widget _buildProfileDetailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KShimmer.text(width: 120, height: 20, radius: 4).pOnly(bottom: 16),
        _card(
          child: Row(
            children: [
              KShimmer(height: 80.w, width: 80.w, radius: 80.w),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KShimmer.text(width: 150, height: 16, radius: 4),
                    const SizedBox(height: 4),
                    KShimmer.text(width: 80, height: 12, radius: 4),
                    const SizedBox(height: 8),
                    const Divider(thickness: 1, color: Color(0xffDDDDDD)),
                  ],
                ),
              ),
              const KShimmer(height: 14, width: 14, radius: 7).pOnly(left: 8),
            ],
          ),
        ).pOnly(bottom: 16),
      ],
    );
  }

  Widget _buildMembershipDetailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const KShimmer(height: 20, width: 20, radius: 10), const SizedBox(width: 8), KShimmer.text(width: 100, height: 20, radius: 4)]).pOnly(bottom: 16),

        // Summary cards shimmer with gradient effect
        Row(
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.green.shade50, Colors.green.shade100]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const KShimmer(height: 36, width: 36, radius: 12), const Spacer(), KShimmer.text(width: 30, height: 24, radius: 4)]),
                      const SizedBox(height: 12),
                      KShimmer.text(width: 80, height: 14, radius: 4),
                      const SizedBox(height: 4),
                      KShimmer.text(width: 70, height: 12, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.2)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const KShimmer(height: 36, width: 36, radius: 12), const Spacer(), KShimmer.text(width: 30, height: 24, radius: 4)]),
                      const SizedBox(height: 12),
                      KShimmer.text(width: 70, height: 14, radius: 4),
                      const SizedBox(height: 4),
                      KShimmer.text(width: 50, height: 12, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).pOnly(bottom: 20),

        // Individual membership cards shimmer
        for (int i = 0; i < 2; i++)
          Container(
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                // Header shimmer with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: i == 0 ? [Colors.green.shade50, Colors.green.shade100] : [Colors.orange.shade50, Colors.orange.shade100],
                    ),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const KShimmer(height: 36, width: 36, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KShimmer.text(width: 150, height: 18, radius: 4),
                            const SizedBox(height: 4),
                            Row(children: [const KShimmer(height: 14, width: 14, radius: 7), const SizedBox(width: 4), KShimmer.text(width: 60, height: 12, radius: 4)]),
                          ],
                        ),
                      ),
                      if (i == 0) const KShimmer(height: 24, width: 50, radius: 12),
                    ],
                  ),
                ),

                // Content shimmer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress indicator shimmer
                      if (i == 0) ...[
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [KShimmer.text(width: 120, height: 14, radius: 4), KShimmer.text(width: 40, height: 14, radius: 4)]),
                        const SizedBox(height: 8),
                        const KShimmer(height: 8, width: double.maxFinite, radius: 4),
                        const SizedBox(height: 8),
                        KShimmer.text(width: 100, height: 12, radius: 4),
                        const SizedBox(height: 12),
                      ],

                      // Details grid shimmer
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [const KShimmer(height: 16, width: 16, radius: 8), const SizedBox(width: 6), KShimmer.text(width: 60, height: 12, radius: 4)]),
                                  const SizedBox(height: 4),
                                  KShimmer.text(width: 80, height: 13, radius: 4),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [const KShimmer(height: 16, width: 16, radius: 8), const SizedBox(width: 6), KShimmer.text(width: 60, height: 12, radius: 4)]),
                                  const SizedBox(height: 4),
                                  KShimmer.text(width: 80, height: 13, radius: 4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.3))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [const KShimmer(height: 16, width: 16, radius: 8), const SizedBox(width: 6), KShimmer.text(width: 50, height: 12, radius: 4)]),
                                  const SizedBox(height: 4),
                                  KShimmer.text(width: 60, height: 13, radius: 4),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple.withOpacity(0.3))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [const KShimmer(height: 16, width: 16, radius: 8), const SizedBox(width: 6), KShimmer.text(width: 50, height: 12, radius: 4)]),
                                  const SizedBox(height: 4),
                                  KShimmer.text(width: 60, height: 13, radius: 4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Trial section shimmer (for first card)
                      if (i == 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const KShimmer(height: 16, width: 16, radius: 8), const SizedBox(width: 8), KShimmer.text(width: 80, height: 14, radius: 4)]),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [const KShimmer(height: 14, width: 14, radius: 7), const SizedBox(width: 6), KShimmer.text(width: 50, height: 10, radius: 4)]),
                                          const SizedBox(height: 4),
                                          KShimmer.text(width: 70, height: 11, radius: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [const KShimmer(height: 14, width: 14, radius: 7), const SizedBox(width: 6), KShimmer.text(width: 50, height: 10, radius: 4)]),
                                          const SizedBox(height: 4),
                                          KShimmer.text(width: 70, height: 11, radius: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Created date shimmer
                      Row(children: [const KShimmer(height: 14, width: 14, radius: 7), const SizedBox(width: 8), KShimmer.text(width: 120, height: 12, radius: 4)]),
                    ],
                  ),
                ),
              ],
            ),
          ).pOnly(bottom: 16),
      ],
    );
  }

  Widget _buildContactDetailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KShimmer.text(width: 130, height: 20, radius: 4).pOnly(bottom: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [KShimmer.text(width: 60, height: 14, radius: 4), const SizedBox(width: 8), KShimmer.text(width: 120, height: 14, radius: 4)]),
              const SizedBox(height: 8),
              Row(children: [KShimmer.text(width: 50, height: 14, radius: 4), const SizedBox(width: 8), KShimmer.text(width: 150, height: 14, radius: 4)]),
              const SizedBox(height: 16),
              const Row(spacing: 8, children: [KShimmer(height: 24, width: 60, radius: 12), KShimmer(height: 24, width: 50, radius: 12), KShimmer(height: 24, width: 60, radius: 12)]),
            ],
          ),
        ).pOnly(bottom: 16),
      ],
    );
  }

  Widget _buildPersonalDetailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KShimmer.text(width: 130, height: 20, radius: 4).pOnly(bottom: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal details items shimmer
              for (int i = 0; i < 3; i++) ...[
                Row(
                  children: [
                    KShimmer.text(width: 80, height: 14, radius: 4),
                    const Spacer(),
                    KShimmer.text(width: 100, height: 14, radius: 4),
                    const SizedBox(width: 8),
                    const KShimmer(height: 12, width: 12, radius: 6),
                  ],
                ).pxy(y: 12),
                if (i < 2) const Divider(height: 1, color: Color(0xffDDDDDD)),
              ],
            ],
          ),
        ).pOnly(bottom: 16),

        // Emergency Contact shimmer
        _card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [KShimmer.text(width: 120, height: 14, radius: 4), const SizedBox(height: 8), KShimmer.text(width: 100, height: 14, radius: 4)],
              ),
              const KShimmer(height: 24, width: 24, radius: 12),
            ],
          ),
        ).pOnly(bottom: 32),
      ],
    );
  }
}
