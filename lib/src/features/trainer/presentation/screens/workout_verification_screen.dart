import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_customers_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';

class WorkoutVerificationScreen extends StatefulWidget {
  const WorkoutVerificationScreen({super.key});

  @override
  State<WorkoutVerificationScreen> createState() => _WorkoutVerificationScreenState();
}

class _WorkoutVerificationScreenState extends State<WorkoutVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pendingList = [];
  List<dynamic> _historyList = [];
  bool _isLoadingPending = true;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPending();
    _fetchHistory();
  }

  Future<void> _fetchPending() async {
    setState(() {
      _isLoadingPending = true;
    });
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.pendingVerifications,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _pendingList = List<dynamic>.from(response.data as List? ?? []);
          _isLoadingPending = false;
        });
      } else {
        setState(() {
          _isLoadingPending = false;
        });
        Dialogs.showSnack(msg: 'Failed to load pending verifications');
      }
    } catch (e) {
      setState(() {
        _isLoadingPending = false;
      });
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.verificationHistory,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _historyList = List<dynamic>.from(response.data as List? ?? []);
          _isLoadingHistory = false;
        });
      } else {
        setState(() {
          _isLoadingHistory = false;
        });
        Dialogs.showSnack(msg: 'Failed to load verification history');
      }
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  Future<void> _verifyWorkout(int sessionId) async {
    final remarksController = TextEditingController();
    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify Workout Session',
              style: AppStyles.text18Px.poppins.w700.dark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Confirming this workout will mark it as verified for the client and organization.',
              style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g. Excellent execution, form was perfect.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Confirm Verification',
                style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.verifyWorkout(sessionId),
        data: {
          'status': 'verified',
          'remarks': remarksController.text.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Workout session verified successfully');
        _fetchPending();
        _fetchHistory();
      } else {
        Dialogs.showSnack(msg: 'Failed to verify workout');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error verifying workout: ${e.toString()}');
    }
  }

  void _showWorkoutDetails(Map<String, dynamic> session) {
    final exercises = session['exercises'] as List? ?? [];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              session['title'] ?? 'Workout Details',
              style: AppStyles.text18Px.poppins.w700.dark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Client: ${session['customer_name'] ?? 'Unknown'}',
              style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: exercises.isEmpty
                  ? Center(
                      child: Text(
                        'No exercises logged for this session.',
                        style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final ex = exercises[index] as Map<String, dynamic>;
                        final sets = ex['sets'] as List? ?? [];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex['exercise_name'] ?? 'Exercise',
                                  style: AppStyles.text16Px.poppins.w600.dark,
                                ),
                                const SizedBox(height: 6),
                                ...sets.map((s) {
                                  final setMap = s as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Set ${setMap['set_number'] ?? 1}:',
                                          style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${setMap['reps'] ?? 0} reps @ ${setMap['weight'] ?? 0.0} kg',
                                          style: AppStyles.text12Px.poppins.w400.dark,
                                        ),
                                        if (setMap['is_completed'] == true) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            if (session['is_verified'] != true)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _verifyWorkout(session['session_id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Verify Workout',
                  style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Verification',
          style: AppStyles.text18Px.poppins.w700.dark,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingList.isEmpty) {
      return Center(
        child: Text(
          'No pending verifications',
          style: AppStyles.text16Px.poppins.w400.copyWith(color: AppColors.textGrey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchPending,
      child: ListView.builder(
        itemCount: _pendingList.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = _pendingList[index] as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () => _showWorkoutDetails(item),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(Icons.pending_actions, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['customer_name'] ?? 'Client',
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['title'] ?? 'Workout Session',
                            style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Workout Date: ${item['started_at']?.split('T')[0] ?? ''}',
                            style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _verifyWorkout(item['session_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Verify',
                        style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyList.isEmpty) {
      return Center(
        child: Text(
          'No verification history',
          style: AppStyles.text16Px.poppins.w400.copyWith(color: AppColors.textGrey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        itemCount: _historyList.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = _historyList[index] as Map<String, dynamic>;
          final bool isVerified = item['status'] == 'verified';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isVerified ? Colors.green.shade50 : Colors.red.shade50,
                    child: Icon(
                      isVerified ? Icons.verified : Icons.cancel,
                      color: isVerified ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['customer_name'] ?? 'Client',
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verified on: ${item['verified_at']?.split('T')[0] ?? ''}',
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                        if (item['remarks'] != null && item['remarks'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Remarks: ${item['remarks']}',
                            style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
