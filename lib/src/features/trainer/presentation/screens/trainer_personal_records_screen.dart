import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/models/trainer_personal_records_model.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/repositories/trainer_personal_records_repository.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_exercise_pr_detail_screen.dart';

class TrainerPersonalRecordsScreen extends StatefulWidget {
  const TrainerPersonalRecordsScreen({
    required this.customerId,
    required this.clientName,
    super.key,
  });

  final int customerId;
  final String clientName;

  @override
  State<TrainerPersonalRecordsScreen> createState() =>
      _TrainerPersonalRecordsScreenState();
}

class _TrainerPersonalRecordsScreenState
    extends State<TrainerPersonalRecordsScreen> {
  final TrainerPersonalRecordsRepository _repository =
      TrainerPersonalRecordsRepository();

  bool _isLoading = true;
  String? _errorMessage;
  TrainerPersonalRecordsResponseModel? _data;

  String _selectedCategory = 'All';
  String _selectedSort = 'Recent';

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

    final result = await _repository.fetchPersonalRecords(widget.customerId);

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
          if (data.categories.isNotEmpty) {
            _selectedCategory = data.categories.first;
          }
        });
      },
    );
  }

  void _showSortMenu() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sort Records By',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Recent (Latest PRs)'),
                trailing: _selectedSort == 'Recent'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSort = 'Recent');
                },
              ),
              ListTile(
                title: const Text('Max Weight (Highest First)'),
                trailing: _selectedSort == 'Weight'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSort = 'Weight');
                },
              ),
              ListTile(
                title: const Text('Exercise Name (A-Z)'),
                trailing: _selectedSort == 'Name'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSort = 'Name');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('About PR Records', style: AppStyles.text16Px.poppins.w600.dark),
          ],
        ),
        content: Text(
          'Personal Records (PRs) track your client’s all-time highest weight, best repetition set, and total volume for each exercise.\n\nThey update automatically whenever a workout session is logged.',
          style: AppStyles.text13Px.poppins.w400.copyWith(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
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
        title: Text(
          'Personal Records',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textDark),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingShimmer()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    final categories = data.categories.isNotEmpty
        ? data.categories
        : ['All', 'Chest', 'Back', 'Shoulders', 'Arms', 'Legs'];

    var filteredRecords = data.records;
    if (_selectedCategory != 'All') {
      filteredRecords = filteredRecords
          .where((r) =>
              r.category.toLowerCase() == _selectedCategory.toLowerCase() ||
              r.majorMuscle.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_selectedSort == 'Weight') {
      filteredRecords.sort((a, b) =>
          (b.maxWeight?.value ?? 0).toDouble()
              .compareTo((a.maxWeight?.value ?? 0).toDouble()));
    } else if (_selectedSort == 'Name') {
      filteredRecords.sort((a, b) => a.name.compareTo(b.name));
    }

    // Calculate this month's count
    final now = DateTime.now();
    final thisMonthPrCount = data.records.where((r) {
      final dateStr = r.maxWeight?.rawDate ?? '';
      if (dateStr.length >= 7) {
        final year = int.tryParse(dateStr.substring(0, 4));
        final month = int.tryParse(dateStr.substring(5, 7));
        return year == now.year && month == now.month;
      }
      return false;
    }).length;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Banner Card
            _buildBannerCard(),
            const SizedBox(height: 16),

            // 2. Summary Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.emoji_events_outlined,
                    iconColor: const Color(0xFFE53935),
                    count: data.totalPrsCount.toString(),
                    label: 'Total PRs',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFFE53935),
                    count: '+$thisMonthPrCount',
                    label: 'This month',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Section Header: Your PR Records + Sort by
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your PR Records',
                  style: AppStyles.text18Px.poppins.w700.dark,
                ),
                InkWell(
                  onTap: _showSortMenu,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Sort by: $_selectedSort',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: const Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFFE53935),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Horizontal Category Filter Pills
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == _selectedCategory;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE53935)
                            : const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF495057),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 5. Exercise Records List
            if (filteredRecords.isEmpty)
              _buildEmptyRecordsCard()
            else
              ...filteredRecords.map(_buildExercisePrCard),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Banner Card
  // ===========================================================================
  Widget _buildBannerCard() {
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFFE53935),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PR Records',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your best performance across exercises.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Summary Metric Card
  // ===========================================================================
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
  }) {
    return Container(
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
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 10),
          Text(
            count,
            style: AppStyles.text24Px.poppins.w700.dark,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Exercise PR Card
  // ===========================================================================
  Widget _buildExercisePrCard(ExercisePrRecordModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => TrainerExercisePrDetailScreen(
                  customerId: widget.customerId,
                  record: record,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Thumbnail, Name, Category, Chevron
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: record.thumbnail != null &&
                              record.thumbnail!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: record.thumbnail!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.fitness_center_rounded,
                                  color: Color(0xFFE53935),
                                  size: 22,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.fitness_center_rounded,
                              color: Color(0xFFE53935),
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.name,
                            style: AppStyles.text15Px.poppins.w700.dark,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record.category.isNotEmpty
                                ? record.category
                                : record.majorMuscle,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3 Stats Columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPrStatColumn(
                        label: 'Max Weight',
                        icon: Icons.fitness_center_rounded,
                        iconColor: const Color(0xFFE53935),
                        valueText: record.maxWeight != null
                            ? '${record.maxWeight!.formatted} × ${record.maxWeight!.reps ?? 1}'
                            : '-',
                        dateText: record.maxWeight?.date ?? '-',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPrStatColumn(
                        label: 'Best Rep',
                        icon: Icons.sync_rounded,
                        iconColor: const Color(0xFF2E7D32),
                        valueText: record.bestReps != null
                            ? '${record.bestReps!.formatted} × ${record.bestReps!.reps ?? 1}'
                            : '-',
                        dateText: record.bestReps?.date ?? '-',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPrStatColumn(
                        label: 'Total Volume',
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFF1976D2),
                        valueText: record.totalVolume?.formatted ?? '-',
                        dateText: record.totalVolume?.date ?? '-',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrStatColumn({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String valueText,
    required String dateText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                valueText,
                style: AppStyles.text13Px.poppins.w700.dark,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          dateText,
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Empty & Loading States
  // ===========================================================================
  Widget _buildEmptyRecordsCard() {
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
          const Icon(
            Icons.fitness_center_outlined,
            size: 48,
            color: Color(0xFFBDBDBD),
          ),
          const SizedBox(height: 12),
          Text(
            'No records found for $_selectedCategory',
            style: AppStyles.text14Px.poppins.w600.dark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Records will automatically appear as workouts are logged.',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFEEEEEE),
        highlightColor: const Color(0xFFF9F9F9),
        child: Column(
          children: [
            Container(
              height: 76,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 38,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
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
              _errorMessage ?? 'Failed to load personal records',
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
