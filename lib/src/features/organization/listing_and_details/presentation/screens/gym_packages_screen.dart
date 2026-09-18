import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/package_group_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_add_or_edit_package_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/group_packages_detail_screen.dart';

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
  GroupedMembershipPackagesModel? _groupedData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await MembershipRepository().getGroupedMembershipPackages(
      orgId: '${widget.orgDetails.id!}',
    );

    if (!mounted) return;
    res.fold(
      (err) {
        setState(() {
          _isLoading = false;
          _errorMessage = err.msg;
        });
      },
      (data) {
        setState(() {
          _groupedData = data;
          _isLoading = false;
        });
      },
    );
  }

  int get _totalPackagesCount {
    if (_groupedData == null) return 0;
    final inGroups = _groupedData!.groups.fold<int>(
      0,
      (sum, g) => sum + (g.plansCount),
    );
    return inGroups + _groupedData!.ungrouped.length;
  }

  void _showAddOptionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add New',
              style: AppStyles.text18Px.poppins.w600.dark,
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              icon: Icons.create_new_folder_outlined,
              iconColor: AppColors.primary,
              iconBgColor: const Color(0xffFFEAEA),
              title: 'Create Group',
              subtitle: 'Organize packages into categories',
              onTap: () {
                Navigator.pop(ctx);
                _showCreateGroupDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              icon: Icons.fitness_center_rounded,
              iconColor: const Color(0xff12B76A),
              iconBgColor: const Color(0xffE6F9F0),
              title: 'Add Package',
              subtitle: 'Create a new membership package',
              onTap: () async {
                Navigator.pop(ctx);
                if (widget.orgDetails.id == null) {
                  Dialogs.showSnack(msg: 'Organization is not available');
                  return;
                }
                await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (context) => BlocProvider.value(
                      value: _cubit,
                      child: const GymAddOrEditPackageScreen(),
                    ),
                  ),
                );
                _fetch();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE4E7EC)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.text15Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppStyles.text12Px.poppins.w400.textGrey,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xff98A2B3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'New Package Group',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a group like Gym, CrossFit, Personal Training, etc.',
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Group Name (e.g. CrossFit)',
                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final res = await _cubit.createPackageGroup(name: name);
              res.fold(
                (err) => Dialogs.showSnack(msg: err.msg),
                (group) {
                  Dialogs.showSnack(msg: 'Group "${group.name}" created');
                  _fetch();
                },
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _onDeleteGroup(MembershipPackageGroupModel group) async {
    if (group.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete "${group.name}"? Packages in this group will not be deleted and will move to General Packages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final res = await _cubit.deletePackageGroup(groupId: group.id!);
      res.fold(
        (err) => Dialogs.showSnack(msg: err.msg),
        (_) {
          Dialogs.showSnack(msg: 'Group deleted');
          _fetch();
        },
      );
    }
  }

  Widget _buildGroupCard({
    required String title,
    required int count,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE4E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.text16Px.poppins.w600.dark,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 1 ? '1 Package' : '$count Packages',
                    style: AppStyles.text12Px.poppins.w400.textGrey,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xff98A2B3),
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (val) {
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Delete Group',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: Color(0xff98A2B3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedData?.groups ?? [];
    final ungrouped = _groupedData?.ungrouped ?? [];
    final hasGroups = groups.isNotEmpty;
    final hasUngrouped = ungrouped.isNotEmpty;
    final isEmpty = !hasGroups && !hasUngrouped;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        onPressed: _showAddOptionsSheet,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: widget.progress == 0
          ? AppBar(
              leading: const PopButton().center,
              title: Text(
                'Package Groups',
                style: AppStyles.text16Px.poppins.w500,
              ),
            )
          : AppBar(automaticallyImplyLeading: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.progress != 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          color: isActive
                              ? AppColors.primary
                              : AppColors.borderGrey,
                        ),
                        Transform.rotate(
                          angle: 0.785398,
                          child: Container(
                            width: 8,
                            height: 8,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.borderGrey,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Text(
                  'Your Fitness \nPlans, Their \nChoices 💼',
                  textAlign: TextAlign.left,
                  style: AppStyles.text30Px.poppins.w600.dark,
                ),
                const SizedBox(height: 12),
                Text(
                  'Group membership packages into categories like Gym, CrossFit, etc.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 24),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.progress == 0 ? 'Package Groups' : 'Groups',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: AppStyles.text14Px.poppins.w500.dark,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetch,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
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
                                      Icons.folder_open_rounded,
                                      size: 36,
                                      color: Color(0xff98A2B3),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No Package Groups Yet',
                                    textAlign: TextAlign.center,
                                    style:
                                        AppStyles.text16Px.poppins.w600.dark,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Organize packages into groups like Gym, CrossFit, Personal Training, etc. to make browsing easier for your clients.',
                                    textAlign: TextAlign.center,
                                    style: AppStyles
                                        .text12Px.poppins.w400.textGrey,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _showCreateGroupDialog,
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('New Group'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          await Navigator.push<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (context) =>
                                                  BlocProvider.value(
                                                value: _cubit,
                                                child:
                                                    const GymAddOrEditPackageScreen(),
                                              ),
                                            ),
                                          );
                                          _fetch();
                                        },
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Add Package'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(
                                              color: AppColors.primary),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetch,
                            child: ListView(
                              children: [
                                ...groups.map((group) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildGroupCard(
                                      title: group.name ?? 'Group',
                                      count: group.plansCount,
                                      onDelete: () => _onDeleteGroup(group),
                                      onTap: () async {
                                        await Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (context) =>
                                                GroupPackagesDetailScreen(
                                              orgDetails: widget.orgDetails,
                                              groupName:
                                                  group.name ?? 'Package Group',
                                              groupId: group.id,
                                            ),
                                          ),
                                        );
                                        _fetch();
                                      },
                                    ),
                                  );
                                }),
                                if (hasUngrouped)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildGroupCard(
                                      title: 'General Packages',
                                      count: ungrouped.length,
                                      onTap: () async {
                                        await Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (context) =>
                                                GroupPackagesDetailScreen(
                                              orgDetails: widget.orgDetails,
                                              groupName: 'General Packages',
                                              groupId: null,
                                              isUngrouped: true,
                                            ),
                                          ),
                                        );
                                        _fetch();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
          ),
        ],
      ).pad(16),
      bottomNavigationBar: widget.progress != 0 && _totalPackagesCount > 0
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Button.filled(
                title: 'Continue',
                buttonColor: AppColors.primary,
                ontap: () {
                  context.read<AppCubit>().onboardingUpdate(
                    body: {'profile_completeness': 7},
                    id: int.tryParse(_cubit.orgId),
                  );

                  context.pushAndRemoveUntil(
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) => OrganizationListingAndDetailsCubit(),
                        ),
                      ],
                      child: SubscriptionPlanChooseCom(
                        orgDetails: OrganizationDetailsModel(
                          id: widget.orgDetails.id,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : const SizedBox(),
    );
  }
}
