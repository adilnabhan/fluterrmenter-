import 'package:mentor_mobile_app/imports_bindings.dart';

class UpcomingRenewalsListingScreen extends StatelessWidget {
  const UpcomingRenewalsListingScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: const _UpcomingRenewalsListingScreen(),
    );
  }
}

class _UpcomingRenewalsListingScreen extends StatefulWidget {
  const _UpcomingRenewalsListingScreen();

  @override
  State<_UpcomingRenewalsListingScreen> createState() =>
      __UpcomingRenewalsListingScreenState();
}

class __UpcomingRenewalsListingScreenState
    extends State<_UpcomingRenewalsListingScreen>
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
        status: MemberStatus.expired,
        searchQuery: searchQuery,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
        title: const Text('Upcoming Renewals'),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (q) {
              EasyDebounce.debounce(
                'upcoming_renewals_search_query',
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
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${memebersDataum.count ?? 0} members',
                                  style: AppStyles.text14Px.poppins.w400.dark,
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xffDDDDDD),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Sort by',
                                    style: AppStyles.text12Px.poppins.copyWith(
                                      color: const Color(0xff222222),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                    return ClipRRect(
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
                                                          Text(
                                                            memberData?.name ??
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
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'memberId',
                                                    style:
                                                        AppStyles
                                                            .text12Px
                                                            .poppins
                                                            .w400
                                                            .textGrey,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Check In',
                                                style:
                                                    AppStyles
                                                        .text10Px
                                                        .poppins
                                                        .w400
                                                        .textGrey,
                                                textAlign: TextAlign.end,
                                              ).align(Alignment.centerRight),
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
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '05:30 AM',
                                                    style:
                                                        AppStyles
                                                            .text12Px
                                                            .poppins
                                                            .w500
                                                            .dark,
                                                  ),
                                                ],
                                              ),
                                            ],
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
              ).pad(16),
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