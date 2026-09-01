import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_clients_trained_screen.dart';

final ValueNotifier<int> reportsRefreshTrigger = ValueNotifier<int>(0);

class TrainerReportsScreen extends StatefulWidget {
  const TrainerReportsScreen({super.key});

  @override
  State<TrainerReportsScreen> createState() => _TrainerReportsScreenState();
}

class _TrainerReportsScreenState extends State<TrainerReportsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dailyReport = {};
  Map<String, dynamic> _monthlyReport = {};

  @override
  void initState() {
    super.initState();
    _fetchReports();
    reportsRefreshTrigger.addListener(_fetchReports);
  }

  @override
  void dispose() {
    reportsRefreshTrigger.removeListener(_fetchReports);
    super.dispose();
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<AppCubit>().state.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch daily report
      final dailyResponse = await DioClient().dio.get<dynamic>(
        ApiUris.trainerReports,
        queryParameters: {'range_type': 'daily'},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      // Fetch monthly report
      final monthlyResponse = await DioClient().dio.get<dynamic>(
        ApiUris.trainerReports,
        queryParameters: {'range_type': 'monthly'},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (!mounted) return;
      setState(() {
        if (dailyResponse.statusCode == 200 && dailyResponse.data is Map) {
          _dailyReport = Map<String, dynamic>.from(dailyResponse.data as Map);
        }
        if (monthlyResponse.statusCode == 200 && monthlyResponse.data is Map) {
          _monthlyReport = Map<String, dynamic>.from(
            monthlyResponse.data as Map,
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Daily Stats
    final dailyClientsTrained = _dailyReport['clients_trained_count'] ?? 0;
    final dailyWorkoutsAssigned =
        _dailyReport['workouts_assigned_count'] ??
        _dailyReport['workout_plans_given_count'] ??
        0;
    final dailyWorkoutsCompleted =
        _dailyReport['workouts_completed_count'] ?? 0;
    final dailyVerifiedWorkouts =
        _dailyReport['verified_workouts_count'] ??
        _dailyReport['verified_workouts'] ??
        0;

    // Monthly Stats
    final monthlyClientsTrained = _monthlyReport['clients_trained_count'] ?? 0;
    final monthlyWorkoutsAssigned =
        _monthlyReport['workouts_assigned_count'] ??
        _monthlyReport['workout_plans_given_count'] ??
        0;
    final monthlyCompletionRate =
        _monthlyReport['completion_rate']?.toString() ?? "0%";
    final monthlyActiveProgress =
        _monthlyReport['active_progress']?.toString() ?? "-";

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.icon),
        title: Text(
          'Trainer Reports',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body:
          _isLoading
              ? _buildShimmerLoading()
              : RefreshIndicator(
                onRefresh: _fetchReports,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Report Summary Cards
                      Text(
                        'Daily Report',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          _buildReportCard(
                            title: 'Clients Trained',
                            value: '$dailyClientsTrained',
                            icon: Icons.people_outline,
                            color: const Color(0xff486CC2),
                            onTap: () {
                              final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TrainerClientsTrainedScreen(
                                        rangeType: 'daily',
                                        date: todayStr,
                                        title: 'Clients Trained Today',
                                      ),
                                ),
                              );
                            },
                          ),
                          _buildReportCard(
                            title: 'Workouts Assigned',
                            value: '$dailyWorkoutsAssigned',
                            icon: Icons.assignment_outlined,
                            color: const Color(0xff9C51BF),
                          ),
                          _buildReportCard(
                            title: 'Workouts Completed',
                            value: '$dailyWorkoutsCompleted',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xff527F50),
                          ),
                          _buildReportCard(
                            title: 'Verified Workouts',
                            value: '$dailyVerifiedWorkouts',
                            icon: Icons.verified_outlined,
                            color: const Color(0xffE67E22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Monthly Report
                      Text(
                        'Monthly Performance Report',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          children: [
                            _buildReportRow(
                              'Total Clients Trained',
                              '$monthlyClientsTrained',
                            ),
                            Divider(
                              height: 24,
                              thickness: 1,
                              color: context.colors.divider,
                            ),
                            _buildReportRow(
                              'Total Assigned Workouts',
                              '$monthlyWorkoutsAssigned',
                            ),
                            Divider(
                              height: 24,
                              thickness: 1,
                              color: context.colors.divider,
                            ),
                            _buildReportRow(
                              'Workout Completion Rate',
                              monthlyCompletionRate,
                            ),
                            Divider(
                              height: 24,
                              thickness: 1,
                              color: context.colors.divider,
                            ),
                            _buildReportRow(
                              'Active Workouts Progress',
                              monthlyActiveProgress,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppStyles.text24Px.poppins.w700.copyWith(
                    fontSize: 28,
                    color: context.colors.textPrimary,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              title,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Report Header
          Text(
            'Daily Report',
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid Shimmer Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: List.generate(4, (index) => _buildCardShimmer()),
          ),
          const SizedBox(height: 28),

          // Monthly Report Header
          Text(
            'Monthly Performance Report',
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Monthly Report Container Shimmer
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                _buildRowShimmer(leftWidth: 160, rightWidth: 30),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: context.colors.divider,
                ),
                _buildRowShimmer(leftWidth: 150, rightWidth: 40),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: context.colors.divider,
                ),
                _buildRowShimmer(leftWidth: 170, rightWidth: 50),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: context.colors.divider,
                ),
                _buildRowShimmer(leftWidth: 140, rightWidth: 120, twoLinesRight: true),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              KShimmer(width: 28, height: 28, radius: 14),
              KShimmer(width: 50, height: 10, radius: 4),
            ],
          ),
          KShimmer(width: double.infinity, height: 26, radius: 8),
          KShimmer(width: 80, height: 10, radius: 4),
        ],
      ),
    );
  }

  Widget _buildRowShimmer({
    required double leftWidth,
    required double rightWidth,
    bool twoLinesRight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KShimmer(width: leftWidth, height: 14, radius: 6),
        if (twoLinesRight)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              KShimmer(width: rightWidth, height: 12, radius: 6),
              const SizedBox(height: 4),
              KShimmer(width: rightWidth * 0.7, height: 10, radius: 6),
            ],
          )
        else
          KShimmer(width: rightWidth, height: 14, radius: 6),
      ],
    );
  }
}
