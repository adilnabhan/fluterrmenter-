import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/package_group_model.dart';

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
  List<MembershipPackageGroupModel> _groups = [];
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    _fetchGroups();
    await _cubit.fetchMembershipPackages(groupId: _selectedGroupId);
  }

  Future<void> _fetchGroups() async {
    final groups = await _cubit.fetchPackageGroups();
    if (mounted) {
      setState(() {
        _groups = groups;
      });
    }
  }

  void _showManageGroupsSheet() {
    final nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Package Groups',
                        style: AppStyles.text18Px.poppins.w600.dark,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Text(
                    'Categorize packages into Gym, CrossFit, Personal Training, etc.',
                    style: AppStyles.text12Px.poppins.w400.textGrey,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'New group name (e.g. CrossFit)',
                            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.borderGrey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;
                          final res =
                              await _cubit.createPackageGroup(name: name);
                          res.fold(
                            (err) => Dialogs.showSnack(msg: err.msg),
                            (group) {
                              nameController.clear();
                              Dialogs.showSnack(
                                  msg: 'Group "${group.name}" created');
                              _fetchGroups();
                              setSheetState(() {});
                            },
                          );
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_groups.isNotEmpty) ...[
                    Text(
                      'Existing Groups (${_groups.length})',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _groups.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final g = _groups[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              g.name ?? '',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            subtitle: Text(
                              '${g.plansCount} plans',
                              style: AppStyles.text12Px.poppins.w400.textGrey,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Delete Group'),
                                    content: Text(
                                      'Are you sure you want to delete "${g.name}"? Packages in this group will become ungrouped.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true && g.id != null) {
                                  final res = await _cubit.deletePackageGroup(
                                      groupId: g.id!);
                                  res.fold(
                                    (err) => Dialogs.showSnack(msg: err.msg),
                                    (_) {
                                      Dialogs.showSnack(msg: 'Group deleted');
                                      if (_selectedGroupId == g.id) {
                                        _selectedGroupId = null;
                                      }
                                      _fetch();
                                      setSheetState(() {});
                                    },
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onDeletePackage({int? id}) async {
    if (id == null) return;

    if (!context.mounted) return;
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
                : AppBar(automaticallyImplyLeading: false),
        body: Column(
          children: [
            if (widget.progress != 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: MediaQuery.of(context).padding.top + 20),
                  // OrganizationCreationCompletionStatusCard(
                  //   progress: widget.progress ?? 0,
                  // ),
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
                            color:
                                isActive
                                    ? AppColors.primary
                                    : AppColors.borderGrey,
                          ),
                          Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 8,
                              height: 8,
                              color:
                                  isActive
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Your Fitness \nPlans, Their \nChoices 💼',
                    textAlign: TextAlign.left,
                    style: AppStyles.text30Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add the membership packages users can subscribe to.',
                    style: AppStyles.text14Px.poppins.w400.textGrey,
                  ),
                  const SizedBox(height: 28),
                ],
              )
            else
              const SizedBox(),
            Row(
              children: [
                Text(
                  widget.progress == 0 ? 'Current Packages' : 'Packages',
                  style: AppStyles.text16Px.poppins.w500.dark,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _showManageGroupsSheet,
                  label: const Text('Groups'),
                  icon: const Icon(Icons.folder_outlined, size: 16),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            if (_groups.isNotEmpty) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _groups.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final isSelected = isAll
                        ? _selectedGroupId == null
                        : _selectedGroupId == _groups[index - 1].id;
                    final label =
                        isAll ? 'All' : (_groups[index - 1].name ?? '');
                    final count = isAll ? null : _groups[index - 1].plansCount;

                    return ChoiceChip(
                      label: Text(
                        count != null && count > 0 ? '$label ($count)' : label,
                        style: AppStyles.text12Px.poppins.copyWith(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xffF2F4F7),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xffE4E7EC),
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedGroupId =
                              isAll ? null : _groups[index - 1].id;
                        });
                        _cubit.fetchMembershipPackages(
                          groupId: _selectedGroupId,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 4),
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
                                      // EXISTING CODE - COMMENTED OUT
                                      // Row(
                                      //   // mainAxisAlignment:
                                      //   //     MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Expanded(
                                      //       child: Text(
                                      //         membership?.name ?? '',
                                      //         style:
                                      //             AppStyles
                                      //                 .text14Px
                                      //                 .poppins
                                      //                 .w600
                                      //                 .dark,
                                      //       ),
                                      //     ),
                                      //     IconButton(
                                      //       icon: const Icon(Icons.edit),
                                      //       onPressed: () {
                                      //         if (widget.orgDetails.id ==
                                      //             null) {
                                      //           Dialogs.showSnack(
                                      //             msg:
                                      //                 'Organization is not available',
                                      //           );
                                      //           return;
                                      //         }
                                      //         context.push(
                                      //           BlocProvider.value(
                                      //             value: _cubit,
                                      //             child:
                                      //                 GymAddOrEditPackageScreen(
                                      //                   membershipPackage:
                                      //                       membership,
                                      //                 ),
                                      //           ),
                                      //         );
                                      //       },
                                      //       style: TextButton.styleFrom(
                                      //         foregroundColor: Colors.red,
                                      //       ),
                                      //     ).pOnly(left: 8),
                                      //     IconButton(
                                      //       icon: const Icon(Icons.delete),
                                      //       onPressed: () {
                                      //         if (widget.orgDetails.id ==
                                      //             null) {
                                      //           Dialogs.showSnack(
                                      //             msg:
                                      //                 'Organization is not available',
                                      //           );
                                      //           return;
                                      //         }
                                      //         _onDeletePackage(
                                      //           id: data.results?[index].id,
                                      //         );
                                      //         // _cubit.deleteMembershipPackage(
                                      //         //   id: data.results?[index].id,
                                      //         // );
                                      //       },
                                      //       style: TextButton.styleFrom(
                                      //         foregroundColor: Colors.red,
                                      //       ),
                                      //     ).pOnly(left: 8),
                                      //   ],
                                      // ),
                                      // const SizedBox(
                                      //   height: 1,
                                      //   child: Divider(
                                      //     thickness: 1,
                                      //     color: Color(0xffDDDDDD),
                                      //   ),
                                      // ).pOnly(bottom: 20, top: 12),
                                      // // if (membership?.offerPrice?.isNotEmpty ??
                                      // //     false)
                                      // //   Row(
                                      // //     mainAxisAlignment:
                                      // //         MainAxisAlignment.spaceBetween,
                                      // //     children: [
                                      // //       Text(
                                      // //         'Offer Price',
                                      // //         style:
                                      // //             AppStyles
                                      // //                 .text13Px
                                      // //                 .poppins
                                      // //                 .w400
                                      // //                 .dark,
                                      // //       ),
                                      // //
                                      // //       ///
                                      // //       Text(
                                      // //         '₹${membership?.offerPrice}',
                                      // //         style:
                                      // //             AppStyles
                                      // //                 .text14Px
                                      // //                 .poppins
                                      // //                 .w500
                                      // //                 .dark,
                                      // //       ),
                                      // //     ],
                                      // //   ).pOnly(bottom: 16),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //       'Duration',
                                      //       style:
                                      //           AppStyles
                                      //               .text13Px
                                      //               .poppins
                                      //               .w400
                                      //               .dark,
                                      //     ),
                                      //     Text(
                                      //       // '${(membership?.durationDays ?? 0) ~/ 30} months',
                                      //       '${membership?.durationDays ?? 0} days',
                                      //       style:
                                      //           AppStyles
                                      //               .text14Px
                                      //               .poppins
                                      //               .w500
                                      //               .dark,
                                      //     ),
                                      //   ],
                                      // ).pOnly(bottom: 16),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //       // 'Actual Price',
                                      //       'Amount',
                                      //       style:
                                      //           AppStyles
                                      //               .text13Px
                                      //               .poppins
                                      //               .w400
                                      //               .dark,
                                      //     ),
                                      //
                                      //     ///
                                      //     Text(
                                      //       '₹${membership?.actualPrice}',
                                      //       style: AppStyles
                                      //           .text14Px
                                      //           .poppins
                                      //           .w500
                                      //           .dark
                                      //           .copyWith(
                                      //             // decoration:
                                      //             //     membership
                                      //             //                 ?.offerPrice
                                      //             //                 ?.isNotEmpty ??
                                      //             //             false
                                      //             //         ?
                                      //             //     TextDecoration
                                      //             //             .lineThrough
                                      //             //         : null,
                                      //           ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // END OF EXISTING CODE

                                      // NEW UI DESIGN - MATCHING REFERENCE IMAGE
                                      // Header with Plan Name and Edit/Delete Icons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            membership?.name ?? '',
                                            style:
                                                AppStyles
                                                    .text16Px
                                                    .poppins
                                                    .w600
                                                    .dark,
                                          ),
                                           PopupMenuButton<String>(
                                             icon: const Icon(
                                               Icons.more_vert,
                                               color: Color(0xff666666),
                                             ),
                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(12),
                                             ),
                                             onSelected: (value) {
                                               if (widget.orgDetails.id == null) {
                                                 Dialogs.showSnack(
                                                   msg: 'Organization is not available',
                                                 );
                                                 return;
                                               }
                                               if (value == 'edit') {
                                                 context.push(
                                                   BlocProvider.value(
                                                     value: _cubit,
                                                     child: GymAddOrEditPackageScreen(
                                                       membershipPackage: membership,
                                                     ),
                                                   ),
                                                 );
                                               } else if (value == 'delete') {
                                                 _onDeletePackage(
                                                   id: data.results?[index].id,
                                                 );
                                               }
                                             },
                                             itemBuilder: (BuildContext context) => [
                                               const PopupMenuItem<String>(
                                                 value: 'edit',
                                                 child: Row(
                                                   children: [
                                                     Icon(Icons.edit_outlined, size: 18, color: AppColors.dark),
                                                     SizedBox(width: 8),
                                                     Text('Edit', style: TextStyle(color: AppColors.dark)),
                                                   ],
                                                 ),
                                               ),
                                               const PopupMenuItem<String>(
                                                 value: 'delete',
                                                 child: Row(
                                                   children: [
                                                     Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                     SizedBox(width: 8),
                                                     Text('Delete', style: TextStyle(color: Colors.red)),
                                                   ],
                                                 ),
                                               ),
                                             ],
                                           ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // Offer Price (if available)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Actual Price',
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w400
                                                    .dark,
                                          ),
                                          Text(
                                            '₹${membership?.actualPrice}',
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w500
                                                    .dark,
                                          ),
                                        ],
                                      ),
                                      /* if (membership?.offerPrice?.isNotEmpty ??
                                          false)
                                        Column(
                                          children: [
                                            SizedBox(height: 10.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'offer Price',
                                                  style:
                                                      AppStyles
                                                          .text14Px
                                                          .poppins
                                                          .w400
                                                          .dark,
                                                ),
                                                if (membership
                                                        ?.offerPrice
                                                        ?.isNotEmpty ??
                                                    false)
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
                                            ),
                                          ],
                                        ), */

                                      // EMI Options Section (if available)
                                      if (membership?.isEmiAvailable == true &&
                                          (membership?.emiPlans.isNotEmpty ??
                                              false))
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffF8F8F8),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'EMI Option',
                                                    style:
                                                        AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w600
                                                            .dark,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  ...membership!.emiPlans.map((
                                                    emi,
                                                  ) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 8,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            '${emi.month} Month',
                                                            style:
                                                                AppStyles
                                                                    .text13Px
                                                                    .poppins
                                                                    .w400
                                                                    .dark,
                                                          ),
                                                          Text(
                                                            '₹${emi.price.toStringAsFixed(0)}',
                                                            style:
                                                                AppStyles
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
                                      id: int.tryParse(_cubit.orgId),
                                    );

                                    // EXISTING CODE - COMMENTED OUT (Using BlocProvider.value which may not work properly)
                                    // final cubit =
                                    //     context
                                    //         .read<
                                    //           OrganizationListingAndDetailsCubit
                                    //         >();
                                    // context.pushAndRemoveUntil(
                                    //   BlocProvider.value(
                                    //     value: cubit,
                                    //     child: SubscriptionPlanChooseCom(
                                    //       orgDetails: OrganizationDetailsModel(
                                    //         id: widget.orgDetails.id,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // );

                                    // FIXED CODE - Using MultiBlocProvider pattern like other screens
                                    context.pushAndRemoveUntil(
                                      MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create:
                                                (_) =>
                                                    OrganizationListingAndDetailsCubit(),
                                          ),
                                        ],
                                        child: SubscriptionPlanChooseCom(
                                          orgDetails: OrganizationDetailsModel(
                                            id: widget.orgDetails.id,
                                          ),
                                        ),
                                      ),
                                    );

                                    // context.pushAndRemoveUntil(
                                    //   const OrganizationCreationSuccessScreen(),
                                    // );

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
