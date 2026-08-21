import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/widgets/trainer_client_workout_history_calendar.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_assigned_workouts_screen.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  const TrainerClientDetailScreen({required this.customerId, super.key});

  final int customerId;

  @override
  State<TrainerClientDetailScreen> createState() =>
      _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen> {
  Map<String, dynamic> _clientData = {};
  Map<String, dynamic>? _bodyMatrixData;
  List<Map<String, dynamic>> _workoutHistory = [];
  List<Map<String, dynamic>> _assignedWorkouts = [];
  bool _isAssignedWorkoutsExpanded = false;
  bool _isLoading = true;

  List<Map<String, dynamic>> get _todayAssignedWorkouts {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    return _assignedWorkouts.where((workout) {
      final String? rawDate =
          workout['start_date']?.toString() ??
          workout['assigned_date']?.toString() ??
          workout['date']?.toString() ??
          workout['created_at']?.toString();

      if (rawDate == null || rawDate.isEmpty) return false;
      try {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) {
          final workoutDateStr = DateFormat('yyyy-MM-dd').format(parsed);
          return workoutDateStr == todayStr;
        }
      } catch (_) {}
      return rawDate.contains(todayStr);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchClientDetails();
    _fetchWorkoutHistory();
    _fetchAssignedWorkouts();
    _fetchBodyMatrix();
  }

  List<Map<String, dynamic>> _parseWorkoutsResponse(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (data is Map) {
      if (data['results'] is List && (data['results'] as List).isNotEmpty) {
        return (data['results'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        final plans = data['assigned_plans'] is List
            ? (data['assigned_plans'] as List)
            : [];
        final sessions = data['assigned_sessions'] is List
            ? (data['assigned_sessions'] as List)
            : [];
        final workouts = data['assigned_workouts'] is List
            ? (data['assigned_workouts'] as List)
            : [];
        final genericPlans =
            data['plans'] is List ? (data['plans'] as List) : [];
        final dataItems =
            data['data'] is List ? (data['data'] as List) : [];

        final combined = [
          ...plans,
          ...sessions,
          ...workouts,
          ...genericPlans,
          ...dataItems,
        ];
        if (combined.isNotEmpty) {
          return combined
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    }
    return [];
  }

  Future<void> _fetchAssignedWorkouts() async {
    List<Map<String, dynamic>> workoutsList = [];

    // Primary endpoint with server-side date filter for today
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final url = '${ApiUris.trainerClientAssignedWorkouts(widget.customerId)}?date=$todayStr';
      debugPrint('📋 Fetching assigned workouts: $url');
      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      debugPrint('📋 Response status: ${response.statusCode}');
      debugPrint('📋 Response data type: ${response.data.runtimeType}');
      if (response.statusCode == 200) {
        workoutsList = _parseWorkoutsResponse(response.data);
        debugPrint('📋 Parsed workouts count: ${workoutsList.length}');
      }
    } catch (e) {
      debugPrint('❌ Primary assigned workouts API failed: $e');
      // Fallback only if primary fails
      try {
        final response = await DioClient().dio.get<dynamic>(
          ApiUris.customerAssignedWorkouts(widget.customerId),
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          workoutsList = _parseWorkoutsResponse(response.data);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _assignedWorkouts = workoutsList;
      });
    }
  }

  Future<void> _deleteAssignedWorkout(Map<String, dynamic> workout) async {
    final assignmentId = (workout['customer_workout_plan_id'] is int)
        ? workout['customer_workout_plan_id'] as int
        : (workout['customer_workout_plan'] is int)
            ? workout['customer_workout_plan'] as int
            : (workout['customer_workout_plan'] is Map &&
                    workout['customer_workout_plan']['id'] is int)
                ? workout['customer_workout_plan']['id'] as int
                : (workout['assignment_id'] is int)
                    ? workout['assignment_id'] as int
                    : (workout['id'] is int)
                        ? workout['id'] as int
                        : 0;

    if (assignmentId <= 0) {
      Dialogs.showSnack(msg: 'Unable to identify assigned workout ID.');
      return;
    }

    final title = (workout['plan_name'] ??
            workout['title'] ??
            workout['name'] ??
            workout['workout_plan_name'] ??
            'Workout Plan')
        .toString();

    final clientName = (_clientData['name'] ??
            _clientData['first_name'] ??
            _clientData['user']?['name'] ??
            'Client')
        .toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Assigned Workout'),
        content: Text(
          'Are you sure you want to delete "$title" for $clientName?\n\nThis will remove the assignment and uncompleted future workout sessions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffE53E3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.trainerDeleteAssignedWorkout(assignmentId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        String successMsg = 'Assigned workout deleted successfully.';
        if (response.data is Map && response.data['message'] != null) {
          successMsg = response.data['message'].toString();
        }
        Dialogs.showSnack(msg: successMsg);
        _fetchAssignedWorkouts();
      } else {
        Dialogs.showSnack(msg: 'Failed to delete assigned workout.');
      }
    } on DioException catch (e) {
      String errorMsg = 'Error deleting assigned workout.';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMsg = data['detail']?.toString() ??
            data['message']?.toString() ??
            errorMsg;
      }
      Dialogs.showSnack(msg: errorMsg);
    } catch (e) {
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
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

  Future<void> _fetchBodyMatrix() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.customerBodyMatrix(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['status'] == 'success' && resMap['data'] is Map) {
          if (!mounted) return;
          setState(() {
            _bodyMatrixData = Map<String, dynamic>.from(resMap['data'] as Map);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching body matrix: $e');
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
            style: AppStyles.text13Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
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
        Text(
          label,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    String title,
    String value, {
    String? label,
    String? extra,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                if (extra != null && extra.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    extra,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (label != null && label.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                label,
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.text13Px.poppins.w500.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppStyles.text13Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showBodyMatrixSheet(BuildContext context) {
    final metrics = _bodyMatrixData?['metrics'] as Map<dynamic, dynamic>? ?? {};
    final inputs = _bodyMatrixData?['inputs'] as Map<dynamic, dynamic>? ?? {};

    final bmi = metrics['bmi'] as Map<dynamic, dynamic>? ?? {};
    final bmr = metrics['bmr'] as Map<dynamic, dynamic>? ?? {};
    final bodyFat = metrics['body_fat'] as Map<dynamic, dynamic>? ?? {};
    final whr = metrics['whr'] as Map<dynamic, dynamic>? ?? {};
    final whtr = metrics['whtr'] as Map<dynamic, dynamic>? ?? {};

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Body Metrix Analytics',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.icon),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calculated Metrics',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricTile(
                        'BMI (Body Mass Index)',
                        '${bmi['value'] ?? 'N/A'}',
                        label:
                            bmi['label']?.toString() ??
                            bmi['category']?.toString(),
                      ),
                      _buildMetricTile(
                        'BMR (Basal Metabolic Rate)',
                        '${bmr['value'] ?? 'N/A'} ${bmr['unit'] ?? ''}'.trim(),
                      ),
                      _buildMetricTile(
                        'Body Fat Percentage',
                        bodyFat['percentage'] != null
                            ? '${bodyFat['percentage']}%'
                            : 'N/A',
                        label: bodyFat['category']?.toString(),
                        extra:
                            bodyFat['navy_method_percentage'] != null
                                ? 'Navy Method: ${bodyFat['navy_method_percentage']}%'
                                : null,
                      ),
                      _buildMetricTile(
                        'WHR (Waist-to-Hip Ratio)',
                        '${whr['ratio'] ?? 'N/A'}',
                        label: whr['category']?.toString(),
                      ),
                      _buildMetricTile(
                        'WHtR (Waist-to-Height Ratio)',
                        '${whtr['ratio'] ?? 'N/A'}',
                        label: whtr['category']?.toString(),
                      ),
                      if (inputs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Body Measurements',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.fieldFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Column(
                            children: [
                              if (inputs['height_cm'] != null)
                                _buildMeasurementRow(
                                  'Height',
                                  '${inputs['height_cm']} cm',
                                ),
                              if (inputs['weight_kg'] != null)
                                _buildMeasurementRow(
                                  'Weight',
                                  '${inputs['weight_kg']} kg',
                                ),
                              if (inputs['neck_cm'] != null)
                                _buildMeasurementRow(
                                  'Neck',
                                  '${inputs['neck_cm']} cm',
                                ),
                              if (inputs['waist_cm'] != null)
                                _buildMeasurementRow(
                                  'Waist',
                                  '${inputs['waist_cm']} cm',
                                ),
                              if (inputs['hip_cm'] != null)
                                _buildMeasurementRow(
                                  'Hip',
                                  '${inputs['hip_cm']} cm',
                                ),
                              if (inputs['gender'] != null)
                                _buildMeasurementRow(
                                  'Gender',
                                  '${inputs['gender']}'.toUpperCase(),
                                ),
                              if (inputs['age'] != null)
                                _buildMeasurementRow(
                                  'Age',
                                  '${inputs['age']} yrs',
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const Center(child: CircularProgressIndicator()),
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
    final metricsMap =
        _bodyMatrixData?['metrics'] as Map<dynamic, dynamic>? ?? {};
    final bmiObj = metricsMap['bmi'] as Map<dynamic, dynamic>? ?? {};
    final bmrObj = metricsMap['bmr'] as Map<dynamic, dynamic>? ?? {};
    final bodyFatObj = metricsMap['body_fat'] as Map<dynamic, dynamic>? ?? {};
    final whrObj = metricsMap['whr'] as Map<dynamic, dynamic>? ?? {};

    final String bmi =
        bmiObj['value']?.toString() ?? (profile['bmi'] ?? 'XX').toString();
    final String bmiLabel =
        bmiObj['label']?.toString() ?? bmiObj['category']?.toString() ?? '';
    final String bmr =
        bmrObj['value']?.toString() ?? (profile['bmr'] ?? 'XX').toString();
    final String bmrUnit = bmrObj['unit']?.toString() ?? '';
    final String? bodyFatPct = bodyFatObj['percentage']?.toString();
    final String? bodyFatCategory = bodyFatObj['category']?.toString();
    final String? whrRatio = whrObj['ratio']?.toString();
    final String? whrCategory = whrObj['category']?.toString();

    // Other Details
    final int age = _calculateAge(profile['date_of_birth'] as String?);
    final String height = (profile['height'] ?? 'N/A').toString();
    final String weight = (profile['weight'] ?? 'N/A').toString();
    final String healthIssues = (profile['health_issues'] ?? 'NO').toString();

    final inputsMap =
        _bodyMatrixData?['inputs'] as Map<dynamic, dynamic>? ?? {};
    final String displayHeight =
        inputsMap['height_cm'] != null
            ? '${inputsMap['height_cm']} CM'
            : (height == 'N/A'
                ? 'N/A'
                : (height.toLowerCase().contains('cm')
                    ? height.toUpperCase()
                    : '$height CM'));
    final String displayWeight =
        inputsMap['weight_kg'] != null
            ? '${inputsMap['weight_kg']} KG'
            : (weight == 'N/A'
                ? 'N/A'
                : (weight.toLowerCase().contains('kg')
                    ? weight.toUpperCase()
                    : '$weight KG'));

    // Target Goals Parsing
    final dynamic rawGoals =
        profile['target_goal'] ??
        profile['target_goals'] ??
        profile['goal'] ??
        _clientData['target_goal'] ??
        _clientData['target_goals'];
    List<String> targetGoals = [];
    if (rawGoals is List) {
      targetGoals =
          rawGoals
              .map((e) => e.toString().replaceAll('_', ' ').trim())
              .where((s) => s.isNotEmpty)
              .toList();
    } else if (rawGoals is String && rawGoals.isNotEmpty) {
      targetGoals =
          rawGoals
              .split(',')
              .map((e) => e.replaceAll('_', ' ').trim())
              .where((s) => s.isNotEmpty)
              .toList();
    }

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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: const PopButton().center,
        iconTheme: IconThemeData(color: context.colors.icon),
        title: Text(
          'Details',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
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
            icon: Icon(Icons.settings_outlined, color: context.colors.icon),
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
                color: context.colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      context.isDarkMode ? 0.2 : 0.04,
                    ),
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
                      color: context.colors.fieldFill,
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
                        Text(
                          name,
                          style: AppStyles.text16Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: context.colors.textSecondary,
                          ),
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
                                color: context.colors.fieldFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                gender.isNotEmpty
                                    ? '${gender[0].toUpperCase()}${gender.substring(1)}'
                                    : 'N/A',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.fieldFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                bloodGroup,
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: context.colors.textPrimary,
                                ),
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
            if (targetGoals.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    targetGoals.map((goal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          goal,
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 12),
            ],

            // Health Matrix Section Header
            Text(
              'Health Matrix',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showBodyMatrixSheet(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        context.isDarkMode ? 0.2 : 0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Split View: BMI & Body Fat with Center Divider and Heart Icon
                    Stack(
                      children: [
                        Row(
                          children: [
                            // BMI Column
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'BMI',
                                    style: AppStyles.text12Px.poppins.w600
                                        .copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bmi,
                                    style: AppStyles.text22Px.poppins.w700
                                        .copyWith(
                                          color: context.colors.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        bmiLabel.isNotEmpty
                                            ? bmiLabel
                                            : 'Normal',
                                        style: AppStyles.text12Px.poppins.w500
                                            .copyWith(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Body Fat Column
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Body Fat',
                                    style: AppStyles.text12Px.poppins.w600
                                        .copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bodyFatPct ?? '16.8',
                                    style: AppStyles.text22Px.poppins.w700
                                        .copyWith(
                                          color: context.colors.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        bodyFatCategory != null &&
                                                bodyFatCategory.isNotEmpty
                                            ? bodyFatCategory
                                            : 'Fitness',
                                        style: AppStyles.text12Px.poppins.w500
                                            .copyWith(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Center Vertical Line with Heart Badge
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 32,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 1,
                                    height: 55,
                                    color: context.colors.border,
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: context.colors.card,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.colors.border,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Top Right Chevron Icon
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: context.colors.fieldFill,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: context.colors.icon,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Embedded Height & Weight Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Column(
                        children: [
                          // Height Row
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.swap_vert,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Height',
                                  style: AppStyles.text14Px.poppins.w500
                                      .copyWith(
                                        color: context.colors.textPrimary,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  displayHeight,
                                  style: AppStyles.text14Px.poppins.w600
                                      .copyWith(
                                        color: context.colors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: context.colors.border.withOpacity(0.6),
                            height: 1,
                          ),
                          // Weight Row
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monitor_weight_outlined,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Weight',
                                  style: AppStyles.text14Px.poppins.w500
                                      .copyWith(
                                        color: context.colors.textPrimary,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  displayWeight,
                                  style: AppStyles.text14Px.poppins.w600
                                      .copyWith(
                                        color: context.colors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Membership
            Builder(
              builder: (context) {
                final String? memStatusStr =
                    membership['status']?.toString().toLowerCase();
                final bool isExpired =
                    memStatusStr == 'expired' ||
                    (hasProgress && remainingDays <= 0) ||
                    progress >= 1.0;
                final bool isExpiringSoon =
                    !isExpired && hasProgress && remainingDays <= 10;

                final Color topBannerBg =
                    membership.isEmpty
                        ? (context.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200)
                        : isExpired
                        ? (context.isDarkMode
                            ? Colors.red.shade900.withValues(alpha: 0.3)
                            : const Color(0xffFFEAEA))
                        : isExpiringSoon
                        ? (context.isDarkMode
                            ? Colors.orange.shade900.withValues(alpha: 0.3)
                            : Colors.orange.shade100)
                        : (context.isDarkMode
                            ? Colors.green.shade900.withValues(alpha: 0.3)
                            : Colors.green.shade100);

                final Color iconBg =
                    membership.isEmpty
                        ? Colors.grey.shade500
                        : isExpired
                        ? Colors.red.shade500
                        : isExpiringSoon
                        ? Colors.orange.shade700
                        : Colors.green.shade500;

                final String badgeText =
                    membership.isEmpty
                        ? 'No Membership'
                        : isExpired
                        ? 'Expired'
                        : isExpiringSoon
                        ? 'Expiring Soon'
                        : 'Active';

                final Color badgeColor =
                    membership.isEmpty
                        ? Colors.grey
                        : isExpired
                        ? Colors.red.shade600
                        : isExpiringSoon
                        ? Colors.orange.shade800
                        : Colors.green.shade600;

                final Color accentColor =
                    isExpired
                        ? Colors.red.shade600
                        : isExpiringSoon
                        ? Colors.orange.shade700
                        : Colors.green;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.04,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: topBannerBg,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconBg,
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
                                      membership['plan_name'] as String? ??
                                          'No Plan',
                                      style: AppStyles.text16Px.poppins.w600
                                          .copyWith(
                                            color: context.colors.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.card,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 3,
                                            backgroundColor: badgeColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            badgeText,
                                            style: AppStyles
                                                .text12Px
                                                .poppins
                                                .w500
                                                .copyWith(color: badgeColor),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Membership Progress',
                                      style: AppStyles.text14Px.poppins.w600
                                          .copyWith(
                                            color: context.colors.textPrimary,
                                          ),
                                    ),
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: AppStyles.text14Px.poppins.w600
                                          .copyWith(color: accentColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: context.colors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accentColor,
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
                                  style: AppStyles.text12Px.poppins.w500
                                      .copyWith(
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
                                        color: _getPaymentStatusColor(
                                          paymentStatus,
                                        ),
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
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Assigned Workouts
            if (_assignedWorkouts.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned Workouts',
                    style: AppStyles.text16Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      final clientName =
                          (_clientData['name'] ??
                                  _clientData['first_name'] ??
                                  _clientData['user']?['name'] ??
                                  'Client')
                              .toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder:
                              (context) => TrainerAssignedWorkoutsScreen(
                                customerId: widget.customerId,
                                customerName: clientName,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All (${_assignedWorkouts.length})',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_todayAssignedWorkouts.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 32,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No workout assigned for today',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ..._todayAssignedWorkouts.map((workout) {
                  final planId =
                      workout['plan_id'] as int? ??
                      workout['customer_workout_plan_id'] as int? ??
                      workout['workout_plan_id'] as int? ??
                      workout['id'] as int? ??
                      0;
                  final title =
                      (workout['plan_name'] ??
                              workout['title'] ??
                              workout['name'] ??
                              workout['workout_plan_name'] ??
                              'Workout Plan')
                          .toString();
                  final rawStatus =
                      (workout['status'] ??
                              workout['assignment_status'] ??
                              'Active')
                          .toString()
                          .toLowerCase();
                  final bool isCompleted =
                      workout['is_completed'] == true ||
                      workout['completed'] == true ||
                      rawStatus == 'completed' ||
                      rawStatus == 'done' ||
                      rawStatus == 'verified';
                  final String? rawDate =
                      workout['start_date']?.toString() ??
                      workout['assigned_date']?.toString() ??
                      workout['date']?.toString() ??
                      workout['created_at']?.toString();
                  final String formattedDate =
                      rawDate != null && rawDate.isNotEmpty
                          ? _formatDate(rawDate)
                          : '';

                  DateTime? workoutDate;
                  if (rawDate != null && rawDate.isNotEmpty) {
                    workoutDate = DateTime.tryParse(rawDate);
                  }

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  final bool isMissed =
                      !isCompleted &&
                      (rawStatus == 'missed' ||
                          (workoutDate != null &&
                              DateTime(
                                workoutDate.year,
                                workoutDate.month,
                                workoutDate.day,
                              ).isBefore(today)));

                  Color statusColor;
                  IconData statusIcon;
                  String statusLabel;

                  if (isCompleted) {
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle_rounded;
                    statusLabel = 'Completed';
                  } else if (isMissed) {
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel_rounded;
                    statusLabel = 'Missed';
                  } else {
                    statusColor = AppColors.primary;
                    statusIcon = Icons.fitness_center;
                    statusLabel = 'Pending';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 24),
                      ),
                      title: Text(
                        title,
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: statusColor,
                            ),
                          ),
                          if (formattedDate.isNotEmpty &&
                              formattedDate != 'N/A') ...[
                            Text(
                              '  •  $formattedDate',
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCompleted)
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                                color: context.colors.icon,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onSelected: (val) {
                                if (val == 'delete') {
                                  _deleteAssignedWorkout(workout);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            color: Color(0xffE53E3E),
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete Assignment',
                                            style: TextStyle(
                                              color: Color(0xffE53E3E),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          Icon(
                            Icons.chevron_right,
                            color: context.colors.icon,
                          ),
                        ],
                      ),
                      onTap:
                          planId > 0
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder:
                                        (context) => WorkoutPlanDetailsScreen(
                                          planId: planId,
                                          planTitle: title,
                                        ),
                                  ),
                                );
                              }
                              : null,
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
            ],

            // Workout Journey Calendar
            if (membership.isNotEmpty) ...[
              TrainerClientWorkoutHistoryCalendar(
                customerId: widget.customerId,
                startDate:
                    membership['start_date'] != null
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
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      context.isDarkMode ? 0.2 : 0.04,
                    ),
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
