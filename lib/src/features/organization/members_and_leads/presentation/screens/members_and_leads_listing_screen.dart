import 'package:mentor_mobile_app/imports_bindings.dart';

class MembersAndLeadsListingScreen extends StatelessWidget {
  const MembersAndLeadsListingScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => MembersAndLeadsCubit(orgId: orgId), child: _MembersAndLeadsListingScreen(orgId: orgId));
  }
}

class _MembersAndLeadsListingScreen extends StatefulWidget {
  const _MembersAndLeadsListingScreen({required this.orgId});

  final int orgId;

  @override
  State<_MembersAndLeadsListingScreen> createState() => __MembersAndLeadsListingScreenState();
}

class __MembersAndLeadsListingScreenState extends State<_MembersAndLeadsListingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final MembersAndLeadsCubit _cubit;
  List<({String label, String value})>? _selectedMembersSorts;
  List<({String label, String value})>? _selectedLeadsSorts;
  final _sortOptions = const [(label: 'Active', value: 'active'), (label: 'New', value: 'new')];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMembers();
    _fetchLeads();
  }

  Future<void> _fetchMembers() async {
    await _cubit.fetchMembers(
      sort: (_selectedMembersSorts?.contains(_sortOptions[1]) ?? false) ? ListingSort.recent : null,
      status: (_selectedMembersSorts?.contains(_sortOptions[0]) ?? false) ? MemberStatus.active : null,
    );
  }

  Future<void> _fetchLeads() async {
    await _cubit.fetchLeads(
      sort: (_selectedMembersSorts?.contains(_sortOptions[1]) ?? false) ? ListingSort.recent : null,
      status: (_selectedMembersSorts?.contains(_sortOptions[0]) ?? false) ? MemberStatus.active : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
          listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
          bloc: _cubit,
          listener: (context, state) {
            state.createOrUpdateMember?.fold(
              () => null,
              (either) => either.fold((error) {}, (data) {
                _tabController.animateTo(0);
                _fetchMembers();
              }),
            );
          },
        ),
        BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
          listenWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead,
          bloc: _cubit,
          listener: (context, state) {
            state.createOrUpdateLead?.fold(
              () => null,
              (either) => either.fold((error) {}, (data) {
                _tabController.animateTo(1);
                _fetchLeads();
              }),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Members & Leads')),
        body: Column(
          children: [
            TextField(
              onChanged: (q) {
                EasyDebounce.debounce('search_query', const Duration(milliseconds: 100), () {});
              },
              decoration: InputDecoration(
                hintText: 'Search for name or phone number',
                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                filled: false,
                prefixIcon: SizedBox.square(dimension: 32, child: SvgPicture.asset('assets/images/svg/icons/search.svg', height: 32, width: 32, color: AppColors.textGrey).center),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
              ),
            ).pad(16),
            Expanded(
              child: ColoredBox(
                color: const Color(0xffF7F7F7),
                child: Column(
                  spacing: 16,
                  children: [
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 140,
                            child: TabBar(
                              controller: _tabController,
                              tabs: const [Tab(text: 'Members'), Tab(text: 'Trainers')],
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide(width: 2, color: Colors.red), // Red underline for the active tab
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              indicatorSize: TabBarIndicatorSize.label,
                              indicatorColor: Colors.red, // Red color for the active tab underline
                              unselectedLabelColor: Colors.grey, // Grey color for the inactive tab underline
                              labelColor: Colors.red, // Red color for the active tab text
                              labelStyle: AppStyles.text14Px.poppins.w500, // Style for the active tab text
                              unselectedLabelStyle: AppStyles.text14Px.poppins.w400, // Style for the inactive tab text
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _tabController.animation!,
                            builder: (context, value, child) {
                              final isMember = _tabController.index == 0;
                              return SortButton(
                                isSelected: isMember ? (_selectedMembersSorts?.isNotEmpty ?? false) : (_selectedLeadsSorts?.isNotEmpty ?? false),
                                onTap: () {
                                  SortSelectionSheet(
                                    selectedSorts: (isMember ? _selectedMembersSorts : _selectedLeadsSorts),
                                    onSortSelected: (values) {
                                      if (isMember) {
                                        _selectedMembersSorts = values;
                                        _fetchMembers();
                                      } else {
                                        _selectedLeadsSorts = values;
                                        _fetchLeads();
                                      }
                                      setState(() {});
                                    },
                                    items: _sortOptions,
                                  ).show(context);
                                },
                                sortLabel: 'Sort by',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          //* Members Listing
                          BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                            buildWhen: (p, c) => p.members != c.members,
                            bloc: _cubit,
                            builder: (context, state) {
                              return state.members.data.fold(
                                () => const Center(child: CircularProgressIndicator()),
                                (either) => either.fold(
                                  (error) => error.maybeWhen(
                                    network: (e) => ErrorUi.network(onTap: _fetchMembers),
                                    notFound: (e) => ErrorUi.notFound(onTap: _fetchMembers),
                                    orElse: () => ErrorUi.server(onTap: _fetchMembers),
                                  ),
                                  (memebrsDataum) {
                                    if (memebrsDataum.results?.isEmpty ?? true) {
                                      return ErrorUi.empty().center;
                                    }
                                    return RefreshIndicator.adaptive(
                                      onRefresh: _fetchMembers,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(bottom: 104),
                                        itemCount: memebrsDataum.results?.length ?? 0,
                                        separatorBuilder: (BuildContext context, int index) {
                                          return const SizedBox(height: 16);
                                        },
                                        itemBuilder: (BuildContext context, int index) {
                                          final memberData = memebrsDataum.results?[index];
                                          return InkWell(
                                            onTap: () {
                                              if (memberData?.id != null) {
                                                context.push(BlocProvider.value(value: _cubit, child: MemberDetialsScreen(memberData: memberData!)));
                                              } else {
                                                Dialogs.showSnack(msg: 'Selected lead is not valid');
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: ColoredBox(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    spacing: 8,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius.all(Radius.circular(80000)),
                                                            child: ProfileImage(isEdit: false, url: '//${memberData?.profilePicture ?? ''}', radius: 40),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Flexible(
                                                            child: SizedBox(
                                                              width: double.maxFinite,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(memberData?.name ?? '', style: AppStyles.text14Px.poppins.w500.dark),
                                                                  const SizedBox(height: 4),
                                                                  Text('+91 ${memberData?.mobileNumber ?? ''}', style: AppStyles.text12Px.poppins.w400.dark),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            '# ${memberData?.id}'.length > 3 ? '${'# ${memberData?.id}'.substring(0, 3)}...' : '# ${memberData?.id}',
                                                            style: AppStyles.text12Px.poppins.w400.textGrey,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      // Text('Check In', style: AppStyles.text10Px.poppins.w400.textGrey, textAlign: TextAlign.end).align(Alignment.centerRight),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(memberData?.activePlan?.planName ?? '', style: AppStyles.text12Px.poppins.w500.dark),
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
                          ),
                          //* Leads Listing
                          BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                            buildWhen: (p, c) => p.leads != c.leads,
                            bloc: _cubit,
                            builder: (context, state) {
                              return state.leads.data.fold(
                                () => const Center(child: CircularProgressIndicator()),
                                (either) => either.fold(
                                  (error) => error.maybeWhen(
                                    network: (e) => ErrorUi.network(onTap: _fetchLeads),
                                    notFound: (e) => ErrorUi.notFound(onTap: _fetchLeads),
                                    orElse: () => ErrorUi.server(onTap: _fetchLeads),
                                  ),
                                  (leadsDataum) {
                                    if (leadsDataum.results?.isEmpty ?? true) {
                                      return ErrorUi.empty().center;
                                    }
                                    return RefreshIndicator.adaptive(
                                      onRefresh: _fetchLeads,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(bottom: 104),
                                        itemCount: leadsDataum.results?.length ?? 0,
                                        separatorBuilder: (BuildContext context, int index) {
                                          return const SizedBox(height: 16);
                                        },
                                        itemBuilder: (BuildContext context, int index) {
                                          final leadsData = leadsDataum.results?[index];
                                          return InkWell(
                                            onTap: () {
                                              if (leadsData?.userId != null) {
                                                context.push(BlocProvider.value(value: _cubit, child: LeadDetailsScreen(leadData: leadsData!)));
                                              } else {
                                                Dialogs.showSnack(msg: 'Selected lead is not valid');
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: ColoredBox(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    spacing: 8,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius.all(Radius.circular(80000)),
                                                            child: ProfileImage(isEdit: false, url: '${leadsData?.profilePicture ?? ''}', radius: 40),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Flexible(
                                                            child: SizedBox(
                                                              width: double.maxFinite,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(leadsData?.name ?? '', style: AppStyles.text14Px.poppins.w500.dark),
                                                                  const SizedBox(height: 4),
                                                                  Text('+91 ${leadsData?.mobileNumber ?? ''}', style: AppStyles.text12Px.poppins.w400.dark),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            '# ${leadsData?.id}'.length > 3 ? '${'# ${leadsData?.id}'.substring(0, 3)}...' : '# ${leadsData?.id}',
                                                            style: AppStyles.text12Px.poppins.w400.textGrey,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      // Text('Check In', style: AppStyles.text10Px.poppins.w400.textGrey, textAlign: TextAlign.end).align(Alignment.centerRight),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('6 MONTH PLAN + Admission', style: AppStyles.text12Px.poppins.w500.dark),
                                                          // const SizedBox(height: 4),
                                                          // Text('05:30 AM', style: AppStyles.text12Px.poppins.w500.dark),
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
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  context.push(BlocProvider.value(value: _cubit, child: AddOrEditMemeberScreen(orgId: widget.orgId)));
                } else {
                  context.push(BlocProvider.value(value: _cubit, child: const AddOrEditLeadScreen()));
                }
              },
            ).show(context);
          },
          child: const Icon(Icons.add),
        ).pOnly(right: 16),
      ),
    );
  }
}
