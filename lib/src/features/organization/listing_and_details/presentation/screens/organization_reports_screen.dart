import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class OrganizationReportsScreen extends StatefulWidget {
  final int orgId;
  const OrganizationReportsScreen({super.key, required this.orgId});

  @override
  State<OrganizationReportsScreen> createState() => _OrganizationReportsScreenState();
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
        setState(() {
          _reportsData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Financial metrics
    final financial = _reportsData['financial_metrics'] as Map<dynamic, dynamic>?;
    final totalRevenue = financial?['total_revenue'] ?? 0.0;
    final newSignups = financial?['new_signups'] ?? 0;
    final churnRate = financial?['churn_rate'] ?? "0%";

    // Demographics/Attendance
    final demographics = _reportsData['client_demographics'] as Map<dynamic, dynamic>?;
    final totalClients = demographics?['total_clients'] ?? 0;

    final attendance = _reportsData['attendance_patterns'] as Map<dynamic, dynamic>?;
    final totalCompletedSessions = attendance?['total_completed_sessions'] ?? 0;

    // Trainers performance list
    final trainersPerformance = _reportsData['trainers_performance'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text(
          'Gym Analytics & Reports',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily / Overview metrics
                    Text(
                      'Overview',
                      style: AppStyles.text16Px.poppins.w600.dark,
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
                          title: 'Active Clients',
                          value: '$totalClients',
                          icon: Icons.people_outline,
                          color: const Color(0xff486CC2),
                        ),
                        _buildReportCard(
                          title: 'Completed Sessions',
                          value: '$totalCompletedSessions',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xff527F50),
                        ),
                        _buildReportCard(
                          title: 'Monthly Revenue',
                          value: '₹${totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.currency_rupee,
                          color: const Color(0xff9C51BF),
                        ),
                        _buildReportCard(
                          title: 'Churn Rate',
                          value: churnRate,
                          icon: Icons.trending_down_outlined,
                          color: const Color(0xffE67E22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Financial details
                    Text(
                      'Financial & Demographics Summary',
                      style: AppStyles.text16Px.poppins.w600.dark,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _buildReportRow('New Signups (Last 30 Days)', '$newSignups'),
                          const Divider(height: 24, thickness: 1, color: Color(0xffEEEEEE)),
                          _buildReportRow('Total Monthly Revenue', '₹${totalRevenue.toStringAsFixed(2)}'),
                          const Divider(height: 24, thickness: 1, color: Color(0xffEEEEEE)),
                          _buildReportRow('Member Retention Status', 'Healthy'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Trainer Performance leaderboard
                    if (trainersPerformance.isNotEmpty) ...[
                      Text(
                        'Trainer Performance',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trainersPerformance.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = trainersPerformance[index] as Map<dynamic, dynamic>;
                          final name = item['name'] ?? 'Unknown';
                          final clients = item['clients_trained_count'] ?? 0;
                          final completed = item['workouts_completed_count'] ?? 0;
                          final rate = item['completion_rate'] ?? '0.0%';
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: AppStyles.text14Px.poppins.w600.dark,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffEAF2FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Rate: $rate',
                                        style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xff486CC2)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Active Clients: $clients',
                                      style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                    ),
                                    Text(
                                      'Workouts Completed: $completed',
                                      style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppStyles.text20Px.poppins.w700.dark.copyWith(fontSize: 24),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            title,
            style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
        ),
        Text(
          value,
          style: AppStyles.text14Px.poppins.w600.dark,
        ),
      ],
    );
  }
}
