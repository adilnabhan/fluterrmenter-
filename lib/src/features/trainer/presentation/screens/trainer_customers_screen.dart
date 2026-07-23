import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/assign_to_client_bottom_sheet.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_settings_screen.dart';

class TrainerCustomersScreen extends StatefulWidget {
  final bool isPushed;
  final String initialStatusFilter;

  const TrainerCustomersScreen({
    super.key,
    this.isPushed = false,
    this.initialStatusFilter = 'all',
  });

  @override
  State<TrainerCustomersScreen> createState() => _TrainerCustomersScreenState();
}

class _TrainerCustomersScreenState extends State<TrainerCustomersScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late String _statusFilter;
  String _selectedGymFilter = 'All'; // Selected gym capsule filter

  String? _nextUrl;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  // Static cache to avoid refetching on every screen visit
  static List<Map<String, dynamic>>? _cachedClients;
  static String? _cachedNextUrl;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatusFilter;
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

  Future<void> _fetchClients({bool forceRefresh = false}) async {
    if (!mounted) return;

    if (!forceRefresh &&
        _cachedClients != null &&
        _searchQuery.trim().isEmpty &&
        _statusFilter == 'all') {
      setState(() {
        _clients = List.from(_cachedClients!);
        _nextUrl = _cachedNextUrl;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      if (forceRefresh) {
        _clients = [];
        _nextUrl = null;
      }
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        queryParameters: {
          'status': _statusFilter,
          'page_size': 10000,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> results = [];
        if (data is Map) {
          results = List<dynamic>.from(data['results'] as List? ?? []);
          _nextUrl = data['next']?.toString();
        } else if (data is List) {
          results = data;
          _nextUrl = null;
        }

        if (!mounted) return;
        setState(() {
          _clients =
              results.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;

          // Cache the baseline data
          if (_searchQuery.trim().isEmpty && _statusFilter == 'all') {
            _cachedClients = List.from(_clients);
            _cachedNextUrl = _nextUrl;
          }
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

  List<String> get _gymFilters {
    final Set<String> gyms = {'All'};
    for (var client in _clients) {
      final orgName = client['organization_name'] as String?;
      if (orgName != null && orgName.isNotEmpty) {
        gyms.add(orgName);
      }
    }
    return gyms.toList();
  }

  List<Map<String, dynamic>> get _filteredClients {
    return _clients.where((client) {
      final orgName = client['organization_name'] ?? 'Direct Client';
      if (_selectedGymFilter != 'All' && orgName != _selectedGymFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGrey),
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
                  icon: const Icon(Icons.search, color: AppColors.textGrey),
                  hintText: 'Search for name or phone number',
                  fillColor: Colors.white,
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Horizontal Gym Selection Chips
          if (_clients.isNotEmpty)
            Container(
              height: 32,
              margin: const EdgeInsets.only(top: 14, bottom: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children:
                    _gymFilters.map((gymName) {
                      final isSelected = _selectedGymFilter == gymName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            if (!mounted) return;
                            setState(() {
                              _selectedGymFilter = gymName;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                gymName,
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

          // 3. Sub-filter Chips (Filter and Active Clients)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (!mounted) return;
                    setState(() {
                      _statusFilter = value;
                    });
                    _fetchClients();
                  },
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'all',
                          child: Text(
                            'All Clients',
                            style: AppStyles.text12Px.poppins.copyWith(
                              fontWeight:
                                  _statusFilter == 'all'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  _statusFilter == 'all'
                                      ? AppColors.primary
                                      : AppColors.textDark,
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'active',
                          child: Text(
                            'Active Clients',
                            style: AppStyles.text12Px.poppins.copyWith(
                              fontWeight:
                                  _statusFilter == 'active'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  _statusFilter == 'active'
                                      ? AppColors.primary
                                      : AppColors.textDark,
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'expired',
                          child: Text(
                            'Expired Clients',
                            style: AppStyles.text12Px.poppins.copyWith(
                              fontWeight:
                                  _statusFilter == 'expired'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  _statusFilter == 'expired'
                                      ? AppColors.primary
                                      : AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _statusFilter != 'all'
                              ? const Color(0xffFFEAEA)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _statusFilter != 'all'
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 13,
                          color:
                              _statusFilter != 'all'
                                  ? AppColors.primary
                                  : AppColors.textDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _statusFilter == 'all'
                              ? 'Filter'
                              : _statusFilter == 'active'
                              ? 'Active Clients'
                              : 'Expired Clients',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color:
                                _statusFilter != 'all'
                                    ? AppColors.primary
                                    : AppColors.textDark,
                          ),
                        ),
                        if (_statusFilter != 'all') ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              if (!mounted) return;
                              setState(() {
                                _statusFilter = 'all';
                              });
                              _fetchClients();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: AppColors.textDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Member Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '${filtered.length} members',
              style: AppStyles.text14Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ),

          // 5. Clients list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
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

                          String statusText = 'Active';
                          Color statusColor = const Color(0xff27AE60);
                          Color statusBgColor = const Color(0xffE2F6EA);

                          final membershipEndDateStr =
                              client['membership_end_date'] as String? ??
                              (client['membership'] as Map?)?['end_date']
                                  as String?;
                          if (membershipEndDateStr != null &&
                              membershipEndDateStr.isNotEmpty) {
                            final endDate = DateTime.tryParse(
                              membershipEndDateStr,
                            );
                            if (endDate != null) {
                              final now = DateTime.now();
                              final today = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              final end = DateTime(
                                endDate.year,
                                endDate.month,
                                endDate.day,
                              );
                              final diff = end.difference(today).inDays;

                              if (diff < 0) {
                                if (diff >= -30) {
                                  statusText = 'Expired ${-diff} days ago';
                                } else {
                                  statusText = 'Expired';
                                }
                                statusColor = Colors.red;
                                statusBgColor = Colors.red.shade50;
                              } else if (diff <= 10) {
                                statusText =
                                    diff == 0
                                        ? 'Expires today'
                                        : 'Expire in $diff days';
                                statusColor = Colors.orange.shade800;
                                statusBgColor = Colors.orange.shade50;
                              }
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .02),
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
                                              style:
                                                  AppStyles
                                                      .text14Px
                                                      .poppins
                                                      .w600
                                                      .dark,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              category,
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color: AppColors.dark,
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
                                                    color: AppColors.dark,
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
                                                    color: AppColors.dark,
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
}

class TrainerQuickActionsSheet extends StatelessWidget {
  const TrainerQuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: AppStyles.text20Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          // TODO: Uncomment when 'Add Client Directly' feature is needed
          /*
          _ActionCard(
            icon: Icons.person_add_alt_1,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFF1877F2),
            title: 'Add Client Directly',
            subtitle: 'Quick registration',
            onTap: () {
              Navigator.pop(context);
              final orgId = context.read<AppCubit>().state.currentUser?.mentor?.org?.id;
              if (orgId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder:
                        (context) => BlocProvider(
                          create: (context) => MembersAndLeadsCubit(orgId: orgId),
                          child: AddOrEditMemeberScreen(orgId: orgId),
                        ),
                  ),
                );
              } else {
                Dialogs.showSnack(msg: 'Your gym/organization is not configured yet.');
              }
            },
          ),
          const SizedBox(height: 16),
          */
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
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
  bool _isLoading = true;
  String _searchQuery = '';
  final Map<int, bool> _submittingMap = {};
  final Map<int, bool> _assigningMap = {};
  String _selectedSource = 'gym'; // 'gym' or 'trainer'

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutPlans,
        queryParameters: {
          'source': _selectedSource,
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

    if (!context.mounted) return;
    final trainerId = context.read<AppCubit>().state.currentUser?.mentor?.id;
    if (trainerId == null) {
      Dialogs.showSnack(msg: 'Trainer profile not found.');
      return;
    }

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
            _assigningMap[widget.customerId] = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.push(
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
      builder: (dialogContext) => AlertDialog(
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
            builder: (context) => WorkoutPlanDetailsScreen(
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
            });
            _fetchPlans();
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
                    () => _fetchPlans(),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search for workout plan',
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
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _plans.isEmpty
                    ? Center(
                      child: Text(
                        'No workout plans found',
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _plans.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        final int planId = plan['id'] as int;
                        final String planName = plan['plan_name'] as String;
                        final String groupName =
                            plan['group_name'] as String? ?? 'General';
                        final int exerciseCount =
                            plan['exercise_count'] as int? ?? 0;
                        final bool isSubmitting =
                            _submittingMap[planId] ?? false;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      planName,
                                      style:
                                          AppStyles.text14Px.poppins.w600.dark,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Group: $groupName | Exercises: $exerciseCount',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              isSubmitting
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : ElevatedButton(
                                    onPressed:
                                        () => _assignPlan(planId, planName),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Assign',
                                      style: AppStyles.text12Px.poppins.w600,
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
