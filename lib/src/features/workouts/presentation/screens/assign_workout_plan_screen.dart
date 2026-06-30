import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class AssignWorkoutPlanScreen extends StatefulWidget {
  final int planId;
  final String planTitle;

  const AssignWorkoutPlanScreen({
    required this.planId,
    required this.planTitle,
    super.key,
  });

  @override
  State<AssignWorkoutPlanScreen> createState() => _AssignWorkoutPlanScreenState();
}

class _AssignWorkoutPlanScreenState extends State<AssignWorkoutPlanScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _customers = [];
  final Map<int, bool> _assigningMap = {}; // Tracks loading state per customer toggle

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
        ApiUris.assignWorkoutPlan(widget.planId),
        queryParameters: {
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
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

  Future<void> _assignWorkout(int customerId) async {
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

    if (confirmed != true) return;

    final enteredTitle = titleController.text.trim();
    final String finalTitle = enteredTitle.isNotEmpty ? enteredTitle : widget.planTitle;

    if (!mounted) return;
    setState(() {
      _assigningMap[customerId] = true;
    });

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.assignWorkoutPlan(widget.planId),
        data: {
          'customer_id': customerId,
          'title': finalTitle,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (!mounted) return;
      setState(() {
        _assigningMap[customerId] = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        setState(() {
          for (var i = 0; i < _customers.length; i++) {
            if (_customers[i]['customer_id'] == customerId) {
              _customers[i]['is_assigned'] = true;
              break;
            }
          }
        });
        Dialogs.showSnack(msg: 'Plan assigned successfully');
      } else {
        Dialogs.showSnack(msg: 'Failed to assign plan');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _assigningMap[customerId] = false;
      });
      String errorMsg = 'Error assigning plan';
      if (e.response?.data is Map) {
        errorMsg = (e.response!.data as Map)['error']?.toString() ?? errorMsg;
      }
      Dialogs.showSnack(msg: errorMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _assigningMap[customerId] = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const PopButton().center,
        titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
        title: Text('Assign: ${widget.planTitle}'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) {
                _searchQuery = q;
                EasyDebounce.debounce(
                  'assign_workout_search',
                  const Duration(milliseconds: 300),
                  () {
                    _fetchCustomers();
                  },
                );
              },
              decoration: InputDecoration(
                hintText: 'Search for client name',
                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                filled: false,
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xffF7F7F7),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _customers.isEmpty
                      ? const Center(child: Text('No customers found'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _customers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final customer = _customers[index];
                            final int customerId = customer['customer_id'] as int;
                            final String name = customer['name'] as String;
                            final String? mobile = customer['mobile'] as String?;
                            final String? pic = customer['profile_picture'] as String?;
                            final bool isAssigned = customer['is_assigned'] as bool? ?? false;
                            final bool isToggling = _assigningMap[customerId] ?? false;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ProfileImage(
                                      isEdit: false,
                                      url: pic ?? '',
                                      radius: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppStyles.text14Px.poppins.w500.dark,
                                        ),
                                        if (mobile != null && mobile.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            mobile,
                                            style: AppStyles.text12Px.poppins.w400.textGrey,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  isToggling
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : ElevatedButton(
                                          onPressed: () => _assignWorkout(customerId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isAssigned
                                                ? const Color(0xffE2E2E2)
                                                : const Color(0xFFD30000),
                                            foregroundColor: isAssigned ? Colors.black87 : Colors.white,
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
                                            isAssigned ? 'Assign Again' : 'Assign',
                                            style: AppStyles.text12Px.poppins.w600,
                                          ),
                                        ),
                                ],
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
}
