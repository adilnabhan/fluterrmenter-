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
          : Colors.white,
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
                  : const Color(0xffDDDDDD),
              width: hasActiveFilter ? 1.5 : 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 22,
                color: hasActiveFilter ? AppColors.primary : AppColors.textGrey,
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
        appBar: AppBar(
          leading: const PopButton().center,
          titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
          title: const Text('Members & Leads'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                        filled: false,
                        prefixIcon: SizedBox.square(
                          dimension: 32,
                          child: SvgPicture.asset(
                            'assets/images/svg/icons/search.svg',
                            height: 32,
                            width: 32,
                            color: AppColors.textGrey,
                          ).center,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xffDDDDDD)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xffDDDDDD)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xffDDDDDD)),
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
                color: const Color(0xffF7F7F7),
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
                                  child: ListView.separated(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(bottom: 104),
                                    itemCount:
                                        // (memebrsDataum.results?.length ??
                                        //     0) +
                                        // (state.members.isPagination
                                        //     ? 1
                                        //     : 0),
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
                                      // final items =
                                      //     memebrsDataum.results ?? [];
                                      //
                                      // // ===== Pagination Loader UI =====
                                      // if (index == items.length) {
                                      //   return const Padding(
                                      //     padding: EdgeInsets.symmetric(
                                      //       vertical: 16,
                                      //     ),
                                      //     child: Center(
                                      //       child:
                                      //           CircularProgressIndicator(),
                                      //     ),
                                      //   );
                                      // }
                                      final memberData =
                                          memebrsDataum.results?[index];
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
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: ColoredBox(
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                spacing: 8,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius.all(
                                                              Radius.circular(
                                                                80000,
                                                              ),
                                                            ),
                                                        child: ProfileImage(
                                                          isEdit: false,
                                                          url:
                                                              '${memberData?.profilePicture ?? ''}',
                                                          radius: 40,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                memberData
                                                                        ?.name ??
                                                                    '',
                                                                style:
                                                                    AppStyles
                                                                        .text14Px
                                                                        .poppins
                                                                        .w500
                                                                        .dark,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                memberData
                                                                        ?.mobileNumber ??
                                                                    '',
                                                                style:
                                                                    AppStyles
                                                                        .text12Px
                                                                        .poppins
                                                                        .w400
                                                                        .dark,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (_buildStatusBadge(memberData) != null)
                                                        _buildStatusBadge(memberData)!,
                                                    ],
                                                  ),
                                                  // Text('Check In', style: AppStyles.text10Px.poppins.w400.textGrey, textAlign: TextAlign.end).align(Alignment.centerRight),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        memberData
                                                                ?.activePlan
                                                                ?.planName ??
                                                            '',
                                                        style:
                                                            AppStyles
                                                                .text12Px
                                                                .poppins
                                                                .w500
                                                                .dark,
                                                      ),
                                                      // const SizedBox(height: 4),
                                                      // Text('05: AM', style: AppStyles.text12Px.poppins.w500.dark),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
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
                      ).pad(16),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
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

  Widget? _buildStatusBadge(MemberDataModel? member) {
    final rawStatus = member?.activePlan?.status?.trim();
    if (rawStatus == null || rawStatus.isEmpty) return null;
    final statusLower = rawStatus.toLowerCase();

    Color bg;
    Color text;
    String label;

    if (statusLower == 'active') {
      bg = const Color(0xFFE8F5E9);
      text = const Color(0xFF4CAF50);
      label = 'Active';
    } else if (statusLower == 'expired') {
      bg = const Color(0xFFFFEBEE);
      text = const Color(0xFFD30000);
      label = 'Expired';
    } else if (statusLower == 'frozen' || statusLower == 'paused' || statusLower == 'hold') {
      bg = const Color(0xFFE1F5FE);
      text = const Color(0xFF0288D1);
      label = statusLower == 'frozen' ? 'Frozen' : 'Paused';
    } else if (statusLower == 'pending' || statusLower.contains('due')) {
      bg = const Color(0xFFFFF3E0);
      text = const Color(0xFFE65100);
      label = 'Pending';
    } else {
      bg = const Color(0xFFF5F5F5);
      text = const Color(0xFF616161);
      label = rawStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppStyles.text10Px.poppins.w500.copyWith(color: text),
      ),
    );
  }
}
