import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class AssignToClientBottomSheet extends StatefulWidget {
  final int planId;
  final String planTitle;

  const AssignToClientBottomSheet({
    required this.planId,
    required this.planTitle,
    super.key,
  });

  @override
  State<AssignToClientBottomSheet> createState() => _AssignToClientBottomSheetState();
}

class _AssignToClientBottomSheetState extends State<AssignToClientBottomSheet> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedGymFilter = 'All';
  final Map<int, bool> _submittingMap = {};

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
      // 1. Fetch clients list
      final clientsResponse = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      // 2. Fetch already assigned client IDs for this specific plan
      final assignedResponse = await DioClient().dio.get<dynamic>(
        ApiUris.assignWorkoutPlan(widget.planId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      final Set<int> assignedCustomerIds = {};
      if (assignedResponse.statusCode == 200 && assignedResponse.data is List) {
        final List<dynamic> assignedList = assignedResponse.data as List<dynamic>;
        for (var item in assignedList) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['is_assigned'] == true) {
            assignedCustomerIds.add(map['customer_id'] as int);
          }
        }
      }

      if (clientsResponse.statusCode == 200) {
        final List<dynamic> data = (clientsResponse.data is Map)
            ? (List<dynamic>.from((clientsResponse.data as Map)['results'] as List? ?? []))
            : (clientsResponse.data as List<dynamic>);

        final parsedClients = data.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          final customerId = map['customer_id'] as int;
          return {
            ...map,
            'is_assigned': assignedCustomerIds.contains(customerId),
          };
        }).toList();

        setState(() {
          _clients = parsedClients;
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
      final name = (client['name'] as String? ?? '').toLowerCase();
      if (_searchQuery.trim().isNotEmpty && !name.contains(_searchQuery.trim().toLowerCase())) {
        return false;
      }
      final orgName = client['organization_name'] ?? 'Direct Client';
      if (_selectedGymFilter != 'All' && orgName != _selectedGymFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _assignPlan(int customerId, String customerName, bool isAssignedToMe) async {
    if (_submittingMap[customerId] == true) return;

    setState(() {
      _submittingMap[customerId] = true;
    });

    final titleController = TextEditingController(text: widget.planTitle);
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

    if (confirmed != true) {
      setState(() {
        _submittingMap[customerId] = false;
      });
      return;
    }

    final enteredTitle = titleController.text.trim();
    final String finalTitle = enteredTitle.isNotEmpty ? enteredTitle : widget.planTitle;

    final trainerId = context.read<AppCubit>().state.currentUser?.trainer?.id ??
                      context.read<AppCubit>().state.currentUser?.mentor?.id;
    if (trainerId == null) {
      setState(() {
        _submittingMap[customerId] = false;
      });
      Dialogs.showSnack(msg: 'Trainer profile not found.');
      return;
    }

    try {
      final dio = DioClient().dio;

      // 1. Link trainer to client if not already linked
      if (!isAssignedToMe) {
        final patchResponse = await dio.patch<dynamic>(
          ApiUris.updateMember(customerId),
          data: {
            'trainer_id': trainerId,
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (patchResponse.statusCode != 200) {
          Dialogs.showSnack(msg: 'Failed to link trainer to customer.');
          setState(() {
            _submittingMap[customerId] = false;
          });
          return;
        }
      }

      // 2. Assign workout plan
      final response = await dio.post<dynamic>(
        ApiUris.assignWorkoutPlan(widget.planId),
        data: {
          'customer_id': customerId,
          'title': finalTitle,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      setState(() {
        _submittingMap[customerId] = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Plan assigned successfully to $customerName');
        setState(() {
          final idx = _clients.indexWhere((c) => c['customer_id'] == customerId);
          if (idx != -1) {
            _clients[idx]['is_assigned'] = true;
          }
        });
      } else {
        Dialogs.showSnack(msg: 'Failed to assign plan');
      }
    } catch (e) {
      setState(() {
        _submittingMap[customerId] = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients;
    final gyms = _gymFilters;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assign Workout',
                style: AppStyles.text18Px.poppins.w600.dark,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: "Search by client's name",
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
            ),
          ),
          const SizedBox(height: 12),
          // Gym select chips
          if (gyms.length > 1)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: gyms.map((gymName) {
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
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No clients found',
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final client = filtered[index];
                          final int customerId = client['customer_id'] as int;
                          final String name = client['name'] as String? ?? 'Client';
                          final String goal = client['target_goal'] as String? ?? '';
                          final bool isAssigned = client['is_assigned'] as bool? ?? false;
                          final bool isAssignedToMe = client['is_assigned_to_me'] as bool? ?? false;
                          final bool isSubmitting = _submittingMap[customerId] ?? false;
                          final imgUrl = client['profile_picture'];

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.iconBackground,
                                  backgroundImage: imgUrl != null ? NetworkImage(imgUrl as String) : null,
                                  child: imgUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppStyles.text14Px.poppins.w600.dark,
                                      ),
                                      if (goal.isNotEmpty)
                                        Text(
                                          goal,
                                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
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
                                    : isAssigned
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F1F1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Assigned',
                                              style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.textGrey),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () => _assignPlan(customerId, name, isAssignedToMe),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
