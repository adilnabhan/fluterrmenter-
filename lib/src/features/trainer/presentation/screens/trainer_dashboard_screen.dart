import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_customers_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/account_switcher_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerDashboard,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _dashboardData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load dashboard data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading dashboard: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _dashboardData['stats'] as Map<String, dynamic>? ?? {};
    final activeClients = stats['active_clients'] ?? 0;
    final pendingVerifications = stats['pending_verifications'] ?? 0;
    final workoutPlansCreated = stats['workout_plans_created'] ?? 0;
    final averageRating = stats['average_rating'] ?? 0.0;

    final memberInsights =
        _dashboardData['member_insights'] as Map<String, dynamic>? ?? {};
    final upcomingBirthdays =
        memberInsights['upcoming_birthdays'] as List<dynamic>? ?? [];

    final performanceOverview =
        _dashboardData['performance_overview'] as Map<String, dynamic>? ?? {};
    final monthlyEarnings =
        performanceOverview['monthly_earnings'] as List<dynamic>? ?? [];
    final currentMonthEarnings = performanceOverview['current_month'] ?? 0.0;

    final leaderboard = _dashboardData['leaderboard'] as List<dynamic>? ?? [];

    final user = context.watch<AppCubit>().state.currentUser;
    final trainerName = '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim();
    final displayName = trainerName.isNotEmpty ? trainerName : 'Trainer Profile';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            side: const BorderSide(color: Color(0xffDDDDDD)),
          ),
          onPressed: () {
            const AccountSwitcherSheet().show(context);
          },
          label: const Icon(
            Icons.keyboard_arrow_down_sharp,
            color: Color(0xff222222),
            size: 20,
          ),
          icon: Text(
            displayName,
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: const Color(0xff222222),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header greeting
                      // Text(
                      //   'Welcome back,',
                      //   style: AppStyles.text14Px.poppins.w400.copyWith(
                      //     color: AppColors.textGrey,
                      //   ),
                      // ),
                      // Text(
                      //   context.read<AppCubit>().state.currentUser?.firstName ??
                      //       'Trainer',
                      //   style: AppStyles.text22Px.poppins.w700.dark,
                      // ),
                      // const SizedBox(height: 20),

                      _buildBannerCarousel(),
                      const SizedBox(height: 22),

                      // Stats Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.6,
                          children: [
                          _buildStatCard(
                            title: 'Active\nClients',
                            value: '$activeClients',
                            valueColor: const Color(0xFF486CC2),
                            titleColor: const Color(0xFF486CC2),
                            circleArrowColor: const Color(0xFF486CC2),
                            onTap: () {
                              context.push(const TrainerCustomersScreen(isPushed: true));
                            },
                          ),
                          _buildStatCard(
                            title: 'Pending\nVerifications',
                            value: '$pendingVerifications',
                            valueColor: const Color(0xFFD35555),
                            titleColor: const Color(0xFFD35555),
                            circleArrowColor: const Color(0xFFD35555),
                          ),
                          _buildStatCard(
                            title: 'Workout Plans\nCreated',
                            value: '$workoutPlansCreated',
                            valueColor: const Color(0xFFD97706),
                            titleColor: AppColors.textDark,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const WorkoutGroupsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildStatCard(
                            title: 'Average\nRating',
                            value: '$averageRating',
                            valueColor: const Color(0xFF16A34A),
                            titleColor: AppColors.textDark,
                          ),
                        ],
                      ),
                      ),
                      const SizedBox(height: 24),
                      // Upcoming Birthdays
                      if (upcomingBirthdays.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Member Insights',
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children:
                                upcomingBirthdays.map<Widget>((bday) {
                                  final String name =
                                      bday['name'] as String? ?? 'N/A';
                                  final String dateStr =
                                      bday['date_of_birth'] as String? ?? '';
                                  final daysUntil = bday['days_until'] ?? 0;
                                  final imgUrl = bday['profile_picture'];

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.iconBackground,
                                              ),
                                              child: ClipOval(
                                                child:
                                                    imgUrl != null
                                                        ? Image.network(
                                                          imgUrl as String,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                _,
                                                                __,
                                                                ___,
                                                              ) => const Icon(
                                                                Icons.person,
                                                                size: 20,
                                                                color:
                                                                    AppColors
                                                                        .primary,
                                                              ),
                                                        )
                                                        : const Icon(
                                                          Icons.person,
                                                          size: 20,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name as String,
                                                    style:
                                                        AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w600,
                                                  ),
                                                  Text(
                                                    dateStr as String,
                                                    style: AppStyles
                                                        .text12Px
                                                        .poppins
                                                        .w400
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .textGrey,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffFFF3E0),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                daysUntil == 0
                                                    ? 'Today 🎉'
                                                    : 'In $daysUntil day${daysUntil == 1 ? "" : "s"}',
                                                style: AppStyles
                                                    .text12Px
                                                    .poppins
                                                    .w600
                                                    .copyWith(
                                                      color: const Color(
                                                        0xFFE65100,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (upcomingBirthdays.indexOf(bday) <
                                          upcomingBirthdays.length - 1)
                                        const Divider(
                                          height: 8,
                                          thickness: 0.5,
                                        ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildBannerCarousel() {
    final List<Widget> banners = [
      _buildBannerItem(
        title: 'BEST CUSTOMER SERVICES\nFor perfect body',
        subtitle: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.',
        discount: '30% OFF',
        gradientColors: [const Color(0xFFC471F5), const Color(0xFFFA71CD)],
      ),
      _buildBannerItem(
        title: 'NEW WORKOUT PLANS\nAvailable now',
        subtitle: 'Reach your goals faster with our expert trainers.',
        discount: 'JOIN NOW',
        gradientColors: [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      ),
    ];

    return Column(
      children: [
        CarouselSlider(
          items: banners,
          options: CarouselOptions(
            height: 180,
            viewportFraction: 1,
            enlargeCenterPage: false,
            autoPlay: true,
            onPageChanged: (index, reason) {
              if (!mounted) return;
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: banners.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == entry.key
                    ? AppColors.primary
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBannerItem({
    required String title,
    required String subtitle,
    required String discount,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppStyles.text22Px.poppins.w800.copyWith(color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white.withOpacity(0.9)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Text(
              discount,
              style: AppStyles.text14Px.poppins.w700.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required Color titleColor,
    Color? circleArrowColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              value,
              style: AppStyles.text28Px.poppins.w600.copyWith(color: valueColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.text13Px.poppins.w500.copyWith(
                      color: titleColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (circleArrowColor != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: circleArrowColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textDark,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBarChart(List<dynamic> earnings) {
    double maxAmt = 1.0;
    for (final e in earnings) {
      final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
      if (amt > maxAmt) {
        maxAmt = amt;
      }
    }

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            earnings.map((e) {
              final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
              final month = e['month'] as String? ?? '';
              final double barHeight = (amt / maxAmt) * 110;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '₹${amt.toInt()}',
                    style: AppStyles.text10Px.poppins.w600.copyWith(
                      color: amt > 0 ? AppColors.primary : AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 24,
                    height: barHeight == 0 ? 4 : barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors:
                            amt > 0
                                ? [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.5),
                                ]
                                : [Colors.grey.shade200, Colors.grey.shade100],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    month,
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor;
    String text;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700);
        textColor = const Color(0xFF8B6508);
        text = '1';
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0);
        textColor = const Color(0xFF4F4F4F);
        text = '2';
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32);
        textColor = const Color(0xFF8B4513);
        text = '3';
        break;
      default:
        badgeColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = '$rank';
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
      child: Text(
        text,
        style: AppStyles.text12Px.poppins.w700.copyWith(color: textColor),
      ),
    );
  }
}
