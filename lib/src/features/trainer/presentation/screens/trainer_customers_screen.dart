import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/assign_to_client_bottom_sheet.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_settings_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/components/sheets/filter_selection_sheet.dart';

class TrainerCustomersScreen extends StatefulWidget {
  final bool isPushed;
  final String initialStatusFilter;
  final bool hideStatusFilter;

  const TrainerCustomersScreen({
    super.key,
    this.isPushed = false,
    this.initialStatusFilter = 'all',
    this.hideStatusFilter = false,
  });

  @override
  State<TrainerCustomersScreen> createState() => _TrainerCustomersScreenState();
}

class _TrainerCustomersScreenState extends State<TrainerCustomersScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late String _statusFilter;

  List<({String label, String value})>? _selectedFilters;
  ({String label, String value})? _selectedSort;

  final _filterCategories = const [
    FilterCategory(
      title: 'Membership Status',
      isSingleSelect: true,
      items: [
        (label: 'Active', value: 'active'),
        (label: 'Frozen / Paused', value: 'frozen'),
        (label: 'Expired (Last 10 Days)', value: 'expired_10d'),
        (label: 'Expired', value: 'expired'),
        (label: 'Pending Fee', value: 'pending_fee'),
      ],
    ),
    FilterCategory(
      title: 'Gender',
      isSingleSelect: true,
      items: [
        (label: 'Male', value: 'male'),
        (label: 'Female', value: 'female'),
      ],
    ),
  ];

  final _sortOptions = const [
    (label: 'Joined Recently', value: 'recent'),
    (label: 'Joined First', value: 'oldest'),
    (label: 'Name: A-Z', value: 'a_z'),
    (label: 'Name: Z-A', value: 'z_a'),
  ];

  List<FilterCategory> get _sortAndFilterCategories => [
    FilterCategory(
      title: 'Sort by',
      isSingleSelect: true,
      items: _sortOptions,
    ),
    ..._filterCategories,
  ];

  void _openSortAndFilterSheet() {
    final initialSelected = <({String label, String value})>[
      if (_selectedSort != null) _selectedSort!,
      if (_selectedFilters != null) ..._selectedFilters!,
    ];

    FilterSelectionSheet(
      title: 'Sort & Filter',
      categories: _sortAndFilterCategories,
      selectedFilters: initialSelected.isNotEmpty ? initialSelected : null,
      onFilterSelected: (values) {
        if (values == null || values.isEmpty) {
          _selectedSort = null;
          _selectedFilters = null;
        } else {
          final sortValues = _sortOptions.map((e) => e.value).toSet();
          final selectedSortList =
              values.where((e) => sortValues.contains(e.value)).toList();
          _selectedSort =
              selectedSortList.isNotEmpty ? selectedSortList.first : null;
          _selectedFilters =
              values.where((e) => !sortValues.contains(e.value)).toList();
        }
        _fetchClients();
        if (!mounted) return;
        setState(() {});
      },
    ).show(context);
  }

  Widget _buildFilterIconButton() {
    final hasActiveFilter =
        _selectedSort != null || (_selectedFilters?.isNotEmpty ?? false);

    return Material(
      color: hasActiveFilter
          ? AppColors.primary.withValues(alpha: 0.08)
          : context.colors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _openSortAndFilterSheet,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasActiveFilter
                  ? AppColors.primary
                  : context.colors.border,
              width: hasActiveFilter ? 1.5 : 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 22,
                color: hasActiveFilter
                    ? AppColors.primary
                    : context.colors.textSecondary,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _nextUrl;
  int? _totalCount;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatusFilter;
    if (widget.initialStatusFilter != 'all') {
      final label = widget.initialStatusFilter == 'active'
          ? 'Active'
          : widget.initialStatusFilter == 'paused'
              ? 'Frozen / Paused'
              : widget.initialStatusFilter == 'expired'
                  ? 'Expired'
                  : widget.initialStatusFilter;
      _selectedFilters = [(label: label, value: widget.initialStatusFilter)];
    }
    _fetchClients();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchMoreClients();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients({bool forceRefresh = true}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _clients = [];
      _nextUrl = null;
      _totalCount = null;
    });

    String? status;
    String? gender;
    bool? pendingFee;

    if (_selectedFilters != null && _selectedFilters!.isNotEmpty) {
      for (final f in _selectedFilters!) {
        if (f.value == 'male' || f.value == 'female') {
          gender = f.value;
        } else if (f.value == 'pending_fee') {
          pendingFee = true;
          status = 'pending_fee';
        } else {
          status = f.value;
        }
      }
    } else if (_statusFilter != 'all') {
      status = _statusFilter;
    }

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
          if (gender != null) 'gender': gender,
          if (pendingFee == true) 'pending_fee': 'true',
          if (_selectedSort != null) 'sort': _selectedSort!.value,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> results = [];
        int? count;
        if (data is Map) {
          results = List<dynamic>.from(data['results'] as List? ?? []);
          _nextUrl = data['next']?.toString();
          if (data['count'] != null) {
            count = int.tryParse(data['count'].toString());
          }
        } else if (data is List) {
          results = data;
          _nextUrl = null;
          count = data.length;
        }

        if (!mounted) return;
        setState(() {
          _clients =
              results.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _totalCount = count;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load clients');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading clients: ${e.toString()}');
    }
  }

  Future<void> _fetchMoreClients() async {
    if (_isFetchingMore || _nextUrl == null || !mounted) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        _nextUrl!,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> results = [];
        if (data is Map) {
          results = List<dynamic>.from(data['results'] as List? ?? []);
          _nextUrl = data['next']?.toString();
          if (data['count'] != null) {
            _totalCount = int.tryParse(data['count'].toString()) ?? _totalCount;
          }
        } else if (data is List) {
          results = data;
          _nextUrl = null;
        }

        if (!mounted) return;
        setState(() {
          _clients.addAll(
            results.map((e) => Map<String, dynamic>.from(e as Map)),
          );
          _isFetchingMore = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  bool get _shouldHideFilter =>
      widget.hideStatusFilter || widget.initialStatusFilter == 'active';

  List<Map<String, dynamic>> get _filteredClients => _clients;

  DateTime? _parseAnyDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'N/A') return null;

    final iso = DateTime.tryParse(str);
    if (iso != null) return iso;

    final formats = [
      'yyyy-MM-dd',
      'dd MMM yyyy',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'yyyy/MM/dd',
      'dd MMMM yyyy',
      'MMM dd, yyyy',
      'MM/dd/yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(str);
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic> _evaluateClientStatus(Map<String, dynamic> client) {
    final List<Map<String, dynamic>> allMemberships = [];

    if (client['membership'] is Map) {
      allMemberships.add(Map<String, dynamic>.from(client['membership'] as Map));
    } else if (client['membership'] is List) {
      for (var m in client['membership'] as List) {
        if (m is Map) allMemberships.add(Map<String, dynamic>.from(m as Map));
      }
    }

    if (client['memberships'] is List) {
      for (var m in client['memberships'] as List) {
        if (m is Map) allMemberships.add(Map<String, dynamic>.from(m as Map));
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

    // Direct Boolean Flags
    final bool? isActiveMember =
        client['is_active_member'] as bool? ??
        client['is_membership_active'] as bool?;
    final bool? isUserActive = client['is_active'] as bool?;

    DateTime? latestEndDate;
    String? latestStatus;

    // Check root client fields
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

    // Check frozen / paused / hold
    if (resolvedStatus == 'frozen' ||
        resolvedStatus == 'paused' ||
        resolvedStatus == 'hold' ||
        latestStatus == 'frozen' ||
        latestStatus == 'paused' ||
        latestStatus == 'hold') {
      final isFrozen = resolvedStatus == 'frozen' || latestStatus == 'frozen';
      return {
        'text': isFrozen ? 'Frozen' : 'Paused',
        'color': const Color(0xff0288D1),
        'bgColor': const Color(0xffE1F5FE),
        'isExpired': false,
      };
    }

    // Check pending fee
    if (resolvedStatus == 'pending_fee' ||
        (client['payment_status']?.toString().toLowerCase() == 'pending')) {
      return {
        'text': 'Fee Due',
        'color': const Color(0xffE65100),
        'bgColor': const Color(0xffFFF3E0),
        'isExpired': false,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. If explicit status says expired / inactive / completed
    if (resolvedStatus == 'expired' ||
        latestStatus == 'expired' ||
        latestStatus == 'inactive' ||
        latestStatus == 'completed' ||
        isActiveMember == false) {
      if (latestEndDate != null) {
        final endDay = DateTime(
          latestEndDate.year,
          latestEndDate.month,
          latestEndDate.day,
        );
        final diff = endDay.difference(today).inDays;
        if (diff < 0 && diff >= -30) {
          return {
            'text': 'Expired ${-diff} days ago',
            'color': Colors.red,
            'bgColor': Colors.red.shade50,
            'isExpired': true,
          };
        }
      }
      return {
        'text': 'Expired',
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
        'isExpired': true,
      };
    }

    // 2. If we have a membership end date, check diff
    if (latestEndDate != null) {
      final endDay = DateTime(
        latestEndDate.year,
        latestEndDate.month,
        latestEndDate.day,
      );
      final diff = endDay.difference(today).inDays;

      if (diff < 0) {
        return {
          'text': diff >= -30 ? 'Expired ${-diff} days ago' : 'Expired',
          'color': Colors.red,
          'bgColor': Colors.red.shade50,
          'isExpired': true,
        };
      } else if (diff == 0) {
        return {
          'text': 'Expires today',
          'color': Colors.orange.shade800,
          'bgColor': Colors.orange.shade50,
          'isExpired': false,
        };
      } else if (diff <= 10) {
        return {
          'text': 'Expire in $diff days',
          'color': Colors.orange.shade800,
          'bgColor': Colors.orange.shade50,
          'isExpired': false,
        };
      }
    }

    if (isUserActive == false) {
      return {
        'text': 'Expired',
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
        'isExpired': true,
      };
    }

    return {
      'text': 'Active',
      'color': const Color(0xff27AE60),
      'bgColor': const Color(0xffE2F6EA),
      'isExpired': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.isPushed ? const PopButton().center : null,
        centerTitle: false,
        title: Text('Clients', style: AppStyles.text20Px.poppins.w600.dark),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerProfileSettingsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.settings_outlined,
              color: context.colors.icon,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        if (!mounted) return;
                        setState(() {
                          _searchQuery = val;
                        });
                        EasyDebounce.debounce(
                          'clients-search',
                          const Duration(milliseconds: 400),
                          () => _fetchClients(),
                        );
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: context.colors.textSecondary),
                        hintText: 'Search for name or phone number',
                        fillColor: context.colors.card,
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (!_shouldHideFilter) ...[
                  const SizedBox(width: 10),
                  _buildFilterIconButton(),
                ],
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '${_totalCount ?? filtered.length} members',
              style: AppStyles.text14Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ),

          // 5. Clients list
          Expanded(
            child:
                _isLoading
                    ? _buildClientsShimmer()
                    : filtered.isEmpty
                    ? Center(
                      child: Text(
                        'No clients found!',
                        style: AppStyles.text14Px.poppins.w400.dark,
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () => _fetchClients(forceRefresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: filtered.length + (_isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final client = filtered[index];
                          final bool isAssignedToMe =
                              client['is_assigned_to_me'] as bool? ?? false;
                          final int customerId = client['customer_id'] as int;
                          final String name =
                              client['name'] as String? ?? 'N/A';
                          final String? pic =
                              client['profile_picture'] as String?;
                          final String category =
                              client['category'] as String? ?? 'Strength';
                          final String orgName =
                              client['organization_name'] as String? ??
                              'Direct Client';
                          final String goal =
                              client['target_goal'] as String? ??
                              'General Fitness';

                          final statusInfo = _evaluateClientStatus(client);
                          final String statusText = statusInfo['text'] as String;
                          final Color statusColor = statusInfo['color'] as Color;
                          final Color statusBgColor = statusInfo['bgColor'] as Color;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.colors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : .02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder:
                                        (context) => TrainerClientDetailScreen(
                                          customerId: customerId,
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchClients(forceRefresh: true);
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row
                                  Row(
                                    children: [
                                      // Profile picture
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.iconBackground,
                                        ),
                                        child: ClipOval(
                                          child:
                                              pic != null
                                                  ? Image.network(
                                                    pic,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                              Icons.person,
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                  )
                                                  : const Icon(
                                                    Icons.person,
                                                    color: AppColors.primary,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Name and Category
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: AppStyles
                                                  .text14Px
                                                  .poppins
                                                  .w600
                                                  .copyWith(
                                                    color: context.colors.textPrimary,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              category,
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color: context.colors.textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Active Status Mark
                                      Text(
                                        statusText,
                                        style: AppStyles.text12Px.poppins.w500
                                            .copyWith(color: statusColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Bottom Row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Org Name and Goal
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              orgName,
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color: context.colors.textSecondary,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Goal: $goal',
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color: context.colors.textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Assign Workout
                                      if (!isAssignedToMe)
                                        OutlinedButton(
                                          onPressed:
                                              () => _showAssignPlanBottomSheet(
                                                context,
                                                client,
                                              ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xffE2F6EA,
                                            ),
                                            side: BorderSide(
                                              color: Colors.green.shade700,
                                              width: 1.5,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            'Assign Workout',
                                            style: AppStyles
                                                .text12Px
                                                .poppins
                                                .w500
                                                .copyWith(
                                                  color: Colors.green.shade700,
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
          ),
        ],
      ),
    );
  }

  void _showAssignPlanBottomSheet(
    BuildContext context,
    Map<String, dynamic> client,
  ) {
    final int customerId = client['customer_id'] as int;
    final String name = client['name'] as String? ?? 'N/A';
    final bool isAssignedToMe = client['is_assigned_to_me'] as bool? ?? false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AssignPlanBottomSheetContent(
          customerId: customerId,
          customerName: name,
          isAssignedToMe: isAssignedToMe,
          onSuccess: () {
            _fetchClients(forceRefresh: true);
          },
        );
      },
    );
  }

  Widget _buildClientsShimmer() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KShimmer(width: 48, height: 48, radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        KShimmer(width: 120, height: 14, radius: 4),
                        SizedBox(height: 6),
                        KShimmer(width: 70, height: 12, radius: 4),
                      ],
                    ),
                  ),
                  const KShimmer(width: 50, height: 14, radius: 4),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KShimmer(width: 110, height: 12, radius: 4),
                      SizedBox(height: 4),
                      KShimmer(width: 90, height: 12, radius: 4),
                    ],
                  ),
                  KShimmer(width: 110, height: 32, radius: 16),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class TrainerQuickActionsSheet extends StatelessWidget {
  const TrainerQuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: AppStyles.text20Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _ActionCard(
            icon: Icons.assignment_outlined,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFFFF5722),
            title: 'Create Workout Plan',
            subtitle: 'Create/Assign Plan',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const WorkoutGroupsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.currency_rupee,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFFFFC107),
            title: 'Create Package',
            subtitle: 'Record recurring or variable costs',
            onTap: () {
              Navigator.pop(context);
              Dialogs.showSnack(msg: 'Create Package triggered');
            },
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.fitness_center,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFF4CAF50),
            title: 'Assign Workouts',
            subtitle: 'Assign workout plans to clients',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const WorkoutGroupsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFD30000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? context.colors.fieldFill : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.text16Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignPlanBottomSheetContent extends StatefulWidget {
  final int customerId;
  final String customerName;
  final bool isAssignedToMe;
  final VoidCallback onSuccess;

  const _AssignPlanBottomSheetContent({
    required this.customerId,
    required this.customerName,
    required this.isAssignedToMe,
    required this.onSuccess,
  });

  @override
  State<_AssignPlanBottomSheetContent> createState() =>
      _AssignPlanBottomSheetContentState();
}

class _AssignPlanBottomSheetContentState
    extends State<_AssignPlanBottomSheetContent> {
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Map<int, bool> _submittingMap = {};
  final Map<int, bool> _assigningMap = {};
  String _selectedSource = 'gym'; // 'gym' or 'trainer'

  int? _selectedGroupId;
  String? _selectedGroupName;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _groups = [];
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutGroups,
        queryParameters: {
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (response.data['results'] as List<dynamic>? ?? [])
                : (response.data as List<dynamic>);
        if (!mounted) return;

        final allGroups =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        // Filter groups based on source
        final filteredGroups =
            allGroups.where((g) {
              final src = g['source']?.toString();
              if (_selectedSource == 'gym') {
                return src == 'gym' || src == 'organization';
              } else {
                return src == 'trainer';
              }
            }).toList();

        setState(() {
          _groups = filteredGroups;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load workout groups');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading groups: ${e.toString()}');
    }
  }

  Future<void> _fetchPlans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _plans = [];
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutPlans,
        queryParameters: {
          'source': _selectedSource,
          if (_selectedGroupId != null) 'group': _selectedGroupId,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _plans =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load plans');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading plans: ${e.toString()}');
    }
  }

  Future<void> _assignPlan(int planId, String planName) async {
    final titleController = TextEditingController(text: planName);
    final notesController = TextEditingController();
    DateTime? selectedDate;
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
              content: Column(
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
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDate != null
                                  ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                  child: Text(
                    'Cancel',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'customize'),
                  child: Text(
                    'Customize',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, 'assign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
            );
          },
        );
      },
    );

    if (action == null || action == 'cancel') return;

    final enteredTitle = titleController.text.trim();
    final String finalTitle = enteredTitle.isNotEmpty ? enteredTitle : planName;

    if (!mounted) return;
    setState(() {
      _submittingMap[planId] = true;
      _assigningMap[widget.customerId] = true;
    });

    try {
      final dio = DioClient().dio;

      if (action == 'customize') {
        final response = await dio.post<dynamic>(
          ApiUris.copyWorkoutPlan(planId),
          data: {'is_assignment': true},
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data as Map<String, dynamic>;
          final newPlanId = data['id'] as int;
          if (!mounted) return;
          setState(() {
            _submittingMap[planId] = false;
            _assigningMap[widget.customerId] = false;
          });
          // ignore: use_build_context_synchronously
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => WorkoutPlanDetailsScreen(
                    planId: newPlanId,
                    planTitle: finalTitle,
                    assignToCustomerId: widget.customerId,
                  ),
            ),
          );
          return;
        } else {
          Dialogs.showSnack(msg: 'Failed to copy plan');
        }
        if (!mounted) return;
        setState(() {
          _submittingMap[planId] = false;
          _assigningMap[widget.customerId] = false;
        });
        return;
      }

      // 2. Assign workout plan directly — backend resolves trainer from auth token
      final response = await dio.post<dynamic>(
        ApiUris.assignWorkoutPlan(planId),
        data: {
          'customer_id': widget.customerId,
          'title': finalTitle,
          if (notesController.text.trim().isNotEmpty)
            'notes': notesController.text.trim(),
          if (selectedDate != null)
            'start_date':
                "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (!mounted) return;
      setState(() {
        _submittingMap[planId] = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Plan assigned successfully');
        Navigator.pop(context);
        widget.onSuccess();
      } else {
        Dialogs.showSnack(msg: 'Failed to assign plan');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _submittingMap[planId] = false;
      });
      String errorMsg = 'Error assigning plan';
      if (e.response?.data is Map) {
        errorMsg = (e.response!.data as Map)['error']?.toString() ?? errorMsg;
      }
      Dialogs.showSnack(msg: errorMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submittingMap[planId] = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  Future<void> _createInstantWorkout() async {
    final titleController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'New Instant Workout',
              style: AppStyles.text16Px.poppins.w600,
            ),
            content: TextField(
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Create',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final String finalTitle = titleController.text.trim();
    if (finalTitle.isEmpty) {
      Dialogs.showSnack(msg: 'Please enter a workout title');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = DioClient().dio;
      final response = await dio.post<dynamic>(
        ApiUris.workoutPlans,
        data: {
          'plan_name': finalTitle,
          'group': null,
          'total_weeks': 1,
          'total_days': 1,
          'source': 'trainer',
          'is_preset': false,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final int newPlanId = data['id'] as int;
        final String newPlanTitle = data['plan_name'] as String? ?? finalTitle;

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Close the Assign Plan bottom sheet
        Navigator.pop(context);

        // Go to workout details screen to add/edit exercises
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder:
                (context) => WorkoutPlanDetailsScreen(
                  planId: newPlanId,
                  planTitle: newPlanTitle,
                  assignToCustomerId: widget.customerId,
                  isInstantWorkout: true,
                ),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to create instant workout plan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error creating instant workout: ${e.toString()}');
    }
  }

  Widget _buildTabButton(String label, String sourceValue) {
    final isSelected = _selectedSource == sourceValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedSource != sourceValue) {
            if (!mounted) return;
            setState(() {
              _selectedSource = sourceValue;
              _selectedGroupId = null;
              _selectedGroupName = null;
            });
            _fetchGroups();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Assign Workout to ${widget.customerName}',
                      style: AppStyles.text18Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTabButton('Library', 'gym'),
                  const SizedBox(width: 12),
                  _buildTabButton('Own Created', 'trainer'),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) {
                  _searchQuery = val;
                  EasyDebounce.debounce(
                    'assign_sheet_plans_search',
                    const Duration(milliseconds: 300),
                    () {
                      if (_selectedGroupId == null) {
                        _fetchGroups();
                      } else {
                        _fetchPlans();
                      }
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText:
                      _selectedGroupId == null
                          ? 'Search for workout group'
                          : 'Search for workout plan',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedGroupId != null) ...[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedGroupId = null;
                          _selectedGroupName = null;
                          _searchQuery = '';
                        });
                        _fetchGroups();
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Group: $_selectedGroupName',
                        style: AppStyles.text14Px.poppins.w600.dark,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (_selectedGroupId == null
                            ? (_groups.isEmpty
                                ? Center(
                                  child: Text(
                                    'No workout groups found',
                                    style: AppStyles.text14Px.poppins.w400
                                        .copyWith(color: AppColors.textGrey),
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: _groups.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final group = _groups[index];
                                    final int groupId = group['id'] as int;
                                    final String groupTitle =
                                        group['name'] as String? ?? 'General';
                                    final String groupType =
                                        group['type'] == 'single_day'
                                            ? 'Single Day'
                                            : 'Multi Day';
                                    final int planCount =
                                        group['plans_count'] as int? ?? 0;

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedGroupId = groupId;
                                          _selectedGroupName = groupTitle;
                                          _searchQuery = '';
                                        });
                                        _fetchPlans();
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderGrey,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    groupTitle,
                                                    style:
                                                        AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w600
                                                            .dark,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '$groupType • $planCount plans',
                                                    style: AppStyles
                                                        .text12Px
                                                        .poppins
                                                        .w400
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .textGrey,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: AppColors.textGrey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ))
                            : (_plans.isEmpty
                                ? Center(
                                  child: Text(
                                    'No workout plans found in this group',
                                    style: AppStyles.text14Px.poppins.w400
                                        .copyWith(color: AppColors.textGrey),
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: _plans.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final plan = _plans[index];
                                    final int planId = plan['id'] as int;
                                    final String planName =
                                        plan['plan_name'] as String;
                                    final int exerciseCount =
                                        plan['exercise_count'] as int? ?? 0;
                                    final bool isSubmitting =
                                        _submittingMap[planId] ?? false;

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (context) =>
                                                WorkoutPlanDetailsScreen(
                                                  planId: planId,
                                                  planTitle: planName,
                                                  assignToCustomerId:
                                                      widget.customerId,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.borderGrey,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    planName,
                                                    style: AppStyles.text14Px
                                                        .poppins.w600.dark,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Exercises: $exerciseCount',
                                                    style: AppStyles.text12Px
                                                        .poppins.w400
                                                        .copyWith(
                                                      color:
                                                          AppColors.textGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            isSubmitting
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    onPressed: () =>
                                                        _assignPlan(
                                                      planId,
                                                      planName,
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                        0xFF2E7D32,
                                                      ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    child: Text(
                                                      'Assign',
                                                      style: AppStyles
                                                          .text12Px
                                                          .poppins
                                                          .w600,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ))),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _createInstantWorkout,
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  'Create Workout',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
