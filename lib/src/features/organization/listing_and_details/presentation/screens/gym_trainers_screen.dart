import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/leads/add_or_edit_lead_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class GymTrainersScreen extends StatefulWidget {
  const GymTrainersScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymTrainersScreen> createState() => _GymTrainersScreenState();
}

class _GymTrainersScreenState extends State<GymTrainersScreen> {
  List<Map<String, dynamic>> _trainers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.leadsListing,
        queryParameters: {
          'organization_id': widget.orgDetails.id,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (List<dynamic>.from((response.data as Map)['results'] as List? ?? []))
            : (response.data as List<dynamic>);
        if (!mounted) return;
        setState(() {
          _trainers = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load trainers');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading trainers: ${e.toString()}');
    }
  }

  void _showAssignClientsSheet(Map<String, dynamic> trainer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _AssignClientsBottomSheet(
          orgId: widget.orgDetails.id ?? 0,
          trainer: trainer,
          onComplete: () {
            _fetchTrainers();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrainers = _trainers.where((trainer) {
      final name = (trainer['name'] as String? ?? '').toLowerCase();
      final first = (trainer['first_name'] as String? ?? '').toLowerCase();
      final last = (trainer['last_name'] as String? ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || 
             first.contains(_searchQuery.toLowerCase()) || 
             last.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: Text('Trainers', style: AppStyles.text16Px.poppins.w500),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search trainers...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffDDDDDD)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (!mounted) return;
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text(
                'Available Trainers',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (context) => BlocProvider(
                        create: (context) => MembersAndLeadsCubit(orgId: widget.orgDetails.id ?? 0),
                        child: const AddOrEditLeadScreen(),
                      ),
                    ),
                  );
                  _fetchTrainers();
                },
                label: const Text('Add'),
                icon: const Icon(Icons.add, size: 16),
                style: FilledButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: const Color(0xffFFEAEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTrainers.isEmpty
                    ? Center(
                        child: Text(
                          'No Trainers found!',
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTrainers.length,
                        itemBuilder: (context, index) {
                          final trainer = filteredTrainers[index];
                          final int exp = trainer['experience_years'] as int? ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.iconBackground,
                                  ),
                                  child: ClipOval(
                                    child: trainer['profile_image'] != null
                                        ? Image.network(
                                            trainer['profile_image'] as String,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person, color: AppColors.primary),
                                          )
                                        : const Icon(Icons.person, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trainer['name'] as String? ?? 'N/A',
                                        style: AppStyles.text14Px.poppins.w600,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Experience: $exp year${exp == 1 ? "" : "s"}',
                                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ).pad(16),
    );
  }
}

class _AssignClientsBottomSheet extends StatefulWidget {
  const _AssignClientsBottomSheet({
    required this.orgId,
    required this.trainer,
    required this.onComplete,
  });

  final int orgId;
  final Map<String, dynamic> trainer;
  final VoidCallback onComplete;

  @override
  State<_AssignClientsBottomSheet> createState() => _AssignClientsBottomSheetState();
}

class _AssignClientsBottomSheetState extends State<_AssignClientsBottomSheet> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = false;
  final Map<int, bool> _updatingMap = {};

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
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.membersListing,
        queryParameters: {
          'organization_id': widget.orgId,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (List<dynamic>.from((response.data as Map)['results'] as List? ?? []))
            : (response.data as List<dynamic>);
        if (!mounted) return;
        setState(() {
          _customers = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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

  Future<void> _toggleCustomer(Map<String, dynamic> customer, bool isCurrentlyAssigned) async {
    final customerId = customer['id'] as int;

    if (!mounted) return;
    setState(() {
      _updatingMap[customerId] = true;
    });

    try {
      // Toggle logic: assign to trainer id, or unassign (set trainer_id to null)
      final int? newTrainerId = isCurrentlyAssigned ? null : (widget.trainer['id'] as int);

      final response = await DioClient().dio.patch<dynamic>(
        ApiUris.updateMember(customerId),
        data: {
          'trainer_id': newTrainerId,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final updatedCustomer = response.data as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          final index = _customers.indexWhere((c) => c['id'] == customerId);
          if (index != -1) {
            _customers[index] = Map<String, dynamic>.from(updatedCustomer);
          }
        });
        Dialogs.showSnack(
          msg: isCurrentlyAssigned
              ? 'Unassigned ${customer['full_name']} from ${widget.trainer['name']}'
              : 'Assigned ${customer['full_name']} to ${widget.trainer['name']}',
        );
      } else {
        Dialogs.showSnack(msg: 'Failed to update assignment');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error updating assignment: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() {
        _updatingMap[customerId] = false;
      });
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerId = widget.trainer['id'] as int;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Assign clients to ${widget.trainer['name']}',
                style: AppStyles.text16Px.poppins.w600,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                    ? Center(
                        child: Text(
                          'No customers found in this gym.',
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _customers.length,
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          final customerId = customer['id'] as int;
                          final isUpdating = _updatingMap[customerId] ?? false;

                          // Check if currently assigned to this trainer
                          final assignedTrainer = customer['assigned_trainer'] as Map<dynamic, dynamic>?;
                          final bool isAssignedToThisTrainer =
                              assignedTrainer != null && assignedTrainer['id'] == trainerId;

                          String trainerLabel = '';
                          if (assignedTrainer != null) {
                            trainerLabel = isAssignedToThisTrainer
                                ? 'Assigned'
                                : 'Assigned to ${assignedTrainer['name']}';
                          } else {
                            trainerLabel = 'Unassigned';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xffF7F7F7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isAssignedToThisTrainer ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: customer['profile_picture'] != null
                                        ? Image.network(
                                            customer['profile_picture'] as String,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person, color: AppColors.primary),
                                          )
                                        : const Icon(Icons.person, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer['full_name'] as String? ?? 'N/A',
                                        style: AppStyles.text14Px.poppins.w600,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        trainerLabel,
                                        style: AppStyles.text12Px.poppins.w400.copyWith(
                                          color: isAssignedToThisTrainer
                                              ? AppColors.primary
                                              : (assignedTrainer != null ? Colors.amber.shade800 : AppColors.textGrey),
                                          fontWeight: isAssignedToThisTrainer ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                isUpdating
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Checkbox(
                                        value: isAssignedToThisTrainer,
                                        activeColor: AppColors.primary,
                                        onChanged: (val) {
                                          _toggleCustomer(customer, isAssignedToThisTrainer);
                                        },
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
