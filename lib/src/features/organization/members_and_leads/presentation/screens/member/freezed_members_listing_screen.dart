import 'package:mentor_mobile_app/imports_bindings.dart';

class FreezedMembersListingScreen extends StatelessWidget {
  const FreezedMembersListingScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: const _FreezedMembersListingScreen(),
    );
  }
}

class _FreezedMembersListingScreen extends StatefulWidget {
  const _FreezedMembersListingScreen();

  @override
  State<_FreezedMembersListingScreen> createState() =>
      __FreezedMembersListingScreenState();
}

class __FreezedMembersListingScreenState
    extends State<_FreezedMembersListingScreen>
    with SingleTickerProviderStateMixin {
  late final MembersAndLeadsCubit _cubit;
  late final ScrollController _scrollController;
  ListingSort? _sort;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetch(isPaginating: true);
      }
    });
    _fetch();
  }

  Future<void> _fetch({bool isPaginating = false, String? searchQuery}) =>
      _cubit.fetchMembers(
        isPagination: isPaginating,
        sort: _sort,
        status: MemberStatus.paused,
        searchQuery: searchQuery,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
        title: const Text('Freezed Members'),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (q) {
              EasyDebounce.debounce(
                'freezed_members_search_query',
                const Duration(milliseconds: 300),
                () => _fetch(searchQuery: q),
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
                      colorFilter: const ColorFilter.mode(
                        AppColors.textGrey,
                        BlendMode.srcIn,
                      ),
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
              child: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen: (p, c) => p.members != c.members,
                builder: (context, state) {
                  return state.members.data.fold(
                    () => const Center(child: CircularProgressIndicator()),
                    (either) => either.fold(
                      (error) => error.maybeWhen(
                        network: (e) => ErrorUi.network(onTap: _fetch),
                        notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                        orElse: () => ErrorUi.server(onTap: _fetch),
                      ),
                      (memebersDataum) {
                        if (memebersDataum.results?.isEmpty ?? true) {
                          return ErrorUi.empty().center;
                        }
                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${memebersDataum.count ?? 0} freezed clients',
                                style: AppStyles.text14Px.poppins.w400.dark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: RefreshIndicator.adaptive(
                                onRefresh: _fetch,
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount:
                                      memebersDataum.results?.length ?? 0,
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
                                        memebersDataum.results?[index];
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
                                            msg: 'Member not found!',
                                          );
                                        }
                                      },
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                        canViewFullImage: true,
                                                        name: memberData?.name,
                                                        url:
                                                            '${memberData?.profilePicture ?? ''}',
                                                        radius: 40,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    memberData
                                                                            ?.name ??
                                                                        '',
                                                                    style: AppStyles
                                                                        .text14Px
                                                                        .poppins
                                                                        .w500
                                                                        .dark,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            3,
                                                                      ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                        color:
                                                                            Colors.amber.shade50,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                        border: Border.all(
                                                                          color:
                                                                              Colors.amber.shade200,
                                                                        ),
                                                                      ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .pause_circle_filled,
                                                                        size:
                                                                            12,
                                                                        color:
                                                                            Colors.amber.shade800,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        'PAUSED',
                                                                        style: AppStyles
                                                                            .text10Px
                                                                            .poppins
                                                                            .w600
                                                                            .copyWith(
                                                                              color:
                                                                                  Colors.amber.shade900,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              memberData
                                                                      ?.mobileNumber ??
                                                                  '',
                                                              style: AppStyles
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
                                                if ((memberData?.activePlan?.planName ?? '').isNotEmpty) ...[
                                                  const Divider(
                                                    height: 8,
                                                    thickness: 1,
                                                    color: Color(0xffEEEEEE),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          memberData
                                                                  ?.activePlan
                                                                  ?.planName ??
                                                              '',
                                                          style: AppStyles
                                                              .text12Px
                                                              .poppins
                                                                  .w400
                                                              .dark,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ).pad(16);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
