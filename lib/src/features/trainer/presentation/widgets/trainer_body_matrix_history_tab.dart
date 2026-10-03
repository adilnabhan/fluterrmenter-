import 'package:mentor_mobile_app/imports_bindings.dart';

/// Data point model for the body matrix history line charts.
class HealthMatrixHistoryPoint {
  const HealthMatrixHistoryPoint({
    required this.date,
    required this.value,
    this.labelOverride,
  });

  final String date;
  final double value;
  final String? labelOverride;

  String get formattedValue =>
      labelOverride ??
      (value % 1 == 0 ? value.toInt().toString() : value.toString());
}

/// Configuration model for a single Body Matrix History card.
class MatrixHistoryCardData {
  const MatrixHistoryCardData({
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.changeText,
    required this.changeSince,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.lineColor,
    required this.yTicks,
    required this.history,
    this.badgeText,
    this.badgeBg = const Color(0xFFF1F5F9),
    this.badgeTextColor = const Color(0xFF475569),
    this.unit,
    this.isIncrease = false,
    this.isZeroChange = false,
    this.isPositiveChange = true,
    this.hasBadgeDot = false,
    this.rangeLabel,
    this.rangeValue,
    this.calloutText,
    this.calloutIcon,
    this.calloutBg,
    this.calloutIconColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String currentValue;
  final String? unit;
  final String changeText;
  final bool isIncrease;
  final bool isZeroChange;
  final bool isPositiveChange;
  final String changeSince;
  final String? badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final bool hasBadgeDot;
  final String? rangeLabel;
  final String? rangeValue;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color lineColor;
  final List<double> yTicks;
  final List<HealthMatrixHistoryPoint> history;
  final String? calloutText;
  final IconData? calloutIcon;
  final Color? calloutBg;
  final Color? calloutIconColor;
  final VoidCallback? onTap;

  String formatTick(double tick) {
    if (tick >= 1000) {
      return NumberFormat('#,###').format(tick.toInt());
    }
    if (tick % 1 == 0) {
      return tick.toInt().toString();
    }
    return tick.toStringAsFixed(2);
  }
}

/// The History tab view for [TrainerBodyMatrixScreen].
class TrainerBodyMatrixHistoryTab extends StatelessWidget {
  const TrainerBodyMatrixHistoryTab({
    super.key,
    this.customerId,
    this.historyData,
    this.cards,
  });

  final dynamic customerId;
  final Map<dynamic, dynamic>? historyData;
  final List<MatrixHistoryCardData>? cards;

  /// Helper to dynamically compute clean yTicks covering data points
  static List<double> computeYTicks(
    List<HealthMatrixHistoryPoint> points,
    List<double> defaultTicks,
  ) {
    if (points.isEmpty) return defaultTicks;

    double minVal = points.first.value;
    double maxVal = points.first.value;
    for (final p in points) {
      if (p.value < minVal) minVal = p.value;
      if (p.value > maxVal) maxVal = p.value;
    }

    final double defMin = defaultTicks.last;
    final double defMax = defaultTicks.first;

    if (minVal >= defMin && maxVal <= defMax) {
      return defaultTicks;
    }

    final range = (maxVal - minVal).abs();
    final padding = range == 0 ? (maxVal * 0.1).clamp(1.0, 50.0) : range * 0.15;
    final double high = maxVal + padding;
    final double low = (minVal - padding).clamp(0.0, double.infinity);
    final double step = (high - low) / 4;

    return List.generate(5, (i) => high - (step * i));
  }

  /// Parses the backend JSON history object from GET /api/v1/customer/body-matrix/
  static List<MatrixHistoryCardData> fromHistoryJson(Map<dynamic, dynamic> history) {
    final List<MatrixHistoryCardData> result = [];

    // Helper for status badge colors
    Map<String, Color> getBadgeColors(String? badge) {
      final b = (badge ?? '').trim().toLowerCase();
      if (b == 'normal' || b == 'healthy' || b == 'fit') {
        return {
          'bg': const Color(0xFFE8F8F2),
          'text': const Color(0xFF059669),
        };
      }
      if (b == 'on track') {
        return {
          'bg': const Color(0xFFFFF7ED),
          'text': const Color(0xFFD97706),
        };
      }
      if (b == 'fitness' || b == 'athletic') {
        return {
          'bg': const Color(0xFFF3E8FF),
          'text': const Color(0xFF7E22CE),
        };
      }
      if (b.contains('over') || b.contains('obese') || b.contains('high')) {
        return {
          'bg': const Color(0xFFFEF2F2),
          'text': const Color(0xFFDC2626),
        };
      }
      if (b.contains('under') || b.contains('low')) {
        return {
          'bg': const Color(0xFFEFF6FF),
          'text': const Color(0xFF2563EB),
        };
      }
      return {
        'bg': const Color(0xFFF1F5F9),
        'text': const Color(0xFF475569),
      };
    }

    List<HealthMatrixHistoryPoint> parseTimeline(dynamic timelineRaw) {
      if (timelineRaw is! List) return [];
      return timelineRaw
          .whereType<Map>()
          .map((item) {
            final date = (item['date'] ?? '').toString();
            final val = (item['value'] as num?)?.toDouble() ?? 0.0;
            final formatted = val % 1 == 0 ? val.toInt().toString() : val.toString();
            return HealthMatrixHistoryPoint(
              date: date,
              value: val,
              labelOverride: val >= 1000 ? NumberFormat('#,###').format(val.toInt()) : formatted,
            );
          })
          .toList();
    }

    // 1. BMI Card
    final bmiMap = (history['bmi'] as Map<dynamic, dynamic>?) ?? {};
    final bmiTimeline = parseTimeline(bmiMap['timeline']);
    final dynamic rawBmiVal = bmiMap['current_value'];
    final double? bmiVal = (rawBmiVal as num?)?.toDouble();
    final String bmiCurStr = rawBmiVal != null
        ? (bmiVal != null
            ? (bmiVal % 1 == 0 ? bmiVal.toInt().toString() : bmiVal.toStringAsFixed(1))
            : rawBmiVal.toString())
        : '--';
    final double bmiChange = (bmiMap['change'] as num?)?.toDouble() ?? 0.0;
    final String? bmiBadge = bmiMap['status_badge']?.toString();
    final bmiColors = getBadgeColors(bmiBadge);
    final String? bmiRange = bmiMap['healthy_range']?.toString();
    final String? bmiInsight = bmiMap['insight']?.toString();

    result.add(
      MatrixHistoryCardData(
        title: 'BMI',
        subtitle: 'Body Mass Index',
        currentValue: bmiCurStr,
        changeText: bmiChange.abs() % 1 == 0
            ? bmiChange.abs().toInt().toString()
            : bmiChange.abs().toStringAsFixed(1),
        isIncrease: bmiChange > 0,
        isZeroChange: bmiChange == 0,
        isPositiveChange: bmiChange <= 0,
        changeSince: (bmiMap['change_since'] ??
                (bmiTimeline.isNotEmpty ? 'since ${bmiTimeline.first.date}' : 'Initial record'))
            .toString(),
        badgeText: bmiBadge,
        badgeBg: bmiColors['bg']!,
        badgeTextColor: bmiColors['text']!,
        rangeLabel: bmiRange != null && bmiRange.isNotEmpty ? 'Healthy range' : null,
        rangeValue: bmiRange,
        icon: Icons.speed_rounded,
        iconBg: const Color(0xFFE8F8F2),
        iconColor: const Color(0xFF059669),
        lineColor: const Color(0xFF10B981),
        yTicks: computeYTicks(bmiTimeline, const [28.0, 26.0, 24.0, 22.0, 20.0, 18.0]),
        history: bmiTimeline,
        calloutText: bmiInsight != null && bmiInsight.isNotEmpty ? bmiInsight : null,
        calloutIcon: Icons.lightbulb_outline_rounded,
        calloutBg: const Color(0xFFFFFBEB),
        calloutIconColor: const Color(0xFFF59E0B),
      ),
    );

    // 2. BMR Card
    final bmrMap = (history['bmr'] as Map<dynamic, dynamic>?) ?? {};
    final bmrTimeline = parseTimeline(bmrMap['timeline']);
    final dynamic rawBmrVal = bmrMap['current_value'];
    final double? bmrVal = (rawBmrVal as num?)?.toDouble();
    final String bmrCurStr = rawBmrVal != null
        ? (bmrVal != null
            ? NumberFormat('#,###').format(bmrVal.toInt())
            : rawBmrVal.toString())
        : '--';
    final double bmrChange = (bmrMap['change'] as num?)?.toDouble() ?? 0.0;
    final String? bmrBadge = bmrMap['status_badge']?.toString();
    final bmrColors = getBadgeColors(bmrBadge);
    final String bmrUnit = (bmrMap['unit'] ?? 'kcal/day').toString();
    final String? bmrInsight = bmrMap['insight']?.toString();

    result.add(
      MatrixHistoryCardData(
        title: 'BMR',
        subtitle: 'Basal Metabolic Rate',
        currentValue: bmrCurStr,
        unit: bmrUnit,
        changeText: bmrChange.abs().toInt().toString(),
        isIncrease: bmrChange > 0,
        isZeroChange: bmrChange == 0,
        isPositiveChange: bmrChange >= 0,
        changeSince: (bmrMap['change_since'] ??
                (bmrTimeline.isNotEmpty ? 'since ${bmrTimeline.first.date}' : 'Initial record'))
            .toString(),
        badgeText: bmrBadge,
        badgeBg: bmrColors['bg']!,
        badgeTextColor: bmrColors['text']!,
        hasBadgeDot: (bmrBadge ?? '').toLowerCase() == 'on track',
        icon: Icons.local_fire_department_rounded,
        iconBg: const Color(0xFFFFF4EC),
        iconColor: const Color(0xFFF97316),
        lineColor: const Color(0xFFF97316),
        yTicks: computeYTicks(bmrTimeline, const [1800.0, 1600.0, 1400.0, 1200.0, 1000.0]),
        history: bmrTimeline,
        calloutText: bmrInsight != null && bmrInsight.isNotEmpty ? bmrInsight : null,
        calloutIcon: Icons.local_fire_department_rounded,
        calloutBg: const Color(0xFFFFF4EC),
        calloutIconColor: const Color(0xFFF97316),
      ),
    );

    // 3. Waist to Hip Ratio (WHR) Card
    final whrMap = (history['whr'] as Map<dynamic, dynamic>?) ?? {};
    final whrTimeline = parseTimeline(whrMap['timeline']);
    final dynamic rawWhrVal = whrMap['current_value'];
    final double? whrVal = (rawWhrVal as num?)?.toDouble();
    final String whrCurStr = rawWhrVal != null
        ? (whrVal != null ? whrVal.toStringAsFixed(2) : rawWhrVal.toString())
        : '--';
    final double whrChange = (whrMap['change'] as num?)?.toDouble() ?? 0.0;
    final String? whrBadge = whrMap['status_badge']?.toString();
    final whrColors = getBadgeColors(whrBadge);
    final String? whrRange = whrMap['healthy_range']?.toString();
    final String? whrInsight = whrMap['insight']?.toString();

    result.add(
      MatrixHistoryCardData(
        title: 'Waist to Hip Ratio',
        subtitle: 'Fat distribution indicator',
        currentValue: whrCurStr,
        changeText: whrChange.abs().toStringAsFixed(2),
        isIncrease: whrChange > 0,
        isZeroChange: whrChange == 0,
        isPositiveChange: whrChange <= 0,
        changeSince: (whrMap['change_since'] ??
                (whrTimeline.isNotEmpty ? 'since ${whrTimeline.first.date}' : 'Initial record'))
            .toString(),
        badgeText: whrBadge,
        badgeBg: whrColors['bg']!,
        badgeTextColor: whrColors['text']!,
        rangeLabel: whrRange != null && whrRange.isNotEmpty ? 'Healthy range' : null,
        rangeValue: whrRange,
        icon: Icons.accessibility_new_rounded,
        iconBg: const Color(0xFFE0F7FA),
        iconColor: const Color(0xFF0D9488),
        lineColor: const Color(0xFF0D9488),
        yTicks: computeYTicks(whrTimeline, const [1.00, 0.90, 0.80, 0.70, 0.60]),
        history: whrTimeline,
        calloutText: whrInsight != null && whrInsight.isNotEmpty ? whrInsight : null,
        calloutIcon: Icons.track_changes_rounded,
        calloutBg: const Color(0xFFF0FDFA),
        calloutIconColor: const Color(0xFF0D9488),
      ),
    );

    // 4. Body Fat % Card
    final bfMap = (history['body_fat'] as Map<dynamic, dynamic>?) ?? {};
    final bfTimeline = parseTimeline(bfMap['timeline']);
    final dynamic rawBfVal = bfMap['current_value'];
    final double? bfVal = (rawBfVal as num?)?.toDouble();
    final String bfCurStr = rawBfVal != null
        ? (bfVal != null ? '${bfVal % 1 == 0 ? bfVal.toInt().toString() : bfVal.toString()}%' : '$rawBfVal%')
        : '--';
    final double bfChange = (bfMap['change'] as num?)?.toDouble() ?? 0.0;
    final String? bfBadge = bfMap['status_badge']?.toString();
    final bfColors = getBadgeColors(bfBadge);
    final String? bfRange = bfMap['healthy_range']?.toString();
    final String? bfInsight = bfMap['insight']?.toString();

    result.add(
      MatrixHistoryCardData(
        title: 'Body Fat %',
        subtitle: 'Body Fat Percentage',
        currentValue: bfCurStr,
        changeText:
            '${bfChange.abs() % 1 == 0 ? bfChange.abs().toInt().toString() : bfChange.abs().toStringAsFixed(1)}%',
        isIncrease: bfChange > 0,
        isZeroChange: bfChange == 0,
        isPositiveChange: bfChange <= 0,
        changeSince: (bfMap['change_since'] ??
                (bfTimeline.isNotEmpty ? 'since ${bfTimeline.first.date}' : 'Initial record'))
            .toString(),
        badgeText: bfBadge,
        badgeBg: bfColors['bg']!,
        badgeTextColor: bfColors['text']!,
        rangeLabel: bfRange != null && bfRange.isNotEmpty ? 'Healthy range' : null,
        rangeValue: bfRange,
        icon: Icons.percent_rounded,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF8B5CF6),
        lineColor: const Color(0xFF8B5CF6),
        yTicks: computeYTicks(bfTimeline, const [28.0, 24.0, 20.0, 16.0, 12.0]),
        history: bfTimeline,
        calloutText: bfInsight != null && bfInsight.isNotEmpty ? bfInsight : null,
        calloutIcon: Icons.emoji_events_outlined,
        calloutBg: const Color(0xFFFAF5FF),
        calloutIconColor: const Color(0xFF8B5CF6),
      ),
    );

    return result;
  }

  /// Default cards matching the design specifications.
  static List<MatrixHistoryCardData> get defaultCards => [
        // 1. BMI Card
        const MatrixHistoryCardData(
          title: 'BMI',
          subtitle: 'Body Mass Index',
          currentValue: '23.0',
          changeText: '3.8',
          isIncrease: false,
          isPositiveChange: true,
          changeSince: 'since May 1',
          badgeText: 'Normal',
          badgeBg: Color(0xFFE8F8F2),
          badgeTextColor: Color(0xFF059669),
          rangeLabel: 'Healthy range',
          rangeValue: '18.5 – 24.9',
          icon: Icons.speed_rounded,
          iconBg: Color(0xFFE8F8F2),
          iconColor: Color(0xFF059669),
          lineColor: Color(0xFF10B981),
          yTicks: [28.0, 26.0, 24.0, 22.0, 20.0, 18.0],
          history: [
            HealthMatrixHistoryPoint(date: 'May 1', value: 26.8, labelOverride: '26.8'),
            HealthMatrixHistoryPoint(date: 'May 8', value: 25.7, labelOverride: '25.7'),
            HealthMatrixHistoryPoint(date: 'May 15', value: 24.6, labelOverride: '24.6'),
            HealthMatrixHistoryPoint(date: 'May 22', value: 23.8, labelOverride: '23.8'),
            HealthMatrixHistoryPoint(date: 'May 29', value: 23.0, labelOverride: '23.0'),
          ],
        ),

        // 2. BMR Card
        const MatrixHistoryCardData(
          title: 'BMR',
          subtitle: 'Basal Metabolic Rate',
          currentValue: '1,641',
          unit: 'kcal/day',
          changeText: '121',
          isIncrease: true,
          isPositiveChange: true,
          changeSince: 'since May 1',
          badgeText: 'On track',
          badgeBg: Color(0xFFFFF7ED),
          badgeTextColor: Color(0xFFD97706),
          hasBadgeDot: true,
          icon: Icons.local_fire_department_rounded,
          iconBg: Color(0xFFFFF4EC),
          iconColor: Color(0xFFF97316),
          lineColor: Color(0xFFF97316),
          yTicks: [1800.0, 1600.0, 1400.0, 1200.0, 1000.0],
          history: [
            HealthMatrixHistoryPoint(date: 'May 1', value: 1520.0, labelOverride: '1,520'),
            HealthMatrixHistoryPoint(date: 'May 8', value: 1560.0, labelOverride: '1,560'),
            HealthMatrixHistoryPoint(date: 'May 15', value: 1598.0, labelOverride: '1,598'),
            HealthMatrixHistoryPoint(date: 'May 22', value: 1620.0, labelOverride: '1,620'),
            HealthMatrixHistoryPoint(date: 'May 29', value: 1641.0, labelOverride: '1,641'),
          ],
          calloutText:
              'Your BMR has increased, meaning your body is burning more calories at rest.',
          calloutIcon: Icons.lightbulb_outline_rounded,
          calloutBg: Color(0xFFFFFBEB),
          calloutIconColor: Color(0xFFF59E0B),
        ),

        // 3. Waist to Hip Ratio Card
        const MatrixHistoryCardData(
          title: 'Waist to Hip Ratio',
          subtitle: 'Fat distribution indicator',
          currentValue: '0.84',
          changeText: '0.04',
          isIncrease: false,
          isPositiveChange: true,
          changeSince: 'since May 1',
          badgeText: 'Healthy',
          badgeBg: Color(0xFFE8F8F2),
          badgeTextColor: Color(0xFF059669),
          rangeLabel: 'Your range',
          rangeValue: '0.70 – 0.90',
          icon: Icons.accessibility_new_rounded,
          iconBg: Color(0xFFE0F7FA),
          iconColor: Color(0xFF0D9488),
          lineColor: Color(0xFF0D9488),
          yTicks: [1.00, 0.90, 0.80, 0.70, 0.60],
          history: [
            HealthMatrixHistoryPoint(date: 'May 1', value: 0.88, labelOverride: '0.88'),
            HealthMatrixHistoryPoint(date: 'May 8', value: 0.87, labelOverride: '0.87'),
            HealthMatrixHistoryPoint(date: 'May 15', value: 0.85, labelOverride: '0.85'),
            HealthMatrixHistoryPoint(date: 'May 22', value: 0.83, labelOverride: '0.83'),
            HealthMatrixHistoryPoint(date: 'May 29', value: 0.84, labelOverride: '0.84'),
          ],
          calloutText:
              'Moving towards a healthier balance of muscle and fat distribution.',
          calloutIcon: Icons.track_changes_rounded,
          calloutBg: Color(0xFFF0FDFA),
          calloutIconColor: Color(0xFF0D9488),
        ),

        // 4. Body Fat % Card
        const MatrixHistoryCardData(
          title: 'Body Fat %',
          subtitle: 'Body Fat Percentage',
          currentValue: '16.5%',
          changeText: '5.3%',
          isIncrease: false,
          isPositiveChange: true,
          changeSince: 'since May 1',
          badgeText: 'Fitness',
          badgeBg: Color(0xFFF3E8FF),
          badgeTextColor: Color(0xFF7E22CE),
          rangeLabel: 'Your range',
          rangeValue: '14 – 17%',
          icon: Icons.percent_rounded,
          iconBg: Color(0xFFF3E8FF),
          iconColor: Color(0xFF8B5CF6),
          lineColor: Color(0xFF8B5CF6),
          yTicks: [28.0, 24.0, 20.0, 16.0, 12.0],
          history: [
            HealthMatrixHistoryPoint(date: 'May 1', value: 21.8, labelOverride: '21.8'),
            HealthMatrixHistoryPoint(date: 'May 8', value: 20.4, labelOverride: '20.4'),
            HealthMatrixHistoryPoint(date: 'May 15', value: 19.2, labelOverride: '19.2'),
            HealthMatrixHistoryPoint(date: 'May 22', value: 17.8, labelOverride: '17.8'),
            HealthMatrixHistoryPoint(date: 'May 29', value: 16.5, labelOverride: '16.5'),
          ],
          calloutText:
              'Great progress! Lower body fat helps you build a leaner, healthier physique.',
          calloutIcon: Icons.emoji_events_outlined,
          calloutBg: Color(0xFFFAF5FF),
          calloutIconColor: Color(0xFF8B5CF6),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final list = cards ??
        (historyData != null && historyData!.isNotEmpty
            ? fromHistoryJson(historyData!)
            : defaultCards);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _HistoryCardItem(data: list[index]),
    );
  }
}

class _HistoryCardItem extends StatelessWidget {
  const _HistoryCardItem({required this.data});

