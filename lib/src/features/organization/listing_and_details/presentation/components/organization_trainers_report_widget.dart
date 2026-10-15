import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/trainer_reports_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/repos/trainer_reports_repository.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/all_trainers_summary_screen.dart';

class OrganizationTrainersReportWidget extends StatefulWidget {
  final int orgId;

  const OrganizationTrainersReportWidget({
    super.key,
    required this.orgId,
  });

  @override
  State<OrganizationTrainersReportWidget> createState() =>
      _OrganizationTrainersReportWidgetState();
}

class _OrganizationTrainersReportWidgetState
    extends State<OrganizationTrainersReportWidget> {
  final TrainerReportsRepository _repository = TrainerReportsRepository();

  bool _isLoading = true;
  String? _errorMessage;
  TrainerReportsResponseModel? _data;

  DateTime _selectedDate = DateTime.now();
  bool _isDrilldownExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
          _data = data;
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
    await AppMonthPickerBottomSheet.show(
      context,
      initialDate: _selectedDate,
      onSelected: _onMonthChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_data == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Activity Card (Today)
            _buildLiveActivityCard(_data!.liveActivity),
            const SizedBox(height: 16),

            // 2. Month Selector Pill
            Center(
              child: _buildMonthSelector(),
            ),
            const SizedBox(height: 16),

            // 3. Trainer Summary Header
            _buildSummaryHeader(_data!.summary.totalTrainers),
            const SizedBox(height: 12),

            // 4. Trainer Summary & Drilldown
            _buildSummaryCard(_data!.summary),
            const SizedBox(height: 24),
            _buildDrilldownSection(_data!.trainers),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. Live Activity Card
  // ===========================================================================
  Widget _buildLiveActivityCard(LiveActivityModel live) {
    final double verifiedProgress = (live.verifiedRate / 100.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Live Activity',
                    style: AppStyles.text16Px.poppins.w600.dark,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sensors,
                          color: Color(0xFF2E7D32),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                'Today',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Metric Pills
          Row(
            children: [
              Expanded(
                child: _buildLiveMetricBox(
                  label: 'Assigned',
                  value: live.assigned.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLiveMetricBox(
                  label: 'Verified',
                  value: live.verified.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLiveMetricBox(
                  label: 'Pending',
                  value: live.pending.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Verified Rate Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's verified rate",
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                '${live.verifiedRate.toStringAsFixed(0)}%',
                style: AppStyles.text14Px.poppins.w700.dark,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: verifiedProgress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMetricBox({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppStyles.text20Px.poppins.w700.dark,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. Month Selector Pill
  // ===========================================================================
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

  // ===========================================================================
  // 3. Trainer Summary Header
  // ===========================================================================
  Widget _buildSummaryHeader(int totalTrainers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trainer Summary',
          style: AppStyles.text16Px.poppins.w700.dark,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$totalTrainers trainers',
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. Summary Card (2x2 Grid)
  // ===========================================================================
  Widget _buildSummaryCard(TrainerSummaryModel summary) {
    return Container(
      width: double.infinity,
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  dotColor: const Color(0xFFE67E22),
                  title: 'Workout Assigned',
                  value: summary.workoutAssigned.count.toString(),
                  diffText: summary.workoutAssigned.diffText,
                  diffVal: summary.workoutAssigned.diff.toDouble(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  dotColor: const Color(0xFF27AE60),
                  title: 'Workout Verified',
                  value: summary.workoutVerified.count.toString(),
                  diffText: summary.workoutVerified.diffText,
                  diffVal: summary.workoutVerified.diff.toDouble(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  dotColor: const Color(0xFF8E44AD),
                  title: 'Avg. verified rate',
                  value: '${summary.avgVerifiedRate.rate.toStringAsFixed(0)}%',
                  diffText: summary.avgVerifiedRate.diffText,
                  diffVal: summary.avgVerifiedRate.diff,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTopTrainerTile(summary.topTrainer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AllTrainersSummaryScreen(
                    orgId: widget.orgId,
                    initialDate: _selectedDate,
                    initialTrainers: _data!.trainers,
                    initialTotalTrainers: _data!.summary.totalTrainers,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View more details',
                    style: AppStyles.text13Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ),
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

  Widget _buildTopTrainerTile(TopTrainerModel? topTrainer) {
    return Container(
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
                decoration: const BoxDecoration(
                  color: Color(0xFF2ECC71),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Top trainer',
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
            topTrainer != null ? topTrainer.name : 'N/A',
            style: AppStyles.text18Px.poppins.w700.dark,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            topTrainer != null ? '${topTrainer.totalClients} clients' : '0 clients',
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Drilldown Section (Top Trainers Preview)
  // ===========================================================================
  Widget _buildDrilldownSection(List<TrainerPerformanceItemModel> trainers) {
    if (trainers.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayList = _isDrilldownExpanded
        ? trainers
        : trainers.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Drilldown',
              style: AppStyles.text16Px.poppins.w700.dark,
            ),
            Text(
              'Top trainers',
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
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
            children: [
              ...displayList.asMap().entries.map((entry) {
                final int idx = entry.key;
                final trainer = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainer.name,
                                  style: AppStyles.text14Px.poppins.w600.dark,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${trainer.totalClients} clients • ${trainer.verifiedClients} verified',
                                  style: AppStyles.text12Px.poppins.w400.copyWith(
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Verified',
                                style: AppStyles.text12Px.poppins.w400.copyWith(
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${trainer.verifiedRate.toStringAsFixed(0)}%',
                                style: AppStyles.text16Px.poppins.w700.dark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (idx < displayList.length - 1)
                      const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  ],
                );
              }),
              if (trainers.length > 3) ...[
                const Divider(height: 1, color: Color(0xFFF1F3F5)),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isDrilldownExpanded = !_isDrilldownExpanded;
                    });
                  },
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isDrilldownExpanded ? 'Collapse' : 'Expand',
                          style: AppStyles.text13Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        Icon(
                          _isDrilldownExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }



  // ===========================================================================
  // Loading & Error States
  // ===========================================================================
  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFEEEEEE),
        highlightColor: const Color(0xFFF9F9F9),
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 36,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
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
