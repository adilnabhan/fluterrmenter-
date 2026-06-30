import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class TrainerReportsScreen extends StatefulWidget {
  const TrainerReportsScreen({super.key});

  @override
  State<TrainerReportsScreen> createState() => _TrainerReportsScreenState();
}

class _TrainerReportsScreenState extends State<TrainerReportsScreen> {
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
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerReports,
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
    final clientsTrained = _reportsData['clients_trained_count'] ?? 0;
    final workoutsAssigned = _reportsData['workout_plans_given_count'] ?? 0;
    final workoutsCompleted = _reportsData['workouts_completed_count'] ?? 0;
    final attendance = _reportsData['attendance_rate']?.toString() ?? "0%";
    final completionRate = _reportsData['completion_rate']?.toString() ?? "0%";
    final activeProgress = _reportsData['active_progress']?.toString() ?? "Good";

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text(
          'Trainer Reports',
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
                    // Report Summary Cards
                    Text(
                      'Daily Report',
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
                          title: 'Clients Trained',
                          value: '$clientsTrained',
                          icon: Icons.people_outline,
                          color: const Color(0xff486CC2),
                        ),
                        _buildReportCard(
                          title: 'Workouts Assigned',
                          value: '$workoutsAssigned',
                          icon: Icons.assignment_outlined,
                          color: const Color(0xff9C51BF),
                        ),
                        _buildReportCard(
                          title: 'Workouts Completed',
                          value: '$workoutsCompleted',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xff527F50),
                        ),
                        _buildReportCard(
                          title: 'Attendance Rate',
                          value: attendance,
                          icon: Icons.calendar_today_outlined,
                          color: const Color(0xffE67E22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Monthly Performance Report',
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
                          _buildReportRow('Total Clients Assigned', '$clientsTrained'),
                          const Divider(height: 24, thickness: 1, color: Color(0xffEEEEEE)),
                          _buildReportRow('Total Assigned Workouts', '$workoutsAssigned'),
                          const Divider(height: 24, thickness: 1, color: Color(0xffEEEEEE)),
                          _buildReportRow('Workout Completion Rate', completionRate),
                          const Divider(height: 24, thickness: 1, color: Color(0xffEEEEEE)),
                          _buildReportRow('Active Workouts Progress', activeProgress),
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
              Text(
                value,
                style: AppStyles.text24Px.poppins.w700.dark.copyWith(fontSize: 28),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
        ),
      ],
    );
  }
}
