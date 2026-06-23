import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  const TrainerClientDetailScreen({required this.customerId, super.key});

  final int customerId;

  @override
  State<TrainerClientDetailScreen> createState() => _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen> {
  Map<String, dynamic> _clientData = {};
  bool _isLoading = true;
  bool _isSavingNotes = false;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _fetchClientDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _clientData = Map<String, dynamic>.from(response.data as Map);
          final profile = _clientData['profile'] as Map<dynamic, dynamic>? ?? {};
          _notesController.text = profile['trainer_notes'] as String? ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load client details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading client details: ${e.toString()}');
    }
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isSavingNotes = true;
    });

    try {
      final response = await DioClient().dio.put<dynamic>(
        ApiUris.trainerCustomerDetails(widget.customerId),
        data: {
          'trainer_notes': _notesController.text.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        Dialogs.showSnack(msg: 'Remarks saved successfully');
      } else {
        Dialogs.showSnack(msg: 'Failed to save remarks');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error saving remarks: ${e.toString()}');
    } finally {
      setState(() {
        _isSavingNotes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF7F7F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _clientData['profile'] as Map<String, dynamic>? ?? {};
    final membership = _clientData['membership'] as Map<String, dynamic>? ?? {};
    final assignedPlans = _clientData['assigned_plans'] as List<dynamic>? ?? [];
    final prRecords = _clientData['pr_records'] as List<dynamic>? ?? [];
    final recentSessions = _clientData['recent_sessions'] as List<dynamic>? ?? [];

    final name = profile['name'] ?? 'N/A';
    final mobile = profile['mobile'] ?? 'N/A';
    final email = profile['email'] ?? 'N/A';
    final gender = profile['gender'] ?? 'N/A';
    final height = profile['height'] ?? 'N/A';
    final weight = profile['weight'] ?? 'N/A';
    final bmi = profile['bmi'] ?? 'N/A';
    final fitnessLevel = profile['fitness_level'] ?? 'N/A';
    final imgUrl = profile['profile_picture'];

    final hasActiveMembership = membership.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text(
          'Client Details',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client main profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.iconBackground,
                    ),
                    child: ClipOval(
                      child: imgUrl != null
                          ? Image.network(
                              imgUrl as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person, size: 30, color: AppColors.primary),
                            )
                          : const Icon(Icons.person, size: 30, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mobile: $mobile',
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                        Text(
                          'Email: $email',
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Health & Body Stats
            Text(
              'Health & Body Stats',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatRow('Gender', gender),
                  const Divider(height: 20, thickness: 0.5),
                  _buildStatRow('Height', '$height cm'),
                  const Divider(height: 20, thickness: 0.5),
                  _buildStatRow('Weight', '$weight kg'),
                  const Divider(height: 20, thickness: 0.5),
                  _buildStatRow('BMI', '$bmi'),
                  const Divider(height: 20, thickness: 0.5),
                  _buildStatRow('Fitness Level', fitnessLevel),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Membership info
            Text(
              'Gym Membership',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: hasActiveMembership
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF43A047)),
                            const SizedBox(width: 8),
                            Text(
                              membership['plan_name'] ?? 'Active Plan',
                              style: AppStyles.text14Px.poppins.w600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gym: ${membership['organization'] ?? "N/A"}',
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                        Text(
                          'Valid: ${membership['start_date'] ?? ""} to ${membership['end_date'] ?? ""}',
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'No active membership plan',
                          style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Trainer Notes & Remarks (Editable)
            Text(
              'Trainer Remarks & Progress Notes',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add progress logs, dietary notes, or remarks...',
                      hintStyle: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      fillColor: const Color(0xffF7F7F7),
                      filled: true,
                    ),
                    style: AppStyles.text13Px.poppins.w400,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: Button.filled(
                      ontap: _isSavingNotes ? () {} : _saveNotes,
                      title: 'Save Notes',
                      buttonColor: AppColors.primary,
                      isLoading: _isSavingNotes,
                      style: AppStyles.text14Px.poppins.w600.light,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assigned workout plans
            Text(
              'Assigned Workout Plans',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: assignedPlans.isEmpty
                  ? Center(
                      child: Text(
                        'No workout plans assigned.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : Column(
                      children: assignedPlans.map((plan) {
                        final planName = plan['plan_name'] ?? 'Plan';
                        final statusStr = plan['status'] ?? 'active';
                        final days = plan['total_days'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF7F7F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    planName,
                                    style: AppStyles.text13Px.poppins.w600,
                                  ),
                                  Text(
                                    '$days Days duration',
                                    style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusStr == 'active' ? const Color(0xffE8F5E9) : const Color(0xffE0E0E0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusStr.toUpperCase(),
                                  style: AppStyles.text10Px.poppins.w600.copyWith(
                                    color: statusStr == 'active' ? const Color(0xFF43A047) : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 20),

            // PR records
            Text(
              'Personal Records (PR)',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: prRecords.isEmpty
                  ? Center(
                      child: Text(
                        'No personal records logged yet.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : Column(
                      children: prRecords.map((pr) {
                        final workout = pr['workout_name'] ?? 'Workout';
                        final val = pr['value'] ?? '';
                        final unit = pr['unit'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(workout, style: AppStyles.text13Px.poppins.w500),
                              Text('$val $unit', style: AppStyles.text13Px.poppins.w600.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 20),

            // Recent Sessions
            Text(
              'Recent Completed Sessions',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: recentSessions.isEmpty
                  ? Center(
                      child: Text(
                        'No completed sessions logged.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : Column(
                      children: recentSessions.map((session) {
                        final dateStr = session['session_date'] ?? '';
                        final titleStr = session['plan_day_title'] ?? 'Session';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(titleStr, style: AppStyles.text13Px.poppins.w500),
                              Text(dateStr, style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text13Px.poppins.w500.copyWith(color: AppColors.textGrey),
        ),
        Text(
          value,
          style: AppStyles.text13Px.poppins.w600,
        ),
      ],
    );
  }
}
