import 'dart:async';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reports_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_workout_session_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/repositories/trainer_repository.dart';

class TrainerPendingVerificationsScreen extends StatefulWidget {
  const TrainerPendingVerificationsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

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

  final Set<int> _selectedSessionIds = {};
  bool _isBulkVerifying = false;
  bool _isSelectionMode = false;

  bool _isLoadingPending = true;
  bool _isLoadingHistory = false;
  bool _hasFetchedPending = false;
  bool _hasFetchedHistory = false;
  int _lastTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  String _pendingTypeFilter = 'assigned'; // 'assigned', 'self'

  final TextEditingController _historySearchController =
      TextEditingController();
  String _historySearchQuery = '';
  DateTime? _historySelectedDate;
  String _historyTypeFilter = 'assigned'; // 'assigned', 'self'

  bool _isAssignedWorkout(Map<String, dynamic> item) {
    final type =
        (item['workout_type'] ??
                item['session_type'] ??
                item['type'] ??
                item['plan_type'] ??
                item['category'] ??
                '')
            .toString()
            .toLowerCase();
    if (type.contains('assigned')) return true;
    if (type.contains('self') ||
        type.contains('custom') ||
        type.contains('own'))
      return false;

    final isAssigned =
        item['is_assigned'] as bool? ??
        item['is_assigned_workout'] as bool? ??
        item['is_assigned_to_me'] as bool?;
    if (isAssigned != null) return isAssigned;

    final isSelf =
        item['is_self_workout'] as bool? ??
        item['is_custom'] as bool? ??
        item['is_self'] as bool?;
    if (isSelf != null) return !isSelf;

    if (item['assigned_by'] != null ||
        item['assigned_by_id'] != null ||
        item['trainer_id'] != null) {
      return true;
    }

    final planId =
        item['customer_workout_plan_id'] ??
        item['plan_id'] ??
        item['workout_plan_id'] ??
        item['plan'] ??
        item['assigned_workout_plan'] ??
        item['assigned_plan_id'] ??
        item['plan_day_id'] ??
        item['plan_day'] ??
        item['assignment_id'];
    return planId != null && planId != 0 && planId != '' && planId != 'null';
  }

