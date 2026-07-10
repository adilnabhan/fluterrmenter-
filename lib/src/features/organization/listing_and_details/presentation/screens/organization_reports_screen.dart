import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganizationReportsScreen extends StatefulWidget {
  final int orgId;
  const OrganizationReportsScreen({super.key, required this.orgId});

  @override
  State<OrganizationReportsScreen> createState() => _OrganizationReportsScreenState();
}

class _OrganizationReportsScreenState extends State<OrganizationReportsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _reportsData = {};
  int _selectedDays = 30;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.reports}?organization_id=${widget.orgId}&days=$_selectedDays',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _reportsData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load report metrics. Please try again.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Unable to connect to the server. Please check your internet.";
        _isLoading = false;
      });
    }
  }

  void _changeDaysFilter(int days) {
    if (_selectedDays == days) return;
    setState(() {
      _selectedDays = days;
    });
    _fetchReports();
  }

  Future<void> _launchWhatsApp(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse data safely
    final financialMetrics = _reportsData['financial_metrics'] as Map<dynamic, dynamic>? ?? {};
    final totalRevenue = double.tryParse(financialMetrics['total_revenue']?.toString() ?? '0') ?? 0.0;
    final newSignups = int.tryParse(financialMetrics['new_signups']?.toString() ?? '0') ?? 0;
    final churnRate = financialMetrics['churn_rate']?.toString() ?? "0%";
    final planBreakdown = financialMetrics['plan_revenue_breakdown'] as List<dynamic>? ?? [];

    final clientDemographics = _reportsData['client_demographics'] as Map<dynamic, dynamic>? ?? {};
    final totalClients = int.tryParse(clientDemographics['total_clients']?.toString() ?? '0') ?? 0;
    final genderDist = clientDemographics['gender_distribution'] as Map<dynamic, dynamic>? ?? {};
    final ageDist = clientDemographics['age_distribution'] as Map<dynamic, dynamic>? ?? {};

    final goalsInsights = _reportsData['goals_insights'] as Map<dynamic, dynamic>? ?? {};
    final fitnessLevels = goalsInsights['fitness_levels'] as Map<dynamic, dynamic>? ?? {};
    final weightGoals = goalsInsights['weight_goals'] as Map<dynamic, dynamic>? ?? {};
    final stressLevels = goalsInsights['stress_levels'] as Map<dynamic, dynamic>? ?? {};

    final healthProfiles = _reportsData['health_profiles'] as Map<dynamic, dynamic>? ?? {};
    final injuries = healthProfiles['injuries'] as Map<dynamic, dynamic>? ?? {};
    final medicalConditions = healthProfiles['medical_conditions'] as Map<dynamic, dynamic>? ?? {};

    final attendancePatterns = _reportsData['attendance_patterns'] as Map<dynamic, dynamic>? ?? {};
    final completedSessions = int.tryParse(attendancePatterns['total_completed_sessions']?.toString() ?? '0') ?? 0;

    final trainersPerformance = _reportsData['trainers_performance'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffFAFBFD),
      appBar: AppBar(
        title: Text(
          'Gym Analytics & Reports',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Demographics'),
            Tab(text: 'Trainers'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchReports,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Day range filter selector bar
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time Range:',
                            style: AppStyles.text13Px.poppins.w500.copyWith(color: AppColors.textGrey),
                          ),
                          Row(
                            children: [
                              _buildFilterButton('10 Days', 10),
                              const SizedBox(width: 8),
                              _buildFilterButton('30 Days', 30),
                              const SizedBox(width: 8),
                              _buildFilterButton('90 Days', 90),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Overview
                          RefreshIndicator(
                            onRefresh: _fetchReports,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildOverviewGrid(totalClients, completedSessions, totalRevenue, churnRate),
                                  const SizedBox(height: 24),
                                  _buildPlanBreakdownCard(planBreakdown),
                                ],
                              ),
                            ),
                          ),

                          // Tab 2: Demographics & Insights
                          RefreshIndicator(
                            onRefresh: _fetchReports,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDistributionCard('Gender Distribution', genderDist, color: Colors.teal),
                                  const SizedBox(height: 16),
                                  _buildDistributionCard('Age Distribution', ageDist, color: Colors.blue),
                                  const SizedBox(height: 16),
                                  _buildDistributionCard('Weight Goals', weightGoals, color: Colors.orange),
                                  const SizedBox(height: 16),
                                  _buildDistributionCard('Fitness Levels', fitnessLevels, color: Colors.indigo),
                                  const SizedBox(height: 16),
                                  _buildHealthSection(injuries, medicalConditions),
                                ],
                              ),
                            ),
                          ),

                          // Tab 3: Trainers
                          RefreshIndicator(
                            onRefresh: _fetchReports,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (trainersPerformance.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                                        child: Text(
                                          'No trainer performance data found.',
                                          style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: trainersPerformance.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final trainer = trainersPerformance[index] as Map<dynamic, dynamic>;
                                        final String name = trainer['name'] ?? 'Trainer';
                                        final String rate = trainer['completion_rate'] ?? '0.0%';
                                        final int clients = trainer['clients_trained_count'] ?? 0;
                                        final int completed = trainer['workouts_completed_count'] ?? 0;
                                        final String? waLink = trainer['whatsapp_link']?.toString();
                                        final String progress = trainer['active_progress'] ?? 'No Data';

                                        return _buildTrainerCard(name, rate, clients, completed, progress, waLink);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterButton(String label, int days) {
    final bool isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () => _changeDaysFilter(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xffF0F2F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppStyles.text12Px.poppins.w600.copyWith(
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewGrid(int totalClients, int completedSessions, double totalRevenue, String churnRate) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _buildReportCard(
          title: 'Active Clients',
          value: '$totalClients',
          icon: Icons.people_outline,
          color: const Color(0xff486CC2),
        ),
        _buildReportCard(
          title: 'Completed Sessions',
          value: '$completedSessions',
          icon: Icons.check_circle_outline,
          color: const Color(0xff527F50),
        ),
        _buildReportCard(
          title: 'Total Revenue',
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
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
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
                  style: AppStyles.text20Px.poppins.w700.dark.copyWith(fontSize: 22),
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

  Widget _buildPlanBreakdownCard(List<dynamic> planBreakdown) {
    return Container(
      width: double.maxFinite,
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
            'Membership Plan Revenue Share',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          if (planBreakdown.isEmpty)
            Text(
              'No active plans found for this gym.',
              style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: planBreakdown.length,
              separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xffEEEEEE)),
              itemBuilder: (context, index) {
                final plan = planBreakdown[index] as Map<dynamic, dynamic>;
                final String name = plan['plan_name'] ?? 'Plan';
                final double revenue = double.tryParse(plan['revenue']?.toString() ?? '0') ?? 0.0;
                final String percentage = plan['percentage'] ?? '0.0%';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppStyles.text13Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revenue Share: $percentage',
                          style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                    Text(
                      '₹${revenue.toStringAsFixed(0)}',
                      style: AppStyles.text14Px.poppins.w700.copyWith(color: const Color(0xff9C51BF)),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(String title, Map<dynamic, dynamic> data, {required Color color}) {
    return Container(
      width: double.maxFinite,
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
            title,
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            Text(
              'No demographic details recorded.',
              style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
            )
          else
            Column(
              children: data.entries.map<Widget>((entry) {
                final String label = entry.key.toString().toUpperCase();
                final val = entry.value as Map<dynamic, dynamic>;
                final String pctString = val['percentage']?.toString() ?? '0%';
                final double pct = double.tryParse(pctString.replaceAll('%', '')) ?? 0.0;
                final int count = int.tryParse(val['count']?.toString() ?? '0') ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$label ($count)',
                            style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                          ),
                          Text(
                            pctString,
                            style: AppStyles.text12Px.poppins.w600.dark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100.0,
                          backgroundColor: const Color(0xffF0F2F6),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthSection(Map<dynamic, dynamic> injuries, Map<dynamic, dynamic> medicalConditions) {
    return Container(
      width: double.maxFinite,
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
            'Health Profiles',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          Text(
            'Common Injuries / Pain Areas:',
            style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          if (injuries.isEmpty)
            Text(
              'None reported.',
              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
            )
          else
            ...injuries.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.toString(), style: AppStyles.text12Px.poppins.w500.dark),
                      Text((e.value as Map)['percentage']?.toString() ?? '0%',
                          style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.red)),
                    ],
                  ),
                )),
          const Divider(height: 24, color: Color(0xffEEEEEE)),
          Text(
            'Medical Conditions:',
            style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          if (medicalConditions.isEmpty)
            Text(
              'None reported.',
              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
            )
          else
            ...medicalConditions.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.toString(), style: AppStyles.text12Px.poppins.w500.dark),
                      Text((e.value as Map)['percentage']?.toString() ?? '0%',
                          style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.red)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTrainerCard(String name, String rate, int clients, int completed, String progress, String? waLink) {
    Color progressColor = Colors.teal;
    if (progress == 'Needs Attention') {
      progressColor = Colors.red;
    } else if (progress == 'Average') {
      progressColor = Colors.blue;
    }

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
              Expanded(
                child: Text(
                  name,
                  style: AppStyles.text14Px.poppins.w600.dark,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  progress,
                  style: AppStyles.text12Px.poppins.w600.copyWith(color: progressColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clients: $clients',
                style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
              ),
              Text(
                'Completion Rate: $rate',
                style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Workouts Completed: $completed',
            style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
          ),
          if (waLink != null && waLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(waLink),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('WhatsApp Enquiry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
