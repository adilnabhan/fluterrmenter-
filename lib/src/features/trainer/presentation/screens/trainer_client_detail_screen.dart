import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/widgets/trainer_client_workout_history_calendar.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  const TrainerClientDetailScreen({required this.customerId, super.key});

  final int customerId;

  @override
  State<TrainerClientDetailScreen> createState() =>
      _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen> {
  Map<String, dynamic> _clientData = {};
  List<Map<String, dynamic>> _workoutHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClientDetails();
    _fetchWorkoutHistory();
  }

  Future<void> _fetchWorkoutHistory() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.customerWorkoutHistory(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        // Debug: Print workout history response to check field names
        for (final entry in data) {
          write('WORKOUT_HISTORY_ENTRY: $entry');
        }
        if (!mounted) return;
        setState(() {
          _workoutHistory =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      // Silently handle — calendar will show all days as missed if no data
    }
  }

  Future<void> _fetchClientDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        if (!mounted) return;
        setState(() {
          _clientData = Map<String, dynamic>.from(response.data as Map);
          write('CLIENT_DATA_KEYS: ${_clientData.keys.toList()}');
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Dialogs.showSnack(msg: 'Failed to load client details');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Error loading client details: ${e.toString()}');
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool small = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: small ? 14 : 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.text12Px.poppins.w500.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.text13Px.poppins.w600.dark,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _calculateAge(String? dobStr) {
    if (dobStr == null || dobStr.isEmpty) return 0;
    try {
      final dob = DateFormat('yyyy-MM-dd').parse(dobStr);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age > 0 ? age : 0;
    } catch (_) {
      return 0;
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return isoString.split('T').first;
    }
  }

  Widget _buildOtherDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.text14Px.poppins.w500.dark),
        Text(value, style: AppStyles.text14Px.poppins.w500.dark),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _clientData['profile'] as Map<dynamic, dynamic>? ?? {};
    final membership =
        _clientData['membership'] as Map<dynamic, dynamic>? ?? {};

    final String name = profile['name'] as String? ?? 'N/A';
    final String phone = profile['mobile'] as String? ?? 'N/A';
    final String email = profile['email'] as String? ?? 'N/A';
    final String imageUrl =
        (profile['profile_picture'] ?? profile['image_url'] ?? '').toString();
    final bool isActive = profile['is_active'] as bool? ?? false;
    final String gender = (profile['gender'] as String? ?? 'N/A').toLowerCase();
    final String bloodGroup = profile['blood_group'] as String? ?? 'N/A';

    // Body Metrix
    final String bmi = (profile['bmi'] ?? 'XX').toString();
    final String bmr = (profile['bmr'] ?? 'XX').toString();

    // Other Details
    final int age = _calculateAge(profile['date_of_birth'] as String?);
    final String height = (profile['height'] ?? 'N/A').toString();
    final String weight = (profile['weight'] ?? 'N/A').toString();
    final String healthIssues = (profile['health_issues'] ?? 'NO').toString();

    // Payment Status fallback check
    final String paymentStatus =
        membership['payment_status'] as String? ??
        membership['status'] as String? ??
        membership['payment'] as String? ??
        'N/A';

    // Membership Progress
    double progress = 0.0;
    int remainingDays = 0;
    bool hasProgress = false;
    final startDateStr = membership['start_date'] as String?;
    final endDateStr = membership['end_date'] as String?;
    if (startDateStr != null && endDateStr != null) {
      try {
        final start = DateFormat('yyyy-MM-dd').parse(startDateStr);
        final end = DateFormat('yyyy-MM-dd').parse(endDateStr);
        final now = DateTime.now();
        final totalDays = end.difference(start).inDays;
        final elapsedDays = now.difference(start).inDays;
        if (totalDays > 0) {
          progress = (elapsedDays / totalDays).clamp(0.0, 1.0);
          remainingDays = end.difference(now).inDays;
          hasProgress = true;
        }
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: const PopButton().center,
        title: Text('Details', style: AppStyles.text16Px.poppins.w600.dark),
        centerTitle: true,
        actions: [
          if (profile['whatsapp_link']?.toString().isNotEmpty ?? false)
            IconButton(
              icon: SvgPicture.asset(
                'assets/images/svg/icons/whatsapp.svg',
                height: 24,
                width: 24,
              ),
              onPressed: () {
                launchUrl(
                  Uri.parse(profile['whatsapp_link']!.toString()),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textDark,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.iconBackground,
                      image:
                          imageUrl.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        imageUrl.isEmpty
                            ? const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 32,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: AppStyles.text16Px.poppins.w600.dark,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F1F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: AppStyles.text12Px.poppins.w400.textGrey,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: AppStyles.text12Px.poppins.w400.textGrey,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 3,
                                      backgroundColor: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Active',
                                      style: AppStyles.text12Px.poppins.w500
                                          .copyWith(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                gender.isNotEmpty
                                    ? '${gender[0].toUpperCase()}${gender.substring(1)}'
                                    : 'N/A',
                                style: AppStyles.text12Px.poppins.w500.dark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                bloodGroup,
                                style: AppStyles.text12Px.poppins.w500.dark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tags / Goals
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                'Weight Loss',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Fitness Analytics
            Text(
              'Fitness Analytics',
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
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                        'Body Metrix',
                        style: AppStyles.text14Px.poppins.w600.dark,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F1F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'BMI : $bmi',
                    style: AppStyles.text13Px.poppins.w500.dark,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BMR : $bmr',
                    style: AppStyles.text13Px.poppins.w500.dark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Membership
            Text('Membership', style: AppStyles.text16Px.poppins.w600.dark),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Green Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              membership['plan_name'] as String? ?? 'No Plan',
                              style: AppStyles.text16Px.poppins.w600.dark,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    membership.isNotEmpty
                                        ? 'Active'
                                        : 'Inactive',
                                    style: AppStyles.text12Px.poppins.w500
                                        .copyWith(color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bottom Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Membership Progress',
                              style: AppStyles.text14Px.poppins.w600.dark,
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasProgress
                              ? (remainingDays > 0
                                  ? '🕒 $remainingDays days remaining'
                                  : '✅ Membership completed')
                              : '🕒 N/A',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color:
                                remainingDays > 0
                                    ? Colors.orange.shade700
                                    : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.calendar_today,
                                label: 'Start Date',
                                value: _formatDate(
                                  membership['start_date'] as String?,
                                ),
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.event_busy,
                                label: 'End Date',
                                value: _formatDate(
                                  membership['end_date'] as String?,
                                ),
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.currency_rupee,
                                label: 'Amount',
                                value:
                                    membership['amount'] != null
                                        ? '${membership['amount']}'
                                        : 'N/A',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.payment,
                                label: 'Payment',
                                value: paymentStatus.toUpperCase(),
                                color: _getPaymentStatusColor(paymentStatus),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Workout Journey Calendar
            if (membership.isNotEmpty) ...[
              TrainerClientWorkoutHistoryCalendar(
                customerId: widget.customerId,
                startDate: membership['start_date'] != null
                    ? DateTime.tryParse(membership['start_date'].toString())
                    : null,
                workoutHistory: _workoutHistory,
              ),
              const SizedBox(height: 24),
            ],

            // Other Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Other Details',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildOtherDetailRow('Age', age.toString()),
                  const SizedBox(height: 16),
                  _buildOtherDetailRow(
                    'Height',
                    height == 'N/A' ? height : '$height CM',
                  ),
                  const SizedBox(height: 16),
                  _buildOtherDetailRow(
                    'Weight',
                    weight == 'N/A' ? weight : '$weight KG',
                  ),
                  const SizedBox(height: 16),
                  _buildOtherDetailRow('Health Issues', healthIssues),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
