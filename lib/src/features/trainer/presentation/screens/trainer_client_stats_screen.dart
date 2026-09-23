import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:intl/intl.dart';

class TrainerClientStatsScreen extends StatefulWidget {
  const TrainerClientStatsScreen({
    required this.customerId,
    this.showAppBar = true,
    super.key,
  });

  final int customerId;
  final bool showAppBar;

  @override
  State<TrainerClientStatsScreen> createState() =>
      _TrainerClientStatsScreenState();
}

class _TrainerClientStatsScreenState extends State<TrainerClientStatsScreen> {
  Map<String, dynamic> _clientData = {};
  List<Map<String, dynamic>> _workoutHistory = [];
  bool _isLoading = true;
  bool _isLoadingHistory = false;
  bool _isSavingNotes = false;
  bool _isPlansExpanded = false;
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        if (!mounted) return;
        setState(() {
          _clientData = Map<String, dynamic>.from(response.data as Map);
          final profile =
              _clientData['profile'] as Map<dynamic, dynamic>? ?? {};
          _notesController.text = profile['trainer_notes'] as String? ?? '';
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load client details');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading client details: ${e.toString()}');
    }
  }

  Future<void> _fetchWorkoutHistory() async {
    if (!mounted) return;
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
        if (!mounted) return;
        setState(() {
          _workoutHistory =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoadingHistory = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
      });
      Dialogs.showSnack(msg: 'Error loading workout history: ${e.toString()}');
    }
  }

  Future<void> _saveNotes() async {
    if (!mounted) return;
    setState(() {
      _isSavingNotes = true;
    });

    try {
      final response = await DioClient().dio.put<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        data: {'trainer_notes': _notesController.text.trim()},
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
      if (!mounted) return;
      setState(() {
        _isSavingNotes = false;
      });
    }
  }

  int _calculateAge(String? dobStr) {
    if (dobStr == null || dobStr.isEmpty) return 0;
    final dob = DateTime.tryParse(dobStr);
    if (dob == null) return 0;
    int age = DateTime.now().year - dob.year;
    if (DateTime.now().month < dob.month ||
        (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _buildSegmentTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF0F0F0),
          border:
              isSelected
                  ? const Border(
                    bottom: BorderSide(color: AppColors.primary, width: 3),
                  )
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

  Widget _buildGeneralStatsTab(
    Map<String, dynamic> profile,
    Map<String, dynamic> membership,
    List<dynamic> assignedPlans,
    List<dynamic> prRecords,
    bool isAssignedToMe,
    String? trainerName,
  ) {
    final String gender = profile['gender'] as String? ?? 'N/A';
    final rawHeight = profile['height'];
    final rawWeight = profile['weight'];
    final String height =
        (rawHeight != null && rawHeight.toString().isNotEmpty && rawHeight.toString() != 'N/A')
            ? '${rawHeight} cm'
            : 'N/A';
    final String weight =
        (rawWeight != null && rawWeight.toString().isNotEmpty && rawWeight.toString() != 'N/A')
            ? '${rawWeight} kg'
            : 'N/A';
    final String bmi = (profile['bmi'] ?? 'N/A').toString();
    final String fitnessLevel = profile['fitness_level'] as String? ?? 'N/A';
    final hasActiveMembership = membership.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PR Records Panel (dynamic, only shown if real PR records exist)
        if (prRecords.isNotEmpty) ...[
          Text('PR Records', style: AppStyles.text16Px.poppins.w600.dark),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < prRecords.length; i++) ...[
                  if (i > 0) const Divider(height: 20, thickness: 0.5),
                  Builder(
                    builder: (context) {
                      final item = Map<String, dynamic>.from(prRecords[i] as Map);
                      final workoutName = item['workout_name'] as String? ?? 'Exercise';
                      final val = item['value'] != null ? '${item['value']} ${item['unit'] ?? ''}'.trim() : 'N/A';
                      return _buildPrRow(Icons.fitness_center, workoutName, val);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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
        Text('Gym Membership', style: AppStyles.text16Px.poppins.w600.dark),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              hasActiveMembership
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF43A047),
                          ),
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
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        'Valid: ${membership['start_date'] ?? ""} to ${membership['end_date'] ?? ""}',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No active membership plan',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
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
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: const Color(0xFF2E7D32),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: const Color(0xffE8F5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              assignedPlans.isEmpty
                  ? Center(
                    child: Text(
                      'No workout plans assigned.',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      ...assignedPlans
                          .take(_isPlansExpanded ? assignedPlans.length : 3)
                          .map((plan) {
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        planName as String,
                                        style: AppStyles.text13Px.poppins.w600,
                                      ),
                                      Text(
                                        '$days Days duration',
                                        style: AppStyles.text12Px.poppins.w400
                                            .copyWith(
                                              color: AppColors.textGrey,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          statusStr == 'active'
                                              ? const Color(0xffE8F5E9)
                                              : const Color(0xffE0E0E0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (statusStr as String).toUpperCase(),
                                      style: AppStyles.text10Px.poppins.w600
                                          .copyWith(
                                            color:
                                                statusStr == 'active'
                                                    ? const Color(0xFF43A047)
                                                    : Colors.grey.shade700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      if (assignedPlans.length > 3)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isPlansExpanded = !_isPlansExpanded;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: AppStyles.text14Px.poppins.w600,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isPlansExpanded
                                    ? 'Show Less'
                                    : 'See all ${assignedPlans.length} plans',
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isPlansExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                    ],
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add progress logs, dietary notes, or remarks...',
                  hintStyle: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_workoutHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No workout history logged.',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
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
            Text('History Logs', style: AppStyles.text16Px.poppins.w600.dark),
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
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ...entries.map((entry) {
                  final dateRaw = entry['date'] as String;
                  final date = DateTime.parse(dateRaw);
                  final formattedDate = DateFormat('MMMM d, yyyy').format(date);
                  final logs = entry['logs'] as List<dynamic>? ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 1,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          formattedDate,
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                        subtitle: Text(
                          '${logs.length} exercises logged',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final itemWidth =
                                    (constraints.maxWidth - 12) / 2;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children:
                                      logs.map((log) {
                                        final logMap =
                                            Map<String, dynamic>.from(
                                              log as Map,
                                            );
                                        final workoutName =
                                            logMap['workout_name'] ??
                                            'Exercise';
                                        final setLogs =
                                            logMap['set_logs']
                                                as List<dynamic>? ??
                                            [];

                                        return Container(
                                          width: itemWidth,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF9F9F9),
                                            border: Border.all(
                                              color: Colors.grey.withValues(
                                                alpha: .2,
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                workoutName as String,
                                                style:
                                                    AppStyles
                                                        .text13Px
                                                        .poppins
                                                        .w600
                                                        .dark,
                                              ),
                                              const SizedBox(height: 6),
                                              ...setLogs.map((set) {
                                                final setMap =
                                                    Map<String, dynamic>.from(
                                                      set as Map,
                                                    );
                                                final reps =
                                                    setMap['reps'] ?? 0;
                                                final weight =
                                                    setMap['weight_kg'] ?? 0.0;
                                                return Text(
                                                  'Set ${setMap['set_number']}: $weight kg x $reps reps',
                                                  style: AppStyles
                                                      .text12Px
                                                      .poppins
                                                      .w400
                                                      .copyWith(
                                                        color:
                                                            AppColors.textGrey,
                                                      ),
                                                );
                                              }),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                );
                              },
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
          child: Text(name, style: AppStyles.text13Px.poppins.w500.dark),
        ),
        Text(
          value,
          style: AppStyles.text13Px.poppins.w600.copyWith(
            color: AppColors.primary,
          ),
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
      appBar:
          widget.showAppBar
              ? AppBar(
                leading: const PopButton().center,
                title: Text(
                  'Client Details',
                  style: AppStyles.text18Px.poppins.w600.dark,
                ),
              )
              : AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
      body: SafeArea(
        child: Column(
          children: [
            // Main profile card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TrainerClientDetailScreen(
                          customerId: widget.customerId,
                        ),
                  ),
                );
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Dialogs.showEnlargedProfilePhoto(
                          context,
                          imgUrl as String?,
                          name: profile['name'] as String?,
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.iconBackground,
                        ),
                        child: ClipOval(
                          child:
                              imgUrl != null
                                  ? Image.network(
                                    imgUrl as String,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: AppColors.primary,
                                        ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppColors.primary,
                                  ),
                        ),
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
                            age > 0
                                ? 'Age: $age  |  Phone: $mobile'
                                : 'Phone: $mobile',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                child:
                    _selectedTab == 0
                        ? _buildGeneralStatsTab(
                          profile,
                          membership,
                          assignedPlans,
                          prRecords,
                          isAssignedToMe,
                          trainerName,
                        )
                        : _buildWorkoutHistoryTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text13Px.poppins.w500.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        Text(value, style: AppStyles.text13Px.poppins.w600),
      ],
    );
  }
}
