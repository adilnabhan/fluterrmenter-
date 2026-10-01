import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_add_or_edit_package_screen.dart';

class GroupPackagesDetailScreen extends StatelessWidget {
  const GroupPackagesDetailScreen({
    required this.orgDetails,
    required this.groupName,
    this.groupId,
    this.isUngrouped = false,
    super.key,
  });

  final OrganizationDetailsModel orgDetails;
  final String groupName;
  final int? groupId;
  final bool isUngrouped;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembershipCubit(orgId: '${orgDetails.id!}'),
      child: _GroupPackagesDetailScreen(
        orgDetails: orgDetails,
        groupName: groupName,
        groupId: groupId,
        isUngrouped: isUngrouped,
      ),
    );
  }
}

class _GroupPackagesDetailScreen extends StatefulWidget {
  const _GroupPackagesDetailScreen({
    required this.orgDetails,
    required this.groupName,
    this.groupId,
    this.isUngrouped = false,
  });

  final OrganizationDetailsModel orgDetails;
  final String groupName;
  final int? groupId;
  final bool isUngrouped;

  @override
  State<_GroupPackagesDetailScreen> createState() =>
      __GroupPackagesDetailScreenState();
}

class __GroupPackagesDetailScreenState
    extends State<_GroupPackagesDetailScreen> {
  late final MembershipCubit _cubit;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetch();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      final queryGroupId = widget.isUngrouped ? 'ungrouped' : widget.groupId;
      _cubit.fetchMoreMembershipPackages(groupId: queryGroupId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final queryGroupId = widget.isUngrouped ? 'ungrouped' : widget.groupId;
    await _cubit.fetchMembershipPackages(groupId: queryGroupId);
  }

  Future<void> _onDeletePackage({int? id}) async {
    if (id == null) return;
    if (!context.mounted) return;

    await showDialog<void>(
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            await _cubit.deleteMembershipPackage(id: id);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            _fetch();
                          },
                    child: isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
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
                            style: AppStyles.text14Px.poppins.w500
                                .copyWith(color: Colors.white),
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
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text(
          widget.groupName,
          style: AppStyles.text16Px.poppins.w600,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () async {
                if (widget.orgDetails.id == null) {
                  Dialogs.showSnack(msg: 'Organization is not available');
                  return;
                }
                await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (context) => BlocProvider.value(
                      value: _cubit,
                      child: GymAddOrEditPackageScreen(
                        initialGroupId: widget.groupId,
                      ),
                    ),
                  ),
                );
                _fetch();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Package'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffFFEAEA),
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MembershipCubit, MembershipState>(
        bloc: _cubit,
        buildWhen: (p, c) =>
            p.membershipPackages != c.membershipPackages ||
            p.isLoading != c.isLoading,
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
                final packages = data.results ?? [];
                if (packages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xffF2F4F7),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 36,
                              color: Color(0xff98A2B3),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No packages in "${widget.groupName}"',
                            textAlign: TextAlign.center,
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add packages that belong to this group so clients can view and subscribe to them.',
                            textAlign: TextAlign.center,
                            style: AppStyles.text12Px.poppins.w400.textGrey,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (context) => BlocProvider.value(
                                    value: _cubit,
                                    child: GymAddOrEditPackageScreen(
                                      initialGroupId: widget.groupId,
                                    ),
                                  ),
                                ),
                              );
                              _fetch();
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add First Package'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final isFetchingMore = _cubit.isLoadingMore;
                return RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: packages.length + (isFetchingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == packages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      final membership = packages[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.light,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with Plan Name and Edit/Delete Icons
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    membership.name ?? '',
                                    style: AppStyles
                                        .text16Px
                                        .poppins
                                        .w600
                                        .dark,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Color(0xff666666),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await Navigator.push<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (context) =>
                                              BlocProvider.value(
                                            value: _cubit,
                                            child: GymAddOrEditPackageScreen(
                                              membershipPackage: membership,
                                              initialGroupId: widget.groupId,
                                            ),
                                          ),
                                        ),
                                      );
                                      _fetch();
                                    } else if (value == 'delete') {
                                      _onDeletePackage(id: membership.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: AppColors.dark,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                                color: AppColors.dark),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Duration
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Duration',
                                  style: AppStyles
                                      .text14Px
                                      .poppins
                                      .w400
                                      .dark,
                                ),
                                Text(
                                  '${membership.durationDays ?? 0} days',
                                  style: AppStyles
                                      .text14Px
                                      .poppins
                                      .w500
                                      .dark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Actual Price
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Actual Price',
                                  style: AppStyles
                                      .text14Px
                                      .poppins
                                      .w400
                                      .dark,
                                ),
                                Text(
                                  '₹${membership.actualPrice}',
                                  style: AppStyles
                                      .text14Px
                                      .poppins
                                      .w500
                                      .dark,
                                ),
                              ],
                            ),

                            // Offer Price (if available)
                            if (membership.offerPrice != null &&
                                membership.offerPrice!.isNotEmpty &&
                                membership.offerPrice != '0.00') ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Offer Price',
                                    style: AppStyles
                                        .text14Px
                                        .poppins
                                        .w400
                                        .dark,
                                  ),
                                  Text(
                                    '₹${membership.offerPrice}',
                                    style: AppStyles
                                        .text14Px
                                        .poppins
                                        .w600
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],

                            // EMI Options Section (if available)
                            if (membership.isEmiAvailable == true &&
                                membership.emiPlans.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xffEEEEEE)),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'EMI Options',
                                      style: AppStyles
                                          .text14Px
                                          .poppins
                                          .w600
                                          .dark,
                                    ),
                                    const SizedBox(height: 10),
                                    ...membership.emiPlans.map((emi) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              '${emi.month} Month',
                                              style: AppStyles
                                                  .text13Px
                                                  .poppins
                                                  .w400
                                                  .dark,
                                            ),
                                            Text(
                                              '₹${emi.price.toStringAsFixed(0)}',
                                              style: AppStyles
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
                          ],
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
    );
  }
}
