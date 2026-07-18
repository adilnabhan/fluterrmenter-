import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class OrganizationReportsScreen extends StatefulWidget {
  final int orgId;
  const OrganizationReportsScreen({super.key, required this.orgId});

  @override
  State<OrganizationReportsScreen> createState() =>
      _OrganizationReportsScreenState();
}

class _OrganizationReportsScreenState extends State<OrganizationReportsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _reportsData = {};

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch advanced reports from fitnesscenter/reports endpoint for the organization
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.reports}?organization_id=${widget.orgId}',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        if (!mounted) return;
        setState(() {
          _reportsData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parsing variables
    final financial =
        _reportsData['financial_metrics'] as Map<dynamic, dynamic>?;
    final totalRevenue = financial?['total_revenue'] ?? 0.0;
    final churnRate = financial?['churn_rate']?.toString() ?? "0%";
    final planRevenueBreakdown =
        financial?['plan_revenue_breakdown'] as List<dynamic>? ?? [];

    final demographics =
        _reportsData['client_demographics'] as Map<dynamic, dynamic>?;
    final totalClients = demographics?['total_clients'] ?? 0;
    final genderDistribution =
        demographics?['gender_distribution'] as Map<dynamic, dynamic>? ?? {};
    final ageDistribution =
        demographics?['age_distribution'] as Map<dynamic, dynamic>? ?? {};

    final attendance =
        _reportsData['attendance_patterns'] as Map<dynamic, dynamic>?;
    final totalCompletedSessions = attendance?['total_completed_sessions'] ?? 0;
    final peakWorkoutHours =
        attendance?['peak_workout_hours'] as Map<dynamic, dynamic>? ?? {};

    final trainersPerformance =
        _reportsData['trainers_performance'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text(
          'Gym Analytics & Reports',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
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
                      _buildSectionTitle('Overview'),
                      _buildOverviewGrid(
                        totalClients: totalClients.toString(),
                        completedSessions: totalCompletedSessions.toString(),
                        monthlyRevenue:
                            totalRevenue is double
                                ? totalRevenue
                                : double.tryParse(totalRevenue.toString()) ??
                                    0.0,
                        churnRate: churnRate,
                      ),
                      const SizedBox(height: 28),

                      if (planRevenueBreakdown.isNotEmpty) ...[
                        _buildSectionTitle('Plan Revenue Breakdown'),
                        _buildPlanRevenueBreakdown(planRevenueBreakdown),
                        const SizedBox(height: 28),
                      ],

                      _buildSectionTitle('Client Demographics'),
                      _buildDemographics(genderDistribution, ageDistribution),
                      const SizedBox(height: 28),

                      if (peakWorkoutHours.isNotEmpty) ...[
                        _buildSectionTitle('Peak Workout Hours'),
                        _buildPeakHours(peakWorkoutHours),
                        const SizedBox(height: 28),
                      ],

                      if (trainersPerformance.isNotEmpty) ...[
                        _buildSectionTitle('Trainer Performance'),
                        _buildTrainerPerformance(trainersPerformance),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppStyles.text16Px.poppins.w600.dark),
    );
  }

  Widget _buildOverviewGrid({
    required String totalClients,
    required String completedSessions,
    required double monthlyRevenue,
    required String churnRate,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildReportCard(
          title: 'Active Clients',
          value: totalClients,
          icon: Icons.people_outline,
          color: const Color(0xff486CC2),
        ),
        _buildReportCard(
          title: 'Completed Sessions',
          value: completedSessions,
          icon: Icons.check_circle_outline,
          color: const Color(0xff527F50),
        ),
        _buildReportCard(
          title: 'Monthly Revenue',
          value: "₹${monthlyRevenue.toStringAsFixed(0)}",
          icon: Icons.currency_rupee,
          color: AppColors.primary,
        ),
        _buildReportCard(
          title: 'Churn Rate',
          value: churnRate,
          icon: Icons.trending_down_outlined,
          color: const Color(0xffE67E22),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppStyles.text20Px.poppins.w600.copyWith(color: color),
              ),
              Text(
                title,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: AppColors.textGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRevenueBreakdown(List<dynamic> plans) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: plans.length,
        separatorBuilder:
            (_, __) => const Divider(height: 1, color: Color(0xffEEEEEE)),
        itemBuilder: (context, index) {
          final plan = plans[index] as Map<dynamic, dynamic>;
          final name = plan['plan_name']?.toString() ?? 'Unknown Plan';
          final type = plan['package_type']?.toString() ?? '';
          final revenue = plan['revenue'] ?? 0.0;
          final pctStr = plan['percentage']?.toString() ?? '0%';
          final subscribers = plan['subscribers_count'] ?? 0;

          double parsedPct = 0.0;
          try {
            parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
          } catch (_) {}

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppStyles.text14Px.poppins.w600.dark,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${(revenue is double ? revenue : double.tryParse(revenue.toString()) ?? 0.0).toStringAsFixed(0)}',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$type • $subscribers subscribers',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    Text(
                      pctStr,
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: parsedPct,
                  backgroundColor: const Color(0xffF0F0F0),
                  color: AppColors.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemographics(
    Map<dynamic, dynamic> genderDist,
    Map<dynamic, dynamic> ageDist,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender Distribution',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 12),
          ...genderDist.entries.map((e) {
            final key = e.key.toString();
            final data = e.value as Map<dynamic, dynamic>?;
            if (data == null) return const SizedBox.shrink();
            final String pctStr = data['percentage']?.toString() ?? '0%';

            double parsedPct = 0.0;
            try {
              parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
            } catch (_) {}

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        key[0].toUpperCase() + key.substring(1),
                        style: AppStyles.text12Px.poppins.w500.dark,
                      ),
                      Text(pctStr, style: AppStyles.text12Px.poppins.w500.dark),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: parsedPct,
                    backgroundColor: const Color(0xffF0F0F0),
                    color:
                        key.toLowerCase() == 'male'
                            ? const Color(0xff486CC2)
                            : (key.toLowerCase() == 'female'
                                ? const Color(0xffC2486C)
                                : Colors.grey),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 24, color: Color(0xffEEEEEE)),

          Text('Age Distribution', style: AppStyles.text14Px.poppins.w300.dark),
          const SizedBox(height: 12),
          ...ageDist.entries.map((e) {
            final key = e.key.toString();
            final data = e.value as Map<dynamic, dynamic>?;
            if (data == null) return const SizedBox.shrink();
            final String pctStr = data['percentage']?.toString() ?? '0%';

            double parsedPct = 0.0;
            try {
              parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
            } catch (_) {}

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      key,
                      style: AppStyles.text12Px.poppins.w500.dark,
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: parsedPct,
                      backgroundColor: const Color(0xffF0F0F0),
                      color: const Color(0xffF39C12),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 50,
                    child: Text(
                      pctStr,
                      style: AppStyles.text12Px.poppins.w500.dark,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPeakHours(Map<dynamic, dynamic> peakHours) {
    final sortedEntries =
        peakHours.entries.toList()..sort(
          (a, b) => ((b.value as int?) ?? 0).compareTo((a.value as int?) ?? 0),
        );

    final topEntries = sortedEntries.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        children:
            topEntries.map((e) {
              final time = e.key.toString();
              final count = e.value.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xff527F50),
                        ),
                        const SizedBox(width: 8),
                        Text(time, style: AppStyles.text14Px.poppins.w500.dark),
                      ],
                    ),
                    Text(
                      '$count Sessions',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTrainerPerformance(List<dynamic> trainers) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trainers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trainer = trainers[index] as Map<dynamic, dynamic>;
        final name = trainer['name']?.toString() ?? 'Unknown Trainer';
        final exp = trainer['experience_years'] ?? 0;
        final clients = trainer['clients_trained_count'] ?? 0;
        final given = trainer['workout_plans_given_count'] ?? 0;
        final completed = trainer['workouts_completed_count'] ?? 0;
        final attendance = trainer['attendance_rate']?.toString() ?? '0%';
        final completion = trainer['completion_rate']?.toString() ?? '0%';
        final progress = trainer['active_progress']?.toString() ?? 'N/A';
        final waLink = trainer['whatsapp_link']?.toString() ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppStyles.text16Px.poppins.w500.dark),
                        const SizedBox(height: 4),
                        Text(
                          '$exp Years Experience • Progress: $progress',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (waLink.isNotEmpty)
                    InkWell(
                      onTap: () => launchUrl(Uri.parse(waLink)),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff25D366).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xff25D366),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTrainerStatBlock(
                      'Clients',
                      clients.toString(),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: const Color(0xffEEEEEE),
                  ),
                  Expanded(
                    child: _buildTrainerStatBlock('Given', given.toString()),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: const Color(0xffEEEEEE),
                  ),
                  Expanded(
                    child: _buildTrainerStatBlock(
                      'Completed',
                      completed.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF9F9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance: $attendance',
                      style: AppStyles.text12Px.poppins.w500.dark,
                    ),
                    Text(
                      'Completion: $completion',
                      style: AppStyles.text12Px.poppins.w500.dark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainerStatBlock(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppStyles.text16Px.poppins.w600.dark),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
