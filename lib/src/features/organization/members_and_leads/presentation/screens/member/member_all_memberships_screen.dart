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
                    onPressed: () => _showMembershipActionSheet(data),
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
                              ontap: () => _addNewMembership(data),
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

    final memStatusStr = membership.status?.toLowerCase() ?? '';
    final isPaused = memStatusStr == 'paused';
    final isActive = membership.isActive ?? false;
    final isTrial = membership.isTrial ?? false;
    final isTrialExpired =
        isTrial && (membership.trialEndAt?.isBefore(now) ?? false);
    final isMembershipExpired = membership.endDate?.isBefore(now) ?? false;
    final isCancelled = memStatusStr == 'cancelled';
    final isExpired =
        memStatusStr == 'expired' || isMembershipExpired;

    final payStatus = membership.paymentStatus?.toLowerCase() ?? '';
    final isFree = membership.assignFree ?? false;
    final isPaid = payStatus == 'paid' || payStatus == 'completed';
    final hasPendingFee = !isFree &&
        !isPaid &&
        (payStatus == 'pending' ||
            payStatus == 'partial' ||
            payStatus == 'due' ||
            payStatus == 'unpaid' ||
            (payStatus.isNotEmpty && payStatus != 'paid' && payStatus != 'completed'));

    final actualIsActive =
        isActive && !isMembershipExpired && !isTrialExpired && !isCancelled && !isPaused;
    final actualIsTrial = isTrial && !isTrialExpired && !isCancelled && !isPaused;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled
              ? Colors.red.withOpacity(0.3)
              : isPaused
                  ? Colors.amber.withOpacity(0.4)
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
                    : isPaused
                        ? [Colors.amber.shade50, Colors.amber.shade100]
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
                        : isPaused
                            ? Colors.amber.shade800
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
                        : isPaused
                            ? Icons.pause_circle_filled
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
                                : isPaused
                                    ? Icons.pause_circle_outline
                                    : actualIsActive
                                        ? Icons.check_circle
                                        : isExpired
                                            ? Icons.cancel
                                            : Icons.schedule,
                            size: 14,
                            color: isCancelled
                                ? Colors.red.shade700
                                : isPaused
                                    ? Colors.amber.shade800
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
                                : isPaused
                                    ? 'Paused'
                                    : actualIsActive
                                        ? 'Active'
                                        : isExpired
                                            ? 'Expired'
                                            : membership.status?.toUpperCase() ??
                                                'Unknown',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: isCancelled
                                  ? Colors.red.shade700
                                  : isPaused
                                      ? Colors.amber.shade800
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
                        : isPaused
                            ? Colors.amber.shade800
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
                    } else if (value == 'pause') {
                      _showPauseMembershipDialog(membership);
                    } else if (value == 'resume') {
                      _showResumeMembershipDialog(membership);
                    } else if (value == 'cancel') {
                      _showCancelMembershipDialog(membership);
                    } else if (value == 'collect_fee') {
                      _openCollectFeeSheet(membership, data);
                    }
                  },
                  itemBuilder: (context) => [
                    if (hasPendingFee && !isCancelled && membership.id != null)
                      PopupMenuItem<String>(
                        value: 'collect_fee',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: Color(0xff27AE60),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Collect Fee',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: const Color(0xff27AE60),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    if (actualIsActive && !isPaused && !isCancelled)
                      PopupMenuItem<String>(
                        value: 'pause',
                        child: Row(
                          children: [
                            Icon(
                              Icons.pause_circle_outline,
                              size: 18,
                              color: Colors.amber.shade800,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Pause Membership',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isPaused)
                      PopupMenuItem<String>(
                        value: 'resume',
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Resume Membership',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: Colors.green.shade700,
                              ),
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
                if (isPaused)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pause_circle_outline,
                            size: 16, color: Colors.amber.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Membership is currently paused. Tap ⋮ to resume.',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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

                if (hasPendingFee && !isCancelled && membership.id != null) ...[
                  const Divider(
                    thickness: 1,
                    color: Color(0xffEEEEEE),
                  ).pxy(y: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openCollectFeeSheet(membership, data),
                      icon: const Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: Color(0xff27AE60),
                      ),
                      label: Text(
                        'Collect Pending Fee',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: const Color(0xff27AE60),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xff27AE60),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],

                if (isExpired) ...[
                  const Divider(
                    thickness: 1,
                    color: Color(0xffEEEEEE),
                  ).pxy(y: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Button.filled(
                      title: 'Renew Plan',
                      buttonColor: AppColors.primary,
                      ontap: () => _renewSpecificMembership(data, membership),
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

  void _showPauseMembershipDialog(MembershipDataModel membership) {
    final membershipId = membership.id;
    if (membershipId == null) {
      Dialogs.showSnack(msg: 'Unable to pause: Membership ID is missing');
      return;
    }

    final reasonController = TextEditingController();
    final durationController = TextEditingController(text: '7');
    String durationType = 'days'; // 'days' or 'months'
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pause_circle_filled,
                    color: Colors.amber.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pause Membership',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      Text(
                        membership.membershipName ?? 'Current Plan',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade800,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Temporarily freezes attendance. The membership end date will automatically be extended by the pause duration.',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pause Duration',
                    style: AppStyles.text12Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 8),
                  // Preset duration chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      (count: 7, type: 'days', label: '7 Days'),
                      (count: 14, type: 'days', label: '14 Days'),
                      (count: 30, type: 'days', label: '30 Days'),
                      (count: 1, type: 'months', label: '1 Month'),
                      (count: 2, type: 'months', label: '2 Months'),
                    ].map((preset) {
                      final isSelected =
                          durationController.text == preset.count.toString() &&
                              durationType == preset.type;
                      return ChoiceChip(
                        label: Text(preset.label),
                        selected: isSelected,
                        onSelected: isSubmitting
                            ? null
                            : (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    durationController.text =
                                        preset.count.toString();
                                    durationType = preset.type;
                                  });
                                }
                              },
                        selectedColor: Colors.amber.shade100,
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: AppStyles.text12Px.poppins.w500.copyWith(
                          color: isSelected
                              ? Colors.amber.shade900
                              : AppColors.textDark,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.amber.shade700
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Custom Count',
                            labelStyle: AppStyles.text12Px.poppins.w400,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: durationType,
                          items: const [
                            DropdownMenuItem(value: 'days', child: Text('Days')),
                            DropdownMenuItem(value: 'months', child: Text('Months')),
                          ],
                          onChanged: isSubmitting
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      durationType = val;
                                    });
                                  }
                                },
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            labelStyle: AppStyles.text12Px.poppins.w400,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Reason (Optional)',
                      hintText: 'e.g., Medical leave, Traveling',
                      labelStyle: AppStyles.text12Px.poppins.w400,
                      hintStyle: AppStyles.text12Px.poppins.w400.copyWith(
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Dismiss',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final durationVal = int.tryParse(
                                    durationController.text.trim(),
                                  );
                                  if (durationVal == null || durationVal <= 0) {
                                    Dialogs.showSnack(
                                      msg: 'Please enter a valid positive duration',
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    isSubmitting = true;
                                  });

                                  final result = await MembershipRepository()
                                      .pauseCustomerMembership(
                                    customerMembershipId: membershipId,
                                    duration: durationVal,
                                    durationType: durationType,
                                    reason: reasonController.text.trim(),
                                  );

                                  if (!mounted) return;
                                  Navigator.pop(dialogContext);

                                  result.fold(
                                    (error) {
                                      Dialogs.showSnack(
                                        msg: error.msg.isNotEmpty
                                            ? error.msg
                                            : 'Failed to pause membership',
                                      );
                                    },
                                    (_) {
                                      Dialogs.showSnack(
                                        msg: 'Membership paused successfully',
                                      );
                                      _fetch();
                                    },
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Pause Plan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
  }

  void _showResumeMembershipDialog(MembershipDataModel membership) {
    final membershipId = membership.id;
    if (membershipId == null) {
      Dialogs.showSnack(msg: 'Unable to resume: Membership ID is missing');
      return;
    }

    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resume Membership',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      Text(
                        membership.membershipName ?? 'Current Plan',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resuming early automatically recalculates elapsed pause days and credits back any unused days by adjusting the end date accordingly.',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Reason for Resuming (Optional)',
                    hintText: 'e.g., Returned from vacation earlier than planned',
                    labelStyle: AppStyles.text12Px.poppins.w400,
                    hintStyle: AppStyles.text12Px.poppins.w400.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Keep Paused',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setDialogState(() {
                                  isSubmitting = true;
                                });

                                final result = await MembershipRepository()
                                    .resumeCustomerMembership(
                                  customerMembershipId: membershipId,
                                  reason: reasonController.text.trim(),
                                );

                                if (!mounted) return;
                                Navigator.pop(dialogContext);

                                result.fold(
                                  (error) {
                                    Dialogs.showSnack(
                                      msg: error.msg.isNotEmpty
                                          ? error.msg
                                          : 'Failed to resume membership',
                                    );
                                  },
                                  (_) {
                                    Dialogs.showSnack(
                                      msg: 'Membership resumed successfully',
                                    );
                                    _fetch();
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Yes, Resume',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCollectFeeSheet(
    MembershipDataModel membership,
    MemberDetailsModel data,
  ) {
    if (membership.id == null) return;

    double? totalAmount;
    if (membership.amount != null) {
      totalAmount = double.tryParse(membership.amount!);
    }

    CollectMembershipFeeSheet.show(
      context: context,
      customerMembershipId: membership.id!,
      membershipName: membership.membershipName,
      memberName: data.fullName ?? widget.memberName,
      totalPayable: totalAmount,
      pendingAmount: null,
      onFeeCollected: _fetch,
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

  void _renewSpecificMembership(
    MemberDetailsModel memberDetails,
    MembershipDataModel membership,
  ) {
    DateTime? calcStartDate;
    if (membership.endDate != null &&
        membership.endDate!.isAfter(DateTime.now())) {
      calcStartDate = membership.endDate!.add(const Duration(days: 1));
    } else {
      calcStartDate = DateTime.now();
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => RenewMembershipScreen(
              orgId: widget.orgId ?? _cubit.orgId,
              memberId: widget.memberId,
              memberName:
                  '${memberDetails.firstName ?? ''} ${memberDetails.lastName ?? ''}'
                      .trim(),
              memberDetails: memberDetails,
              onRenewed: _fetch,
              isAddNew: false,
              initialPlanId: membership.membership,
              initialStartDate: calcStartDate,
            ),
      ),
    );
  }

  void _addNewMembership(MemberDetailsModel memberDetails) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => RenewMembershipScreen(
              orgId: widget.orgId ?? _cubit.orgId,
              memberId: widget.memberId,
              memberName:
                  '${memberDetails.firstName ?? ''} ${memberDetails.lastName ?? ''}'
                      .trim(),
              memberDetails: memberDetails,
              onRenewed: _fetch,
              isAddNew: true,
              initialStartDate: DateTime.now(),
            ),
      ),
    );
  }

  void _showMembershipActionSheet(MemberDetailsModel memberDetails) {
    final membershipsList = memberDetails.memberships ?? [];
    if (membershipsList.isEmpty) {
      _addNewMembership(memberDetails);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Membership Actions',
                    style: AppStyles.text18Px.poppins.w600.dark,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                tileColor: AppColors.primary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Renew Existing Plan',
                  style: AppStyles.text14Px.poppins.w600.dark,
                ),
                subtitle: Text(
                  'Extend duration of current membership',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _renewSpecificMembership(
                    memberDetails,
                    membershipsList.first,
                  );
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                tileColor: const Color(0xFFE8F8EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFB8E8CA)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD5F5E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF27AE60),
                  ),
                ),
                title: Text(
                  'Add Another Membership',
                  style: AppStyles.text14Px.poppins.w600.dark,
                ),
                subtitle: Text(
                  'Assign a concurrent plan (PT, Sauna, Locker, etc.)',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _addNewMembership(memberDetails);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showRenewMembershipBottomSheet(MemberDetailsModel memberDetails) {
    _showMembershipActionSheet(memberDetails);
  }
}
