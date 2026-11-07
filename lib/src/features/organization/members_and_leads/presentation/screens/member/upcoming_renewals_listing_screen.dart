import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/domain/models/upcoming_renewals/upcoming_renewal_model.dart';

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
    extends State<_UpcomingRenewalsListingScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool isPaginating = false, String? searchQuery}) =>
      _cubit.fetchUpcomingRenewals(
        isPagination: isPaginating,
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
        title: const Text('Upcoming Renewals'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: TextStyle(
                  color: context.colors.textPrimary,
                ),
                onChanged: (q) {
                  setState(() {});
                  EasyDebounce.debounce(
                    'upcoming_renewals_search_query',
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: isDark
                                ? context.colors.textSecondary
                                : AppColors.textGrey,
                          ),
                          splashRadius: 18,
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            FocusManager.instance.primaryFocus?.unfocus();
                            _fetch(searchQuery: '');
                          },
                        )
                      : null,
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
                    buildWhen: (p, c) => p.upcomingRenewals != c.upcomingRenewals,
                    builder: (context, state) {
                      return state.upcomingRenewals.data.fold(
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
                            return RefreshIndicator.adaptive(
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
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
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
        ),
      ),
    );
  }

  Widget _buildMemberGridCard(
      BuildContext context, UpcomingRenewalModel? memberData) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: () {
        final id = memberData?.id;
        if (id != null) {
          context.push(
            BlocProvider.value(
              value: _cubit,
              child: MemberDetialsScreen(
                memberId: id,
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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ProfileImage(
                  isEdit: false,
                  canViewFullImage: true,
                  name: memberData?.name,
                  url: '${memberData?.profileImage ?? ''}',
                  radius: 72,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
            Text(
              memberData?.phone ?? '',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    memberData?.membershipName ?? '',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B250A) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    (memberData?.expiryLabel ?? '').isNotEmpty
                        ? memberData!.expiryLabel!
                        : 'Renew',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberListItem(
      BuildContext context, UpcomingRenewalModel? memberData) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: () {
        final id = memberData?.id;
        if (id != null) {
          context.push(
            BlocProvider.value(
              value: _cubit,
              child: MemberDetialsScreen(
                memberId: id,
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
            color: isDark ? context.colors.border : Colors.transparent,
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
                    url: '${memberData?.profileImage ?? ''}',
                    radius: 40,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memberData?.name ?? '',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          memberData?.phone ?? '',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B250A) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    (memberData?.expiryLabel ?? '').isNotEmpty
                        ? memberData!.expiryLabel!
                        : 'Renew',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
            if ((memberData?.membershipName ?? '').isNotEmpty) ...[
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
                  Text(
                    memberData?.membershipName ?? '',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Text(
                    memberData?.renewalDate ?? '',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.colors.textSecondary,
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
}
