import 'package:mentor_mobile_app/imports_bindings.dart';

class ActiveMembersListingScreen extends StatelessWidget {
  const ActiveMembersListingScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => MembersAndLeadsCubit(orgId: orgId), child: const _ActiveMembersListingScreen());
  }
}

class _ActiveMembersListingScreen extends StatefulWidget {
  const _ActiveMembersListingScreen();

  @override
  State<_ActiveMembersListingScreen> createState() => _ActiveMembersListingScreenState();
}

class _ActiveMembersListingScreenState extends State<_ActiveMembersListingScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final ScrollController _scrollController;
  ListingSort? _sort;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetch(isPaginating: true);
      }
    });
    _fetch();
  }

  Future<void> _fetch({bool isPaginating = false, String? searchQuery}) => _cubit.fetchMembers(isPagination: isPaginating, sort: _sort, status: MemberStatus.active, searchQuery: searchQuery);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Active Members')),
      body: Column(
        children: [
          TextField(
            onChanged: (q) {
              EasyDebounce.debounce('active_members_search_query', const Duration(milliseconds: 300), () => _fetch(searchQuery: q));
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
              child: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen: (p, c) => p.members != c.members,
                builder: (context, state) {
                  return state.members.data.fold(
                    () => const Center(child: CircularProgressIndicator()),
                    (either) => either.fold(
                      (error) => error.maybeWhen(network: (e) => ErrorUi.network(onTap: _fetch), notFound: (e) => ErrorUi.notFound(onTap: _fetch), orElse: () => ErrorUi.server(onTap: _fetch)),
                      (memebersDataum) {
                        if (memebersDataum.results?.isEmpty ?? true) {
                          return ErrorUi.empty().center;
                        }
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${memebersDataum.count ?? 0} members', style: AppStyles.text14Px.poppins.w400.dark),
                                FilterButton(
                                  isSelected: _sort != null,
                                  sortLabel: 'Sort by Joined Recently',
                                  onTap: () {
                                    if (_sort == ListingSort.recent) {
                                      _sort = null;
                                    } else {
                                      _sort = ListingSort.recent;
                                    }
                                    _fetch();
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: RefreshIndicator.adaptive(
                                onRefresh: _fetch,
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount: memebersDataum.results?.length ?? 0,
                                  separatorBuilder: (BuildContext context, int index) {
                                    return const SizedBox(height: 16);
                                  },
                                  itemBuilder: (BuildContext context, int index) {
                                    final memberData = memebersDataum.results?[index];
                                    return InkWell(
                                      onTap: () {
                                        if (memberData?.id != null) {
                                          context.push(BlocProvider.value(value: _cubit, child: MemberDetialsScreen(memberData: memberData!)));
                                        } else {
                                          Dialogs.showSnack(msg: 'Member not found!');
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: const BorderRadius.all(Radius.circular(80000)),
                                                      child: ProfileImage(isEdit: false, url: '${memberData?.profilePicture ?? ''}', radius: 40),
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
                                                            Text(memberData?.mobileNumber ?? '', style: AppStyles.text12Px.poppins.w400.dark),
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
}
