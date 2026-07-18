import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';

class OrganizationWorkoutLibraryScreen extends StatefulWidget {
  final OrganizationDetailsModel orgDetails;

  const OrganizationWorkoutLibraryScreen({super.key, required this.orgDetails});

  @override
  State<OrganizationWorkoutLibraryScreen> createState() =>
      _OrganizationWorkoutLibraryScreenState();
}

class _OrganizationWorkoutLibraryScreenState
    extends State<OrganizationWorkoutLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orgExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGymExercises();
  }

  Future<void> _fetchGymExercises() async {
    try {
      final res = await DioClient().dio.get<dynamic>(ApiUris.gymExercises);
      if (!mounted) return;

      final dataList = res.data as List;
      setState(() {
        _orgExercises =
            dataList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _filteredExercises = List.from(_orgExercises);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Failed to load gym exercises');
    }
  }

  Future<void> _deleteExercise(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: const Text('Are you sure you want to remove this exercise from your library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // First try to delete it as a custom exercise
      await DioClient().dio.delete<dynamic>(ApiUris.deleteGymExercise(id));
      Dialogs.showSnack(msg: 'Exercise deleted successfully');
      _fetchGymExercises();
    } on DioException catch (e) {
      // If it fails (e.g. 403 Forbidden or 404 because it's a global exercise), try the library override fallback
      try {
        await DioClient().dio.delete<dynamic>(
          '${ApiUris.gymWorkoutLibrary}0/?workout_id=$id',
        );
        Dialogs.showSnack(msg: 'Exercise removed from library');
        _fetchGymExercises();
      } catch (fallbackError) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Dialogs.showSnack(msg: 'Failed to delete exercise');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Failed to delete exercise');
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _filteredExercises = List.from(_orgExercises));
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredExercises =
          _orgExercises.where((ex) {
            final name = ex['name']?.toString().toLowerCase() ?? '';
            return name.contains(lowerQuery);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSelectExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _SelectExerciseSheet(
            orgId: widget.orgDetails.id!,
            onExerciseAdded: _fetchGymExercises,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Workout Library',
          style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: 'Search for workout group',
                              hintStyle: AppStyles.text14Px.poppins.w400
                                  .copyWith(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredExercises.isEmpty
                          ? const Center(child: Text('No exercises found'))
                          : ListView.separated(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 16,
                              right: 16,
                              bottom: 100,
                            ),
                            itemCount: _filteredExercises.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final ex = _filteredExercises[index];

                              final muscleData = ex['primary_muscle_group'];
                              final muscleStr =
                                  (muscleData is Map)
                                      ? muscleData['name']?.toString()
                                      : (ex['primary_muscle_group_name']
                                              ?.toString() ??
                                          ex['muscle']?.toString() ??
                                          'N/A');

                              final eqData = ex['equipment'];
                              final eqStr =
                                  (eqData is Map)
                                      ? eqData['name']?.toString()
                                      : (ex['equipment_name']?.toString() ??
                                          ex['equipment']?.toString() ??
                                          'N/A');

                              final typeStr =
                                  ex['exercise_type_name']?.toString() ??
                                  ex['type']?.toString() ??
                                  ex['exercise_type']?.toString() ??
                                  'N/A';

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex['name']?.toString() ??
                                                'Unnamed Exercise',
                                            style:
                                                AppStyles.text14Px.poppins.w600,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$muscleStr / $eqStr / $typeStr',
                                            style: AppStyles
                                                .text12Px
                                                .poppins
                                                .w400
                                                .copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      color: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          final result = await showModalBottomSheet<bool>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => _CreateNewExerciseSheet(editExercise: ex),
                                          );
                                          if (result == true) {
                                            _fetchGymExercises();
                                          }
                                        } else if (value == 'delete') {
                                          if (ex['id'] != null) {
                                            _deleteExercise(ex['id'] as int);
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
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
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showSelectExerciseSheet,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add new Exercise',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectExerciseSheet extends StatefulWidget {
  final int orgId;
  final VoidCallback onExerciseAdded;

  const _SelectExerciseSheet({
    required this.orgId,
    required this.onExerciseAdded,
  });

  @override
  State<_SelectExerciseSheet> createState() => _SelectExerciseSheetState();
}

class _SelectExerciseSheetState extends State<_SelectExerciseSheet> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _globalExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGlobalExercises();
  }

  Future<void> _fetchGlobalExercises() async {
    try {
      final res = await DioClient().dio.get<dynamic>(
        '${ApiUris.workoutExercises}?source=library',
      );
      if (!mounted) return;

      final dataList = res.data as List;
      setState(() {
        _globalExercises =
            dataList
                .map(
                  (e) =>
                      Map<String, dynamic>.from(e as Map)..['isAdded'] = false,
                )
                .toList();
        _filteredExercises = List.from(_globalExercises);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Failed to load global exercises');
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _filteredExercises = List.from(_globalExercises));
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredExercises =
          _globalExercises.where((ex) {
            final name = ex['name']?.toString().toLowerCase() ?? '';
            return name.contains(lowerQuery);
          }).toList();
    });
  }

  Future<void> _addExerciseToLibrary(Map<String, dynamic> ex) async {
    setState(() => ex['isAdded'] = true);
    try {
      final res = await DioClient().dio.post(
        ApiUris.gymWorkoutLibrary,
        data: {
          "organization_id": widget.orgId,
          "workout_id": ex['id'],
          "is_visible": true,
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        widget.onExerciseAdded();
      } else {
        setState(() => ex['isAdded'] = false);
        Dialogs.showSnack(msg: 'Failed to add exercise');
      }
    } catch (e) {
      setState(() => ex['isAdded'] = false);
      Dialogs.showSnack(msg: 'Failed to add exercise');
    }
  }

  void _showCreateExerciseSheet() {
    Navigator.pop(context); // Close the current sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateNewExerciseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Exercise', style: AppStyles.text16Px.poppins.w600),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Search for added exercise',
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredExercises.isEmpty
                    ? const Center(child: Text('No exercises found'))
                    : ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 100,
                      ),
                      itemCount: _filteredExercises.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ex = _filteredExercises[index];
                        final isAdded = ex['isAdded'] == true;

                        final muscleData = ex['primary_muscle_group'];
                        final muscleStr =
                            (muscleData is Map)
                                ? muscleData['name']?.toString()
                                : (ex['primary_muscle_group_name']
                                        ?.toString() ??
                                    ex['muscle']?.toString() ??
                                    'N/A');

                        final eqData = ex['equipment'];
                        final eqStr =
                            (eqData is Map)
                                ? eqData['name']?.toString()
                                : (ex['equipment_name']?.toString() ??
                                    ex['equipment']?.toString() ??
                                    'N/A');

                        final typeStr =
                            ex['exercise_type_name']?.toString() ??
                            ex['type']?.toString() ??
                            ex['exercise_type']?.toString() ??
                            'N/A';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex['name']?.toString() ?? 'Unnamed',
                                      style: AppStyles.text14Px.poppins.w600,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$muscleStr / $eqStr / $typeStr',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (!isAdded) {
                                    _addExerciseToLibrary(ex);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isAdded
                                            ? Colors.white
                                            : AppColors.primary,
                                    border: Border.all(
                                      color:
                                          isAdded
                                              ? AppColors.primary.withOpacity(
                                                0.5,
                                              )
                                              : Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isAdded ? 'Added' : 'Add',
                                    style: AppStyles.text12Px.poppins.w500
                                        .copyWith(
                                          color:
                                              isAdded
                                                  ? AppColors.primary
                                                  : Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _showCreateExerciseSheet,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Create new Exercise',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateNewExerciseSheet extends StatefulWidget {
  final Map<String, dynamic>? editExercise;

  const _CreateNewExerciseSheet({this.editExercise});

  @override
  State<_CreateNewExerciseSheet> createState() =>
      _CreateNewExerciseSheetState();
}

class _CreateNewExerciseSheetState extends State<_CreateNewExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _youtubeController = TextEditingController();

  List<Map<String, dynamic>> _muscles = [];
  List<Map<String, dynamic>> _equipments = [];
  List<Map<String, dynamic>> _types = [];

  int? _selectedMuscleId;
  int? _selectedEquipmentId;
  String? _selectedType;

  bool _isLoadingDropdowns = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (widget.editExercise != null) {
      _nameController.text = widget.editExercise!['name']?.toString() ?? '';
      _youtubeController.text = widget.editExercise!['video_url']?.toString() ??
          widget.editExercise!['youtube_link']?.toString() ??
          '';
      
      final muscle = widget.editExercise!['primary_muscle_group_id'] ?? widget.editExercise!['muscle_group_id'];
      if (muscle != null) _selectedMuscleId = int.tryParse(muscle.toString());

      final equipment = widget.editExercise!['equipment_id'] ?? widget.editExercise!['equipment'];
      if (equipment != null) _selectedEquipmentId = int.tryParse(equipment.toString());

      _selectedType = widget.editExercise!['exercise_type_id']?.toString() ?? widget.editExercise!['type']?.toString();
    }
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final dio = DioClient().dio;
      final mRes = await dio.get<dynamic>(ApiUris.muscleGroups);
      final eRes = await dio.get<dynamic>(ApiUris.equipment);
      final tRes = await dio.get<dynamic>(ApiUris.exerciseTypes);

      if (!mounted) return;
      setState(() {
        _muscles =
            (mRes.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        _equipments =
            (eRes.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        _types =
            (tRes.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDropdowns = false;
      });
      Dialogs.showSnack(msg: 'Error loading form options: ${e.toString()}');
    }
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleId == null ||
        _selectedEquipmentId == null ||
        _selectedType == null) {
      Dialogs.showSnack(msg: 'Please fill all dropdown selections');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCreating = true;
    });

    try {
      final isEditing = widget.editExercise != null;
      final data = {
        'name': _nameController.text.trim(),
        'muscle_group_id': _selectedMuscleId,
        'equipment_id': _selectedEquipmentId,
        'exercise_type_id': _selectedType,
        'youtube_link': _youtubeController.text.trim(),
      };

      final response = isEditing 
        ? await DioClient().dio.put<dynamic>(
            ApiUris.editGymExercise(widget.editExercise!['id'] as int),
            data: data,
          )
        : await DioClient().dio.post<dynamic>(
            ApiUris.createGymExercise,
            data: data,
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: isEditing ? 'Exercise updated successfully' : 'Exercise created successfully');
        Navigator.pop(context, true); // Return true to signal success
      } else {
        if (!mounted) return;
        setState(() {
          _isCreating = false;
        });
        Dialogs.showSnack(msg: isEditing ? 'Failed to update exercise' : 'Failed to create exercise');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
      Dialogs.showSnack(msg: 'Error creating exercise: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> _showAddNewDialog(
    String title,
    String endpoint,
  ) async {
    final controller = TextEditingController();
    bool isSaving = false;
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add New $title'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isSaving
                          ? null
                          : () async {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            setDialogState(() => isSaving = true);
                            try {
                              final res = await DioClient().dio.post<dynamic>(
                                endpoint,
                                data: {'name': name},
                              );
                              if (res.statusCode == 200 ||
                                  res.statusCode == 201) {
                                Navigator.pop(context, res.data);
                              } else {
                                Dialogs.showSnack(msg: 'Failed to create');
                                setDialogState(() => isSaving = false);
                              }
                            } catch (e) {
                              Dialogs.showSnack(msg: 'Error: ${e.toString()}');
                              setDialogState(() => isSaving = false);
                            }
                          },
                  child:
                      isSaving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _isLoadingDropdowns
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create new Exercise',
                            style: AppStyles.text16Px.poppins.w600,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Exercise Name ',
                                  style: AppStyles.text14Px.poppins.w500
                                      .copyWith(color: Colors.black),
                                  children: [
                                    const TextSpan(
                                      text: '*',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                                decoration: InputDecoration(
                                  hintText: 'Enter exercise name',
                                  hintStyle: AppStyles.text14Px.poppins.w400
                                      .copyWith(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'Muscle *',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _selectedMuscleId,
                                hint: const Text('Select the muscle'),
                                items: [
                                  ..._muscles.map((m) {
                                    return DropdownMenuItem<int>(
                                      value: m['id'] as int,
                                      child: Text(m['name'] as String),
                                    );
                                  }),
                                  const DropdownMenuItem<int>(
                                    value: -1,
                                    child: Text(
                                      '+ Add New Muscle...',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) async {
                                  if (val == -1) {
                                    final newMuscle = await _showAddNewDialog(
                                      'Muscle Group',
                                      ApiUris.muscleGroups,
                                    );
                                    if (newMuscle != null && mounted) {
                                      setState(() {
                                        _muscles.add(newMuscle);
                                        _selectedMuscleId =
                                            newMuscle['id'] as int;
                                      });
                                    } else {
                                      setState(() {}); // Reset if cancelled
                                    }
                                  } else {
                                    if (!mounted) return;
                                    setState(() => _selectedMuscleId = val);
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'Type *',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedType,
                                hint: const Text('Select the type of exercise'),
                                items:
                                    _types.map((t) {
                                      return DropdownMenuItem<String>(
                                        value: t['value'] as String,
                                        child: Text(t['label'] as String),
                                      );
                                    }).toList(),
                                onChanged: (val) {
                                  if (!mounted) return;
                                  setState(() => _selectedType = val);
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'Equipment *',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _selectedEquipmentId,
                                hint: const Text('Select the equipment used'),
                                items: [
                                  ..._equipments.map((eq) {
                                    return DropdownMenuItem<int>(
                                      value: eq['id'] as int,
                                      child: Text(eq['name'] as String),
                                    );
                                  }),
                                  const DropdownMenuItem<int>(
                                    value: -1,
                                    child: Text(
                                      '+ Add New Equipment...',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) async {
                                  if (val == -1) {
                                    final newEquipment =
                                        await _showAddNewDialog(
                                          'Equipment',
                                          ApiUris.equipment,
                                        );
                                    if (newEquipment != null && mounted) {
                                      setState(() {
                                        _equipments.add(newEquipment);
                                        _selectedEquipmentId =
                                            newEquipment['id'] as int;
                                      });
                                    } else {
                                      setState(() {}); // Reset if cancelled
                                    }
                                  } else {
                                    if (!mounted) return;
                                    setState(() => _selectedEquipmentId = val);
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'Youtube Link',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _youtubeController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Paste the youtube link of exercis...',
                                  hintStyle: AppStyles.text14Px.poppins.w400
                                      .copyWith(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.copy,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isCreating
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _createExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Create Exercise',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
      ),
    );
  }
}
