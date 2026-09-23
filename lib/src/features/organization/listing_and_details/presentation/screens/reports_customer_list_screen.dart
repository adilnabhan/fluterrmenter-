import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/member_detials_screen.dart';

class ReportsCustomerListScreen extends StatefulWidget {
  final int orgId;
  final String filterType;
  final String filterValue;
  final String filterLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? count;

  const ReportsCustomerListScreen({
    super.key,
    required this.orgId,
    required this.filterType,
    required this.filterValue,
    required this.filterLabel,
    this.startDate,
    this.endDate,
    this.count,
  });

  @override
  State<ReportsCustomerListScreen> createState() => _ReportsCustomerListScreenState();
}

class _ReportsCustomerListScreenState extends State<ReportsCustomerListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isPaginating = false;
  int _currentPage = 1;
  int _totalPages = 1;
  List<dynamic> _customers = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.count == 0) {
      _isLoading = false;
    } else {
      _fetchCustomers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && !_isPaginating && _currentPage < _totalPages) {
        _fetchCustomers(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchCustomers({int page = 1, String? search}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isPaginating = true;
      });
    }

    try {
      final Map<String, dynamic> queryParams = {
        'organization_id': widget.orgId,
        'page': page,
        'page_size': 15,
      };

      if (widget.filterType == 'gender') {
        queryParams['gender'] = widget.filterValue.toLowerCase();
      } else if (widget.filterType == 'age_group') {
        queryParams['age_group'] = widget.filterValue;
      } else if (widget.filterType == 'goal') {
        queryParams['goal'] = widget.filterValue;
      } else if (widget.filterType == 'profession') {
        queryParams['profession'] = widget.filterValue;
      } else if (widget.filterType == 'sleep_hours') {
        queryParams['sleep_hours'] = widget.filterValue;
      } else if (widget.filterType == 'working_hours') {
        queryParams['working_hours'] = widget.filterValue;
      }

      if (widget.startDate != null) {
        queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(widget.startDate!);
      }
      if (widget.endDate != null) {
        queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(widget.endDate!);
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await DioClient().dio.get<dynamic>(
        ApiUris.reportsCustomers,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        final totalCount = data['count'] as int? ?? 0;
        final calculatedTotalPages = (totalCount / 15).ceil();

        setState(() {
          if (page == 1) {
            _customers = results;
          } else {
            _customers.addAll(results);
          }
          _currentPage = page;
          _totalPages = calculatedTotalPages > 0 ? calculatedTotalPages : 1;
        });
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error loading customers');
    } finally {
      setState(() {
        _isLoading = false;
        _isPaginating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.filterLabel,
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            Text(
              'Customer List',
              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (q) {
                EasyDebounce.debounce(
                  'reports_customers_search',
                  const Duration(milliseconds: 300),
                  () => _fetchCustomers(search: q),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search by name or phone number',
                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                filled: true,
                fillColor: const Color(0xffF5F5F5),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Customer List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                    ? Center(
                        child: Text(
                          'No customers found',
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _customers.length + (_isPaginating ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _customers.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          final customer = _customers[index] as Map<String, dynamic>;
                          final name = customer['name']?.toString() ?? 'Unknown';
                          final phone = customer['phone']?.toString() ?? 'No phone';
                          final image = customer['profile_image']?.toString() ?? '';
                          final status = customer['membership_status']?.toString() ?? 'Active';
                          final goal = customer['goal']?.toString() ?? '';
                          final profession = customer['profession']?.toString() ?? '';
                          final sleepHours = customer['sleep_hours']?.toString() ?? '';
                          final workingHours = customer['working_hours']?.toString() ?? '';

                          final extraTag = profession.isNotEmpty
                              ? profession
                              : (sleepHours.isNotEmpty
                                  ? 'Sleep: $sleepHours'
                                  : (workingHours.isNotEmpty ? 'Work: $workingHours' : ''));

                          return InkWell(
                            onTap: () {
                              final customerId = customer['id'] as int?;
                              if (customerId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberDetialsScreen(memberId: customerId),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xffEEEEEE)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.01),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  GestureDetector(
                                    onTap: () {
                                      if (image.isNotEmpty) {
                                        _showEnlargedProfilePhoto(
                                          context,
                                          image,
                                        );
                                      } else {
                                        unawaited(Dialogs.showSnack(
                                          msg: 'No profile photo uploaded for $name',
                                        ));
                                      }
                                    },
                                    child: ClipOval(
                                      child: ProfileImage(
                                        isEdit: false,
                                        url: image,
                                        radius: 44,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppStyles.text14Px.poppins.w600.dark,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          phone,
                                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                        ),
                                        if (goal.isNotEmpty || extraTag.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              if (goal.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    goal,
                                                    style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.primary),
                                                  ),
                                                ),
                                              if (extraTag.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xff3498DB).withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    extraTag,
                                                    style: AppStyles.text10Px.poppins.w500.copyWith(color: const Color(0xff3498DB)),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Status Indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: status.toLowerCase() == 'active'
                                          ? const Color(0xffE8F8F5)
                                          : const Color(0xffFDEDEC),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: AppStyles.text10Px.poppins.w600.copyWith(
                                        color: status.toLowerCase() == 'active'
                                            ? const Color(0xff117A65)
                                            : const Color(0xffC0392B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showEnlargedProfilePhoto(
    BuildContext context,
    String imageUrl,
  ) {
    Dialogs.showEnlargedProfilePhoto(context, imageUrl);
  }
}
