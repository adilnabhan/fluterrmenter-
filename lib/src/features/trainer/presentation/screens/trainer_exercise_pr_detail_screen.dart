import 'dart:math' as math;
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/models/trainer_personal_records_model.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/repositories/trainer_personal_records_repository.dart';

class TrainerExercisePrDetailScreen extends StatefulWidget {
  const TrainerExercisePrDetailScreen({
    required this.customerId,
    required this.record,
    super.key,
  });

  final int customerId;
  final ExercisePrRecordModel record;

  @override
  State<TrainerExercisePrDetailScreen> createState() =>
      _TrainerExercisePrDetailScreenState();
}

class _TrainerExercisePrDetailScreenState
    extends State<TrainerExercisePrDetailScreen> {
  final TrainerPersonalRecordsRepository _repository =
      TrainerPersonalRecordsRepository();

  late ExercisePrRecordModel _record;
  String _selectedMetric = 'Max Weight';

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _refreshRecord();
  }

  Future<void> _refreshRecord() async {
    final result = await _repository.fetchExerciseRecord(
      customerId: widget.customerId,
      workoutId: widget.record.workoutId,
    );

    if (!mounted) return;
    result.fold(
      (_) {},
      (updated) {
        setState(() {
          _record = updated;
        });
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
        title: Text(
          'Details',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Exercise Header Card
            _buildExerciseHeaderCard(),
            const SizedBox(height: 20),

            // 2. Progress Over Time Section
            _buildProgressOverTimeSection(),
            const SizedBox(height: 24),

            // 3. All Time Bests Section
            _buildAllTimeBestsSection(),
            const SizedBox(height: 20),

            // 4. Insights Section (if available)
            if (_record.insights != null && _record.insights!.isNotEmpty)
              _buildInsightsCard(_record.insights!),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. Exercise Header Card
  // ===========================================================================
  Widget _buildExerciseHeaderCard() {
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _record.thumbnail != null && _record.thumbnail!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: _record.thumbnail!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFFE53935),
                        size: 28,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFFE53935),
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _record.name,
                  style: AppStyles.text20Px.poppins.w700.dark,
                ),
                const SizedBox(height: 4),
                Text(
                  _record.category.isNotEmpty
                      ? _record.category
                      : _record.majorMuscle,
                  style: AppStyles.text14Px.poppins.w400.copyWith(
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
  // 2. Progress Over Time Section
  // ===========================================================================
  Widget _buildProgressOverTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Over Time',
              style: AppStyles.text16Px.poppins.w700.dark,
            ),
            _buildMetricDropdown(),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildMetricDropdown() {
    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedMetric = val;
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Max Weight',
          child: Text('Max Weight'),
        ),
        const PopupMenuItem(
          value: 'Best Reps',
          child: Text('Best Reps'),
        ),
        const PopupMenuItem(
          value: 'Total Volume',
          child: Text('Total Volume'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedMetric,
              style: AppStyles.text12Px.poppins.w500.dark,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final progress = _record.progressOverTime;
    final timeline = progress?.timeline ?? [];

    if (timeline.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No progress data recorded yet',
            style: AppStyles.text13Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    final List<double> values = timeline.map((e) {
      if (_selectedMetric == 'Best Reps') {
        return e.reps.toDouble();
      } else if (_selectedMetric == 'Total Volume') {
        return e.totalVolume.toDouble();
      }
      return e.value.toDouble();
    }).toList();

    final List<String> labels = timeline.map((e) => e.displayDate).toList();
    final double maxVal = values.isNotEmpty
        ? values.reduce(math.max)
        : 100.0;
    final double peakVal = maxVal > 0 ? maxVal : 50.0;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: _PrProgressChartPainter(
              values: values,
              labels: labels,
              peakValue: peakVal,
              unit: _selectedMetric == 'Best Reps' ? 'reps' : 'kg',
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. All Time Bests Section
  // ===========================================================================
  Widget _buildAllTimeBestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Time Bests',
              style: AppStyles.text16Px.poppins.w700.dark,
            ),
            const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.textGrey,
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
              _buildBestRow(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFE53935),
                iconBg: const Color(0xFFFFF0F1),
                title: 'Max Weight',
                description: 'Highest weight lifted for 1 rep',
                value: _record.maxWeight?.displayText ??
                    '${_record.maxWeight?.formatted ?? '-'} × ${_record.maxWeight?.reps ?? 1}',
              ),
              const Divider(height: 1, color: Color(0xFFF1F3F5)),
              _buildBestRow(
                icon: Icons.sync_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                title: 'Best Reps',
                description: 'Highest reps at a given weight',
                value: _record.bestReps?.displayText ??
                    '${_record.bestReps?.formatted ?? '-'} × ${_record.bestReps?.reps ?? 1}',
              ),
              const Divider(height: 1, color: Color(0xFFF1F3F5)),
              _buildBestRow(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFF1976D2),
                iconBg: const Color(0xFFE3F2FD),
                title: 'Total Volume',
                description: 'Highest total volume in a workout',
                value: _record.totalVolume?.formatted ?? '-',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBestRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.text14Px.poppins.w600.dark,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: AppStyles.text14Px.poppins.w700.dark,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. Insights Section
  // ===========================================================================
  Widget _buildInsightsCard(String insights) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFF57F17),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: AppStyles.text13Px.poppins.w700.copyWith(
                    color: const Color(0xFFF57F17),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insights,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Custom Line Chart Painter
// =============================================================================
class _PrProgressChartPainter extends CustomPainter {
  _PrProgressChartPainter({
    required this.values,
    required this.labels,
    required this.peakValue,
    required this.unit,
  });

  final List<double> values;
  final List<String> labels;
  final double peakValue;
  final String unit;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const double leftPadding = 32.0;
    const double bottomPadding = 24.0;
    const double topPadding = 30.0;
    const double rightPadding = 48.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = (maxVal - minVal) > 0 ? (maxVal - minVal) : 1.0;

    // Grid lines & Y-axis labels
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final ySteps = [0.0, 0.5, 1.0];
    for (final step in ySteps) {
      final y = topPadding + chartHeight * (1.0 - step);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding + 20, y),
        gridPaint,
      );

      final labelVal = (minVal + range * step).toInt();
      textPainter.text = TextSpan(
        text: '$labelVal',
        style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth * i / (values.length - 1));
      final normY = (values[i] - minVal) / range;
      final y = topPadding + chartHeight * (1.0 - normY);
      points.add(Offset(x, y));
    }

    // Gradient fill under curve
    if (points.isNotEmpty) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, topPadding + chartHeight);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(points.last.dx, topPadding + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33E53935),
            Color(0x00E53935),
          ],
        ).createShader(
          Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
        );

      canvas.drawPath(fillPath, fillPaint);
    }

    // Line Path
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // Data points & peak indicator
    final dotPaint = Paint()..color = const Color(0xFFE53935);
    final dotWhitePaint = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 2.5, dotWhitePaint);

      // Value text above dot
      textPainter.text = TextSpan(
        text: '${values[i].toInt()}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, pt.dy - textPainter.height - 4),
      );

      // X-axis label
      if (i < labels.length) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            pt.dx - textPainter.width / 2,
            topPadding + chartHeight + 6,
          ),
        );
      }
    }

    // Peak badge if peak is at the end or peak point
    if (points.isNotEmpty) {
      final lastPt = points.last;
      final badgeText = '${peakValue.toInt()} $unit';
      textPainter.text = TextSpan(
        text: badgeText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      textPainter.layout();

      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          lastPt.dx - textPainter.width / 2 - 6,
          lastPt.dy - textPainter.height - 18,
          textPainter.width + 12,
          textPainter.height + 6,
        ),
        const Radius.circular(8),
      );

      canvas.drawRRect(badgeRect, Paint()..color = const Color(0xFFE53935));
      textPainter.paint(
        canvas,
        Offset(
          lastPt.dx - textPainter.width / 2,
          lastPt.dy - textPainter.height - 15,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PrProgressChartPainter oldDelegate) => true;
}
