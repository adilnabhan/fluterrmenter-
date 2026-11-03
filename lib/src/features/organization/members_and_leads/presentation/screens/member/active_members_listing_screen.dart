import 'package:mentor_mobile_app/imports_bindings.dart';

class ActiveMembersListingScreen extends StatelessWidget {
  const ActiveMembersListingScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: const _ActiveMembersListingScreen(),
    );
  }
}

class _ActiveMembersListingScreen extends StatefulWidget {
  const _ActiveMembersListingScreen();

  @override
  State<_ActiveMembersListingScreen> createState() =>
      _ActiveMembersListingScreenState();
}

class _ActiveMembersListingScreenState
    extends State<_ActiveMembersListingScreen> {
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
        status: MemberStatus.active,
        searchQuery: searchQuery,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? context.colors.background : const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: const PopButton().center,
        backgroundColor: isDark ? context.colors.background : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        titleTextStyle: AppStyles.text16Px.poppins.w600.copyWith(
          color: context.colors.textPrimary,
        ),
        title: const Text('Members'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            children: [
              TextField(
                style: TextStyle(
                  color: context.colors.textPrimary,
                ),
                onChanged: (q) {
                  EasyDebounce.debounce(
                    'active_members_search_query',
                    const Duration(milliseconds: 300),
                    () => _fetch(searchQuery: q),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search for name or phone number',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  filled: isDark,
                  fillColor: context.colors.fieldFill,
                  prefixIcon: SizedBox.square(
                    dimension: 32,
                    child: SvgPicture.asset(
                      'assets/images/svg/icons/search.svg',
                      height: 32,
                      width: 32,
                      colorFilter: ColorFilter.mode(
                        isDark ? context.colors.textSecondary : AppColors.textGrey,
                        BlendMode.srcIn,
                      ),
                    ).center,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: isDark ? context.colors.border : const Color(0xffDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.primary : const Color(0xffDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: isDark ? context.colors.border : const Color(0xffDDDDDD),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ).pad(16),
              Expanded(
                child: Container(
                  color: isDark ? context.colors.background : const Color(0xffF7F7F7),
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
                                    '${memebersDataum.count ?? 0} members',
                                    style: AppStyles.text14Px.poppins.w500.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: RefreshIndicator.adaptive(
                                    onRefresh: _fetch,
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
                                            padding: const EdgeInsets.only(bottom: 32),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: cols,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              mainAxisExtent: 205,
                                            ),
                                            itemCount:
                                                memebersDataum.results?.length ?? 0,
                                            itemBuilder: (context, index) {
                                              final memberData =
                                                  memebersDataum.results?[index];
                                              return _buildMemberGridCard(
                                                context,
                                                memberData,
                                              );
                                            },
                                          );
                                        }

                                        return ListView.separated(
                                          controller: _scrollController,
                                          padding: const EdgeInsets.only(bottom: 32),
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
                                            return _buildMemberListItem(
                                              context,
                                              memberData,
                                            );
                                          },
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
        ),
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
          Dialogs.showSnack(msg: 'Member not found!');
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

            // Bottom row: Plan Name on the left, Status / Expiry badge on the right
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
                _buildActiveMemberBadge(context, memberData),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberListItem(BuildContext context, MemberDataModel? memberData) {
    final isDark = context.isDarkMode;
    final endDate = memberData?.activePlan?.endDate;
    bool isExpiringSoon = false;
    if (endDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final difference = end.difference(today).inDays;
      isExpiringSoon = difference >= 0 && difference <= 10;
    }

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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isExpiringSoon
              ? (isDark ? const Color(0xFF2B220F) : const Color(0xffFFFDE7))
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpiringSoon
                ? (isDark ? const Color(0xFF5A4418) : const Color(0xFFFFE082))
                : (isDark ? context.colors.border : Colors.transparent),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
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
                      const SizedBox(height: 4),
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
                const SizedBox(width: 8),
                _buildActiveMemberBadge(context, memberData),
              ],
            ),
            if ((memberData?.activePlan?.planName ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xffEEEEEE),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      memberData?.activePlan?.planName ?? '',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMemberBadge(BuildContext context, MemberDataModel? memberData) {
    final endDate = memberData?.activePlan?.endDate;
    final isDark = context.isDarkMode;

    if (endDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final difference = end.difference(today).inDays;

      if (difference < 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF381A1A) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Expired',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: isDark ? const Color(0xFFF87171) : const Color(0xFFD32F2F),
            ),
          ),
        );
      } else if (difference <= 10) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3B250A) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            difference == 0 ? 'Today' : '${difference}d left',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFE65100),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14331C) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Active',
        style: AppStyles.text12Px.poppins.w600.copyWith(
          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
