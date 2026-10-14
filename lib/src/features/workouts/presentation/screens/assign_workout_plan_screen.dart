import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reports_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/core/services/holiday/gym_holiday_service.dart';

class AssignWorkoutPlanScreen extends StatefulWidget {
  final int planId;
  final String planTitle;

  const AssignWorkoutPlanScreen({
    required this.planId,
    required this.planTitle,
    super.key,
  });

  @override
  State<AssignWorkoutPlanScreen> createState() =>
      _AssignWorkoutPlanScreenState();
}

class _AssignWorkoutPlanScreenState extends State<AssignWorkoutPlanScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _customers = [];
  final Map<int, bool> _assigningMap =
      {}; // Tracks loading state per customer toggle

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      dynamic response;
      try {
        response = await DioClient().dio.get<dynamic>(
          ApiUris.assignSingleDayWorkout(widget.planId),
          queryParameters: {
            if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        response = await DioClient().dio.get<dynamic>(
          ApiUris.assignWorkoutPlan(widget.planId),
          queryParameters: {
            if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _customers =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load customers');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading customers: ${e.toString()}');
    }
  }

  Future<void> _assignWorkout(int customerId) async {
    final client = _customers.firstWhere(
      (c) => c['customer_id'] == customerId || c['id'] == customerId,
      orElse: () => <String, dynamic>{},
    );
    final int? clientOrgId =
        client['organization_id'] as int? ?? client['gym_id'] as int?;

    final titleController = TextEditingController(text: widget.planTitle);
    final notesController = TextEditingController();
    DateTime? selectedDate;
    String? holidayWarning;
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Assign Workout Title',
                style: AppStyles.text16Px.poppins.w600,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter workout title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        hintText: 'Trainer notes (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start Date (Optional)',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          final hol = await GymHolidayService.getHolidayName(
                            picked,
                            orgId: clientOrgId,
                            forceRefresh: true,
                          );
                          setStateDialog(() {
                            selectedDate = picked;
                            holidayWarning = hol;
                          });
                          if (hol != null) {
                            Dialogs.showSnack(
                              msg:
                                  'Selected date is a gym holiday ($hol). Workouts cannot be assigned on holidays.',
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                holidayWarning != null
                                    ? const Color(0xffD32F2F)
                                    : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                                    : 'Select start date (Default: Today)',
                                style: AppStyles.text14Px.poppins.w400.copyWith(
                                  color:
                                      selectedDate != null
                                          ? AppColors.textDark
                                          : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (holidayWarning != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xffEF5350).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xffD32F2F),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cannot assign workout: $holidayWarning is a gym holiday.',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: const Color(0xffD32F2F),
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
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, 'customize'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Customize',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, 'assign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Assign',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (action == null || action == 'cancel') return;

    if (action == 'assign') {
      final targetDate = selectedDate ?? DateTime.now();
      final isHol = await GymHolidayService.isHoliday(
        targetDate,
        orgId: clientOrgId,
        forceRefresh: true,
      );
      if (isHol) {
        Dialogs.showSnack(
          msg: 'Cannot assign workout: The selected date is a gym holiday.',
        );
        return;
      }
    }

    final enteredTitle = titleController.text.trim();
    final String finalTitle =
        enteredTitle.isNotEmpty ? enteredTitle : widget.planTitle;

    if (!mounted) return;
    setState(() {
      _assigningMap[customerId] = true;
    });

    try {
      final dio = DioClient().dio;

      if (action == 'customize') {
        final response = await dio.post<dynamic>(
          ApiUris.copyWorkoutPlan(widget.planId),
          data: {'is_assignment': true},
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data as Map<String, dynamic>;
          final newPlanId = data['id'] as int;
          if (!mounted) return;
          setState(() {
            _assigningMap[customerId] = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => WorkoutPlanDetailsScreen(
                    planId: newPlanId,
                    planTitle: finalTitle,
                    assignToCustomerId: customerId,
                  ),
            ),
          );
          return;
        } else {
          Dialogs.showSnack(msg: 'Failed to copy plan');
        }
        if (!mounted) return;
        setState(() {
          _assigningMap[customerId] = false;
        });
        return;
      }

      dynamic response;
      final payload = {
        'customer_id': customerId,
        'title': finalTitle,
        if (notesController.text.trim().isNotEmpty)
          'notes': notesController.text.trim(),
        if (selectedDate != null)
          'start_date':
              "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
      };

      try {
        response = await dio.post<dynamic>(
          ApiUris.assignSingleDayWorkout(widget.planId),
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        response = await dio.post<dynamic>(
          ApiUris.assignWorkoutPlan(widget.planId),
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      if (!mounted) return;
      setState(() {
        _assigningMap[customerId] = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        setState(() {
          for (var i = 0; i < _customers.length; i++) {
            if (_customers[i]['customer_id'] == customerId) {
              _customers[i]['is_assigned'] = true;
              break;
            }
          }
        });
        reportsRefreshTrigger.value++;
        Dialogs.showSnack(msg: 'Plan assigned successfully');
      } else {
        Dialogs.showSnack(msg: 'Failed to assign plan');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _assigningMap[customerId] = false;
      });
      String errorMsg = 'Error assigning plan';
      if (e.response?.data is Map) {
        errorMsg = (e.response!.data as Map)['error']?.toString() ??
            (e.response!.data as Map)['message']?.toString() ??
            (e.response!.data as Map)['detail']?.toString() ??
            errorMsg;
      }
      Dialogs.showSnack(msg: errorMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _assigningMap[customerId] = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  DateTime? _parseAnyDate(String? str) {
    if (str == null || str.isEmpty || str == 'null') return null;
    try {
      final trimmed = str.trim();
      if (trimmed.length >= 10 && trimmed[4] == '-' && trimmed[7] == '-') {
        final parts = trimmed.substring(0, 10).split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return DateTime.parse(trimmed);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _evaluateClientStatus(Map<String, dynamic> client) {
    final List<Map<String, dynamic>> allMemberships = [];

    final rawList = client['memberships'] ?? client['all_memberships'];
    if (rawList is List) {
      for (var item in rawList) {
        if (item is Map) {
          allMemberships.add(Map<String, dynamic>.from(item));
        }
      }
    }

    if (client['membership_details'] is Map) {
      allMemberships.add(
        Map<String, dynamic>.from(client['membership_details'] as Map),
      );
    }

    if (client['active_membership'] is Map) {
      allMemberships.add(
        Map<String, dynamic>.from(client['active_membership'] as Map),
      );
    }

    if (client['customer_membership'] is Map) {
      allMemberships.add(
        Map<String, dynamic>.from(client['customer_membership'] as Map),
      );
    }

    final bool? isActiveMember =
        client['is_active_member'] as bool? ??
        client['is_membership_active'] as bool?;
    final bool? isUserActive = client['is_active'] as bool?;

    DateTime? latestEndDate;
    String? latestStatus;

    final rootEndStr = (client['membership_end_date'] ??
            client['end_date'] ??
            client['expiry_date'] ??
            client['expire_date'] ??
            client['valid_to'])
        ?.toString();
    final parsedRootEnd = _parseAnyDate(rootEndStr);
    if (parsedRootEnd != null) {
      latestEndDate = parsedRootEnd;
    }

    final rootStatus = (client['membership_status'] ?? client['status'])
        ?.toString()
        .toLowerCase();
    if (rootStatus != null && rootStatus.isNotEmpty && rootStatus != 'null') {
      latestStatus = rootStatus;
    }

    for (var mem in allMemberships) {
      final endStr = (mem['end_date'] ??
              mem['membership_end_date'] ??
              mem['expiry_date'] ??
              mem['expire_date'] ??
              mem['valid_to'])
          ?.toString();
      final parsedEnd = _parseAnyDate(endStr);
      if (parsedEnd != null) {
        if (latestEndDate == null || parsedEnd.isAfter(latestEndDate)) {
          latestEndDate = parsedEnd;
        }
      }
      final status = (mem['status'] ?? mem['membership_status'])
          ?.toString()
          .toLowerCase();
      if (status != null && status.isNotEmpty && status != 'null') {
        latestStatus = status;
      }
    }

    final String resolvedStatus = (client['resolved_status'] ?? client['status'])
        ?.toString()
        .toLowerCase()
        .trim() ?? '';

    if (resolvedStatus == 'frozen' ||
        resolvedStatus == 'paused' ||
        resolvedStatus == 'hold' ||
        latestStatus == 'frozen' ||
        latestStatus == 'paused' ||
        latestStatus == 'hold') {
      return {
        'text': 'Frozen',
        'color': const Color(0xff0288D1),
        'bgColor': const Color(0xffE1F5FE),
        'isExpired': false,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (resolvedStatus == 'expired' ||
        latestStatus == 'expired' ||
        latestStatus == 'inactive' ||
        latestStatus == 'completed' ||
        isActiveMember == false ||
        isUserActive == false) {
      return {
        'text': 'Expired',
        'color': const Color(0xffD32F2F),
        'bgColor': const Color(0xffFFEBEE),
        'isExpired': true,
      };
    }

    if (latestEndDate != null) {
      final endDay = DateTime(
        latestEndDate.year,
        latestEndDate.month,
        latestEndDate.day,
      );
      if (endDay.isBefore(today)) {
        return {
          'text': 'Expired',
          'color': const Color(0xffD32F2F),
          'bgColor': const Color(0xffFFEBEE),
          'isExpired': true,
        };
      }
    }

    if (isActiveMember == true ||
        resolvedStatus == 'active' ||
        latestStatus == 'active' ||
        latestEndDate != null) {
      return {
        'text': 'Active',
        'color': const Color(0xff2E7D32),
        'bgColor': const Color(0xffE8F5E9),
        'isExpired': false,
      };
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const PopButton().center,
        titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
        title: Text('Assign: ${widget.planTitle}'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) {
                _searchQuery = q;
                EasyDebounce.debounce(
                  'assign_workout_search',
                  const Duration(milliseconds: 300),
                  () {
                    _fetchCustomers();
                  },
                );
              },
              decoration: InputDecoration(
                hintText: 'Search for client name',
                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                filled: false,
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xffF7F7F7),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _customers.isEmpty
                      ? const Center(child: Text('No customers found'))
                      : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _customers.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          final int customerId = customer['customer_id'] as int;
                          final String name = customer['name'] as String;
                          final String? mobile = customer['mobile'] as String?;
                          final String? pic =
                              customer['profile_picture'] as String?;
                          final bool isAssigned =
                              customer['is_assigned'] as bool? ?? false;
                          final bool isToggling =
                              _assigningMap[customerId] ?? false;
                          final statusInfo = _evaluateClientStatus(customer);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ProfileImage(
                                    isEdit: false,
                                    canViewFullImage: true,
                                    name: name,
                                    url: pic ?? '',
                                    radius: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              name,
                                              style: AppStyles
                                                  .text14Px
                                                  .poppins
                                                  .w500
                                                  .dark,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (statusInfo != null) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusInfo['bgColor']
                                                    as Color,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                statusInfo['text'] as String,
                                                style: AppStyles
                                                    .text10Px
                                                    .poppins
                                                    .w600
                                                    .copyWith(
                                                  color: statusInfo['color']
                                                      as Color,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (mobile != null &&
                                          mobile.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          mobile,
                                          style:
                                              AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w400
                                                  .textGrey,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                isToggling
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : ElevatedButton(
                                      onPressed:
                                          () => _assignWorkout(customerId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isAssigned
                                                ? const Color(0xffE2E2E2)
                                                : const Color(0xFFD30000),
                                        foregroundColor:
                                            isAssigned
                                                ? Colors.black87
                                                : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isAssigned ? 'Assign Again' : 'Assign',
                                        style: AppStyles.text12Px.poppins.w600,
                                      ),
                                    ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
