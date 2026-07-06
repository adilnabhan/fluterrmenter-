import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_workout_session_detail_screen.dart';

class TrainerPendingVerificationsScreen extends StatefulWidget {
  const TrainerPendingVerificationsScreen({super.key});

  @override
  State<TrainerPendingVerificationsScreen> createState() =>
      _TrainerPendingVerificationsScreenState();
}

class _TrainerPendingVerificationsScreenState
    extends State<TrainerPendingVerificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _pendingVerifications = [];
  List<Map<String, dynamic>> _verificationHistory = [];

  bool _isLoadingPending = true;
  bool _isLoadingHistory = true;

  Map<String, String> _clientProfilesByName = {};
  Map<int, String> _clientProfilesById = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchClientProfiles();
    _fetchPendingVerifications();
    _fetchVerificationHistory();
  }

  Future<void> _fetchClientProfiles() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (List<dynamic>.from((response.data as Map)['results'] as List? ?? []))
            : (response.data as List<dynamic>);
        final Map<String, String> byName = {};
        final Map<int, String> byId = {};
        for (final e in data) {
          if (e is Map) {
            final String name = e['name'] as String? ?? '';
            final String pic = e['profile_picture'] as String? ?? e['image_url'] as String? ?? '';
            final int id = e['id'] as int? ?? 0;
            if (name.isNotEmpty && pic.isNotEmpty) {
              byName[name] = pic;
            }
            if (id > 0 && pic.isNotEmpty) {
              byId[id] = pic;
            }
          }
        }
        if (mounted) {
          setState(() {
            _clientProfilesByName = byName;
            _clientProfilesById = byId;
          });
        }
      }
    } catch (_) {}
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        _fetchPendingVerifications();
      } else {
        _fetchVerificationHistory();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPendingVerifications() async {
    if (!mounted) return;
    setState(() => _isLoadingPending = true);

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.pendingVerifications,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final pendingList =
            data['pending_verifications'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _pendingVerifications =
                pendingList
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
            _isLoadingPending = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingPending = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPending = false);
      Dialogs.showSnack(msg: 'Failed to load pending verifications');
    }
  }

  Future<void> _fetchVerificationHistory() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.verificationHistory,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List<dynamic>;
        if (mounted) {
          setState(() {
            _verificationHistory =
                data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
      Dialogs.showSnack(msg: 'Failed to load verification history');
    }
  }

  Future<void> _verifyOrReject(
    int sessionId,
    String status,
    String remarks,
  ) async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.verifyWorkoutSession(sessionId),
        data: {'verification_status': status, 'remarks': remarks},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Workout $status successfully');
        _fetchPendingVerifications();
        _fetchVerificationHistory();
      } else {
        Dialogs.showSnack(msg: 'Failed to update status');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  void _showVerificationDialog(
    int sessionId,
    String customerName,
    String title,
    bool isVerify,
  ) {
    final remarksController = TextEditingController();
    final status = isVerify ? 'verified' : 'rejected';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isVerify ? 'Verify Workout' : 'Reject Workout',
            style: AppStyles.text18Px.poppins.w600.dark,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to ${isVerify ? 'verify' : 'reject'} $customerName\'s $title session?',
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add remarks (optional)',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyOrReject(
                  sessionId,
                  status,
                  remarksController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isVerify ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isVerify ? 'Verify' : 'Reject',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        centerTitle: false,
        title: Text(
          'Verifications',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          labelStyle: AppStyles.text14Px.poppins.w600,
          unselectedLabelStyle: AppStyles.text14Px.poppins.w500,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPendingTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingVerifications.isEmpty) {
      return _buildEmptyState(
        'No Pending Verifications',
        'You have caught up with all client workouts.',
        Icons.verified_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingVerifications.length,
      itemBuilder: (context, index) {
        final item = _pendingVerifications[index];
        final sessionId = item['session_id'] as int? ?? 0;
        final customerName = item['customer_name'] as String? ?? 'Client';
        final customerId = item['customer_id'] as int? ?? 0;
        final profilePic = item['customer_profile_picture'] as String? ?? 
                           item['profile_picture'] as String? ?? 
                           item['customer_image'] as String? ?? 
                           item['image_url'] as String? ??
                           (item['customer'] is Map ? (item['customer'] as Map)['profile_picture'] as String? : null) ??
                           _clientProfilesById[customerId] ??
                           _clientProfilesByName[customerName];
        final workoutTitle = item['workout_title'] as String? ?? 'Workout';
        final completedAtRaw = item['completed_at'] as String? ?? '';
        String completedAt = completedAtRaw;
        if (completedAtRaw.isNotEmpty) {
          final parsed = DateTime.tryParse(completedAtRaw);
          if (parsed != null) {
            final local = parsed.toLocal();
            final hour =
                local.hour == 0
                    ? 12
                    : (local.hour > 12 ? local.hour - 12 : local.hour);
            final amPm = local.hour >= 12 ? 'PM' : 'AM';
            completedAt =
                '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:${local.minute.toString().padLeft(2, '0')} $amPm';
          }
        }

        return GestureDetector(
          onTap: () {
            if (sessionId > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TrainerWorkoutSessionDetailScreen(
                        sessionId: sessionId,
                      ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profilePic != null && profilePic.isNotEmpty)
                      ProfileImage(
                        isEdit: false,
                        url: profilePic,
                        radius: 20,
                      )
                    else
                      const Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workoutTitle,
                            style: AppStyles.text15Px.poppins.w600.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (completedAt.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            completedAt,
                            style: AppStyles.text10Px.poppins.w500.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: OutlinedButton(
                          onPressed:
                              () => _showVerificationDialog(
                                sessionId,
                                customerName,
                                workoutTitle,
                                false,
                              ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed:
                              () => _showVerificationDialog(
                                sessionId,
                                customerName,
                                workoutTitle,
                                true,
                              ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Verify',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_verificationHistory.isEmpty) {
      return _buildEmptyState(
        'No History',
        'You have not verified any workouts yet.',
        Icons.history,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _verificationHistory.length,
      itemBuilder: (context, index) {
        final item = _verificationHistory[index];
        final customerName = item['customer_name'] as String? ?? 'Client';
        final customerId = item['customer_id'] as int? ?? 0;
        final profilePic = item['customer_profile_picture'] as String? ?? 
                           item['profile_picture'] as String? ?? 
                           item['customer_image'] as String? ?? 
                           item['image_url'] as String? ??
                           (item['customer'] is Map ? (item['customer'] as Map)['profile_picture'] as String? : null) ??
                           _clientProfilesById[customerId] ??
                           _clientProfilesByName[customerName];
        final workoutTitle = item['workout_title'] as String? ?? 'Workout';
        final verifiedAtRaw = item['verified_at'] as String? ?? '';
        final sessionId = item['session_id'] as int? ?? 0;
        String verifiedAt = verifiedAtRaw;
        if (verifiedAtRaw.isNotEmpty) {
          final parsed = DateTime.tryParse(verifiedAtRaw);
          if (parsed != null) {
            final local = parsed.toLocal();
            final hour =
                local.hour == 0
                    ? 12
                    : (local.hour > 12 ? local.hour - 12 : local.hour);
            final amPm = local.hour >= 12 ? 'PM' : 'AM';
            verifiedAt =
                '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:${local.minute.toString().padLeft(2, '0')} $amPm';
          }
        }
        final status = item['verification_status'] as String? ?? '';
        final remarks = item['remarks'] as String? ?? '';
        final isVerified = status == 'verified';

        return GestureDetector(
          onTap: () {
            if (sessionId > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TrainerWorkoutSessionDetailScreen(
                        sessionId: sessionId,
                      ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        workoutTitle,
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isVerified
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isVerified ? 'Verified' : 'Rejected',
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: isVerified ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (profilePic != null && profilePic.isNotEmpty)
                      ProfileImage(
                        isEdit: false,
                        url: profilePic,
                        radius: 20,
                      )
                    else
                      const Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      customerName,
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                if (verifiedAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Date: $verifiedAt',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
                if (remarks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          size: 16,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            remarks,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textDark,
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
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
