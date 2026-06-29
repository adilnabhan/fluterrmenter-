import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:intl/intl.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  const TrainerClientDetailScreen({required this.customerId, super.key});

  final int customerId;

  @override
  State<TrainerClientDetailScreen> createState() => _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen> {
  Map<String, dynamic> _clientData = {};
  List<Map<String, dynamic>> _workoutHistory = [];
  bool _isLoading = true;
  bool _isLoadingHistory = false;
  bool _isSavingNotes = false;
  int _selectedTab = 0; // 0: General Stats, 1: Workout History
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _fetchClientDetails();
    _fetchWorkoutHistory();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _clientData = Map<String, dynamic>.from(response.data as Map);
          final profile = _clientData['profile'] as Map<dynamic, dynamic>? ?? {};
          _notesController.text = profile['trainer_notes'] as String? ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load client details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading client details: ${e.toString()}');
    }
  }

  Future<void> _fetchWorkoutHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.customerWorkoutHistory(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        setState(() {
          _workoutHistory = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoadingHistory = false;
        });
      } else {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      Dialogs.showSnack(msg: 'Error loading workout history: ${e.toString()}');
    }
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isSavingNotes = true;
    });

    try {
      final response = await DioClient().dio.put<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        data: {
          'trainer_notes': _notesController.text.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        Dialogs.showSnack(msg: 'Remarks saved successfully');
      } else {
        Dialogs.showSnack(msg: 'Failed to save remarks');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error saving remarks: ${e.toString()}');
    } finally {
      setState(() {
        _isSavingNotes = false;
      });
    }
  }

  Future<void> _toggleDetailAssignment(bool isCurrentlyAssigned) async {
    final trainerId = context.read<AppCubit>().state.currentUser?.mentor?.id;
    if (trainerId == null) {
      Dialogs.showSnack(msg: 'Trainer profile not found.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.patch<dynamic>(
        ApiUris.updateMember(widget.customerId),
        data: {
          'trainer_id': isCurrentlyAssigned ? null : trainerId,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        Dialogs.showSnack(
          msg: isCurrentlyAssigned
              ? 'Client unassigned successfully'
              : 'Client assigned to you successfully',
        );
        _fetchClientDetails();
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to update assignment');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error updating assignment: ${e.toString()}');
    }
  }

  String _getPrValue(List<dynamic> prs, String workoutName, String defaultVal) {
    for (var item in prs) {
      final map = Map<String, dynamic>.from(item as Map);
      final name = (map['workout_name'] as String? ?? '').toLowerCase();
      if (name.contains(workoutName.toLowerCase())) {
        return '${map['value']} ${map['unit']}';
      }
    }
    return defaultVal;
  }

  int _calculateAge(String? dobStr) {
    if (dobStr == null || dobStr.isEmpty) return 25; // Default age if not set
    final dob = DateTime.tryParse(dobStr);
    if (dob == null) return 25;
    int age = DateTime.now().year - dob.year;
    if (DateTime.now().month < dob.month || (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
      age--;
    }
    return age;
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  Widget _buildSegmentTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF0F0F0),
          border: isSelected
              ? const Border(bottom: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralStatsTab(Map<String, dynamic> profile, Map<String, dynamic> membership, List<dynamic> assignedPlans, List<dynamic> prRecords, bool isAssignedToMe, String? trainerName) {
    final String gender = profile['gender'] as String? ?? 'N/A';
    final String height = (profile['height'] ?? 'N/A').toString();
    final String weight = (profile['weight'] ?? 'N/A').toString();
    final String bmi = (profile['bmi'] ?? 'N/A').toString();
    final String fitnessLevel = profile['fitness_level'] as String? ?? 'N/A';
    final hasActiveMembership = membership.isNotEmpty;

    // Resolve PRs
    final bp = _getPrValue(prRecords, 'Bench Press', '15 kg');
    final dl = _getPrValue(prRecords, 'Deadlift', '15 kg');
    final sq = _getPrValue(prRecords, 'Squat', '15 kg');
    final pu = _getPrValue(prRecords, 'Push-Ups', '15 reps');
    final pl = _getPrValue(prRecords, 'Pull-Ups', '15 reps');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PR Records Panel
        Text(
          'PR Records',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildPrRow(Icons.fitness_center, 'Bench Press', bp),
              const Divider(height: 20, thickness: 0.5),
              _buildPrRow(Icons.fitness_center, 'Deadlift', dl),
              const Divider(height: 20, thickness: 0.5),
              _buildPrRow(Icons.fitness_center, 'Squat', sq),
              const Divider(height: 20, thickness: 0.5),
              _buildPrRow(Icons.fitness_center, 'Push-Ups', pu),
              const Divider(height: 20, thickness: 0.5),
              _buildPrRow(Icons.fitness_center, 'Pull-Ups', pl),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Strength Stats Panel
        Text(
          'Strength Stats',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildStatRow('Max Bench Press', bp.contains('kg') ? bp : '225 lbs'),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('Max Deadlift', dl.contains('kg') ? dl : '315 lbs'),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('Max Squat', sq.contains('kg') ? sq : '275 lbs'),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('Max Pull Ups', pl.contains('reps') ? pl : '15 reps'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Health & Body Stats
        Text(
          'Health & Body Stats',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildStatRow('Gender', gender),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('Height', '$height cm'),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('Weight', '$weight kg'),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('BMI', bmi),
              const Divider(height: 20, thickness: 0.5),
              _buildStatRow('Fitness Level', fitnessLevel),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Gym Membership Info
        Text(
          'Gym Membership',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: hasActiveMembership
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF43A047)),
                        const SizedBox(width: 8),
                        Text(
                          membership['plan_name'] as String? ?? 'Active Plan',
                          style: AppStyles.text14Px.poppins.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gym: ${membership['organization'] ?? "N/A"}',
                      style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                    ),
                    Text(
                      'Valid: ${_formatDateString(membership['start_date'] as String?)} to ${_formatDateString(membership['end_date'] as String?)}',
                      style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'No active membership plan',
                      style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 20),

        // Assigned workout plans
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assigned Workout Plans',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            if (isAssignedToMe)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const WorkoutGroupsScreen(),
                    ),
                  ).then((_) => _fetchClientDetails());
                },
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF2E7D32)),
                label: Text(
                  'Assign Plan',
                  style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF2E7D32)),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xffE8F5E9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: !isAssignedToMe
              ? Text(
                  'Workout plans are only visible and manageable when this customer is assigned to you.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                )
              : assignedPlans.isEmpty
                  ? Center(
                      child: Text(
                        'No workout plans assigned.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : Column(
                      children: assignedPlans.map((plan) {
                        final planName = plan['plan_name'] ?? 'Plan';
                        final statusStr = plan['status'] ?? 'active';
                        final days = plan['total_days'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF7F7F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    planName as String,
                                    style: AppStyles.text13Px.poppins.w600,
                                  ),
                                  Text(
                                    '$days Days duration',
                                    style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusStr == 'active' ? const Color(0xffE8F5E9) : const Color(0xffE0E0E0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (statusStr as String).toUpperCase(),
                                  style: AppStyles.text10Px.poppins.w600.copyWith(
                                    color: statusStr == 'active' ? const Color(0xFF43A047) : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
        ),
        const SizedBox(height: 20),

        // Trainer Notes & Remarks (Editable)
        Text(
          'Trainer Remarks & Progress Notes',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: isAssignedToMe
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add progress logs, dietary notes, or remarks...',
                        hintStyle: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        fillColor: const Color(0xffF7F7F7),
                        filled: true,
                      ),
                      style: AppStyles.text13Px.poppins.w400,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.maxFinite,
                      child: Button.filled(
                        ontap: _isSavingNotes ? () {} : _saveNotes,
                        title: 'Save Notes',
                        buttonColor: AppColors.primary,
                        isLoading: _isSavingNotes,
                        style: AppStyles.text14Px.poppins.w600.light,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Assign this client to yourself to write progress notes and remarks.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                ),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }
    if (_workoutHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No workout history logged.',
            style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
          ),
        ),
      );
    }

    // Group history by month: e.g. "October 2025"
    final Map<String, List<Map<String, dynamic>>> groupedByMonth = {};
    for (var entry in _workoutHistory) {
      final dateStr = entry['date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final monthName = DateFormat('MMMM yyyy').format(date);
      groupedByMonth.putIfAbsent(monthName, () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'History Logs',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.primary),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupedByMonth.keys.length,
          itemBuilder: (context, index) {
            final month = groupedByMonth.keys.elementAt(index);
            final entries = groupedByMonth[month]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    month,
                    style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
                  ),
                ),
                ...entries.map((entry) {
                  final dateRaw = entry['date'] as String;
                  final date = DateTime.parse(dateRaw);
                  final formattedDate = DateFormat('MMMM d, yyyy').format(date);
                  final logs = entry['logs'] as List<dynamic>? ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 1,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          formattedDate,
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                        subtitle: Text(
                          '${logs.length} exercises logged',
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: logs.map((log) {
                                final logMap = Map<String, dynamic>.from(log as Map);
                                final workoutName = logMap['workout_name'] ?? 'Exercise';
                                final setLogs = logMap['set_logs'] as List<dynamic>? ?? [];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF9F9F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workoutName as String,
                                        style: AppStyles.text13Px.poppins.w600.dark,
                                      ),
                                      const SizedBox(height: 6),
                                      ...setLogs.map((set) {
                                        final setMap = Map<String, dynamic>.from(set as Map);
                                        final reps = setMap['reps'] ?? 0;
                                        final weight = setMap['weight_kg'] ?? 0.0;
                                        return Text(
                                          'Set ${setMap['set_number']}: $weight kg x $reps reps',
                                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrRow(IconData icon, String name, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: AppStyles.text13Px.poppins.w500.dark,
          ),
        ),
        Text(
          value,
          style: AppStyles.text13Px.poppins.w600.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF7F7F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _clientData['profile'] as Map<String, dynamic>? ?? {};
    final membership = _clientData['membership'] as Map<String, dynamic>? ?? {};
    final assignedPlans = _clientData['assigned_plans'] as List<dynamic>? ?? [];
    final prRecords = _clientData['pr_records'] as List<dynamic>? ?? [];

    final String name = profile['name'] as String? ?? 'N/A';
    final String mobile = profile['mobile'] as String? ?? 'N/A';
    final imgUrl = profile['profile_picture'];
    final bool isAssignedToMe = profile['is_assigned_to_me'] as bool? ?? false;
    final trainerName = profile['trainer_name'] as String?;
    final int age = _calculateAge(profile['date_of_birth'] as String?);

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text(
          'Client Details',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
      ),
      body: Column(
        children: [
          // Main profile card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
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
                                const Icon(Icons.person, size: 30, color: AppColors.primary),
                          )
                        : const Icon(Icons.person, size: 30, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: $age  |  Phone: $mobile',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 6),
                      _buildDetailAssignmentRow(isAssignedToMe, trainerName),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Tab Segment bar
          Row(
            children: [
              Expanded(child: _buildSegmentTab('General Stats', 0)),
              Expanded(child: _buildSegmentTab('Workout History', 1)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _selectedTab == 0
                  ? _buildGeneralStatsTab(profile, membership, assignedPlans, prRecords, isAssignedToMe, trainerName)
                  : _buildWorkoutHistoryTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text13Px.poppins.w500.copyWith(color: AppColors.textGrey),
        ),
        Text(
          value,
          style: AppStyles.text13Px.poppins.w600,
        ),
      ],
    );
  }

  Widget _buildDetailAssignmentRow(bool isAssignedToMe, String? trainerName) {
    return Row(
      children: [
        Expanded(
          child: Text(
            isAssignedToMe
                ? 'Assigned to: Me'
                : (trainerName != null && trainerName.isNotEmpty)
                    ? 'Assigned to: $trainerName'
                    : 'Unassigned',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: isAssignedToMe
                  ? const Color(0xFF43A047)
                  : (trainerName != null && trainerName.isNotEmpty)
                      ? AppColors.textGrey
                      : Colors.orange.shade800,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: isAssignedToMe ? const Color(0xffFFEAEA) : const Color(0xffE8F5E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _toggleDetailAssignment(isAssignedToMe),
          child: Text(
            isAssignedToMe ? 'Unassign' : 'Assign to me',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: isAssignedToMe ? AppColors.primary : const Color(0xFF43A047),
            ),
          ),
        ),
      ],
    );
  }
}
