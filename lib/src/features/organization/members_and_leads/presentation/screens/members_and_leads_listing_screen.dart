import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class MembersAndLeadsListingScreen extends StatelessWidget {
  const MembersAndLeadsListingScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: _MembersAndLeadsListingScreen(orgId: orgId),
    );
  }
}

class _MembersAndLeadsListingScreen extends StatefulWidget {
  const _MembersAndLeadsListingScreen({required this.orgId});

  final int orgId;

  @override
  State<_MembersAndLeadsListingScreen> createState() =>
      __MembersAndLeadsListingScreenState();
}

class __MembersAndLeadsListingScreenState
    extends State<_MembersAndLeadsListingScreen> {
  late final ScrollController _scrollController;
  late final MembersAndLeadsCubit _cubit;
  List<({String label, String value})>? _selectedFilters;
  ({String label, String value})? _selectedSort;
  String? _currentSearchQuery;

  final _filterCategories = const [
    FilterCategory(
      title: 'Membership Status',
      isSingleSelect: true,
      items: [
        (label: 'Active', value: 'active'),
        (label: 'Frozen / Paused', value: 'frozen'),
        (label: 'Expired (Last 10 Days)', value: 'expired_10d'),
        (label: 'Expired', value: 'expired'),
        (label: 'Pending Fee', value: 'pending_fee'),
      ],
    ),
    FilterCategory(
      title: 'Gender',
      isSingleSelect: true,
      items: [
        (label: 'Male', value: 'male'),
        (label: 'Female', value: 'female'),
      ],
    ),
  ];

  final _sortOptions = const [
    (label: 'Joined Recently', value: 'recent'),
    (label: 'Joined First', value: 'oldest'),
    (label: 'Name: A-Z', value: 'a_z'),
    (label: 'Name: Z-A', value: 'z_a'),
  ];

  List<FilterCategory> get _sortAndFilterCategories => [
    FilterCategory(
      title: 'Sort by',
      isSingleSelect: true,
      items: _sortOptions,
    ),
    ..._filterCategories,
  ];

  void _openSortAndFilterSheet() {
    final initialSelected = <({String label, String value})>[
      if (_selectedSort != null) _selectedSort!,
      if (_selectedFilters != null) ..._selectedFilters!,
    ];

    FilterSelectionSheet(
      title: 'Sort & Filter',
      categories: _sortAndFilterCategories,
      selectedFilters: initialSelected.isNotEmpty ? initialSelected : null,
      onFilterSelected: (values) {
        if (values == null || values.isEmpty) {
          _selectedSort = null;
          _selectedFilters = null;
        } else {
          final sortValues = _sortOptions.map((e) => e.value).toSet();
          final selectedSortList =
              values.where((e) => sortValues.contains(e.value)).toList();
          _selectedSort =
              selectedSortList.isNotEmpty ? selectedSortList.first : null;
          _selectedFilters =
              values.where((e) => !sortValues.contains(e.value)).toList();
        }
        _fetchMembers();
        if (!mounted) return;
        setState(() {});
      },
    ).show(context);
  }

  Widget _buildFilterIconButton() {
    final hasActiveFilter =
        _selectedSort != null || (_selectedFilters?.isNotEmpty ?? false);

    return Material(
      color: hasActiveFilter
          ? AppColors.primary.withValues(alpha: 0.08)
          : (context.isDarkMode ? context.colors.fieldFill : Colors.white),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _openSortAndFilterSheet,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasActiveFilter
                  ? AppColors.primary
                  : (context.isDarkMode ? context.colors.border : const Color(0xffDDDDDD)),
              width: hasActiveFilter ? 1.5 : 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 22,
                color: hasActiveFilter
                    ? AppColors.primary
                    : (context.isDarkMode ? context.colors.textSecondary : AppColors.textGrey),
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMembers(isPagination: true);
      }
    });
    _fetchMembers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers({
    String? searchQuery,
    bool? isPagination = false,
  }) async {
    if (searchQuery != null) {
      _currentSearchQuery = searchQuery;
    }
    String? status;
    String? gender;
    bool? pendingFee;

    if (_selectedFilters != null && _selectedFilters!.isNotEmpty) {
      for (final f in _selectedFilters!) {
        if (f.value == 'male' || f.value == 'female') {
          gender = f.value;
        } else if (f.value == 'pending_fee') {
          pendingFee = true;
          status = 'pending_fee';
        } else {
          status = f.value;
        }
      }
    }

    await _cubit.fetchMembers(
      isPagination: isPagination!,
      sortString: _selectedSort?.value,
      statusString: status,
      gender: gender,
      pendingFee: pendingFee,
      searchQuery: _currentSearchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
          listenWhen:
              (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
          bloc: _cubit,
          listener: (context, state) {
            state.createOrUpdateMember?.fold(
              () => null,
              (either) => either.fold((error) {}, (data) {
                _fetchMembers();
              }),
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.isDarkMode ? context.colors.card : Colors.white,
        appBar: AppBar(
          leading: const PopButton().center,
          backgroundColor: context.isDarkMode ? context.colors.card : Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: AppStyles.text16Px.poppins.w500.copyWith(
            color: context.colors.textPrimary,
          ),
          iconTheme: IconThemeData(
            color: context.colors.textPrimary,
          ),
          title: Text(
            'Members & Leads',
            style: AppStyles.text16Px.poppins.w500.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: context.colors.textPrimary,
                      ),
                      onChanged: (q) {
                        if (q.isEmpty) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                        EasyDebounce.debounce(
                          'members_and_leads_search_query',
                          const Duration(milliseconds: 300),
                          () {
                            _fetchMembers(searchQuery: q);
                          },
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for name or phone number',
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        filled: context.isDarkMode,
                        fillColor: context.colors.fieldFill,
                        prefixIcon: SizedBox.square(
                          dimension: 32,
                          child: SvgPicture.asset(
                            'assets/images/svg/icons/search.svg',
                            height: 32,
                            width: 32,
                            colorFilter: ColorFilter.mode(
                              context.isDarkMode
                                  ? context.colors.textSecondary
                                  : AppColors.textGrey,
                              BlendMode.srcIn,
                            ),
                          ).center,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: context.isDarkMode
                                ? context.colors.border
                                : const Color(0xffDDDDDD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: context.isDarkMode
                                ? AppColors.primary
                                : const Color(0xffDDDDDD),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: context.isDarkMode
                                ? context.colors.border
                                : const Color(0xffDDDDDD),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterIconButton(),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: context.isDarkMode
                    ? context.colors.card
                    : const Color(0xffF7F7F7),
                child:
                //* Members Listing
                BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                        buildWhen: (p, c) => p.members != c.members,
                        bloc: _cubit,
                        builder: (context, state) {
                          return state.members.data.fold(
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            (either) => either.fold(
                              (error) => error.maybeWhen(
                                network:
                                    (e) =>
                                        ErrorUi.network(onTap: _fetchMembers),
                                notFound:
                                    (e) =>
                                        ErrorUi.notFound(onTap: _fetchMembers),
                                orElse:
                                    () => ErrorUi.server(onTap: _fetchMembers),
                              ),
                              (memebrsDataum) {
                                if (memebrsDataum.results?.isEmpty ?? true) {
                                  return ErrorUi.empty().center;
                                }
                                return RefreshIndicator.adaptive(
                                  onRefresh: _fetchMembers,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isGrid = constraints.maxWidth >= 600;
                                      if (isGrid) {
                                        final cols = constraints.maxWidth < 650
                                            ? 2
                                            : (constraints.maxWidth < 850
                                                ? 3
                                                : (constraints.maxWidth < 1050
                                                    ? 4
                                                    : (constraints.maxWidth < 1250
                                                        ? 5
                                                        : 6)));

                                        return GridView.builder(
                                          controller: _scrollController,
                                          padding: const EdgeInsets.only(bottom: 104),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: cols,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            mainAxisExtent: 205,
                                          ),
                                          itemCount:
                                              memebrsDataum.results?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            final memberData =
                                                memebrsDataum.results?[index];
                                            return _buildMemberGridCard(
                                              context,
                                              memberData,
                                            );
                                          },
                                        );
                                      }

                                      return ListView.separated(
                                        controller: _scrollController,
                                        padding:
                                            const EdgeInsets.only(bottom: 104),
                                        itemCount:
                                            memebrsDataum.results?.length ?? 0,
                                        separatorBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          return const SizedBox(height: 16);
                                        },
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          final memberData =
                                              memebrsDataum.results?[index];
                                          return _buildMemberListItem(
                                            context,
                                            memberData,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ).pad(16),
              ),
            ),
          ],
        ),
        floatingActionButton: (!kIsWeb &&
                (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
            ? null
            : FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () {
                  AddMemberOrLeadSelectionSheet(
                    onSortSelected: (l, v) {
                      if (v == 'member') {
                        context.push(
                          BlocProvider.value(
                            value: _cubit,
                            child: AddOrEditMemeberScreen(orgId: widget.orgId),
                          ),
                        );
                      } else {
                        Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder:
                                (context) => BlocProvider.value(
                                  value: _cubit,
                                  child: AddTrainerSearchScreen(orgId: widget.orgId),
                                ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _fetchMembers();
                          }
                        });
                      }
                    },
                  ).show(context);
                },
                child: const Icon(Icons.add),
              ).pOnly(right: 16),
      ),
    );
  }

  Widget _buildMemberGridCard(BuildContext context, MemberDataModel? memberData) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: () {
        if (memberData?.id != null) {
          context.push(
            BlocProvider.value(
              value: _cubit,
              child: MemberDetialsScreen(
                memberId: memberData!.id!,
              ),
            ),
          );
        } else {
          Dialogs.showSnack(
            msg: 'Selected lead is not valid',
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Profile Picture
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ProfileImage(
                  isEdit: false,
                  canViewFullImage: true,
                  name: memberData?.name,
                  url: '${memberData?.profilePicture ?? ''}',
                  radius: 72,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Member Name
            Text(
              memberData?.name ?? '',
              textAlign: TextAlign.center,
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Phone Number
            Text(
              memberData?.mobileNumber ?? '',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Bottom row: Plan Name on the left, Status badge on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    memberData?.activePlan?.planName ?? '',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_buildStatusBadge(memberData) != null) ...[
                  const SizedBox(width: 6),
                  _buildStatusBadge(memberData)!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberListItem(BuildContext context, MemberDataModel? memberData) {
    return InkWell(
      onTap: () {
        if (memberData?.id != null) {
          context.push(
            BlocProvider.value(
              value: _cubit,
              child: MemberDetialsScreen(
                memberId: memberData!.id!,
              ),
            ),
          );
        } else {
          Dialogs.showSnack(
            msg: 'Selected lead is not valid',
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.isDarkMode
                ? context.colors.border
                : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(80000),
                  ),
                  child: ProfileImage(
                    isEdit: false,
                    canViewFullImage: true,
                    name: memberData?.name,
                    url: '${memberData?.profilePicture ?? ''}',
                    radius: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberData?.name ?? '',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        memberData?.mobileNumber ?? '',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_buildStatusBadge(memberData) != null) ...[
                  const SizedBox(width: 8),
                  _buildStatusBadge(memberData)!,
                ],
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    memberData?.activePlan?.planName ?? '',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildStatusBadge(MemberDataModel? member) {
    final rawStatus = member?.activePlan?.status?.trim();
    if (rawStatus == null || rawStatus.isEmpty) return null;
    final statusLower = rawStatus.toLowerCase();

    Color bg;
    Color text;
    String label;

    final isDark = context.isDarkMode;

    if (statusLower == 'active') {
      bg = isDark ? const Color(0xFF14331C) : const Color(0xFFE8F5E9);
      text = isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32);
      label = 'Active';
    } else if (statusLower == 'expired') {
      bg = isDark ? const Color(0xFF381A1A) : const Color(0xFFFFEBEE);
      text = isDark ? const Color(0xFFF87171) : const Color(0xFFD32F2F);
      label = 'Expired';
    } else if (statusLower == 'frozen' || statusLower == 'paused' || statusLower == 'hold') {
      bg = isDark ? const Color(0xFF0F263B) : const Color(0xFFE1F5FE);
      text = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0288D1);
      label = statusLower == 'frozen' ? 'Frozen' : 'Paused';
    } else if (statusLower == 'pending' || statusLower.contains('due')) {
      bg = isDark ? const Color(0xFF3B250A) : const Color(0xFFFFF3E0);
      text = isDark ? const Color(0xFFFBBF24) : const Color(0xFFE65100);
      label = 'Pending';
    } else {
      bg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
      text = context.colors.textSecondary;
      label = rawStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppStyles.text12Px.poppins.w600.copyWith(color: text),
      ),
    );
  }
}
