import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reports_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_workout_session_detail_screen.dart';

class TrainerPendingVerificationsScreen extends StatefulWidget {
  const TrainerPendingVerificationsScreen({super.key});

  @override
  State<TrainerPendingVerificationsScreen> createState() =>
      _TrainerPendingVerificationsScreenState();
}

class _TrainerPendingVerificationsScreenState
    extends State<TrainerPendingVerificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _pendingVerifications = [];
  List<Map<String, dynamic>> _verificationHistory = [];

  bool _isLoadingPending = true;
  bool _isLoadingHistory = true;

  Map<String, String> _clientProfilesByName = {};
  Map<int, String> _clientProfilesById = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  String _pendingTypeFilter = 'assigned'; // 'assigned', 'self'

  final TextEditingController _historySearchController = TextEditingController();
  String _historySearchQuery = '';
  DateTime? _historySelectedDate;
  String _historyTypeFilter = 'assigned'; // 'assigned', 'self'

  bool _isAssignedWorkout(Map<String, dynamic> item) {
    final type = (item['workout_type'] ??
            item['session_type'] ??
            item['type'] ??
            item['workout_category'] ??
            '')
        .toString()
        .toLowerCase();
    if (type.contains('assigned')) return true;
    if (type.contains('self') || type.contains('custom') || type.contains('own')) return false;

    final isAssigned = item['is_assigned'] as bool? ??
        item['is_assigned_workout'] as bool?;
    if (isAssigned != null) return isAssigned;

    final isSelf = item['is_self_workout'] as bool? ??
        item['is_custom'] as bool? ??
        item['is_self'] as bool?;
    if (isSelf != null) return !isSelf;

    final planId = item['customer_workout_plan_id'] ??
        item['plan_id'] ??
        item['workout_plan_id'] ??
        item['plan'];
    return planId != null && planId != 0;
  }

  Widget _buildWorkoutTypeBadge(Map<String, dynamic> item) {
    final isAssigned = _isAssignedWorkout(item);
    final label = isAssigned ? 'Assigned' : 'Self Workout';
    final bg = isAssigned
        ? const Color(0xFFEBF3FF)
        : const Color(0xFFF3E8FF);
    final textColor = isAssigned
        ? const Color(0xFF1E56A0)
        : const Color(0xFF7E22CE);
    final icon = isAssigned ? Icons.assignment_outlined : Icons.person_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.text10Px.poppins.w600.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchClientProfiles();
    _fetchPendingVerifications();
    _fetchVerificationHistory();
  }

  Future<void> _fetchClientProfiles() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (List<dynamic>.from(
                  (response.data as Map)['results'] as List? ?? [],
                ))
                : (response.data as List<dynamic>);
        final Map<String, String> byName = {};
        final Map<int, String> byId = {};
        for (final e in data) {
          if (e is Map) {
            final String name = e['name'] as String? ?? '';
            final String pic =
                e['profile_picture'] as String? ??
                e['image_url'] as String? ??
                '';
            final int id = e['id'] as int? ?? 0;
            if (name.isNotEmpty && pic.isNotEmpty) {
              byName[name] = pic;
            }
            if (id > 0 && pic.isNotEmpty) {
              byId[id] = pic;
            }
          }
        }
        if (mounted) {
          setState(() {
            _clientProfilesByName = byName;
            _clientProfilesById = byId;
          });
        }
      }
    } catch (_) {}
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        _fetchPendingVerifications();
      } else {
        _fetchVerificationHistory();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _historySearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPendingVerifications() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPending = true;
      _pendingVerifications = [];
    });

    final Map<String, dynamic> queryParams = {};
    if (_searchQuery.trim().isNotEmpty) {
      queryParams['search'] = _searchQuery.trim();
    }
    if (_selectedDate != null) {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      queryParams['date'] = dateStr;
    }

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.pendingVerifications,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final pendingList =
            data['pending_verifications'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _pendingVerifications =
                pendingList
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
            _isLoadingPending = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingPending = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPending = false);
      Dialogs.showSnack(msg: 'Failed to load pending verifications');
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchPendingVerifications();
    }
  }

  Future<void> _pickHistoryDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _historySelectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _historySelectedDate = picked;
      });
      _fetchVerificationHistory();
    }
  }

  Future<void> _fetchVerificationHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
      _verificationHistory = [];
    });

    final Map<String, dynamic> queryParams = {};
    if (_historySearchQuery.trim().isNotEmpty) {
      queryParams['search'] = _historySearchQuery.trim();
    }
    if (_historySelectedDate != null) {
      final dateStr =
          '${_historySelectedDate!.year}-${_historySelectedDate!.month.toString().padLeft(2, '0')}-${_historySelectedDate!.day.toString().padLeft(2, '0')}';
      queryParams['date'] = dateStr;
    }

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.verificationHistory,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List<dynamic>;
        if (mounted) {
          setState(() {
            _verificationHistory =
                data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
      Dialogs.showSnack(msg: 'Failed to load verification history');
    }
  }

  Future<void> _verifyOrReject(
    int sessionId,
    String status,
    String remarks,
  ) async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.verifyWorkoutSession(sessionId),
        data: {'verification_status': status, 'remarks': remarks},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        reportsRefreshTrigger.value++;
        Dialogs.showSnack(msg: 'Workout $status successfully');
        _fetchPendingVerifications();
        _fetchVerificationHistory();
      } else {
        Dialogs.showSnack(msg: 'Failed to update status');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  void _showVerificationDialog(
    int sessionId,
    String customerName,
    String title,
    bool isVerify,
  ) {
    final remarksController = TextEditingController();
    final status = isVerify ? 'verified' : 'rejected';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isVerify ? 'Verify Workout' : 'Reject Workout',
            style: AppStyles.text18Px.poppins.w600.dark,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to ${isVerify ? 'verify' : 'reject'} $customerName\'s $title session?',
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add remarks (optional)',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyOrReject(
                  sessionId,
                  status,
                  remarksController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isVerify ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isVerify ? 'Verify' : 'Reject',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        centerTitle: false,
        title: Text(
          'Verifications',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          labelStyle: AppStyles.text14Px.poppins.w600,
          unselectedLabelStyle: AppStyles.text14Px.poppins.w500,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPendingTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildPendingTab() {
    final rawPendingList = _pendingVerifications;
    final pendingList = rawPendingList.where((item) {
      if (_pendingTypeFilter == 'assigned' && !_isAssignedWorkout(item)) return false;
      if (_pendingTypeFilter == 'self' && _isAssignedWorkout(item)) return false;
      return true;
    }).toList();

    final hasActiveFilter =
        _searchQuery.trim().isNotEmpty || _selectedDate != null || _pendingTypeFilter != 'all';

    String? dateFilterLabel;
    if (_selectedDate != null) {
      dateFilterLabel =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        if (!mounted) return;
                        setState(() {
                          _searchQuery = val;
                        });
                        EasyDebounce.debounce(
                          'pending-verifications-search',
                          const Duration(milliseconds: 400),
                          () => _fetchPendingVerifications(),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone',
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: AppColors.textGrey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                    _fetchPendingVerifications();
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderGrey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _selectedDate != null
                                  ? AppColors.primary
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _selectedDate != null
                                    ? AppColors.primary
                                    : AppColors.borderGrey,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color:
                              _selectedDate != null
                                  ? Colors.white
                                  : AppColors.textDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Filter Chips: Assigned Workouts (50%) & Self Workouts (50%)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Assigned Workouts')),
                      selected: _pendingTypeFilter == 'assigned',
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _pendingTypeFilter == 'assigned' ? Colors.white : AppColors.dark,
                        fontSize: 12,
                        fontWeight: _pendingTypeFilter == 'assigned' ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _pendingTypeFilter == 'assigned' ? AppColors.primary : const Color(0xffEEEEEE),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _pendingTypeFilter = 'assigned');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Self Workouts')),
                      selected: _pendingTypeFilter == 'self',
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _pendingTypeFilter == 'self' ? Colors.white : AppColors.dark,
                        fontSize: 12,
                        fontWeight: _pendingTypeFilter == 'self' ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _pendingTypeFilter == 'self' ? AppColors.primary : const Color(0xffEEEEEE),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _pendingTypeFilter = 'self');
                      },
                    ),
                  ),
                ],
              ),

              if (dateFilterLabel != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateFilterLabel,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = null;
                              });
                              _fetchPendingVerifications();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child:
              _isLoadingPending
                  ? const Center(child: CircularProgressIndicator())
                  : pendingList.isEmpty
                  ? _buildEmptyState(
                    hasActiveFilter
                        ? 'No Matching Verifications'
                        : 'No Pending Verifications',
                    hasActiveFilter
                        ? 'Try adjusting your search or date filter.'
                        : 'You have caught up with all client workouts.',
                    Icons.verified_outlined,
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pendingList.length,
                    itemBuilder: (context, index) {
                      final item = pendingList[index];
                      final sessionId = item['session_id'] as int? ?? 0;
                      final customerName =
                          item['customer_name'] as String? ?? 'Client';
                      final customerId = item['customer_id'] as int? ?? 0;
                      final profilePic =
                          item['customer_profile_picture'] as String? ??
                          item['profile_picture'] as String? ??
                          item['customer_image'] as String? ??
                          item['image_url'] as String? ??
                          (item['customer'] is Map
                              ? (item['customer']
                                      as Map)['profile_picture']
                                  as String?
                              : null) ??
                          _clientProfilesById[customerId] ??
                          _clientProfilesByName[customerName];
                      final workoutTitle =
                          item['workout_title'] as String? ?? 'Workout';
                      final completedAtRaw =
                          item['completed_at'] as String? ?? '';
                      String completedAt = completedAtRaw;
                      if (completedAtRaw.isNotEmpty) {
                        final parsed = DateTime.tryParse(completedAtRaw);
                        if (parsed != null) {
                          final local = parsed.toLocal();
                          final hour =
                              local.hour == 0
                                  ? 12
                                  : (local.hour > 12
                                      ? local.hour - 12
                                      : local.hour);
                          final amPm = local.hour >= 12 ? 'PM' : 'AM';
                          completedAt =
                              '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:${local.minute.toString().padLeft(2, '0')} $amPm';
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (sessionId > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder:
                                    (context) =>
                                        TrainerWorkoutSessionDetailScreen(
                                          sessionId: sessionId,
                                        ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (profilePic != null &&
                                      profilePic.isNotEmpty)
                                    ProfileImage(
                                      isEdit: false,
                                      url: profilePic,
                                      radius: 20,
                                    )
                                  else
                                    const Icon(
                                      Icons.person,
                                      size: 24,
                                      color: AppColors.primary,
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                customerName,
                                                style: AppStyles
                                                    .text16Px
                                                    .poppins
                                                    .w600
                                                    .dark,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            _buildWorkoutTypeBadge(item),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          workoutTitle,
                                          style: AppStyles
                                              .text15Px
                                              .poppins
                                              .w600
                                              .copyWith(
                                                color: AppColors.textDark,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (completedAt.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          completedAt,
                                          style: AppStyles
                                              .text10Px
                                              .poppins
                                              .w500
                                              .copyWith(
                                                color: AppColors.textGrey,
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: OutlinedButton(
                                        onPressed:
                                            () => _showVerificationDialog(
                                              sessionId,
                                              customerName,
                                              workoutTitle,
                                              false,
                                            ),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        onPressed:
                                            () => _showVerificationDialog(
                                              sessionId,
                                              customerName,
                                              workoutTitle,
                                              true,
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Verify',
                                          style: AppStyles
                                              .text14Px
                                              .poppins
                                              .w600
                                              .copyWith(color: Colors.white),
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
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final rawHistoryList = _verificationHistory;
    final historyList = rawHistoryList.where((item) {
      if (_historyTypeFilter == 'assigned' && !_isAssignedWorkout(item)) return false;
      if (_historyTypeFilter == 'self' && _isAssignedWorkout(item)) return false;
      return true;
    }).toList();

    final hasActiveFilter =
        _historySearchQuery.trim().isNotEmpty || _historySelectedDate != null || _historyTypeFilter != 'all';

    String? dateFilterLabel;
    if (_historySelectedDate != null) {
      dateFilterLabel =
          '${_historySelectedDate!.year}-${_historySelectedDate!.month.toString().padLeft(2, '0')}-${_historySelectedDate!.day.toString().padLeft(2, '0')}';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _historySearchController,
                      onChanged: (val) {
                        if (!mounted) return;
                        setState(() {
                          _historySearchQuery = val;
                        });
                        EasyDebounce.debounce(
                          'history-verifications-search',
                          const Duration(milliseconds: 400),
                          () => _fetchVerificationHistory(),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone',
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                        suffixIcon:
                            _historySearchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: AppColors.textGrey,
                                  ),
                                  onPressed: () {
                                    _historySearchController.clear();
                                    setState(() {
                                      _historySearchQuery = '';
                                    });
                                    _fetchVerificationHistory();
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderGrey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickHistoryDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _historySelectedDate != null
                                  ? AppColors.primary
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _historySelectedDate != null
                                    ? AppColors.primary
                                    : AppColors.borderGrey,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color:
                              _historySelectedDate != null
                                  ? Colors.white
                                  : AppColors.textDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Filter Chips: Assigned Workouts (50%) & Self Workouts (50%)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Assigned Workouts')),
                      selected: _historyTypeFilter == 'assigned',
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _historyTypeFilter == 'assigned' ? Colors.white : AppColors.dark,
                        fontSize: 12,
                        fontWeight: _historyTypeFilter == 'assigned' ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _historyTypeFilter == 'assigned' ? AppColors.primary : const Color(0xffEEEEEE),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _historyTypeFilter = 'assigned');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Self Workouts')),
                      selected: _historyTypeFilter == 'self',
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _historyTypeFilter == 'self' ? Colors.white : AppColors.dark,
                        fontSize: 12,
                        fontWeight: _historyTypeFilter == 'self' ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _historyTypeFilter == 'self' ? AppColors.primary : const Color(0xffEEEEEE),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _historyTypeFilter = 'self');
                      },
                    ),
                  ),
                ],
              ),

              if (dateFilterLabel != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateFilterLabel,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _historySelectedDate = null;
                              });
                              _fetchVerificationHistory();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child:
              _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : historyList.isEmpty
                  ? _buildEmptyState(
                      hasActiveFilter
                          ? 'No Matching Verifications'
                          : 'No History',
                      hasActiveFilter
                          ? 'Try adjusting your search or date filter.'
                          : 'You have not verified any workouts yet.',
                      Icons.history,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final item = historyList[index];
                        final customerName = item['customer_name'] as String? ?? 'Client';
                        final customerId = item['customer_id'] as int? ?? 0;
                        final profilePic =
                            item['customer_profile_picture'] as String? ??
                            item['profile_picture'] as String? ??
                            item['customer_image'] as String? ??
                            item['image_url'] as String? ??
                            (item['customer'] is Map
                                ? (item['customer'] as Map)['profile_picture'] as String?
                                : null) ??
                            _clientProfilesById[customerId] ??
                            _clientProfilesByName[customerName];
                        final workoutTitle = item['workout_title'] as String? ?? 'Workout';
                        final verifiedAtRaw = item['verified_at'] as String? ?? '';
                        final sessionId = item['session_id'] as int? ?? 0;
                        String verifiedAt = verifiedAtRaw;
                        if (verifiedAtRaw.isNotEmpty) {
                          final parsed = DateTime.tryParse(verifiedAtRaw);
                          if (parsed != null) {
                            final local = parsed.toLocal();
                            final hour =
                                local.hour == 0
                                    ? 12
                                    : (local.hour > 12 ? local.hour - 12 : local.hour);
                            final amPm = local.hour >= 12 ? 'PM' : 'AM';
                            verifiedAt =
                                '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:${local.minute.toString().padLeft(2, '0')} $amPm';
                          }
                        }
                        final status = item['verification_status'] as String? ?? '';
                        final remarks = item['remarks'] as String? ?? '';
                        final isVerified = status == 'verified';

                        return GestureDetector(
                          onTap: () {
                            if (sessionId > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder:
                                      (context) => TrainerWorkoutSessionDetailScreen(
                                        sessionId: sessionId,
                                      ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        workoutTitle,
                                        style: AppStyles.text16Px.poppins.w600.dark,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isVerified
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isVerified ? 'Verified' : 'Rejected',
                                        style: AppStyles.text12Px.poppins.w600.copyWith(
                                          color: isVerified ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (profilePic != null && profilePic.isNotEmpty)
                                      ProfileImage(isEdit: false, url: profilePic, radius: 20)
                                    else
                                      const Icon(
                                        Icons.person,
                                        size: 24,
                                        color: AppColors.primary,
                                      ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        customerName,
                                        style: AppStyles.text14Px.poppins.w500.copyWith(
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    _buildWorkoutTypeBadge(item),
                                  ],
                                ),
                                if (verifiedAt.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: $verifiedAt',
                                    style: AppStyles.text12Px.poppins.w400.copyWith(
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                                if (remarks.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.format_quote,
                                          size: 16,
                                          color: AppColors.textGrey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            remarks,
                                            style: AppStyles.text12Px.poppins.w400.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
