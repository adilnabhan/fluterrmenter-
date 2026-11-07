import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/trainer_reports_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/repos/trainer_reports_repository.dart';

class AllTrainersSummaryScreen extends StatefulWidget {
  final int orgId;
  final DateTime initialDate;
  final List<TrainerPerformanceItemModel>? initialTrainers;
  final int? initialTotalTrainers;

  const AllTrainersSummaryScreen({
    super.key,
    required this.orgId,
    required this.initialDate,
    this.initialTrainers,
    this.initialTotalTrainers,
  });

  @override
  State<AllTrainersSummaryScreen> createState() =>
      _AllTrainersSummaryScreenState();
}

class _AllTrainersSummaryScreenState extends State<AllTrainersSummaryScreen> {
  final TrainerReportsRepository _repository = TrainerReportsRepository();

  late DateTime _selectedDate;
  late List<TrainerPerformanceItemModel> _trainers;
  late int _totalTrainers;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _trainers = widget.initialTrainers ?? [];
    _totalTrainers = widget.initialTotalTrainers ?? _trainers.length;

    if (widget.initialTrainers == null) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.fetchTrainerReports(
      organizationId: widget.orgId,
      year: _selectedDate.year,
      month: _selectedDate.month,
    );

    if (!mounted) return;
    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.msg;
        });
      },
      (data) {
        setState(() {
          _isLoading = false;
          _trainers = data.trainers;
          _totalTrainers = data.summary.totalTrainers;
        });
      },
    );
  }

  void _onMonthChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchData();
  }

  Future<void> _showMonthPicker() async {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    int pickerYear = _selectedDate.year;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setModalState(() {
                              pickerYear--;
                            });
                          },
                        ),
                        Text(
                          '$pickerYear',
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setModalState(() {
                              pickerYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedDate.year == pickerYear &&
                            _selectedDate.month == index + 1;
                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _onMonthChanged(DateTime(pickerYear, index + 1, 1));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              months[index].substring(0, 3),
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trainer Summary',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            Text(
              'All Trainers',
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector Pill & Badge Header
              Center(
                child: _buildMonthSelector(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trainer Summary',
                    style: AppStyles.text16Px.poppins.w700.dark,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_totalTrainers trainers',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_isLoading)
                _buildShimmerList()
              else if (_errorMessage != null)
                _buildErrorState()
              else if (_trainers.isEmpty)
                _buildEmptyState()
              else
                ..._trainers.map(_buildTrainerCard),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthFormat = DateFormat('MMMM yyyy');
    final formattedMonth = monthFormat.format(_selectedDate);

    return InkWell(
      onTap: _showMonthPicker,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedMonth,
              style: AppStyles.text13Px.poppins.w600.dark,
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.unfold_more,
              size: 16,
              color: AppColors.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerCard(TrainerPerformanceItemModel trainer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEEEEEE),
                backgroundImage: trainer.profilePicture.isNotEmpty
                    ? CachedNetworkImageProvider(trainer.profilePicture)
                    : null,
                child: trainer.profilePicture.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trainer.name,
                  style: AppStyles.text15Px.poppins.w700.dark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row of 2 metric boxes: Workout Assigned & Workout Verified
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  dotColor: const Color(0xFFE67E22),
                  title: 'Workout Assigned',
                  value: trainer.workoutAssigned.count.toString(),
                  diffText: trainer.workoutAssigned.diffText,
                  diffVal: trainer.workoutAssigned.diff.toDouble(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  dotColor: const Color(0xFF27AE60),
                  title: 'Workout Verified',
                  value: trainer.workoutVerified.count.toString(),
                  diffText: trainer.workoutVerified.diffText,
                  diffVal: trainer.workoutVerified.diff.toDouble(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Box 3: Avg. Verified Rate
          _buildMetricTile(
            dotColor: const Color(0xFF8E44AD),
            title: 'Avg. verified rate',
            value: '${trainer.avgVerifiedRate.rate.toStringAsFixed(0)}%',
            diffText: trainer.avgVerifiedRate.diffText,
            diffVal: trainer.avgVerifiedRate.diff,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required Color dotColor,
    required String title,
    required String value,
    required String diffText,
    required double diffVal,
  }) {
    final bool isPositive = diffVal > 0;
    final bool isNegative = diffVal < 0;
    final Color diffColor = isPositive
        ? const Color(0xFF2E7D32)
        : (isNegative ? const Color(0xFFD32F2F) : AppColors.textGrey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.text22Px.poppins.w700.dark,
          ),
          const SizedBox(height: 4),
          Text(
            diffText.isNotEmpty ? diffText : '0 vs previous',
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: diffColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFF9F9F9),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.textGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No trainers found for this month',
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: AppStyles.text14Px.poppins.w500.dark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
