import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_customers_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerDashboard,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _dashboardData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load dashboard data');
      }
    } catch (e) {
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

    final memberInsights = _dashboardData['member_insights'] as Map<String, dynamic>? ?? {};
    final upcomingBirthdays = memberInsights['upcoming_birthdays'] as List<dynamic>? ?? [];

    final performanceOverview = _dashboardData['performance_overview'] as Map<String, dynamic>? ?? {};
    final monthlyEarnings = performanceOverview['monthly_earnings'] as List<dynamic>? ?? [];
    final currentMonthEarnings = performanceOverview['current_month'] ?? 0.0;

    final leaderboard = _dashboardData['leaderboard'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text(
          'Trainer Dashboard',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        actions: [
          IconButton(
            onPressed: () => const LogoutSheet().show(context),
            icon: const Icon(Icons.logout, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header greeting
                    Text(
                      'Welcome back,',
                      style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                    ),
                    Text(
                      context.read<AppCubit>().state.currentUser?.firstName ?? 'Trainer',
                      style: AppStyles.text22Px.poppins.w700.dark,
                    ),
                    const SizedBox(height: 20),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          title: 'Active Clients',
                          value: '$activeClients',
                          icon: Icons.people,
                          color: const Color(0xFFE3F2FD),
                          iconColor: const Color(0xFF1E88E5),
                          onTap: () {
                            context.push(const TrainerCustomersScreen());
                          },
                        ),
                        _buildStatCard(
                          title: 'Pending Approvals',
                          value: '$pendingVerifications',
                          icon: Icons.pending_actions,
                          color: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFB8C00),
                        ),
                        _buildStatCard(
                          title: 'Workout Plans',
                          value: '$workoutPlansCreated',
                          icon: Icons.fitness_center,
                          color: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF43A047),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkoutGroupsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildStatCard(
                          title: 'Average Rating',
                          value: '$averageRating ★',
                          icon: Icons.star,
                          color: const Color(0xFFFFFDE7),
                          iconColor: const Color(0xFFFDD835),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Clients Section Navigation Card
                    InkWell(
                      onTap: () {
                        context.push(const TrainerCustomersScreen());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.group, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Your Clients',
                                    style: AppStyles.text15Px.poppins.w600.copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    'Track progress, log remarks, & assign workout plans',
                                    style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white.withOpacity(0.85)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Earnings Custom Chart
                    if (monthlyEarnings.isNotEmpty) ...[
                      Text(
                        'Monthly Earnings Overview',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Month',
                                  style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                ),
                                Text(
                                  '₹$currentMonthEarnings',
                                  style: AppStyles.text16Px.poppins.w700.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildCustomBarChart(monthlyEarnings),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Leaderboard
                    if (leaderboard.isNotEmpty) ...[
                      Text(
                        'Clients Performance Leaderboard',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          children: leaderboard.map((player) {
                            final int rank = player['rank'] as int? ?? 1;
                            final String name = player['name'] as String? ?? 'N/A';
                            final completed = player['sessions_completed'] ?? 0;
                            final imgUrl = player['profile_picture'];

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      _buildRankBadge(rank),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.iconBackground,
                                        ),
                                        child: ClipOval(
                                          child: imgUrl != null
                                              ? Image.network(
                                                  imgUrl as String,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(Icons.person, size: 20, color: AppColors.primary),
                                                )
                                              : const Icon(Icons.person, size: 20, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name as String,
                                          style: AppStyles.text14Px.poppins.w600,
                                        ),
                                      ),
                                      Text(
                                        '$completed sessions',
                                        style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (rank < leaderboard.length) const Divider(height: 8, thickness: 0.5),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming Birthdays
                    if (upcomingBirthdays.isNotEmpty) ...[
                      Text(
                        'Upcoming Birthdays (Next 7 days)',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          children: upcomingBirthdays.map<Widget>((bday) {
                            final String name = bday['name'] as String? ?? 'N/A';
                            final String dateStr = bday['date_of_birth'] as String? ?? '';
                            final daysUntil = bday['days_until'] ?? 0;
                            final imgUrl = bday['profile_picture'];

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                                          child: imgUrl != null
                                              ? Image.network(
                                                  imgUrl as String,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(Icons.person, size: 20, color: AppColors.primary),
                                                )
                                              : const Icon(Icons.person, size: 20, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name as String,
                                              style: AppStyles.text14Px.poppins.w600,
                                            ),
                                            Text(
                                              dateStr as String,
                                              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFFF3E0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          daysUntil == 0 ? 'Today 🎉' : 'In $daysUntil day${daysUntil == 1 ? "" : "s"}',
                                          style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFFE65100)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (upcomingBirthdays.indexOf(bday) < upcomingBirthdays.length - 1)
                                  const Divider(height: 8, thickness: 0.5),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                if (onTap != null)
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.textGrey),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppStyles.text18Px.poppins.w700.dark,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        children: earnings.map((e) {
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
                    colors: amt > 0
                        ? [AppColors.primary, AppColors.primary.withOpacity(0.5)]
                        : [Colors.grey.shade200, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                month,
                style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
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
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: AppStyles.text12Px.poppins.w700.copyWith(color: textColor),
      ),
    );
  }
}