  Widget _buildWorkoutTypeBadge(Map<String, dynamic> item) {
    final isAssigned = _isAssignedWorkout(item);
    final label = isAssigned ? 'Assigned' : 'Self Workout';
    final bg = isAssigned ? const Color(0xFFEBF3FF) : const Color(0xFFF3E8FF);
    final textColor =
        isAssigned ? const Color(0xFF1E56A0) : const Color(0xFF7E22CE);
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
    _lastTabIndex = widget.initialTabIndex;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_handleTabSelection);
    if (widget.initialTabIndex == 1) {
      _fetchVerificationHistory();
    } else {
      _fetchPendingVerifications();
    }
  }

  void _handleTabSelection() {
    if (_tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      if (_isSelectionMode) {
        _isSelectionMode = false;
        _selectedSessionIds.clear();
      }
      if (_tabController.index == 1 && !_hasFetchedHistory) {
        _fetchVerificationHistory();
      } else if (_tabController.index == 0 && !_hasFetchedPending) {
        _fetchPendingVerifications();
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _historySearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  final Map<int, bool> _sessionAssignmentMap = {};

  Future<void> _fetchPendingVerifications() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPending = true;
      _pendingVerifications = [];
      _selectedSessionIds.clear();
      _isSelectionMode = false;
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
        final parsedPending =
            pendingList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        for (final item in parsedPending) {
          final sId = item['session_id'] as int? ?? item['id'] as int?;
          if (sId != null && sId > 0) {
            _sessionAssignmentMap[sId] = _isAssignedWorkout(item);
          }
        }

        if (mounted) {
          setState(() {
            _pendingVerifications = parsedPending;
            _isLoadingPending = false;
            _hasFetchedPending = true;
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
        final parsedHistory =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        for (final item in parsedHistory) {
          final sId = item['session_id'] as int? ?? item['id'] as int?;
          if (sId != null &&
              sId > 0 &&
              _sessionAssignmentMap.containsKey(sId)) {
            item['is_assigned'] = _sessionAssignmentMap[sId];
          }
        }

        if (mounted) {
          setState(() {
            _verificationHistory = parsedHistory;
            _isLoadingHistory = false;
            _hasFetchedHistory = true;
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
        _selectedSessionIds.remove(sessionId);
        _fetchPendingVerifications();
        _hasFetchedHistory = false;
        if (_tabController.index == 1) {
          _fetchVerificationHistory();
        }
      } else {
        Dialogs.showSnack(msg: 'Failed to update status');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  Future<void> _executeBulkVerification(
    List<int> sessionIds,
    String remarks,
  ) async {
    if (sessionIds.isEmpty) return;

    setState(() {
      _isBulkVerifying = true;
    });

    try {
      final response = await TrainerRepository().bulkVerifyWorkoutSessions(
        sessionIds: sessionIds,
        remarks: remarks.isNotEmpty ? remarks : 'Batch verified by trainer',
      );

      reportsRefreshTrigger.value++;
      final msg = response.message.isNotEmpty
          ? response.message
          : 'Successfully verified ${response.successCount} workout session(s).';

      if (response.failureCount > 0) {
        Dialogs.showSnack(
          msg: '$msg (${response.failureCount} failed)',
        );
      } else {
        Dialogs.showSnack(msg: msg);
      }

      setState(() {
        _selectedSessionIds.clear();
        _isSelectionMode = false;
      });
      await _fetchPendingVerifications();
      _hasFetchedHistory = false;
      if (_tabController.index == 1) {
        await _fetchVerificationHistory();
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Bulk verification failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isBulkVerifying = false;
        });
      }
    }
  }

  void _showBulkVerificationDialog() {
    final count = _selectedSessionIds.length;
    if (count == 0) return;

    final remarksController =
        TextEditingController(text: 'Batch verified by trainer');

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.done_all, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bulk Verify Workouts',
                      style: AppStyles.text18Px.poppins.w600.dark,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to verify $count selected workout session${count > 1 ? 's' : ''} in a single batch?',
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
                      labelText: 'Remarks',
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
                  onPressed:
                      _isBulkVerifying ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isBulkVerifying
                      ? null
                      : () {
                          Navigator.pop(context);
                          unawaited(
                            _executeBulkVerification(
                              _selectedSessionIds.toList(),
                              remarksController.text.trim(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Verify All ($count)',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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

  List<int> _getVisiblePendingSessionIds() {
    final rawPendingList = _pendingVerifications;
    final pendingList = rawPendingList.where((item) {
      if (_pendingTypeFilter == 'assigned' && !_isAssignedWorkout(item)) {
        return false;
      }
      if (_pendingTypeFilter == 'self' && _isAssignedWorkout(item)) {
        return false;
      }
      return true;
    }).toList();

    return pendingList
        .map((item) => item['session_id'] as int? ?? item['id'] as int? ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  Widget _buildMoreMenu() {
    final visibleIds = _getVisiblePendingSessionIds();
    final hasItems = visibleIds.isNotEmpty;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == 'select') {
          setState(() {
            _isSelectionMode = true;
          });
        } else if (value == 'select_all') {
          setState(() {
            _isSelectionMode = true;
            _selectedSessionIds.addAll(visibleIds);
          });
        } else if (value == 'deselect_all') {
          setState(_selectedSessionIds.clear);
        } else if (value == 'cancel') {
          setState(() {
            _isSelectionMode = false;
            _selectedSessionIds.clear();
          });
        }
      },
      itemBuilder: (context) {
        if (!_isSelectionMode) {
          return [
            PopupMenuItem(
              value: 'select',
              enabled: hasItems,
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 20, color: AppColors.textDark),
                  SizedBox(width: 12),
                  Text('Select'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'select_all',
              enabled: hasItems,
              child: const Row(
                children: [
                  Icon(Icons.done_all, size: 20, color: AppColors.textDark),
                  SizedBox(width: 12),
                  Text('Select All'),
                ],
              ),
            ),
          ];
        } else {
          final isAllSelected =
              hasItems && visibleIds.every(_selectedSessionIds.contains);
          return [
            PopupMenuItem(
              value: isAllSelected ? 'deselect_all' : 'select_all',
              enabled: hasItems,
              child: Row(
                children: [
                  Icon(
                    isAllSelected ? Icons.remove_done : Icons.done_all,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 12),
                  Text(isAllSelected ? 'Deselect All' : 'Select All'),
                ],
              ),
            ),
            if (_selectedSessionIds.isNotEmpty && !isAllSelected)
              const PopupMenuItem(
                value: 'deselect_all',
                child: Row(
                  children: [
                    Icon(Icons.remove_done, size: 20, color: AppColors.textDark),
                    SizedBox(width: 12),
                    Text('Deselect All'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.close, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Cancel Selection', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ];
        }
      },
    );
  }

  Widget _buildRoundSelector(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderGrey,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.textDark),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedSessionIds.clear();
                  });
                },
              )
            : const PopButton().center,
        centerTitle: false,
        title: Text(
          _isSelectionMode
              ? (_selectedSessionIds.isEmpty
                  ? 'Select Workouts'
                  : '${_selectedSessionIds.length} Selected')
              : 'Verifications',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        actions: [
          if (_tabController.index == 0) _buildMoreMenu(),
        ],
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
    final pendingList =
        rawPendingList.where((item) {
          if (_pendingTypeFilter == 'assigned' && !_isAssignedWorkout(item))
            return false;
          if (_pendingTypeFilter == 'self' && _isAssignedWorkout(item))
            return false;
          return true;
        }).toList();

    final hasActiveFilter =
        _searchQuery.trim().isNotEmpty ||
        _selectedDate != null ||
        _pendingTypeFilter != 'all';

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
                        color:
                            _pendingTypeFilter == 'assigned'
                                ? Colors.white
                                : context.colors.textPrimary,
                        fontSize: 12,
                        fontWeight:
                            _pendingTypeFilter == 'assigned'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      backgroundColor: context.colors.card,
                      side: BorderSide(
                        color:
                            _pendingTypeFilter == 'assigned'
                                ? AppColors.primary
                                : context.colors.border,
                      ),
                      onSelected: (val) {
                        if (val)
                          setState(() => _pendingTypeFilter = 'assigned');
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
                        color:
                            _pendingTypeFilter == 'self'
                                ? Colors.white
                                : context.colors.textPrimary,
                        fontSize: 12,
                        fontWeight:
                            _pendingTypeFilter == 'self'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      backgroundColor: context.colors.card,
                      side: BorderSide(
                        color:
                            _pendingTypeFilter == 'self'
                                ? AppColors.primary
                                : context.colors.border,
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
        if (_isSelectionMode && pendingList.isNotEmpty)
          _buildSelectAllBar(pendingList),
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
                      final customerId = item['customer_id'] as int? ??
                          (item['customer'] is Map
                              ? (item['customer'] as Map)['id'] as int?
                              : null) ??
                          (item['client_id'] as int?) ??
                          0;
                      final profilePic =
                          item['customer_profile_picture'] as String? ??
                          item['profile_picture'] as String? ??
                          item['customer_image'] as String? ??
                          item['image_url'] as String? ??
                          (item['customer'] is Map
                              ? (item['customer'] as Map)['profile_picture']
                                  as String?
                              : null);
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

                      final isSelected =
                          sessionId > 0 && _selectedSessionIds.contains(sessionId);

                      return GestureDetector(
                        onTap: () {
                          if (_isSelectionMode) {
                            if (sessionId > 0) {
                              setState(() {
                                if (isSelected) {
                                  _selectedSessionIds.remove(sessionId);
                                } else {
                                  _selectedSessionIds.add(sessionId);
                                }
                              });
                            }
                          } else if (sessionId > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder:
                                    (context) =>
                                        TrainerWorkoutSessionDetailScreen(
                                          sessionId: sessionId,
                                          isAssigned: _isAssignedWorkout(item),
                                        ),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!_isSelectionMode && sessionId > 0) {
                            setState(() {
                              _isSelectionMode = true;
                              _selectedSessionIds.add(sessionId);
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.04)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
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
                                  if (_isSelectionMode && sessionId > 0) ...[
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedSessionIds.remove(sessionId);
                                          } else {
                                            _selectedSessionIds.add(sessionId);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                          top: 14,
                                        ),
                                        child: _buildRoundSelector(isSelected),
                                      ),
                                    ),
                                  ],
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (customerId > 0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder:
                                                (context) =>
                                                    TrainerClientDetailScreen(
                                                      customerId: customerId,
                                                    ),
                                          ),
                                        );
                                      }
                                    },
                                    child:
                                        profilePic != null &&
                                                profilePic.isNotEmpty
                                            ? ProfileImage(
                                              isEdit: false,
                                              url: profilePic,
                                              radius: 26,
                                            )
                                            : Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                size: 28,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customerName,
                                          style:
                                              AppStyles
                                                  .text16Px
                                                  .poppins
                                                  .w600
                                                  .dark,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          workoutTitle,
                                          style: AppStyles.text15Px.poppins.w600
                                              .copyWith(
                                                color: AppColors.textDark,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildWorkoutTypeBadge(item),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                      if (completedAt.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          completedAt,
                                          style: AppStyles.text10Px.poppins.w500
                                              .copyWith(
                                                color: AppColors.textGrey,
                                              ),
                                        ),
                                      ],
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Verify',
                                          style: AppStyles.text14Px.poppins.w600
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
        if (_selectedSessionIds.isNotEmpty) _buildBulkActionBar(),
      ],
    );
  }

  Widget _buildSelectAllBar(List<Map<String, dynamic>> pendingList) {
    final visibleIds = pendingList
        .map((item) => item['session_id'] as int? ?? item['id'] as int? ?? 0)
        .where((id) => id > 0)
        .toList();
    final isAllSelected = visibleIds.isNotEmpty &&
        visibleIds.every((id) => _selectedSessionIds.contains(id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isAllSelected) {
                  _selectedSessionIds.removeAll(visibleIds);
                } else {
                  _selectedSessionIds.addAll(visibleIds);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoundSelector(isAllSelected),
                  const SizedBox(width: 8),
                  Text(
                    isAllSelected
                        ? 'Deselect All'
                        : 'Select All (${visibleIds.length})',
                    style: AppStyles.text13Px.poppins.w500.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSelectionMode = false;
                _selectedSessionIds.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Done',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    final count = _selectedSessionIds.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count Selected',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedSessionIds.clear();
                });
              },
              child: Text(
                'Clear',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isBulkVerifying ? null : _showBulkVerificationDialog,
              icon: _isBulkVerifying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.done_all,
                      size: 18,
                      color: Colors.white,
                    ),
              label: Text(
                'Verify ($count)',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final rawHistoryList = _verificationHistory;
    final historyList =
        rawHistoryList.where((item) {
          if (_historyTypeFilter == 'assigned' && !_isAssignedWorkout(item))
            return false;
          if (_historyTypeFilter == 'self' && _isAssignedWorkout(item))
            return false;
          return true;
        }).toList();

    final hasActiveFilter =
        _historySearchQuery.trim().isNotEmpty ||
        _historySelectedDate != null ||
        _historyTypeFilter != 'all';

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
                        color:
                            _historyTypeFilter == 'assigned'
                                ? Colors.white
                                : context.colors.textPrimary,
                        fontSize: 12,
                        fontWeight:
                            _historyTypeFilter == 'assigned'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      backgroundColor: context.colors.card,
                      side: BorderSide(
                        color:
                            _historyTypeFilter == 'assigned'
                                ? AppColors.primary
                                : context.colors.border,
                      ),
                      onSelected: (val) {
                        if (val)
                          setState(() => _historyTypeFilter = 'assigned');
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
                        color:
                            _historyTypeFilter == 'self'
                                ? Colors.white
                                : context.colors.textPrimary,
                        fontSize: 12,
                        fontWeight:
                            _historyTypeFilter == 'self'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      backgroundColor: context.colors.card,
                      side: BorderSide(
                        color:
                            _historyTypeFilter == 'self'
                                ? AppColors.primary
                                : context.colors.border,
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
                      final customerName =
                          item['customer_name'] as String? ?? 'Client';
                      final customerId = item['customer_id'] as int? ??
                          (item['customer'] is Map
                              ? (item['customer'] as Map)['id'] as int?
                              : null) ??
                          (item['client_id'] as int?) ??
                          0;
                      final profilePic =
                          item['customer_profile_picture'] as String? ??
                          item['profile_picture'] as String? ??
                          item['customer_image'] as String? ??
                          item['image_url'] as String? ??
                          (item['customer'] is Map
                              ? (item['customer'] as Map)['profile_picture']
                                  as String?
                              : null);
                      final workoutTitle =
                          item['workout_title'] as String? ?? 'Workout';
                      final verifiedAtRaw =
                          item['verified_at'] as String? ?? '';
                      final sessionId = item['session_id'] as int? ?? 0;
                      String verifiedAt = verifiedAtRaw;
                      if (verifiedAtRaw.isNotEmpty) {
                        final parsed = DateTime.tryParse(verifiedAtRaw);
                        if (parsed != null) {
                          final local = parsed.toLocal();
                          final hour =
                              local.hour == 0
                                  ? 12
                                  : (local.hour > 12
                                      ? local.hour - 12
                                      : local.hour);
                          final amPm = local.hour >= 12 ? 'PM' : 'AM';
                          verifiedAt =
                              '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:${local.minute.toString().padLeft(2, '0')} $amPm';
                        }
                      }
                      final status =
                          item['verification_status'] as String? ?? '';
                      final remarks = item['remarks'] as String? ?? '';
                      final isVerified = status == 'verified';

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
                                          isAssigned: _isAssignedWorkout(item),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      workoutTitle,
                                      style:
                                          AppStyles.text16Px.poppins.w600.dark,
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
                                      style: AppStyles.text12Px.poppins.w600
                                          .copyWith(
                                            color:
                                                isVerified
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (customerId > 0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder:
                                                (context) =>
                                                    TrainerClientDetailScreen(
                                                      customerId: customerId,
                                                    ),
                                          ),
                                        );
                                      }
                                    },
                                    child:
                                        profilePic != null &&
                                                profilePic.isNotEmpty
                                            ? ProfileImage(
                                              isEdit: false,
                                              url: profilePic,
                                              radius: 24,
                                            )
                                            : Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                size: 24,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      customerName,
                                      style: AppStyles.text14Px.poppins.w500
                                          .copyWith(color: AppColors.textDark),
                                    ),
                                  ),
                                  _buildWorkoutTypeBadge(item),
                                ],
                              ),
                              if (verifiedAt.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Date: $verifiedAt',
                                  style: AppStyles.text12Px.poppins.w400
                                      .copyWith(color: AppColors.textGrey),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          style: AppStyles.text12Px.poppins.w400
                                              .copyWith(
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
