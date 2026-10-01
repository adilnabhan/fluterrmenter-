import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/widgets/trainer_client_workout_history_calendar.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_assigned_workouts_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_body_matrix_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_customers_screen.dart';

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
  bool _isLoading = true;

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
        final candidates = [
          data['assigned_workouts'],
          data['assigned_plans'],
          data['data'],
          data['plans'],
          data['assigned_sessions'],
        ];
        List<dynamic>? matchedList;
        for (final c in candidates) {
          if (c is List && c.isNotEmpty) {
            matchedList = c;
            break;
          }
        }
        if (matchedList != null) {
          final seenKeys = <String>{};
          final unique = <Map<String, dynamic>>[];
          for (final raw in matchedList) {
            if (raw is Map) {
              final map = Map<String, dynamic>.from(raw);
              final id = map['id'] ??
                  map['customer_workout_plan_id'] ??
                  map['session_id'];
              final title = (map['plan_name'] ??
                      map['title'] ??
                      map['name'] ??
                      '')
                  .toString()
                  .toLowerCase();
              final date = (map['start_date'] ??
                      map['scheduled_date'] ??
                      map['date'] ??
                      '')
                  .toString();
              final normDate = date.length >= 10 ? date.substring(0, 10) : date;
              final key = title.isNotEmpty && normDate.isNotEmpty
                  ? '${map['customer_id']}_${title}_$normDate'
                  : (title.isNotEmpty
                      ? '${map['customer_id']}_$title'
                      : (id != null ? 'id_$id' : '${map.hashCode}'));
              if (!seenKeys.contains(key)) {
                seenKeys.add(key);
                unique.add(map);
              }
            }
          }
          return unique;
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

  Future<void> _fetchWorkoutHistory() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.customerWorkoutHistory(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['results'] is List) {
            data = map['results'] as List;
          } else if (map['data'] is List) {
            data = map['data'] as List;
          } else if (map['history'] is List) {
            data = map['history'] as List;
          }
        }
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
      final dateOnly = isoString.split('T').first.trim();
      final date = DateTime.tryParse(dateOnly) ?? DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return isoString.split('T').first;
    }
  }

  String _formatInclusiveEndDate(String? startIsoString, String? endIsoString) {
    if (endIsoString == null || endIsoString.isEmpty) return 'N/A';
    try {
      final endDateOnly = endIsoString.split('T').first.trim();
      final end = DateTime.tryParse(endDateOnly) ?? DateTime.parse(endIsoString);
      if (startIsoString != null && startIsoString.isNotEmpty) {
        final startDateOnly = startIsoString.split('T').first.trim();
        final start = DateTime.tryParse(startDateOnly) ?? DateTime.parse(startIsoString);
        if (end.isAfter(start)) {
          final inclusiveEnd = end.subtract(const Duration(days: 1));
          return DateFormat('dd MMM yyyy').format(inclusiveEnd);
        }
      }
      return DateFormat('dd MMM yyyy').format(end);
    } catch (_) {
      return _formatDate(endIsoString);
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

  List<Map<String, dynamic>> _getPrRecords() {
    final List<Map<String, dynamic>> results = [];
    final Set<String> seenExercises = {};

    // 1. Direct PR records from client profile / API
    final rawPrs = _clientData['pr_records'] ??
        _clientData['personal_records'] ??
        _clientData['prs'] ??
        _clientData['profile']?['pr_records'];
    if (rawPrs is List) {
      for (final item in rawPrs) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final name = (map['workout_name'] ??
                  map['exercise_name'] ??
                  map['name'] ??
                  map['exercise'])
              ?.toString()
              .trim();
          if (name != null && name.isNotEmpty) {
            seenExercises.add(name.toLowerCase());
            results.add({
              'exercise_name': name,
              'value':
                  map['value'] ?? map['weight'] ?? map['max_weight'] ?? 'N/A',
              'unit': map['unit'] ?? 'kg',
              'reps': map['reps'],
              'date': map['date'] ?? map['achieved_at'] ?? map['created_at'],
            });
          }
        }
      }
    }

    // 2. Scan workout history for max weight & reps achieved per exercise
    final Map<String, ({double maxWeight, int reps, String date})> exerciseBests = {};
    for (final dayEntry in _workoutHistory) {
      final dateStr = (dayEntry['date'] ?? '').toString();
      final logs = (dayEntry['logs'] ??
              dayEntry['exercises'] ??
              dayEntry['workout_logs']) as List<dynamic>? ??
          [];
      for (final log in logs) {
        if (log is! Map) continue;
        final exName = (log['exercise_name'] ??
                log['workout_name'] ??
                log['name'])
            ?.toString()
            .trim();
        if (exName == null || exName.isEmpty) continue;

        final setLogs = (log['set_logs'] ?? log['sets'] ?? log['logs'])
                as List<dynamic>? ??
            [];
        for (final setItem in setLogs) {
          if (setItem is! Map) continue;
          final dynamic rawWeight =
              setItem['weight_kg'] ?? setItem['weight'] ?? setItem['load'];
          final dynamic rawReps =
              setItem['reps'] ?? setItem['rep_count'] ?? 0;

          final double weight =
              double.tryParse(rawWeight?.toString() ?? '') ?? 0.0;
          final int reps = int.tryParse(rawReps?.toString() ?? '') ?? 0;

          if (weight > 0) {
            final key = exName.toLowerCase();
            final currentBest = exerciseBests[key];
            if (currentBest == null ||
                weight > currentBest.maxWeight ||
                (weight == currentBest.maxWeight && reps > currentBest.reps)) {
              exerciseBests[key] = (maxWeight: weight, reps: reps, date: dateStr);
            }
          }
        }
      }
    }

    // Merge history-derived PRs that aren't already listed
    exerciseBests.forEach((key, best) {
      if (!seenExercises.contains(key)) {
        final titleName = key
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');
        results.add({
          'exercise_name': titleName,
          'value': best.maxWeight % 1 == 0
              ? best.maxWeight.toInt().toString()
              : best.maxWeight.toStringAsFixed(1),
          'unit': 'kg',
          'reps': best.reps > 0 ? best.reps : null,
          'date': best.date,
        });
      }
    });

    return results;
  }

  void _showWorkoutRecordsSheet(BuildContext context) {
    final prList = _getPrRecords();
    final clientName = (_clientData['profile']?['name'] ??
            _clientData['name'] ??
            'Client')
        .toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout Records',
                            style: AppStyles.text16Px.poppins.w600.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Personal bests (PR) for $clientName',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.colors.icon),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: context.colors.border, height: 1),
              Expanded(
                child: prList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: context.colors.fieldFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.fitness_center_outlined,
                                  color: context.colors.icon,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No PR Records Yet',
                                style: AppStyles.text16Px.poppins.w600.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Personal records will automatically appear here as the client logs workout sessions.',
                                textAlign: TextAlign.center,
                                style: AppStyles.text13Px.poppins.w400.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: prList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final item = prList[index];
                          final exerciseName =
                              item['exercise_name'] as String? ?? 'Exercise';
                          final val = item['value']?.toString() ?? 'N/A';
                          final unit = item['unit']?.toString() ?? '';
                          final reps = item['reps'];
                          final dateStr = item['date']?.toString();

                          String subText = '';
                          if (reps != null && reps.toString().isNotEmpty) {
                            subText = '$reps reps';
                          }
                          if (dateStr != null &&
                              dateStr.isNotEmpty &&
                              dateStr != 'null') {
                            final formattedDate = _formatDate(dateStr);
                            if (formattedDate != 'N/A') {
                              subText = subText.isNotEmpty
                                  ? '$subText • $formattedDate'
                                  : formattedDate;
                            }
                          }

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.colors.fieldFill,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.colors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exerciseName,
                                        style: AppStyles.text14Px.poppins.w600
                                            .copyWith(
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      if (subText.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subText,
                                          style: AppStyles.text12Px.poppins.w400
                                              .copyWith(
                                            color:
                                                context.colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        unit.isNotEmpty ? '$val $unit' : val,
                                        style: AppStyles.text13Px.poppins.w600
                                            .copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedWorkoutsCard(BuildContext context) {
    final clientName = (_clientData['profile']?['name'] ??
            _clientData['name'] ??
            _clientData['first_name'] ??
            _clientData['user']?['name'] ??
            'Client')
        .toString();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => TrainerAssignedWorkoutsScreen(
                  customerId: widget.customerId,
                  customerName: clientName,
                ),
              ),
            ).then((_) {
              _fetchAssignedWorkouts();
              _fetchWorkoutHistory();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Left Icon Circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.colors.fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: context.colors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Center Title
                Expanded(
                  child: Text(
                    'Assigned Workouts',
                    style: AppStyles.text15Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),

                if (_assignedWorkouts.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_assignedWorkouts.length}',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],

                // Right Chevron Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colors.fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: context.colors.icon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutRecordsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showWorkoutRecordsSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Left Icon Circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.colors.fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: context.colors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Center Title
                Expanded(
                  child: Text(
                    'Workout Records',
                    style: AppStyles.text15Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),

                // Right Chevron Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colors.fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: context.colors.icon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthMatrixSection({
    required BuildContext context,
    required String bmi,
    required String bmiLabel,
    required String? bodyFatPct,
    required String? bodyFatCategory,
    required String displayHeight,
    required String displayWeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Matrix',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            final profile =
                _clientData['profile'] as Map<dynamic, dynamic>? ?? {};
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => TrainerBodyMatrixScreen(
                  customerId: widget.customerId,
                  clientName:
                      (profile['name'] ?? _clientData['name'] ?? 'Client')
                          .toString(),
                  initialBodyMatrixData: _bodyMatrixData,
                  initialProfile: profile,
                ),
              ),
            );
          },
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
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bmi,
                                style: AppStyles.text22Px.poppins.w700.copyWith(
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
                                    bmiLabel.isNotEmpty ? bmiLabel : 'Normal',
                                    style: AppStyles.text12Px.poppins.w500.copyWith(
                                      color: context.colors.textSecondary,
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
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bodyFatPct ?? '16.8',
                                style: AppStyles.text22Px.poppins.w700.copyWith(
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
                                    bodyFatCategory != null && bodyFatCategory.isNotEmpty
                                        ? bodyFatCategory
                                        : 'Fitness',
                                    style: AppStyles.text12Px.poppins.w500.copyWith(
                                      color: context.colors.textSecondary,
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
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              displayHeight,
                              style: AppStyles.text14Px.poppins.w600.copyWith(
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
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              displayWeight,
                              style: AppStyles.text14Px.poppins.w600.copyWith(
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
        final start = DateTime.tryParse(startDateStr.split('T').first) ??
            DateFormat('yyyy-MM-dd').parse(startDateStr);
        final end = DateTime.tryParse(endDateStr.split('T').first) ??
            DateFormat('yyyy-MM-dd').parse(endDateStr);
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
                                        value: _formatInclusiveEndDate(
                                          membership['start_date'] as String?,
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

            // Workout Journey Calendar
            if (membership.isNotEmpty) ...[
              TrainerClientWorkoutHistoryCalendar(
                customerId: widget.customerId,
                startDate:
                    membership['start_date'] != null
                        ? DateTime.tryParse(membership['start_date'].toString().split('T').first)
                        : null,
                workoutHistory: _workoutHistory,
              ),
              const SizedBox(height: 24),
            ],

            // Assigned Workouts Card
            _buildAssignedWorkoutsCard(context),
            const SizedBox(height: 24),

            // Workout Records Card (PR Records)
            _buildWorkoutRecordsCard(context),
            const SizedBox(height: 24),

            // Health Matrix Section
            _buildHealthMatrixSection(
              context: context,
              bmi: bmi,
              bmiLabel: bmiLabel,
              bodyFatPct: bodyFatPct,
              bodyFatCategory: bodyFatCategory,
              displayHeight: displayHeight,
              displayWeight: displayWeight,
            ),
            const SizedBox(height: 24),

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
            const SizedBox(height: 140),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActions(context, profile),
    );
  }

  void _handleAssignWorkout(BuildContext context) {
    final clientName = (_clientData['profile']?['name'] ??
            _clientData['name'] ??
            _clientData['first_name'] ??
            _clientData['user']?['name'] ??
            'Client')
        .toString();
    final int? orgId = _clientData['organization_id'] as int? ??
        _clientData['gym_id'] as int? ??
        _clientData['mentor_profile']?['organization']?['id'] as int? ??
        _clientData['organization']?['id'] as int?;
    final bool isAssignedToMe =
        _clientData['is_assigned_to_me'] as bool? ?? true;

    showAssignPlanBottomSheet(
      context: context,
      customerId: widget.customerId,
      customerName: clientName,
      isAssignedToMe: isAssignedToMe,
      organizationId: orgId,
      onSuccess: () {
        _fetchClientDetails();
        _fetchAssignedWorkouts();
        _fetchWorkoutHistory();
      },
    );
  }

  Future<void> _handleSendMessage(Map<dynamic, dynamic> profile) async {
    final waLink = profile['whatsapp_link']?.toString();
    final rawWa = profile['whatsapp']?.toString();
    final mobile =
        profile['mobile']?.toString() ??
        profile['phone']?.toString() ??
        _clientData['mobile']?.toString() ??
        _clientData['phone']?.toString();

    var targetUrl = '';
    if (waLink != null && waLink.isNotEmpty && waLink != 'null') {
      targetUrl = waLink.trim();
      if (!targetUrl.startsWith('http')) {
        final clean = targetUrl.replaceAll(RegExp(r'[^\d+]'), '');
        targetUrl = 'https://wa.me/$clean';
      }
    } else if (rawWa != null && rawWa.isNotEmpty && rawWa != 'null') {
      final clean = rawWa.replaceAll(RegExp(r'[^\d+]'), '');
      targetUrl = 'https://wa.me/$clean';
    } else if (mobile != null &&
        mobile.isNotEmpty &&
        mobile != 'null' &&
        mobile != 'N/A') {
      final clean = mobile.replaceAll(RegExp(r'[^\d+]'), '');
      targetUrl = 'https://wa.me/$clean';
    }

    if (targetUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(targetUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        unawaited(Dialogs.showSnack(msg: 'Could not open WhatsApp: $e'));
      }
    } else {
      unawaited(Dialogs.showSnack(msg: 'No WhatsApp number available for this client'));
    }
  }

  Future<void> _handleCallNow(Map<dynamic, dynamic> profile) async {
    final mobile =
        profile['mobile']?.toString() ??
        profile['phone']?.toString() ??
        _clientData['mobile']?.toString() ??
        _clientData['phone']?.toString();

    if (mobile != null &&
        mobile.isNotEmpty &&
        mobile != 'null' &&
        mobile != 'N/A') {
      final cleanNum = mobile.replaceAll(RegExp(r'[^\d+]'), '');
      try {
        final callUri = Uri.parse('tel:$cleanNum');
        if (await canLaunchUrl(callUri)) {
          await launchUrl(callUri);
        } else {
          await launchUrl(callUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        unawaited(Dialogs.showSnack(msg: 'Could not initiate call: $e'));
      }
    } else {
      unawaited(Dialogs.showSnack(msg: 'No phone number available for this client'));
    }
  }

  Widget _buildFloatingActions(
    BuildContext context,
    Map<dynamic, dynamic> profile,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Assign Workout Button
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _handleAssignWorkout(context),
                  child: Center(
                    child: Text(
                      'Assign Workout',
                      style: AppStyles.text15Px.poppins.w600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Send Message (WhatsApp)
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _handleSendMessage(profile),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/icons/whatsapp.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Send Message',
                              style: AppStyles.text13Px.poppins.w600.copyWith(
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Call Now
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A859),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A859).withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _handleCallNow(profile),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 19,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Call Now',
                              style: AppStyles.text13Px.poppins.w600.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
