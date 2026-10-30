import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_group_details_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_settings_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/assign_to_client_bottom_sheet.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/create_workout_plan_wizard_screen.dart';

class WorkoutGroupsScreen extends StatefulWidget {
  const WorkoutGroupsScreen({super.key, this.orgId});

  final int? orgId;

  @override
  State<WorkoutGroupsScreen> createState() => _WorkoutGroupsScreenState();
}

class _WorkoutGroupsScreenState extends State<WorkoutGroupsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedTabIndex = 0;
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _groupName;

  static List<Map<String, dynamic>>? _cachedGroups;
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all'; // 'all' or 'org'

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _groups = [];
    _fetchGroups();
    _groupName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Group Name',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Group name is required';
        }
        return null;
      },
      maxLength: 30,
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Enter group name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupName.controller?.dispose();
    _groupName.focusNode?.dispose();
    super.dispose();
  }

  Future<void> _fetchGroups({bool silent = false}) async {
    if (!mounted) return;
    if (!silent && _groups.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final resolvedOrgId =
        widget.orgId ?? user?.organizationId ?? user?.trainer?.organizationId;

    final url = isTrainer ? ApiUris.workoutGroups : ApiUris.gymWorkoutGroups;

    try {
      final response = await DioClient().dio.get<dynamic>(
        url,
        queryParameters: {
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
          if (!isTrainer && resolvedOrgId != null)
            'organization_id': resolvedOrgId,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (response.data['results'] as List<dynamic>? ?? [])
                : (response.data as List<dynamic>);
        if (!mounted) return;
        final newGroups =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        newGroups.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

        if (_searchQuery.trim().isEmpty) {
          _cachedGroups = newGroups;
        }

        setState(() {
          _groups = newGroups;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        if (_groups.isEmpty) {
          Dialogs.showSnack(msg: 'Failed to load workout groups');
        }
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (_groups.isEmpty) {
        String errorMsg = 'Failed to load workout groups';
        if (e.response?.data is Map) {
          final map = e.response!.data as Map;
          errorMsg =
              map['detail']?.toString() ??
              map['message']?.toString() ??
              map['error']?.toString() ??
              errorMsg;
        }
        Dialogs.showSnack(msg: 'Error loading groups: $errorMsg');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (_groups.isEmpty) {
        Dialogs.showSnack(msg: 'Error loading groups: ${e.toString()}');
      }
    }
  }

  List<Map<String, dynamic>> get _filteredGroups {
    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;

    final typeFilter = _selectedTabIndex == 0 ? 'single_day' : 'multi_day';
    var filtered = _groups.where((g) => g['type'] == typeFilter).toList();

    if (!isTrainer) {
      filtered =
          filtered
              .where(
                (g) => g['source'] == 'gym' || g['source'] == 'organization',
              )
              .toList();
    } else {
      if (_filterType == 'org') {
        filtered =
            filtered
                .where(
                  (g) => g['source'] == 'gym' || g['source'] == 'organization',
                )
                .toList();
      } else if (_filterType == 'trainer') {
        filtered = filtered.where((g) => g['source'] == 'trainer').toList();
      }
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered.sort((a, b) {
        final nameA = (a['name'] ?? '').toString().toLowerCase();
        final nameB = (b['name'] ?? '').toString().toLowerCase();

        int score(String name) {
          if (name == query) return 0; // Exact match
          if (name.startsWith(query))
            return 1; // Starts with search term (e.g. "Chest Strength")
          final words = name.split(RegExp(r'\s+'));
          if (words.any((w) => w.startsWith(query)))
            return 2; // Word starts with search term (e.g. "Advanced Chest...")
          if (name.contains(query)) return 3; // Contains search term elsewhere
          return 4; // Matched via exercise or description
        }

        final scoreA = score(nameA);
        final scoreB = score(nameB);
        if (scoreA != scoreB) {
          return scoreA.compareTo(scoreB);
        }

        // Tie-breaker: newest ID first
        final idA = a['id'] as int? ?? 0;
        final idB = b['id'] as int? ?? 0;
        return idB.compareTo(idA);
      });
    }

    return filtered;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Filter Workouts',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All Workouts'),
                trailing:
                    _filterType == 'all'
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                onTap: () {
                  setState(() => _filterType = 'all');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Organization Workouts'),
                trailing:
                    _filterType == 'org'
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                onTap: () {
                  setState(() => _filterType = 'org');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('My Workouts'),
                trailing:
                    _filterType == 'trainer'
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                onTap: () {
                  setState(() => _filterType = 'trainer');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(bool isTrainer) {
    if (!isTrainer) return const SizedBox();

    String filterText = 'All';
    if (_filterType == 'org') filterText = 'Organization';
    if (_filterType == 'trainer') filterText = 'My Workouts';

    return InkWell(
      onTap: () => _showFilterSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEAEA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 16, color: Color(0xFFFF3434)),
            const SizedBox(width: 4),
            Text(
              filterText,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: const Color(0xFFFF3434),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup(String name, {String? nameInternal}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final groupType = _selectedTabIndex == 0 ? 'single_day' : 'multi_day';
    final source = isTrainer ? 'trainer' : 'organization';

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutGroups,
        data: {
          'name': name,
          if (nameInternal != null && nameInternal.isNotEmpty)
            'name_internal': nameInternal,
          'type': groupType,
          'source': source,
        },
        options: Options(
          headers: {'X-Platform': platformSource, 'Connection': 'close'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Workout group created successfully');
        _groupName.controller?.clear();

        if (response.data is Map && response.data['id'] != null) {
          final Map<String, dynamic> newGroup =
              Map<String, dynamic>.from(response.data as Map);
          newGroup['plans_count'] ??= 0;
          newGroup['workout_count'] ??= 0;
          newGroup['type'] ??= groupType;
          newGroup['source'] ??= source;

          final int groupId = newGroup['id'] as int;
          final String createdName = newGroup['name'] as String? ?? name;

          if (mounted) {
            setState(() {
              _groups.removeWhere((g) => g['id'] == groupId);
              _groups.insert(0, newGroup);
              _cachedGroups = _groups;
              _isLoading = false;
            });
          }

          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder:
                    (context) => WorkoutGroupDetailsScreen(
                      groupId: groupId,
                      groupTitle: createdName,
                      source: source,
                      groupType: groupType,
                    ),
              ),
            );
          }

          // Silently sync in background when returning from details screen
          if (mounted) {
            _fetchGroups(silent: true);
          }
        } else {
          if (mounted) {
            _fetchGroups(silent: true);
          }
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to create workout group');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error creating workout group: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;

    final filtered = _filteredGroups;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hasBottomNav =
        context.findAncestorWidgetOfExactType<OrganizationDashboardScaffold>() !=
                null ||
            !(ModalRoute.of(context)?.canPop ?? true);
    final createButtonBottom =
        hasBottomNav ? (bottomInset + 20) : (bottomInset + 16);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Workouts',
          style: AppStyles.text20Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: context.colors.icon),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerProfileSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                            _searchQuery = val;
                            if (val.trim().isEmpty && _cachedGroups != null) {
                              setState(() {
                                _groups = List<Map<String, dynamic>>.from(
                                  _cachedGroups!,
                                );
                              });
                            }
                            EasyDebounce.debounce(
                              'groups-search',
                              const Duration(milliseconds: 400),
                              () => _fetchGroups(silent: _groups.isNotEmpty),
                            );
                          },
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: context.colors.textSecondary,
                            ),
                            hintText: 'Search for workout group',
                            fillColor: context.colors.card,
                            hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 44),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.background,
                              border: Border.all(
                                color: context.colors.border,
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isLoading
                                            ? 'Loading workout groups...'
                                            : '${filtered.length} workout groups',
                                        style: AppStyles.text14Px.poppins.w400
                                            .copyWith(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                      ),
                                      _buildFilterButton(isTrainer),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: _fetchGroups,
                                    child:
                                        _isLoading
                                            ? _buildShimmerGrid()
                                            : filtered.isEmpty
                                            ? SingleChildScrollView(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.4,
                                                child: Center(
                                                  child: Text(
                                                    'No workout groups found.',
                                                    style: TextStyle(
                                                      color:
                                                          context
                                                              .colors
                                                              .textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            : WorkoutGroupsGrid(
                                              groups: filtered,
                                              onReturn: _fetchGroups,
                                              isMultiDay:
                                                  _selectedTabIndex == 1,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 1, // Overlaps the container's top border
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Expanded(child: _buildTab('Workouts', 0)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTab('Programs', 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: createButtonBottom,
            left: 0,
            right: 0,
            child: Center(
              child: CreateGroupButton(
                label:
                    _selectedTabIndex == 0
                        ? 'Create Workout Plan'
                        : 'Create new group',
                onTap: () {
                  if (_selectedTabIndex == 0) {
                    _openCreatePlanWizard(context);
                  } else {
                    _showCreateGroupSheet(context);
                  }
                },
                onLongPress: () {
                  _showCreateGroupSheet(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreatePlanWizard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const CreateWorkoutPlanWizardScreen(),
      ),
    ).then((_) {
      if (mounted) {
        _fetchGroups(silent: true);
      }
    });
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() => _selectedTabIndex = index);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:
                  isSelected ? context.colors.background : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border:
                  isSelected
                      ? Border.all(color: context.colors.border, width: 1)
                      : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.text14Px.poppins.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: 0,
              left: 1,
              right: 1,
              height: 2,
              child: Container(color: context.colors.background),
            ),
        ],
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    final isMultiDay = _selectedTabIndex == 1;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              25,
              20,
              MediaQuery.of(context).viewInsets.bottom + 25,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMultiDay
                        ? 'Create a Program group'
                        : 'Create a Workout group',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Field(data: _groupName),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final name = _groupName.controller?.text.trim() ?? '';
                          Navigator.pop(context);
                          if (name.isNotEmpty) {
                            _createGroup(name);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD30000),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create Group',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 180),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.50,
      ),
      itemCount: 8,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  KShimmer(width: 100, height: 14, radius: 4),
                  SizedBox(height: 6),
                  KShimmer(width: 70, height: 12, radius: 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  KShimmer(width: 50, height: 12, radius: 4),
                  KShimmer(width: 14, height: 14, radius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class WorkoutGroupsGrid extends StatelessWidget {
  const WorkoutGroupsGrid({
    super.key,
    required this.groups,
    required this.onReturn,
    this.isMultiDay = false,
  });
  final List<Map<String, dynamic>> groups;
  final VoidCallback onReturn;
  final bool isMultiDay;

  @override
  Widget build(BuildContext context) {
    if (isMultiDay) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 180),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _MultiDayWorkoutGroupCard(
            group: groups[index],
            onReturn: onReturn,
          );
        },
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 180),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.50,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _WorkoutGroupCard(group: groups[index], onReturn: onReturn);
      },
    );
  }
}

class _WorkoutGroupCard extends StatelessWidget {
  const _WorkoutGroupCard({required this.group, required this.onReturn});
  final Map<String, dynamic> group;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final int groupId = group['id'] as int;
    final String groupName = group['name'] as String? ?? '';
    final int planCount =
        group['plan_count'] as int? ??
        group['plans_count'] as int? ??
        group['total_plans'] as int? ??
        (group['plans'] is List ? (group['plans'] as List).length : null) ??
        (group['workout_plans'] is List
            ? (group['workout_plans'] as List).length
            : null) ??
        0;

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final isTrainerOwned = group['source'] == 'trainer' ||
        (isTrainer &&
            group['source'] != 'organization' &&
            group['source'] != 'gym' &&
            group['created_by_organization'] != true);
    final isOrgCreated =
        (group['source'] == 'organization' ||
            group['source'] == 'gym' ||
            group['created_by_organization'] == true ||
            group['is_preset'] == true) &&
        !isTrainerOwned;
    final canEditOrDelete = isTrainerOwned || !isTrainer || !isOrgCreated;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder:
                (context) => WorkoutGroupDetailsScreen(
                  groupId: groupId,
                  groupTitle: groupName,
                  source: group['source'] as String?,
                  groupType: group['type'] as String?,
                ),
          ),
        );
        if (result == true) {
          onReturn();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDarkMode ? 0.2 : .05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: AppStyles.text15Px.poppins.w500.copyWith(
                          color: context.colors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canEditOrDelete)
                  PopupMenuButton<String>(
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    onSelected: (value) async {
                      if (value == 'rename') {
                        final nameController = TextEditingController(
                          text: groupName,
                        );
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                'Rename Workout Group',
                                style: AppStyles.text16Px.poppins.w600,
                              ),
                              content: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter new name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(dialogContext, null),
                                  child: Text(
                                    'Cancel',
                                    style: AppStyles.text14Px.poppins.w500
                                        .copyWith(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      () => Navigator.pop(
                                        dialogContext,
                                        nameController.text.trim(),
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: AppStyles.text14Px.poppins.w600
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (newName != null &&
                            newName.isNotEmpty &&
                            newName != groupName) {
                          try {
                            final response = await DioClient().dio.put<dynamic>(
                              ApiUris.workoutGroupDetail(groupId),
                              data: {'name': newName},
                            );
                            if (response.statusCode == 200 ||
                                response.statusCode == 204) {
                              Dialogs.showSnack(
                                msg: 'Workout group renamed successfully',
                              );
                              onReturn();
                            } else {
                              Dialogs.showSnack(
                                msg: 'Failed to rename workout group',
                              );
                            }
                          } catch (e) {
                            Dialogs.showSnack(
                              msg:
                                  'Error renaming workout group: ${e.toString()}',
                            );
                          }
                        }
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                'Delete Workout Group',
                                style: AppStyles.text16Px.poppins.w600,
                              ),
                              content: const Text(
                                'Are you sure you want to delete this workout group?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(dialogContext, false),
                                  child: Text(
                                    'Cancel',
                                    style: AppStyles.text14Px.poppins.w500
                                        .copyWith(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      () => Navigator.pop(dialogContext, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: AppStyles.text14Px.poppins.w600
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          try {
                            final response = await DioClient().dio
                                .delete<dynamic>(
                                  ApiUris.workoutGroupDetail(groupId),
                                );
                            if (response.statusCode == 200 ||
                                response.statusCode == 204) {
                              Dialogs.showSnack(
                                msg: 'Workout group deleted successfully',
                              );
                              onReturn();
                            } else {
                              Dialogs.showSnack(
                                msg: 'Failed to delete workout group',
                              );
                            }
                          } catch (e) {
                            Dialogs.showSnack(
                              msg:
                                  'Error deleting workout group: ${e.toString()}',
                            );
                          }
                        }
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem<String>(
                            height: 36,
                            value: 'rename',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.textDark,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rename',
                                  style: AppStyles.text14Px.poppins.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            height: 36,
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: AppStyles.text14Px.poppins.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      radius: 16,
                      child: const Icon(
                        Icons.more_vert,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$planCount ${planCount == 1 ? 'plan' : 'plans'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiDayWorkoutGroupCard extends StatelessWidget {
  const _MultiDayWorkoutGroupCard({
    required this.group,
    required this.onReturn,
  });
  final Map<String, dynamic> group;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final int groupId = group['id'] as int;
    final String groupName = group['name'] as String? ?? '';
    final int planCount =
        group['plan_count'] as int? ??
        group['plans_count'] as int? ??
        group['total_plans'] as int? ??
        (group['plans'] is List ? (group['plans'] as List).length : null) ??
        (group['workout_plans'] is List
            ? (group['workout_plans'] as List).length
            : null) ??
        0;

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final isTrainerOwned = group['source'] == 'trainer' ||
        (isTrainer &&
            group['source'] != 'organization' &&
            group['source'] != 'gym' &&
            group['created_by_organization'] != true);
    final isOrgCreated =
        (group['source'] == 'organization' ||
            group['source'] == 'gym' ||
            group['created_by_organization'] == true ||
            group['is_preset'] == true) &&
        !isTrainerOwned;
    final canEditOrDelete = isTrainerOwned || !isTrainer || !isOrgCreated;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder:
                (context) => WorkoutGroupDetailsScreen(
                  groupId: groupId,
                  groupTitle: groupName,
                  source: group['source'] as String?,
                  groupType: 'multi_day',
                ),
          ),
        );
        if (result == true) {
          onReturn();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDarkMode ? 0.2 : .05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    groupName,
                    style: AppStyles.text16Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$planCount ${planCount == 1 ? 'plan' : 'plans'}',
                        style: AppStyles.text13Px.poppins.w400.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => AssignToClientBottomSheet(
                        planId: groupId,
                        planTitle: groupName,
                        isMultiDayGroup: true,
                      ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D32),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Assign to',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            if (canEditOrDelete) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: Colors.white,
                padding: EdgeInsets.zero,
                onSelected: (value) async {
                  if (value == 'rename') {
                    final nameController = TextEditingController(
                      text: groupName,
                    );
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Rename Workout Group',
                            style: AppStyles.text16Px.poppins.w600,
                          ),
                          content: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter new name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, null),
                              child: Text(
                                'Cancel',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(
                                    dialogContext,
                                    nameController.text.trim(),
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Save',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (newName != null &&
                        newName.isNotEmpty &&
                        newName != groupName) {
                      try {
                        final response = await DioClient().dio.put<dynamic>(
                          ApiUris.workoutGroupDetail(groupId),
                          data: {'name': newName},
                        );
                        if (response.statusCode == 200 ||
                            response.statusCode == 204) {
                          Dialogs.showSnack(
                            msg: 'Workout group renamed successfully',
                          );
                          onReturn();
                        } else {
                          Dialogs.showSnack(
                            msg: 'Failed to rename workout group',
                          );
                        }
                      } catch (e) {
                        Dialogs.showSnack(
                          msg: 'Error renaming group: ${e.toString()}',
                        );
                      }
                    }
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Delete Workout Group',
                            style: AppStyles.text16Px.poppins.w600,
                          ),
                          content: const Text(
                            'Are you sure you want to delete this workout group?',
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, false),
                              child: Text(
                                'Cancel',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      try {
                        final response = await DioClient().dio.delete<dynamic>(
                          ApiUris.workoutGroupDetail(groupId),
                        );
                        if (response.statusCode == 200 ||
                            response.statusCode == 204) {
                          Dialogs.showSnack(
                            msg: 'Workout group deleted successfully',
                          );
                          onReturn();
                        } else {
                          Dialogs.showSnack(
                            msg: 'Failed to delete workout group',
                          );
                        }
                      } catch (e) {
                        Dialogs.showSnack(
                          msg: 'Error deleting group: ${e.toString()}',
                        );
                      }
                    }
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem<String>(
                        value: 'rename',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.textDark,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Rename'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: 16,
                  child: const Icon(
                    Icons.more_vert,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
