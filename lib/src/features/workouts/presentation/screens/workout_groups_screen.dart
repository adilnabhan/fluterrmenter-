import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_group_details_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class WorkoutGroupsScreen extends StatefulWidget {
  const WorkoutGroupsScreen({super.key});

  @override
  State<WorkoutGroupsScreen> createState() => _WorkoutGroupsScreenState();
}

class _WorkoutGroupsScreenState extends State<WorkoutGroupsScreen> {
  int _selectedTabIndex = 0;
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _groupName;

  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Enter group name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
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

  Future<void> _fetchGroups() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
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
        setState(() {
          _groups =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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

  List<Map<String, dynamic>> get _filteredGroups {
    final typeFilter = _selectedTabIndex == 0 ? 'single_day' : 'multi_day';
    return _groups.where((g) => g['type'] == typeFilter).toList();
  }

  Future<void> _createGroup(String name) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final groupType = _selectedTabIndex == 0 ? 'single_day' : 'multi_day';

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutGroups,
        data: {'name': name, 'type': groupType},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Workout group created successfully');
        _groupName.controller?.clear();
        _fetchGroups();
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
    final filtered = _filteredGroups;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Workouts',
          style: AppStyles.text20Px.poppins.w500.copyWith(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              Dialogs.showSnack(msg: 'Settings');
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      EasyDebounce.debounce(
                        'groups-search',
                        const Duration(milliseconds: 400),
                        () => _fetchGroups(),
                      );
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: AppColors.textGrey),
                      hintText: 'Search for workout group',
                      fillColor: Colors.white,
                      hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
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
                              color: const Color(0xFFF8F9FB),
                              border: Border.all(
                                color: Colors.grey.shade300,
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
                                        '${filtered.length} workout groups',
                                        style: AppStyles.text14Px.poppins.w400
                                            .copyWith(
                                              color: AppColors.textGrey,
                                            ),
                                      ),
                                      // Container(
                                      //   padding: const EdgeInsets.symmetric(
                                      //     horizontal: 12,
                                      //     vertical: 6,
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     color: const Color(0xFFFFEAEA),
                                      //     borderRadius: BorderRadius.circular(
                                      //       20,
                                      //     ),
                                      //   ),
                                      //   child: Row(
                                      //     children: [
                                      //       const Icon(
                                      //         Icons.filter_list,
                                      //         size: 16,
                                      //         color: Color(0xFFFF3434),
                                      //       ),
                                      //       const SizedBox(width: 4),
                                      //       Text(
                                      //         'Sort',
                                      //         style: AppStyles
                                      //             .text12Px
                                      //             .poppins
                                      //             .w500
                                      //             .copyWith(
                                      //               color: const Color(
                                      //                 0xFFFF3434,
                                      //               ),
                                      //             ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child:
                                      _isLoading
                                          ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                          : filtered.isEmpty
                                          ? const Center(
                                            child: Text(
                                              'No workout groups found.',
                                            ),
                                          )
                                          : WorkoutGroupsGrid(groups: filtered),
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
                          Expanded(child: _buildTab('Single-Day Workout', 0)),
                          // const SizedBox(width: 12),
                          // Expanded(child: _buildTab('Multi-Day Workout', 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: CreateGroupButton(
                onTap: () {
                  _showCreateGroupSheet(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
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
              color: isSelected ? const Color(0xFFF8F9FB) : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border:
                  isSelected
                      ? Border.all(color: Colors.grey.shade300, width: 1)
                      : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.text14Px.poppins.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black : AppColors.textDark,
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: 0,
              left: 1,
              right: 1,
              height: 2,
              child: Container(color: const Color(0xFFF8F9FB)),
            ),
        ],
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
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
              MediaQuery.of(context).viewInsets.bottom + 55,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Single-Day group',
                    style: AppStyles.text15Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create group',
                        style: AppStyles.text15Px.poppins.w600.copyWith(
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
}

class WorkoutGroupsGrid extends StatelessWidget {
  const WorkoutGroupsGrid({super.key, required this.groups});
  final List<Map<String, dynamic>> groups;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.5,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _WorkoutGroupCard(group: groups[index]);
      },
    );
  }
}

class _WorkoutGroupCard extends StatelessWidget {
  const _WorkoutGroupCard({required this.group});
  final Map<String, dynamic> group;

  @override
  Widget build(BuildContext context) {
    final int groupId = group['id'] as int;
    final String groupName = group['name'] as String? ?? '';
    final int planCount = group['plan_count'] as int? ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder:
                (context) => WorkoutGroupDetailsScreen(
                  groupId: groupId,
                  groupTitle: groupName,
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    groupName,
                    style: AppStyles.text15Px.poppins.w500.copyWith(
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: 16,
                  child: const Icon(
                    Icons.more_vert,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$planCount plans',
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