  final MatrixHistoryCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: data.onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Icon + Title + Subtitle + Chevron)
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: data.iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data.icon,
                        color: data.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: AppStyles.text16Px.poppins.w700.copyWith(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            data.subtitle,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content Row (Left stats & Right line chart)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Stats Column
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Big Value in one line
                          Text(
                            data.currentValue,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: AppStyles.text28Px.poppins.w700.copyWith(
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (data.unit != null) ...[
                            Text(
                              data.unit!,
                              maxLines: 1,
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF64748B),
                                height: 1.1,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),

                          // Change Indicator
                          if (data.isZeroChange) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.remove_rounded,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  data.changeText,
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(
                                  data.isIncrease
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: data.isPositiveChange
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  data.changeText,
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: data.isPositiveChange
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          Text(
                            data.changeSince,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Status Badge
                          if (data.badgeText != null &&
                              data.badgeText!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: data.badgeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (data.hasBadgeDot) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: data.badgeTextColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                  Text(
                                    data.badgeText!,
                                    style: AppStyles.text12Px.poppins.w600.copyWith(
                                      color: data.badgeTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Range label and value if available
                          if (data.rangeLabel != null &&
                              data.rangeValue != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              data.rangeLabel!,
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              data.rangeValue!,
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Right Chart
                    Expanded(
                      child: SizedBox(
                        height: 145,
                        child: CustomPaint(
                          painter: _HistoryLineChartPainter(
                            points: data.history,
                            yTicks: data.yTicks,
                            lineColor: data.lineColor,
                            formatTick: data.formatTick,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Callout Note Banner
                if (data.calloutText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: data.calloutBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (data.calloutIcon != null) ...[
                          Icon(
                            data.calloutIcon,
                            color: data.calloutIconColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            data.calloutText!,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: const Color(0xFF475569),
                              height: 1.35,
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
        ),
      ),
    );
  }
}

/// Custom painter for the line chart with gradient fill, Y-ticks, and point labels.
class _HistoryLineChartPainter extends CustomPainter {
  const _HistoryLineChartPainter({
    required this.points,
    required this.yTicks,
    required this.lineColor,
    required this.formatTick,
  });

  final List<HealthMatrixHistoryPoint> points;
  final List<double> yTicks;
  final Color lineColor;
  final String Function(double) formatTick;

  @override
  void paint(Canvas canvas, Size size) {
    if (yTicks.isEmpty) return;

    // Responsive padding based on tick string length
    final maxTickStr = formatTick(yTicks.first);
    final leftPad = maxTickStr.length >= 4 ? 40.0 : 28.0;
    const rightPad = 12.0;
    const topPad = 18.0;
    const bottomPad = 22.0;

    final plotWidth = size.width - leftPad - rightPad;
    final plotHeight = size.height - topPad - bottomPad;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    final double yMax = yTicks.first;
    final double yMin = yTicks.last;
    final int n = points.length;

    double getY(double v) {
      if (yMax <= yMin) return topPad + plotHeight / 2;
      final ratio = (v - yMin) / (yMax - yMin);
      return topPad + plotHeight * (1.0 - ratio.clamp(0.0, 1.0));
    }

    double getX(int i) {
      if (n <= 1) return leftPad + plotWidth / 2;
      return leftPad + (plotWidth / (n - 1)) * i;
    }

    // 1. Draw horizontal grid lines and Y-axis labels
    final gridLinePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    for (final tick in yTicks) {
      final y = getY(tick);

      // Horizontal grid line
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridLinePaint,
      );

      // Y-axis label text
      final tp = TextPainter(
        text: TextSpan(
          text: formatTick(tick),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 9.5,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    // If empty timeline, show empty state message
    if (points.isEmpty) {
      final emptyTp = TextPainter(
        text: const TextSpan(
          text: 'No history yet',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      emptyTp.paint(
        canvas,
        Offset(
          leftPad + (plotWidth - emptyTp.width) / 2,
          topPad + (plotHeight - emptyTp.height) / 2,
        ),
      );
      return;
    }

    if (n > 1) {
      // 2. Draw gradient fill under the line
      final fillPath = Path();
      fillPath.moveTo(getX(0), getY(yMin));
      fillPath.lineTo(getX(0), getY(points[0].value));
      for (int i = 1; i < n; i++) {
        fillPath.lineTo(getX(i), getY(points[i].value));
      }
      fillPath.lineTo(getX(n - 1), getY(yMin));
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.22),
            lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(
          Rect.fromLTRB(leftPad, topPad, size.width - rightPad, getY(yMin)),
        );
      canvas.drawPath(fillPath, fillPaint);

      // 3. Draw connecting line path
      final strokePath = Path();
      strokePath.moveTo(getX(0), getY(points[0].value));
      for (int i = 1; i < n; i++) {
        strokePath.lineTo(getX(i), getY(points[i].value));
      }
      final strokePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(strokePath, strokePaint);
    } else {
      // Single point subtle aura circle
      final x = getX(0);
      final y = getY(points[0].value);
      canvas.drawCircle(
        Offset(x, y),
        7.0,
        Paint()..color = lineColor.withValues(alpha: 0.18),
      );
    }

    // 4. Draw data points, value labels above, and X-axis date labels below
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final x = getX(i);
      final y = getY(points[i].value);

      // Filled circular point
      canvas.drawCircle(Offset(x, y), 3.2, dotPaint);

      // Value label above dot
      final valTp = TextPainter(
        text: TextSpan(
          text: points[i].formattedValue,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      double valX = x - valTp.width / 2;
      if (valX < leftPad) valX = leftPad;
      if (valX + valTp.width > size.width - 2) {
        valX = size.width - valTp.width - 2;
      }
      valTp.paint(canvas, Offset(valX, y - valTp.height - 4));

      // X-axis date label below
      if (points[i].date.isNotEmpty) {
        final dateTp = TextPainter(
          text: TextSpan(
            text: points[i].date,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        double dateX = x - dateTp.width / 2;
        if (dateX < leftPad - 4) dateX = leftPad - 4;
        if (dateX + dateTp.width > size.width) {
          dateX = size.width - dateTp.width;
        }
        dateTp.paint(canvas, Offset(dateX, getY(yMin) + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HistoryLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.yTicks != yTicks;
  }
}
