import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';

class TrainerCustomersScreen extends StatefulWidget {
  const TrainerCustomersScreen({super.key});

  @override
  State<TrainerCustomersScreen> createState() => _TrainerCustomersScreenState();
}

class _TrainerCustomersScreenState extends State<TrainerCustomersScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'active' or 'all'
  String _selectedGymFilter = 'All'; // Selected gym capsule filter

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        queryParameters: {
          'status': _statusFilter,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (List<dynamic>.from((response.data as Map)['results'] as List? ?? []))
            : (response.data as List<dynamic>);
        setState(() {
          _clients = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load clients');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading clients: ${e.toString()}');
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
        centerTitle: false,
        title: Text(
          'Clients',
          style: AppStyles.text20Px.poppins.w600.dark,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Dialogs.showSnack(msg: 'Settings triggered');
            },
            icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<dynamic>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const _TrainerQuickActionsSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) {
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
                  hintText: 'Search for name or phone number',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // 2. Horizontal Gym Selection Chips
          if (_clients.isNotEmpty)
            Container(
              height: 38,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _gymFilters.map((gymName) {
                  final isSelected = _selectedGymFilter == gymName;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGymFilter = gymName;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            gymName,
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: isSelected ? Colors.white : AppColors.textDark,
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _statusFilter = _statusFilter == 'active' ? 'all' : 'active';
                    });
                    _fetchClients();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_outlined, size: 13, color: AppColors.textDark),
                        const SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: AppStyles.text12Px.poppins.w600.dark,
                        ),
                        if (_statusFilter == 'active') ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.close, size: 12, color: AppColors.textDark),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_statusFilter == 'active') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFEAEA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Active Clients',
                          style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _statusFilter = 'all';
                            });
                            _fetchClients();
                          },
                          child: const Icon(Icons.close, size: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 4. Member Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${filtered.length} members',
              style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
            ),
          ),

          // 5. Clients list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No clients found!',
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchClients,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final client = filtered[index];
                            final bool isAssignedToMe = client['is_assigned_to_me'] as bool? ?? false;
                            final int customerId = client['customer_id'] as int;
                            final String name = client['name'] as String? ?? 'N/A';
                            final String? pic = client['profile_picture'] as String?;
                            final String category = client['category'] as String? ?? 'Strength';
                            final String orgName = client['organization_name'] as String? ?? 'Direct Client';
                            final String goal = client['target_goal'] as String? ?? 'General Fitness';
                            final String lastActive = client['last_active'] as String? ?? '05:30 AM';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.push<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                      builder: (context) => TrainerClientDetailScreen(customerId: customerId),
                                    ),
                                  );
                                  _fetchClients();
                                },
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Profile picture
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.iconBackground,
                                        ),
                                        child: ClipOval(
                                          child: pic != null
                                              ? Image.network(
                                                  pic,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(Icons.person, color: AppColors.primary),
                                                )
                                              : const Icon(Icons.person, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Middle Column: Name, Specialty, Gym, Goal
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: AppStyles.text14Px.poppins.w600.dark,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  category,
                                                  style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  orgName,
                                                  style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Goal: $goal',
                                              style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Right Column: Assign/Active, Last Active
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (isAssignedToMe)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffE2F6EA),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                'Active',
                                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                                  color: const Color(0xff27AE60),
                                                ),
                                              ),
                                            )
                                          else
                                            OutlinedButton(
                                              onPressed: () => _showAssignPlanBottomSheet(context, client),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color(0xFF27AE60), width: 1),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                'Assign Workout',
                                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                                  color: const Color(0xFF27AE60),
                                                ),
                                              ),
                                            ),
                                          // Last Active
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Last Active ',
                                                style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                              ),
                                              Text(
                                                lastActive,
                                                style: AppStyles.text12Px.poppins.w600.dark,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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



  void _showAssignPlanBottomSheet(BuildContext context, Map<String, dynamic> client) {
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
            _fetchClients();
          },
        );
      },
    );
  }
}

class _TrainerQuickActionsSheet extends StatelessWidget {
  const _TrainerQuickActionsSheet();

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
                    builder: (context) => AddOrEditMemeberScreen(orgId: orgId),
                  ),
                );
              } else {
                Dialogs.showSnack(msg: 'Your gym/organization is not configured yet.');
              }
            },
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.work_outline,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFFFF9800),
            title: 'Look for Job Offers',
            subtitle: 'Record recurring or variable costs',
            onTap: () {
              Navigator.pop(context);
              Dialogs.showSnack(msg: 'Look for Job Offers triggered');
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
  State<_AssignPlanBottomSheetContent> createState() => _AssignPlanBottomSheetContentState();
}

class _AssignPlanBottomSheetContentState extends State<_AssignPlanBottomSheetContent> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Map<int, bool> _submittingMap = {};
  String _selectedSource = 'library'; // 'library' or 'trainer'

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
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
        setState(() {
          _plans = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load plans');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading plans: ${e.toString()}');
    }
  }

  Future<void> _assignPlan(int planId, String planName) async {
    final titleController = TextEditingController(text: planName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Assign Workout Title',
            style: AppStyles.text16Px.poppins.w600,
          ),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter workout title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel', style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Assign', style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final enteredTitle = titleController.text.trim();
    final String finalTitle = enteredTitle.isNotEmpty ? enteredTitle : planName;

    final trainerId = context.read<AppCubit>().state.currentUser?.mentor?.id;
    if (trainerId == null) {
      Dialogs.showSnack(msg: 'Trainer profile not found.');
      return;
    }

    setState(() {
      _submittingMap[planId] = true;
    });

    try {
      // Assign workout plan directly — backend resolves trainer from auth token
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.assignWorkoutPlan(planId),
        data: {
          'customer_id': widget.customerId,
          'title': finalTitle,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

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
      setState(() {
        _submittingMap[planId] = false;
      });
      String errorMsg = 'Error assigning plan';
      if (e.response?.data is Map) {
        errorMsg = (e.response!.data as Map)['error']?.toString() ?? errorMsg;
      }
      Dialogs.showSnack(msg: errorMsg);
    } catch (e) {
      setState(() {
        _submittingMap[planId] = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  Widget _buildTabButton(String label, String sourceValue) {
    final isSelected = _selectedSource == sourceValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedSource != sourceValue) {
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
      child: Column(
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
              _buildTabButton('Library', 'library'),
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
              hintStyle: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _plans.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final int planId = plan['id'] as int;
                          final String planName = plan['plan_name'] as String;
                          final String groupName = plan['group_name'] as String? ?? 'General';
                          final int exerciseCount = plan['exercise_count'] as int? ?? 0;
                          final bool isSubmitting = _submittingMap[planId] ?? false;

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
                                        style: AppStyles.text14Px.poppins.w600.dark,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Group: $groupName | Exercises: $exerciseCount',
                                        style: AppStyles.text12Px.poppins.w400.copyWith(
                                          color: AppColors.textGrey,
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
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : ElevatedButton(
                                        onPressed: () => _assignPlan(planId, planName),
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
    );
  }
}
