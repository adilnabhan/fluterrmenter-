import 'package:mentor_mobile_app/imports_bindings.dart';

class MemberAllMembershipsScreen extends StatefulWidget {
  const MemberAllMembershipsScreen({
    required this.memberId,
    required this.memberName,
    this.orgId,
    this.memberDetails,
    this.onUpdated,
    super.key,
  });

  final int memberId;
  final String memberName;
  final int? orgId;
  final MemberDetailsModel? memberDetails;
  final VoidCallback? onUpdated;

  @override
  State<MemberAllMembershipsScreen> createState() =>
      _MemberAllMembershipsScreenState();
}

class _MemberAllMembershipsScreenState
    extends State<MemberAllMembershipsScreen> {
  late final MembersAndLeadsCubit _cubit;
  bool _isLocalCubit = false;
  String _selectedFilter = 'all'; // 'all', 'active', 'expired', 'cancelled'

  @override
  void initState() {
    super.initState();
    MembersAndLeadsCubit? existingCubit;
    try {
      existingCubit = context.read<MembersAndLeadsCubit>();
    } catch (_) {
      existingCubit = null;
    }

    if (existingCubit != null) {
      _cubit = existingCubit;
    } else {
      _isLocalCubit = true;
      _cubit = MembersAndLeadsCubit(orgId: widget.orgId ?? 0);
    }
  }

  @override
  void dispose() {
    if (_isLocalCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  Future<void> _fetch() async {
    await _cubit.fetchMemberDetails(memberId: widget.memberId);
    widget.onUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MembersAndLeadsCubit>.value(
      value: _cubit,
      child: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        builder: (context, state) {
          final data = state.memberDetails.fold(
            () => widget.memberDetails,
            (either) => either.fold((l) => widget.memberDetails, (r) => r),
          );

          final membershipsList =
              data?.memberships ?? <MembershipDataModel>[];

          final activeCount =
              membershipsList.where(_isMembershipActive).length;
          final expiredCount =
              membershipsList.where(_isMembershipExpired).length;
          final cancelledCount =
              membershipsList.where(_isMembershipCancelled).length;

          final filteredList = membershipsList.where((m) {
            if (_selectedFilter == 'active') {
              return _isMembershipActive(m);
            } else if (_selectedFilter == 'expired') {
              return _isMembershipExpired(m);
            } else if (_selectedFilter == 'cancelled') {
              return _isMembershipCancelled(m);
            }
            return true;
          }).toList();

          return Scaffold(
            backgroundColor: AppColors.grey,
            appBar: AppBar(
              leading: const PopButton().center,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membership History',
                    style: AppStyles.text16Px.poppins.w600.dark,
                  ),
                  if (widget.memberName.isNotEmpty)
                    Text(
                      widget.memberName,
                      style: AppStyles.text12Px.poppins.w400.textGrey,
                    ),
                ],
              ),
              actions: [
                if (data != null)
                  TextButton.icon(
                    onPressed: () => _showRenewMembershipBottomSheet(data),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: Text(
                      'Renew / Add',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ).pOnly(right: 8),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _fetch,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  if (membershipsList.isNotEmpty) ...[
                    Row(
                      children: [
                        Flexible(
                          child: _buildSummaryCard(
                            icon: Icons.check_circle,
                            iconColor: Colors.green,
                            title: 'Active Plans',
                            value: '$activeCount',
                            subtitle: 'Currently Active',
                            gradient: [
                              Colors.green.shade50,
                              Colors.green.shade100,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: _buildSummaryCard(
                            icon: Icons.fitness_center,
                            iconColor: AppColors.primary,
                            title: 'Total Plans',
                            value: '${membershipsList.length}',
                            subtitle: 'All Time',
                            gradient: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ],
                    ).pOnly(bottom: 16),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All (${membershipsList.length})',
                            filterKey: 'all',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Active ($activeCount)',
                            filterKey: 'active',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Expired ($expiredCount)',
                            filterKey: 'expired',
                          ),
                          if (cancelledCount > 0) ...[
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Cancelled ($cancelledCount)',
                              filterKey: 'cancelled',
                            ),
                          ],
                        ],
                      ),
                    ).pOnly(bottom: 16),
                  ],

                  // Memberships List
                  if (filteredList.isNotEmpty && data != null) ...[
                    for (int i = 0; i < filteredList.length; i++)
                      _buildMembershipCard(
                        filteredList[i],
                        data,
                        isLatest: i == 0 && _selectedFilter == 'all',
                      ).pOnly(bottom: 16),
                  ] else if (membershipsList.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.card_membership_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No memberships found.',
                            style: AppStyles.text14Px.poppins.w500.textGrey,
                          ),
                          if (data != null) ...[
                            const SizedBox(height: 16),
                            Button.filled(
                              title: 'Add Membership Plan',
                              buttonColor: AppColors.primary,
                              ontap: () =>
                                  _showRenewMembershipBottomSheet(data),
                            ),
                          ],
                        ],
                      ),
                    ).pOnly(bottom: 16),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No $_selectedFilter memberships.',
                            style: AppStyles.text14Px.poppins.w500.textGrey,
                          ),
                        ],
                      ),
                    ).pOnly(bottom: 16),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isMembershipCancelled(MembershipDataModel membership) {
    return membership.status?.toLowerCase() == 'cancelled';
  }

  bool _isMembershipExpired(MembershipDataModel membership) {
    if (_isMembershipCancelled(membership)) return false;
    final now = DateTime.now();
    final isMembershipExpired = membership.endDate?.isBefore(now) ?? false;
    return membership.status?.toLowerCase() == 'expired' || isMembershipExpired;
  }

  bool _isMembershipActive(MembershipDataModel membership) {
    if (_isMembershipCancelled(membership)) return false;
    final now = DateTime.now();
    final isActive = membership.isActive ?? false;
    final isTrial = membership.isTrial ?? false;
    final isTrialExpired =
        isTrial && (membership.trialEndAt?.isBefore(now) ?? false);
    final isMembershipExpired = membership.endDate?.isBefore(now) ?? false;
    return isActive && !isMembershipExpired && !isTrialExpired;
  }

  Widget _buildFilterChip({
    required String label,
    required String filterKey,
  }) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppStyles.text12Px.poppins.w500.copyWith(
            color: isSelected ? Colors.white : AppColors.dark,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  Widget _buildMembershipCard(
    MembershipDataModel membership,
    MemberDetailsModel data, {
    bool isLatest = false,
  }) {
    final now = DateTime.now();

    final isActive = membership.isActive ?? false;
    final isTrial = membership.isTrial ?? false;
    final isTrialExpired =
        isTrial && (membership.trialEndAt?.isBefore(now) ?? false);
    final isMembershipExpired = membership.endDate?.isBefore(now) ?? false;
    final isCancelled =
        membership.status?.toLowerCase() == 'cancelled';
    final isExpired =
        membership.status?.toLowerCase() == 'expired' || isMembershipExpired;

    final actualIsActive =
        isActive && !isMembershipExpired && !isTrialExpired && !isCancelled;
    final actualIsTrial = isTrial && !isTrialExpired && !isCancelled;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled
              ? Colors.red.withOpacity(0.3)
              : actualIsActive
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCancelled
                    ? [Colors.red.shade50, Colors.red.shade100]
                    : actualIsActive
                        ? [Colors.green.shade50, Colors.green.shade100]
                        : isExpired
                            ? [Colors.red.shade50, Colors.red.shade100]
                            : [Colors.orange.shade50, Colors.orange.shade100],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.red.shade700
                        : actualIsActive
                            ? Colors.green
                            : isExpired
                                ? Colors.red
                                : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCancelled
                        ? Icons.block
                        : actualIsActive
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              membership.membershipName ?? 'Unknown Plan',
                              style: AppStyles.text16Px.poppins.w600.dark,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLatest) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LATEST',
                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isCancelled
                                ? Icons.block
                                : actualIsActive
                                    ? Icons.check_circle
                                    : isExpired
                                        ? Icons.cancel
                                        : Icons.schedule,
                            size: 14,
                            color: isCancelled
                                ? Colors.red.shade700
                                : actualIsActive
                                    ? Colors.green
                                    : isExpired
                                        ? Colors.red
                                        : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCancelled
                                ? 'CANCELLED'
                                : actualIsActive
                                    ? 'Active'
                                    : isExpired
                                        ? 'Expired'
                                        : membership.status?.toUpperCase() ??
                                            'Unknown',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: isCancelled
                                  ? Colors.red.shade700
                                  : actualIsActive
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'TRIAL',
                          style: AppStyles.text10Px.poppins.w600.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                // 3-dot action menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isCancelled
                        ? Colors.red.shade700
                        : actualIsActive
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                    size: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditMembership(membership, data);
                    } else if (value == 'cancel') {
                      _showCancelMembershipDialog(membership);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Edit Plan',
                            style: AppStyles.text14Px.poppins.w500.dark,
                          ),
                        ],
                      ),
                    ),
                    if (!isCancelled)
                      PopupMenuItem<String>(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Cancel Membership',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
                if (actualIsActive &&
                    membership.startDate != null &&
                    membership.endDate != null)
                  _buildMembershipProgress(membership),

                const SizedBox(height: 12),

                // Membership details in a grid layout
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.calendar_today,
                        label: 'Start Date',
                        value:
                            membership.startDate?.format('dd MMM yyyy') ??
                            'N/A',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.event_busy,
                        label: 'End Date',
                        value:
                            membership.endDate?.format('dd MMM yyyy') ?? 'N/A',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.currency_rupee,
                        label: 'Amount',
                        value: membership.amount != null
                            ? '₹${membership.amount}'
                            : 'N/A',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.payment,
                        label: 'Payment',
                        value: membership.paymentStatus?.toUpperCase() ?? 'N/A',
                        color: _getPaymentStatusColor(membership.paymentStatus),
                      ),
                    ),
                  ],
                ),

                // Trial information
                if (actualIsTrial &&
                    membership.trialStartAt != null &&
                    membership.trialEndAt != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Trial Period',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.play_circle_outline,
                                label: 'Trial Start',
                                value: membership.trialStartAt?.format(
                                      'dd MMM yyyy',
                                    ) ??
                                    'N/A',
                                color: Colors.orange,
                                small: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.stop_circle_outlined,
                                label: 'Trial End',
                                value: membership.trialEndAt?.format(
                                      'dd MMM yyyy',
                                    ) ??
                                    'N/A',
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
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${membership.createdAt?.format('dd MMM yyyy') ?? 'N/A'}',
                      style: AppStyles.text12Px.poppins.w400.textGrey,
                    ),
                  ],
                ),

                if (isExpired) ...[
                  const Divider(
                    thickness: 1,
                    color: Color(0xffEEEEEE),
                  ).pxy(y: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Button.filled(
                      title: 'Renew Membership',
                      buttonColor: AppColors.primary,
                      ontap: () => _showRenewMembershipBottomSheet(data),
                    ),
                  ),
                ],
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
    final progress = totalDays > 0 ? elapsedDays / totalDays : 1.0;
    final remainingDays = endDate.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Membership Progress',
              style: AppStyles.text14Px.poppins.w600.dark,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          remainingDays > 0
              ? '🕒 $remainingDays days remaining'
              : '✅ Membership completed',
          style: AppStyles.text12Px.poppins.w500.copyWith(
            color: remainingDays > 0 ? Colors.orange.shade700 : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool small = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: small ? 14 : 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.text12Px.poppins.w500.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.text13Px.poppins.w600.dark,
            overflow: TextOverflow.ellipsis,
          ),
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

  void _navigateToEditMembership(
    MembershipDataModel membership,
    MemberDetailsModel data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EditCustomerMembershipScreen(
          orgId: widget.orgId ?? _cubit.orgId,
          memberId: widget.memberId,
          memberName:
              '${data.firstName ?? ''} ${data.lastName ?? ''}'.trim(),
          memberAvatar: data.profilePicture,
          memberPhone: data.mobileNumber,
          currentMembership: membership,
          onUpdated: _fetch,
        ),
      ),
    );
  }

  void _showCancelMembershipDialog(MembershipDataModel membership) {
    final membershipId = membership.id;
    if (membershipId == null) {
      Dialogs.showSnack(msg: 'Membership ID not found');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.cancel, color: Colors.red.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Cancel Membership',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this membership?',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
            const SizedBox(height: 8),
            Text(
              membership.membershipName ?? 'Unknown Plan',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Keep Active',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      showDialog<void>(
                        context: context,
                        builder: (confirmContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Confirm Cancellation',
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                          content: Text(
                            'This will permanently cancel "${membership.membershipName ?? 'this membership'}". Are you absolutely sure?',
                            style: AppStyles.text14Px.poppins.w400.dark,
                          ),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmContext),
                              child: Text(
                                'No, Go Back',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(confirmContext);
                                final result = await MembershipRepository()
                                    .cancelCustomerMembership(
                                  customerMembershipId: membershipId,
                                );
                                result.fold(
                                  (error) {
                                    Dialogs.showSnack(
                                      msg: error.msg.isNotEmpty
                                          ? error.msg
                                          : 'Failed to cancel membership',
                                    );
                                  },
                                  (_) {
                                    Dialogs.showSnack(
                                      msg:
                                          'Membership cancelled successfully',
                                    );
                                    _fetch();
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Yes, Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  void _showRenewMembershipBottomSheet(MemberDetailsModel memberDetails) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => RenewMembershipScreen(
          orgId: widget.orgId ?? _cubit.orgId,
          memberId: widget.memberId,
          memberName:
              '${memberDetails.firstName ?? ''} ${memberDetails.lastName ?? ''}'
                  .trim(),
          memberDetails: memberDetails,
          onRenewed: _fetch,
        ),
      ),
    );
  }
}
