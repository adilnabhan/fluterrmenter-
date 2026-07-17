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
  List<({String label, String value})>? _selectedMembersSorts;
  final _filterOptions = const [
    (label: 'Active', value: 'active'),
    (label: 'New', value: 'new'),
  ];

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
    await _cubit.fetchMembers(
      isPagination: isPagination!,
      sort:
          (_selectedMembersSorts?.contains(_filterOptions[1]) ?? false)
              ? ListingSort.recent
              : null,
      status:
          (_selectedMembersSorts?.contains(_filterOptions[0]) ?? false)
              ? MemberStatus.active
              : null,
      searchQuery: searchQuery,
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
            TextField(
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
                  child:
                      SvgPicture.asset(
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilterButton(
                            isSelected: _selectedMembersSorts?.isNotEmpty ?? false,
                            onTap: () {
                              FilterSelectionSheet(
                                selectedFilters: _selectedMembersSorts,
                                onFilterSelected: (values) {
                                  _selectedMembersSorts = values;
                                  _fetchMembers();
                                  if (!mounted) return;
                                  setState(() {});
                                },
                                items: _filterOptions,
                              ).show(context);
                            },
                            sortLabel: 'Filter by',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: 
                          //* Members Listing

                          BlocBuilder<
                            MembersAndLeadsCubit,
                            MembersAndLeadsState
                          >(
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
                                        (e) => ErrorUi.network(
                                          onTap: _fetchMembers,
                                        ),
                                    notFound:
                                        (e) => ErrorUi.notFound(
                                          onTap: _fetchMembers,
                                        ),
                                    orElse:
                                        () => ErrorUi.server(
                                          onTap: _fetchMembers,
                                        ),
                                  ),
                                  (memebrsDataum) {
                                    if (memebrsDataum.results?.isEmpty ??
                                        true) {
                                      return ErrorUi.empty().center;
                                    }
                                    return RefreshIndicator.adaptive(
                                      onRefresh: _fetchMembers,
                                      child: ListView.separated(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.only(
                                          bottom: 104,
                                        ),
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
                                                  msg:
                                                      'Selected lead is not valid',
                                                );
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: ColoredBox(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
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
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Flexible(
                                                            child: SizedBox(
                                                              width:
                                                                  double
                                                                      .maxFinite,
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
                                                                    memberData?.mobileNumber ?? '',
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
                  context.push(
                    BlocProvider.value(
                      value: _cubit,
                      child: AddOrEditMemeberScreen(orgId: widget.orgId),
                    ),
                  );
                } else {
                  context.push(
                    BlocProvider.value(
                      value: _cubit,
                      child: const AddOrEditLeadScreen(),
                    ),
                  );
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
