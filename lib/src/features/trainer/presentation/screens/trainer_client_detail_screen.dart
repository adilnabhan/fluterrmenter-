import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/chat/presentation/screens/trainer_chat_screen.dart';
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
  Map<String, dynamic>? _nutritionReport;
  bool _isLoading = true;
  bool _isLoadingHistory = false;
  bool _isLoadingNutrition = false;
  bool _isSavingNotes = false;
  int _selectedTab = 0; // 0: General Stats, 1: Diet, 2: Workout Calendar, 3: Workout History
  late final TextEditingController _notesController;

  Map<int, Map<String, dynamic>> _calendarData = {};
  bool _isLoadingCalendar = false;
  DateTime _calendarMonth = DateTime.now();
  int? _selectedCalendarDay;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _fetchClientDetails();
    _fetchWorkoutHistory();
    _fetchCalendarData();
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
          final profile = _clientData['profile'] != null
              ? Map<String, dynamic>.from(_clientData['profile'] as Map)
              : <String, dynamic>{};
          _notesController.text = profile['trainer_notes'] as String? ?? '';
          _isLoading = false;
        });
        _fetchNutritionReport();
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

  Future<void> _fetchNutritionReport() async {
    setState(() {
      _isLoadingNutrition = true;
    });
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomerNutritionReport(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _nutritionReport = Map<String, dynamic>.from(response.data as Map);
          _isLoadingNutrition = false;
        });
      } else {
        setState(() {
          _isLoadingNutrition = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingNutrition = false;
        });
      }
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
    final trainerId = context.read<AppCubit>().state.currentUser?.trainer?.id ??
                      context.read<AppCubit>().state.currentUser?.mentor?.id;
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
              ? Builder(
                  builder: (context) {
                    final status = membership['status'] as String? ?? 'Pending';
                    final bool isActive = status.toLowerCase() == 'active' || status.toLowerCase() == 'trial';
                    final bool isExpired = status.toLowerCase() == 'expired';
                    
                    final iconColor = isActive 
                        ? const Color(0xFF43A047) 
                        : isExpired 
                            ? const Color(0xFFD32F2F) 
                            : Colors.orange.shade800;
                            
                    final iconData = isActive 
                        ? Icons.check_circle_outline 
                        : isExpired 
                            ? Icons.cancel_outlined 
                            : Icons.warning_amber_rounded;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(iconData, color: iconColor),
                            const SizedBox(width: 8),
                            Text(
                              '${membership['plan_name'] as String? ?? 'Plan'} (${status.toUpperCase()})',
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: iconColor),
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
                    );
                  }
                )
              : Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'No membership plan configured',
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

  Future<void> _fetchCalendarData() async {
    setState(() {
      _isLoadingCalendar = true;
    });
    try {
      final monthStr = DateFormat('yyyy-MM').format(_calendarMonth);
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.mentorClientCalendar(widget.customerId)}?month=$monthStr',
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> list = response.data as List<dynamic>;
        final Map<int, Map<String, dynamic>> grouped = {};
        for (final item in list) {
          final itemMap = Map<String, dynamic>.from(item as Map);
          final dateStr = itemMap['date'] as String? ?? '';
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            grouped[date.day] = itemMap;
          }
        }
        setState(() {
          _calendarData = grouped;
          _isLoadingCalendar = false;
        });
      } else {
        setState(() {
          _isLoadingCalendar = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCalendar = false;
      });
      Dialogs.showSnack(msg: 'Error loading calendar: ${e.toString()}');
    }
  }

  Widget _buildWorkoutCalendarTab() {
    if (_isLoadingCalendar) {
      return const Center(child: CircularProgressIndicator());
    }

    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday;

    final monthName = DateFormat('MMMM yyyy').format(_calendarMonth);
    final Map<String, dynamic>? selectedDayData = _calendarData[_selectedCalendarDay];
    final List<dynamic> selectedSessions = selectedDayData != null ? (selectedDayData['sessions'] as List? ?? []) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);
                  _selectedCalendarDay = null;
                });
                _fetchCalendarData();
              },
            ),
            Text(
              monthName,
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);
                  _selectedCalendarDay = null;
                });
                _fetchCalendarData();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            Center(child: Text('M', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('T', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('W', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('T', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('F', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('S', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('S', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: daysInMonth + (startWeekday - 1),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final offset = startWeekday - 1;
            if (index < offset) {
              return const SizedBox.shrink();
            }

            final day = index - offset + 1;
            final isSelected = _selectedCalendarDay == day;
            final dayData = _calendarData[day];
            final sessions = dayData != null ? (dayData['sessions'] as List? ?? []) : [];
            
            final bool hasCompleted = sessions.any((s) => s['completed_at'] != null || s['is_completed'] == true);
            final bool hasVerified = sessions.any((s) => s['is_verified'] == true);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCalendarDay = day;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (hasCompleted ? Colors.green.shade50 : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (hasCompleted ? Colors.green.shade200 : Colors.grey.shade200),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (hasCompleted ? Colors.green.shade800 : AppColors.button),
                      ),
                    ),
                    if (hasCompleted) ...[
                      const SizedBox(height: 2),
                      Icon(
                        hasVerified ? Icons.done_all : Icons.check,
                        color: isSelected
                            ? Colors.white
                            : (hasVerified ? Colors.blue : Colors.green),
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (_selectedCalendarDay != null) ...[
          Text(
            'Workouts for $monthName ${_selectedCalendarDay}',
            style: AppStyles.text16Px.poppins.w600.dark,
          ),
          const SizedBox(height: 10),
          if (selectedSessions.isEmpty)
            Text(
              'No workouts logged for this day.',
              style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
            )
          else
            ...selectedSessions.map((s) {
              final Map<String, dynamic> session = Map<String, dynamic>.from(s as Map);
              final exercises = session['exercises'] as List? ?? [];
              final bool isVerified = session['is_verified'] == true;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    session['title'] as String? ?? 'Workout',
                    style: AppStyles.text16Px.poppins.w600.dark,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Exercises: ${exercises.length}',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                      const SizedBox(width: 8),
                      if (isVerified)
                        Row(
                          children: const [
                            Icon(Icons.verified, color: Colors.blue, size: 14),
                            SizedBox(width: 4),
                            Text('Verified', style: TextStyle(color: Colors.blue, fontSize: 12)),
                          ],
                        )
                      else if (session['completed_at'] != null)
                        Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 14),
                            SizedBox(width: 4),
                            Text('Completed', style: TextStyle(color: Colors.green, fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                  children: exercises.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'No exercises logged.',
                              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                            ),
                          )
                        ]
                      : exercises.map((ex) {
                          final exMap = Map<String, dynamic>.from(ex as Map);
                          final sets = exMap['sets'] as List? ?? [];
                          return ListTile(
                            title: Text(exMap['exercise_name'] as String? ?? 'Exercise'),
                            subtitle: Text(
                              sets.map((setObj) {
                                final setMap = Map<String, dynamic>.from(setObj as Map);
                                return '${setMap['reps'] ?? 0} reps @ ${setMap['weight'] ?? 0} kg';
                              }).join(', '),
                            ),
                          );
                        }).toList(),
                ),
              );
            }).toList(),
        ],
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

    final profile = _clientData['profile'] != null
        ? Map<String, dynamic>.from(_clientData['profile'] as Map)
        : <String, dynamic>{};
    final membership = _clientData['membership'] != null
        ? Map<String, dynamic>.from(_clientData['membership'] as Map)
        : <String, dynamic>{};
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppStyles.text16Px.poppins.w600.dark,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => TrainerChatScreen(
                                    customerId: widget.customerId,
                                    customerName: name,
                                    customerPhoto: imgUrl as String?,
                                    customerPhone: mobile,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Chat',
                                    style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
              Expanded(child: _buildSegmentTab('General', 0)),
              Expanded(child: _buildSegmentTab('Diet', 1)),
              Expanded(child: _buildSegmentTab('Calendar', 2)),
              Expanded(child: _buildSegmentTab('History', 3)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _selectedTab == 0
                  ? _buildGeneralStatsTab(profile, membership, assignedPlans, prRecords, isAssignedToMe, trainerName)
                  : _selectedTab == 1
                      ? _buildDietTab()
                      : _selectedTab == 2
                          ? _buildWorkoutCalendarTab()
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

  Widget _buildDietTab() {
    if (_isLoadingNutrition) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }

    final report = _nutritionReport ?? (_clientData['today_nutrition'] as Map<String, dynamic>?);
    final summary = report?['summary'] as Map<String, dynamic>? ?? {};
    final activeDiet = _nutritionReport?['active_diet_plan'] as Map<String, dynamic>? ?? (_clientData['active_diet_plan'] as Map<String, dynamic>?);
    final loggedMeals = report?['logged_meals'];

    final int targetCal = (summary['target_calories'] ?? activeDiet?['target_calories'] ?? 2000) as int;
    final double consumedCal = double.tryParse((summary['consumed_calories'] ?? 0).toString()) ?? 0.0;
    final double remainingCal = double.tryParse((summary['remaining_calories'] ?? targetCal - consumedCal).toString()) ?? 0.0;
    final double targetProt = double.tryParse((summary['target_protein_g'] ?? activeDiet?['target_protein_g'] ?? 120).toString()) ?? 120.0;
    final double consumedProt = double.tryParse((summary['consumed_protein_g'] ?? 0).toString()) ?? 0.0;
    final double targetCarbs = double.tryParse((summary['target_carbs_g'] ?? activeDiet?['target_carbs_g'] ?? 220).toString()) ?? 220.0;
    final double consumedCarbs = double.tryParse((summary['consumed_carbs_g'] ?? 0).toString()) ?? 0.0;
    final double targetFat = double.tryParse((summary['target_fat_g'] ?? activeDiet?['target_fat_g'] ?? 60).toString()) ?? 60.0;
    final double consumedFat = double.tryParse((summary['consumed_fat_g'] ?? 0).toString()) ?? 0.0;
    final int waterMl = int.tryParse((summary['consumed_water_ml'] ?? 0).toString()) ?? 0;

    final double calProgress = targetCal > 0 ? (consumedCal / targetCal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Nutrition Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today\'s Calorie Adherence', style: AppStyles.text14Px.poppins.w600.dark),
                  Text('${consumedCal.toInt()} / $targetCal kcal', style: AppStyles.text13Px.poppins.w600.copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: calProgress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Remaining: ${remainingCal.toInt()} kcal', style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
                  Text('Water: $waterMl ml', style: AppStyles.text12Px.poppins.w500.copyWith(color: Colors.blue.shade700)),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroColumn('Protein', '${consumedProt.toInt()}g', '${targetProt.toInt()}g', Colors.green),
                  _buildMacroColumn('Carbs', '${consumedCarbs.toInt()}g', '${targetCarbs.toInt()}g', Colors.orange),
                  _buildMacroColumn('Fat', '${consumedFat.toInt()}g', '${targetFat.toInt()}g', Colors.purple),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Active Diet Plan Header & Card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Assigned Diet Plan', style: AppStyles.text16Px.poppins.w600.dark),
            TextButton.icon(
              onPressed: _showAssignDietDialog,
              icon: Icon(activeDiet != null ? Icons.edit_note : Icons.add, size: 16, color: const Color(0xFF2E7D32)),
              label: Text(
                activeDiet != null ? 'Change Plan' : 'Assign Plan',
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
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: activeDiet == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No diet plan assigned yet. Tap "Assign Plan" to prescribe daily targets and meals.',
                      textAlign: TextAlign.center,
                      style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeDiet['title'] as String? ?? 'Diet Plan',
                            style: AppStyles.text15Px.poppins.w600.dark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xffE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${activeDiet['target_calories']} KCAL',
                            style: AppStyles.text10Px.poppins.w600.copyWith(color: const Color(0xFF43A047)),
                          ),
                        ),
                      ],
                    ),
                    if (activeDiet['meals'] is List && (activeDiet['meals'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Prescribed Meals:', style: AppStyles.text13Px.poppins.w600.copyWith(color: AppColors.textGrey)),
                      const SizedBox(height: 6),
                      ...(activeDiet['meals'] as List).map((m) {
                        final meal = Map<String, dynamic>.from(m as Map);
                        final type = (meal['meal_type'] as String? ?? 'meal').toUpperCase();
                        final name = meal['name'] as String? ?? '';
                        final cals = meal['calories'] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$type: ${name.isNotEmpty ? name : 'Recommended items'}',
                                  style: AppStyles.text12Px.poppins.w500.dark,
                                ),
                              ),
                              Text('$cals kcal', style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 20),

        // What the Client Ate Today
        Text('Today\'s Food Intake', style: AppStyles.text16Px.poppins.w600.dark),
        const SizedBox(height: 10),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: _buildLoggedMealsSection(loggedMeals),
        ),
      ],
    );
  }

  Widget _buildMacroColumn(String label, String consumed, String target, Color color) {
    return Column(
      children: [
        Text(label, style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey)),
        const SizedBox(height: 4),
        Text(consumed, style: AppStyles.text14Px.poppins.w600.copyWith(color: color)),
        Text('Goal: $target', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildLoggedMealsSection(dynamic loggedMeals) {
    if (loggedMeals == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('No meals logged by client today.', style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
        ),
      );
    }

    final List<Widget> mealWidgets = [];

    if (loggedMeals is Map) {
      final map = Map<String, dynamic>.from(loggedMeals);
      map.forEach((mealType, items) {
        if (items is List && items.isNotEmpty) {
          mealWidgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                mealType.replaceAll('_', ' ').toUpperCase(),
                style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.primary),
              ),
            ),
          );
          for (var item in items) {
            final itemMap = Map<String, dynamic>.from(item as Map);
            final name = itemMap['food_name'] ?? 'Food';
            final cals = itemMap['calories'] ?? 0;
            final servings = itemMap['servings'] ?? 1;
            final unit = itemMap['serving_unit'] ?? 'portion';

            mealWidgets.add(
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name as String, style: AppStyles.text13Px.poppins.w500.dark),
                          Text('$servings $unit', style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Text('$cals kcal', style: AppStyles.text13Px.poppins.w600.dark),
                  ],
                ),
              ),
            );
          }
        }
      });
    } else if (loggedMeals is List && loggedMeals.isNotEmpty) {
      for (var item in loggedMeals) {
        final itemMap = Map<String, dynamic>.from(item as Map);
        final name = itemMap['food_name'] ?? 'Food';
        final cals = itemMap['calories'] ?? 0;
        final mealType = (itemMap['meal_type'] as String? ?? 'Meal').toUpperCase();

        mealWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$mealType: $name', style: AppStyles.text12Px.poppins.w500.dark),
                Text('$cals kcal', style: AppStyles.text12Px.poppins.w600.dark),
              ],
            ),
          ),
        );
      }
    }

    if (mealWidgets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('No meals logged by client today.', style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mealWidgets,
    );
  }

  Future<void> _showAssignDietDialog() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        bool isLoadingPlans = true;
        List<Map<String, dynamic>> plans = [];

        return StatefulBuilder(
          builder: (context, setModalState) {
            void fetchPlans() async {
              try {
                final res = await DioClient().dio.get<dynamic>(
                  ApiUris.trainerDietPlans,
                  options: Options(headers: {'X-Platform': platformSource}),
                );
                if (res.statusCode == 200 && res.data is List) {
                  final list = (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
                  setModalState(() {
                    plans = list;
                    isLoadingPlans = false;
                  });
                } else {
                  setModalState(() => isLoadingPlans = false);
                }
              } catch (_) {
                setModalState(() => isLoadingPlans = false);
              }
            }

            if (isLoadingPlans && plans.isEmpty) {
              fetchPlans();
            }

            Future<void> assignPlan(int planId, String planTitle) async {
              Navigator.pop(context);
              setState(() => _isLoadingNutrition = true);
              try {
                final response = await DioClient().dio.post<dynamic>(
                  ApiUris.trainerAssignDietToCustomer(widget.customerId),
                  data: {'diet_plan_id': planId},
                  options: Options(headers: {'X-Platform': platformSource}),
                );
                if (response.statusCode == 201 || response.statusCode == 200) {
                  Dialogs.showSnack(msg: 'Assigned "$planTitle" successfully!');
                  _fetchNutritionReport();
                } else {
                  Dialogs.showSnack(msg: 'Failed to assign plan.');
                  setState(() => _isLoadingNutrition = false);
                }
              } catch (_) {
                Dialogs.showSnack(msg: 'Error assigning diet plan.');
                setState(() => _isLoadingNutrition = false);
              }
            }

            Future<void> createAndAssignTemplate(String title, int cals, double prot, double carbs, double fat, List<Map<String, dynamic>> meals) async {
              Navigator.pop(context);
              setState(() => _isLoadingNutrition = true);
              try {
                final createRes = await DioClient().dio.post<dynamic>(
                  ApiUris.trainerDietPlans,
                  data: {
                    'title': title,
                    'target_calories': cals,
                    'target_protein_g': prot,
                    'target_carbs_g': carbs,
                    'target_fat_g': fat,
                    'meals': meals,
                  },
                  options: Options(headers: {'X-Platform': platformSource}),
                );
                if (createRes.statusCode == 201 && createRes.data is Map) {
                  final newPlan = Map<String, dynamic>.from(createRes.data as Map);
                  final planId = newPlan['id'] as int;
                  await assignPlan(planId, title);
                } else {
                  setState(() => _isLoadingNutrition = false);
                  Dialogs.showSnack(msg: 'Failed to create plan.');
                }
              } catch (_) {
                setState(() => _isLoadingNutrition = false);
                Dialogs.showSnack(msg: 'Error creating template.');
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assign Diet Plan', style: AppStyles.text18Px.poppins.w600.dark),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(),
                    if (isLoadingPlans)
                      const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                    else if (plans.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: plans.length,
                          itemBuilder: (context, idx) {
                            final p = plans[idx];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.restaurant, color: AppColors.primary),
                                title: Text(p['title'] as String? ?? 'Plan', style: AppStyles.text14Px.poppins.w600.dark),
                                subtitle: Text('${p['target_calories']} kcal  •  ${p['target_protein_g']}g P', style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
                                trailing: ElevatedButton(
                                  onPressed: () => assignPlan(p['id'] as int, p['title'] as String? ?? 'Plan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Assign', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Preset Diet Plans:', style: AppStyles.text14Px.poppins.w600.dark),
                            const SizedBox(height: 10),
                            _buildTemplateTile(
                              'High Protein Fat Loss (1,800 kcal)',
                              '150g Protein • 160g Carbs • 50g Fat',
                              () => createAndAssignTemplate(
                                'High Protein Fat Loss (1,800 kcal)', 1800, 150.0, 160.0, 50.0,
                                [
                                  {'meal_type': 'breakfast', 'name': 'Eggs & Oatmeal', 'calories': 450, 'protein_g': 35.0, 'carbs_g': 45.0, 'fat_g': 12.0},
                                  {'meal_type': 'lunch', 'name': 'Grilled Chicken & Rice', 'calories': 600, 'protein_g': 55.0, 'carbs_g': 60.0, 'fat_g': 15.0},
                                  {'meal_type': 'evening_snack', 'name': 'Greek Yogurt & Almonds', 'calories': 250, 'protein_g': 20.0, 'carbs_g': 15.0, 'fat_g': 10.0},
                                  {'meal_type': 'dinner', 'name': 'Fish & Steamed Greens', 'calories': 500, 'protein_g': 40.0, 'carbs_g': 40.0, 'fat_g': 13.0},
                                ]
                              ),
                            ),
                            _buildTemplateTile(
                              'Balanced Maintenance (2,000 kcal)',
                              '130g Protein • 220g Carbs • 65g Fat',
                              () => createAndAssignTemplate(
                                'Balanced Maintenance (2,000 kcal)', 2000, 130.0, 220.0, 65.0,
                                [
                                  {'meal_type': 'breakfast', 'name': 'Oats, Milk & Peanut Butter', 'calories': 500, 'protein_g': 25.0, 'carbs_g': 60.0, 'fat_g': 18.0},
                                  {'meal_type': 'lunch', 'name': 'Paneer/Chicken Curry & Rice', 'calories': 650, 'protein_g': 45.0, 'carbs_g': 75.0, 'fat_g': 20.0},
                                  {'meal_type': 'evening_snack', 'name': 'Fruits & Boiled Egg', 'calories': 250, 'protein_g': 15.0, 'carbs_g': 30.0, 'fat_g': 7.0},
                                  {'meal_type': 'dinner', 'name': 'Roti with Dal & Veggies', 'calories': 600, 'protein_g': 45.0, 'carbs_g': 55.0, 'fat_g': 20.0},
                                ]
                              ),
                            ),
                            _buildTemplateTile(
                              'Muscle Bulking (2,500 kcal)',
                              '165g Protein • 300g Carbs • 75g Fat',
                              () => createAndAssignTemplate(
                                'Muscle Bulking (2,500 kcal)', 2500, 165.0, 300.0, 75.0,
                                [
                                  {'meal_type': 'breakfast', 'name': 'Eggs, Toast & Protein Shake', 'calories': 650, 'protein_g': 50.0, 'carbs_g': 70.0, 'fat_g': 20.0},
                                  {'meal_type': 'lunch', 'name': 'Chicken Biryani / Dal Rice', 'calories': 800, 'protein_g': 55.0, 'carbs_g': 95.0, 'fat_g': 25.0},
                                  {'meal_type': 'evening_snack', 'name': 'Peanut Butter Sandwich & Banana', 'calories': 400, 'protein_g': 18.0, 'carbs_g': 55.0, 'fat_g': 14.0},
                                  {'meal_type': 'dinner', 'name': 'Steak/Paneer with Sweet Potato', 'calories': 650, 'protein_g': 42.0, 'carbs_g': 80.0, 'fat_g': 16.0},
                                ]
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplateTile(String title, String subtitle, VoidCallback onAssign) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.text13Px.poppins.w600.dark),
                Text(subtitle, style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Assign', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

