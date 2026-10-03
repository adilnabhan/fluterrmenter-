import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';
import 'package:mentor_mobile_app/core/widgets/buttons/pop_button.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/widgets/trainer_body_matrix_history_tab.dart';

class TrainerBodyMatrixScreen extends StatefulWidget {
  const TrainerBodyMatrixScreen({
    required this.customerId,
    this.clientName,
    this.initialBodyMatrixData,
    this.initialProfile,
    super.key,
  });

  final dynamic customerId;
  final String? clientName;
  final Map<String, dynamic>? initialBodyMatrixData;
  final Map<dynamic, dynamic>? initialProfile;

  @override
  State<TrainerBodyMatrixScreen> createState() =>
      _TrainerBodyMatrixScreenState();
}

class _TrainerBodyMatrixScreenState extends State<TrainerBodyMatrixScreen> {
  Map<String, dynamic>? _bodyMatrixData;
  bool _isLoading = false;
  int _selectedTabIndex = 0; // 0: Present Condition, 1: History
  bool _showWhrInfo = false;
  bool _showWhtrInfo = false;
  bool _showAboutBmi = false;
  bool _showAboutBmr = false;
  bool _showAboutBodyFat = false;

  @override
  void initState() {
    super.initState();
    _bodyMatrixData = widget.initialBodyMatrixData;
    _fetchBodyMatrix();
  }

  Future<void> _fetchBodyMatrix() async {
    if (_bodyMatrixData == null) {
      setState(() => _isLoading = true);
    }
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.customerBodyMatrix(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['status'] == 'success' && resMap['data'] is Map) {
          if (!mounted) return;
          setState(() {
            _bodyMatrixData = Map<String, dynamic>.from(resMap['data'] as Map);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching body matrix: $e');
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final metrics =
        _bodyMatrixData?['metrics'] as Map<dynamic, dynamic>? ?? {};
    final inputs =
        _bodyMatrixData?['inputs'] as Map<dynamic, dynamic>? ?? {};
    final profile = widget.initialProfile ?? {};
    final String gender = (profile['gender'] ?? '').toString().toLowerCase();
    final bool isFemale = gender.startsWith('f') || gender == 'women' || gender == 'woman';

    // 1. BMI Data
    final bmiObj = metrics['bmi'] as Map<dynamic, dynamic>? ?? {};
    final dynamic rawBmi = bmiObj['value'] ?? profile['bmi'];
    final double? bmiVal = double.tryParse(rawBmi?.toString() ?? '');
    final String bmiStr = rawBmi != null
        ? (bmiVal != null
            ? (bmiVal % 1 == 0
                ? bmiVal.toInt().toString()
                : (rawBmi.toString().contains('.')
                    ? rawBmi.toString()
                    : bmiVal.toStringAsFixed(2)))
            : rawBmi.toString())
        : '--';
    final String bmiLabel =
        (bmiObj['label'] ?? bmiObj['category'] ?? 'Normal').toString();

    // 2. BMR Data
    final bmrObj = metrics['bmr'] as Map<dynamic, dynamic>? ?? {};
    final dynamic rawBmr = bmrObj['value'] ?? profile['bmr'];
    final double? bmrVal = double.tryParse(rawBmr?.toString() ?? '');
    final String bmrStr = bmrVal != null
        ? NumberFormat('#,###').format(bmrVal.toInt())
        : (rawBmr?.toString() ?? '--');
    final String bmrUnit = (bmrObj['unit'] ?? 'kcal/day').toString();

    // 3. Body Fat Data
    final bodyFatObj = metrics['body_fat'] as Map<dynamic, dynamic>? ?? {};
    final dynamic rawBf = bodyFatObj['percentage'];
    final double? bfVal = double.tryParse(rawBf?.toString() ?? '');
    final String bodyFatStr = rawBf != null
        ? (bfVal != null
            ? (bfVal % 1 == 0 ? bfVal.toInt().toString() : bfVal.toString())
            : rawBf.toString().replaceAll('%', '').trim())
        : '--';
    final String bodyFatCategory =
        (bodyFatObj['category'] ?? bodyFatObj['label'] ?? 'Average').toString();

    // 4. Waist-to-Hip Ratio (WHR)
    final whrObj = metrics['whr'] as Map<dynamic, dynamic>? ?? {};
    final double? whrVal = double.tryParse(
      whrObj['ratio']?.toString() ?? '',
    );
    final String? whrCategory = whrObj['category']?.toString();

    // 5. Waist-to-Height Ratio (WHtR)
    final whtrObj = metrics['whtr'] as Map<dynamic, dynamic>? ?? {};
    final double? whtrVal = double.tryParse(
      whtrObj['ratio']?.toString() ?? '',
    );
    final String? whtrCategory = whtrObj['category']?.toString();

    // 6. Body Measurements (Inputs or Profile fallback)
    final dynamic heightRaw = inputs['height_cm'] ?? profile['height'];
    final dynamic weightRaw = inputs['weight_kg'] ?? profile['weight'];
    final dynamic neckRaw = inputs['neck_cm'];
    final dynamic waistRaw = inputs['waist_cm'];
    final dynamic hipRaw = inputs['hip_cm'];

    final String heightStr = heightRaw != null && heightRaw.toString().isNotEmpty
        ? heightRaw.toString().replaceAll(RegExp(r'[^\d.]'), '')
        : '--';
    final String weightStr = weightRaw != null && weightRaw.toString().isNotEmpty
        ? weightRaw.toString().replaceAll(RegExp(r'[^\d.]'), '')
        : '--';
    final String neckStr = neckRaw != null && neckRaw.toString().isNotEmpty ? '$neckRaw' : '--';
    final String waistStr = waistRaw != null && waistRaw.toString().isNotEmpty ? '$waistRaw' : '--';
    final String hipStr = hipRaw != null && hipRaw.toString().isNotEmpty ? '$hipRaw' : '--';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        centerTitle: true,
        title: Text(
          'Body Matrix',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: _isLoading && _bodyMatrixData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBodyMatrix,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Matrix',
                      style: AppStyles.text20Px.poppins.w700.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tab Bar: Present Condition & History
                    _buildTabBar(),
                    const SizedBox(height: 16),

                    if (_selectedTabIndex == 0) ...[
                      // 1. BMI Card
                      _buildBmiCard(bmiVal ?? 21.8, bmiStr, bmiLabel),
                      const SizedBox(height: 14),

                      // 2. BMR Card
                      _buildBmrCard(bmrStr, bmrUnit),
                      const SizedBox(height: 14),

                      // 3. Body Fat Card
                      _buildBodyFatCard(
                        bfVal: bfVal,
                        bodyFatStr: bodyFatStr,
                        category: bodyFatCategory,
                        isFemale: isFemale,
                      ),
                      const SizedBox(height: 14),

                      // 4 & 5. Waist-to-Hip & Waist-to-Height Ratios
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildWhrCard(whrVal, whrCategory),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildWhtrCard(whtrVal, whtrCategory),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 6. Body Measurements Section
                      _buildMeasurementsSection(
                        height: heightStr,
                        weight: weightStr,
                        neck: neckStr,
                        waist: waistStr,
                        hip: hipStr,
                      ),
                      const SizedBox(height: 16),

                      // 7. Medical Disclaimer
                      _buildDisclaimerCard(),
                      const SizedBox(height: 24),
                    ] else ...[
                      TrainerBodyMatrixHistoryTab(
                        customerId: widget.customerId,
                        historyData: _bodyMatrixData?['history'] as Map<dynamic, dynamic>?,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // ==================== Tab Bar ====================
  Widget _buildTabBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTabIndex != 0) {
                  setState(() => _selectedTabIndex = 0);
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'Present Condition',
                  style: AppStyles.text14Px.poppins.copyWith(
                    color: _selectedTabIndex == 0
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontWeight: _selectedTabIndex == 0
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTabIndex != 1) {
                  setState(() => _selectedTabIndex = 1);
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'History',
                  style: AppStyles.text14Px.poppins.copyWith(
                    color: _selectedTabIndex == 1
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontWeight: _selectedTabIndex == 1
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BMI Card ====================
  Widget _buildBmiCard(double bmi, String bmiStr, String category) {
    // Dynamic Category colors
    final Color categoryColor;
    if (bmi < 18.5) {
      categoryColor = const Color(0xFF4361EE);
    } else if (bmi <= 24.9) {
      categoryColor = const Color(0xFF10B981);
    } else if (bmi <= 29.9) {
      categoryColor = const Color(0xFFF59E0B);
    } else {
      categoryColor = const Color(0xFFEF4444);
    }

    // Difference below / above threshold
    String diffSubtitle = '';
    final bool isBelowThreshold = bmi < 25.0;
    if (bmi <= 0) {
      diffSubtitle = '';
    } else if (isBelowThreshold) {
      final double diff = (25.0 - bmi).clamp(0.0, 30.0);
      final String diffStr = diff % 1 == 0
          ? diff.toInt().toString()
          : (diff.toStringAsFixed(2).endsWith('0')
              ? diff.toStringAsFixed(1)
              : diff.toStringAsFixed(2));
      diffSubtitle = '$diffStr below Overweight threshold (25.0)';
    } else {
      final double diff = bmi - 25.0;
      final String diffStr = diff % 1 == 0
          ? diff.toInt().toString()
          : (diff.toStringAsFixed(2).endsWith('0')
              ? diff.toStringAsFixed(1)
              : diff.toStringAsFixed(2));
      diffSubtitle = '$diffStr above Overweight threshold (25.0)';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.scale_outlined,
                  color: Color(0xFF4A6CF7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI (Body Mass Index)',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Your body composition indicator',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Big BMI Value
          Center(
            child: Column(
              children: [
                Text(
                  bmiStr,
                  style: AppStyles.text36Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                    fontSize: 42,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isBelowThreshold
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      size: 15,
                      color: isBelowThreshold
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      diffSubtitle,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Gauge with dynamic category color marker
          _buildBmiGauge(bmi, categoryColor, bmiStr),
          const SizedBox(height: 18),

          // 4-Column Legend: Underweight, Normal, Overweight, Obese
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: Color(0xFF4361EE),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Underweight',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '< 18.5',
                      style: AppStyles.text10Px.poppins.w400.textGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Normal',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '18.5 – 24.9',
                      style: AppStyles.text10Px.poppins.w400.textGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Overweight',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '25 – 29.9',
                      style: AppStyles.text10Px.poppins.w400.textGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Obese',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\u2265 30',
                      style: AppStyles.text10Px.poppins.w400.textGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // About BMI Button (Expandable: hint is only shown when clicked)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _showAboutBmi = !_showAboutBmi),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF16A34A),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'About BMI',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                      Icon(
                        _showAboutBmi
                            ? Icons.keyboard_arrow_up
                            : Icons.chevron_right,
                        color: const Color(0xFF16A34A),
                        size: 16,
                      ),
                    ],
                  ),
                  if (_showAboutBmi) ...[
                    const SizedBox(height: 6),
                    const Divider(height: 1, color: Color(0xFFDCFCE7)),
                    const SizedBox(height: 6),
                    Text(
                      'BMI is a useful screening tool, but doesn\'t distinguish muscle, bone, or body fat. Use it along with other metrics for a complete picture.',
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF15803D),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiGauge(double bmi, Color categoryColor, String bmiText) {
    // 4-category piecewise linear mapping matching the tick labels (15, 18.5, 25.0, 30, 40)
    // and the 4 equal legend columns:
    // - Underweight: 15.0 - 18.5 -> 0.00 to 0.25
    // - Normal:      18.5 - 25.0 -> 0.25 to 0.50
    // - Overweight:  25.0 - 30.0 -> 0.50 to 0.75
    // - Obese:       30.0 - 40.0 -> 0.75 to 1.00
    double percent;
    if (bmi <= 15.0) {
      percent = 0.0;
    } else if (bmi < 18.5) {
      percent = 0.0 + 0.25 * ((bmi - 15.0) / (18.5 - 15.0));
    } else if (bmi < 25.0) {
      percent = 0.25 + 0.25 * ((bmi - 18.5) / (25.0 - 18.5));
    } else if (bmi < 30.0) {
      percent = 0.50 + 0.25 * ((bmi - 25.0) / (30.0 - 25.0));
    } else if (bmi < 40.0) {
      percent = 0.75 + 0.25 * ((bmi - 30.0) / (40.0 - 30.0));
    } else {
      percent = 1.0;
    }
    percent = percent.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double pinCenter = (width * percent).clamp(24.0, width - 24.0);

        return Column(
          children: [
            // Dynamic Speech Bubble Indicator
            SizedBox(
              height: 34,
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: pinCenter - 26,
                    top: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bmiText,
                            style: AppStyles.text12Px.poppins.w700.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Downward triangle pointer
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: Transform.rotate(
                            angle: 0.785398, // 45 degrees
                            child: Container(
                              width: 6,
                              height: 6,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // The colored gradient bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 10,
                    width: width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4361EE), // Blue (<18.5)
                          Color(0xFF4361EE),
                          Color(0xFF10B981), // Green (18.5 - 25.0)
                          Color(0xFF10B981),
                          Color(0xFFF59E0B), // Orange (25.0 - 30.0)
                          Color(0xFFF59E0B),
                          Color(0xFFEF4444), // Red (30+)
                          Color(0xFFEF4444),
                        ],
                        stops: [0.0, 0.20, 0.28, 0.45, 0.55, 0.70, 0.78, 1.0],
                      ),
                    ),
                  ),
                ),
                // Indicator circle on bar
                Positioned(
                  left: pinCenter - 6,
                  top: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: categoryColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Tick labels: 15, 18.5, 25.0, 30, 40
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('15', style: AppStyles.text10Px.poppins.w500.textGrey),
                Text('18.5', style: AppStyles.text10Px.poppins.w500.textGrey),
                Text('25.0', style: AppStyles.text10Px.poppins.w500.textGrey),
                Text('30', style: AppStyles.text10Px.poppins.w500.textGrey),
                Text('40', style: AppStyles.text10Px.poppins.w500.textGrey),
              ],
            ),
          ],
        );
      },
    );
  }

  // ==================== BMR Card ====================
  Widget _buildBmrCard(String bmrStr, String bmrUnit) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'BMR ',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: const Color(0xFF1E293B),
              ),
              children: [
                TextSpan(
                  text: '(Basal Metabolic Rate)',
                  style: AppStyles.text13Px.poppins.w400.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  bmrStr,
                  style: AppStyles.text36Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                    fontSize: 42,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bmrUnit,
                  style: AppStyles.text13Px.poppins.w500.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // About BMR Expandable Callout
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _showAboutBmr = !_showAboutBmr),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF16A34A),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'About BMR',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Icon(
                        _showAboutBmr
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF64748B),
                        size: 16,
                      ),
                    ],
                  ),
                  if (_showAboutBmr) ...[
                    const SizedBox(height: 8),
                    Text(
                      'BMR is the number of calories your body burns at complete rest to maintain basic functions like breathing and circulation. Use it as your baseline for calorie planning.',
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '∑',
                                style: AppStyles.text13Px.poppins.w700.copyWith(
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Harris-Benedict Formula:',
                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Men: BMR = 88.362 + (13.397 × Weight kg) + (4.799 × Height cm) - (5.677 × Age)',
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Women: BMR = 447.593 + (9.247 × Weight kg) + (3.098 × Height cm) - (4.330 × Age)',
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF0F172A),
                                height: 1.3,
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
        ],
      ),
    );
  }

  // ==================== Body Fat Card ====================
  Widget _buildBodyFatCard({
    required double? bfVal,
    required String bodyFatStr,
    required String category,
    required bool isFemale,
  }) {
    final Color categoryColor = _getBodyFatCategoryColor(category);
    final String cleanVal = bodyFatStr.replaceAll('%', '').trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '%',
                    style: AppStyles.text18Px.poppins.w700.copyWith(
                      color: const Color(0xFF0D9488),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Body Fat ',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: const Color(0xFF0F172A),
                        ),
                        children: [
                          TextSpan(
                            text: '(Body Fat Percentage)',
                            style: AppStyles.text13Px.poppins.w400.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estimated body fat composition indicator',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Big Metric Value
          Center(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    text: cleanVal,
                    style: AppStyles.text36Px.poppins.w700.copyWith(
                      color: const Color(0xFF0F172A),
                      fontSize: 44,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(
                        text: ' %',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Estimated body fat based on your inputs.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Gauge with dynamic category color marker
          _buildBodyFatGauge(bfVal, categoryColor, cleanVal, isFemale),
          const SizedBox(height: 18),

          // 5-Column Legend: Essential, Athletic, Fitness, Average, Above Average
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBfColumn(
                  'Essential',
                  isFemale ? '10-13%' : '2-5%',
                  const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildBfColumn(
                  'Athletic',
                  isFemale ? '14-20%' : '6-13%',
                  const Color(0xFF0D9488),
                ),
              ),
              Expanded(
                child: _buildBfColumn(
                  'Fitness',
                  isFemale ? '21-24%' : '14-17%',
                  const Color(0xFF84CC16),
                ),
              ),
              Expanded(
                child: _buildBfColumn(
                  'Average',
                  isFemale ? '25-31%' : '18-24%',
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildBfColumn(
                  'Above\nAverage',
                  isFemale ? '32%+' : '25%+',
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Expandable About Body Fat Percentage
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _showAboutBodyFat = !_showAboutBodyFat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF16A34A),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'About Body Fat Percentage',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Icon(
                        _showAboutBodyFat
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF64748B),
                        size: 16,
                      ),
                    ],
                  ),
                  if (_showAboutBodyFat) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Body fat percentage is the amount of fat in your body compared to your total body weight. It\'s a better indicator of fitness than weight alone.',
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '∑',
                                style: AppStyles.text13Px.poppins.w700.copyWith(
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Deurenberg Formula:',
                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Men: Body Fat % = (1.20 × BMI) + (0.23 × Age) - 16.2',
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Women: Body Fat % = (1.20 × BMI) + (0.23 × Age) - 5.4',
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF0F172A),
                                height: 1.3,
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
        ],
      ),
    );
  }

  Widget _buildBodyFatGauge(
    double? bf,
    Color categoryColor,
    String bfText,
    bool isFemale,
  ) {
    final double t1 = isFemale ? 10.0 : 2.0;
    final double t2 = isFemale ? 14.0 : 6.0;
    final double t3 = isFemale ? 21.0 : 14.0;
    final double t4 = isFemale ? 25.0 : 18.0;
    final double t5 = isFemale ? 32.0 : 25.0;
    final double t6 = isFemale ? 42.0 : 35.0;

    double percent;
    if (bf == null || bf <= t1) {
      percent = 0.0;
    } else if (bf < t2) {
      percent = 0.0 + 0.20 * ((bf - t1) / (t2 - t1));
    } else if (bf < t3) {
      percent = 0.20 + 0.20 * ((bf - t2) / (t3 - t2));
    } else if (bf < t4) {
      percent = 0.40 + 0.20 * ((bf - t3) / (t4 - t3));
    } else if (bf < t5) {
      percent = 0.60 + 0.20 * ((bf - t4) / (t5 - t4));
    } else if (bf < t6) {
      percent = 0.80 + 0.20 * ((bf - t5) / (t6 - t5));
    } else {
      percent = 1.0;
    }
    percent = percent.clamp(0.0, 1.0);

    final String t1Str = isFemale ? '10%' : '2%';
    final String t2Str = isFemale ? '14%' : '6%';
    final String t3Str = isFemale ? '21%' : '14%';
    final String t4Str = isFemale ? '25%' : '18%';
    final String t5Str = isFemale ? '32%' : '25%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double pinCenter = (width * percent).clamp(24.0, width - 24.0);

        return Column(
          children: [
            // Dynamic Speech Bubble Indicator
            SizedBox(
              height: 34,
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: pinCenter - 26,
                    top: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bfText.endsWith('%') ? bfText : '$bfText%',
                            style: AppStyles.text12Px.poppins.w700.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Downward triangle pointer
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: Transform.rotate(
                            angle: 0.785398, // 45 degrees
                            child: Container(
                              width: 6,
                              height: 6,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            // Tick Marks Row directly above the bar
            SizedBox(
              height: 18,
              width: width,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Text(
                      t1Str,
                      style: AppStyles.text10Px.poppins.w500.textGrey,
                    ),
                  ),
                  Positioned(
                    left: (width * 0.20 - 10).clamp(0.0, width - 20),
                    child: Text(
                      t2Str,
                      style: AppStyles.text10Px.poppins.w500.textGrey,
                    ),
                  ),
                  Positioned(
                    left: (width * 0.40 - 10).clamp(0.0, width - 20),
                    child: Text(
                      t3Str,
                      style: AppStyles.text10Px.poppins.w500.textGrey,
                    ),
                  ),
                  Positioned(
                    left: (width * 0.60 - 10).clamp(0.0, width - 20),
                    child: Text(
                      t4Str,
                      style: AppStyles.text10Px.poppins.w500.textGrey,
                    ),
                  ),
                  Positioned(
                    left: (width * 0.80 - 10).clamp(0.0, width - 20),
                    child: Text(
                      t5Str,
                      style: AppStyles.text10Px.poppins.w500.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // 5-Color Gradient Bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 10,
                    width: width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3B82F6), // Essential: Blue
                          Color(0xFF3B82F6),
                          Color(0xFF06B6D4), // Athletic: Cyan
                          Color(0xFF06B6D4),
                          Color(0xFF84CC16), // Fitness: Lime
                          Color(0xFF84CC16),
                          Color(0xFFF59E0B), // Average: Amber
                          Color(0xFFF59E0B),
                          Color(0xFFEF4444), // Above Average: Red
                          Color(0xFFEF4444),
                        ],
                        stops: [
                          0.0,
                          0.195,
                          0.205,
                          0.395,
                          0.405,
                          0.595,
                          0.605,
                          0.795,
                          0.805,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
                // Tick divider lines
                Positioned(
                  left: width * 0.20 - 0.5,
                  child: Container(
                    width: 1,
                    height: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  left: width * 0.40 - 0.5,
                  child: Container(
                    width: 1,
                    height: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  left: width * 0.60 - 0.5,
                  child: Container(
                    width: 1,
                    height: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  left: width * 0.80 - 0.5,
                  child: Container(
                    width: 1,
                    height: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                // Indicator circle on bar
                Positioned(
                  left: pinCenter - 6,
                  top: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: categoryColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBfColumn(String title, String range, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: AppStyles.text10Px.poppins.w600.copyWith(color: color),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        const SizedBox(height: 2),
        Text(
          range,
          style: AppStyles.text10Px.poppins.w500.copyWith(
            color: color.withValues(alpha: 0.85),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getBodyFatCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('essential')) return const Color(0xFF3B82F6);
    if (cat.contains('athletic')) return const Color(0xFF0D9488);
    if (cat.contains('fitness')) return const Color(0xFF84CC16);
    if (cat.contains('average') && !cat.contains('above')) {
      return const Color(0xFFF59E0B);
    }
    if (cat.contains('above') || cat.contains('obese') || cat.contains('high')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF84CC16);
  }

  // ==================== Waist-to-Hip Ratio (WHR) Card ====================
  Widget _buildWhrCard(double? ratio, String? category) {
    final bool hasData = ratio != null && ratio > 0;
    final String valStr = hasData ? ratio.toStringAsFixed(2) : '--';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.accessibility_new,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waist-to-Hip Ratio',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Fat distribution indic...',
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Value or Add Data
          Center(
            child: Column(
              children: [
                Text(
                  valStr,
                  style: AppStyles.text24Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                if (!hasData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Add Data',
                          style: AppStyles.text10Px.poppins.w500.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    category ?? 'Healthy',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFF22C55E),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Gauge bar
          _buildMiniGauge(
            ratio ?? 0.85,
            min: 0.70,
            max: 1.00,
            hasData: hasData,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.70', style: AppStyles.text9Px.poppins.w400.textGrey),
              Text('0.80', style: AppStyles.text9Px.poppins.w400.textGrey),
              Text('0.90', style: AppStyles.text9Px.poppins.w400.textGrey),
              Text('1.00', style: AppStyles.text9Px.poppins.w400.textGrey),
            ],
          ),
          const SizedBox(height: 10),

          // 2x2 Legend
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFF22C55E),
                      'Excellent',
                      '< 0.80',
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFF10B981),
                      'Healthy',
                      '0.80-0.90',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFFF59E0B),
                      'Average',
                      '0.90-1.00',
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFFEF4444),
                      'High',
                      '> 1.00',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Expandable About & Calculation
          InkWell(
            onTap: () => setState(() => _showWhrInfo = !_showWhrInfo),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'About & Calculation',
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Icon(
                  _showWhrInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          if (_showWhrInfo) ...[
            const SizedBox(height: 6),
            Text(
              'Calculated as Waist (cm) / Hip (cm). Assesses fat storage around hips and waist.',
              style: AppStyles.text10Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== Waist-to-Height Ratio (WHtR) Card ====================
  Widget _buildWhtrCard(double? ratio, String? category) {
    final bool hasData = ratio != null && ratio > 0;
    final String valStr = hasData ? ratio.toStringAsFixed(2) : '--';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.straighten,
                  color: Color(0xFFDB2777),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waist-to-Height Ratio',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Health risk indicator',
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Value or Add Data
          Center(
            child: Column(
              children: [
                Text(
                  valStr,
                  style: AppStyles.text24Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                if (!hasData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Add Data',
                          style: AppStyles.text10Px.poppins.w500.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    category ?? 'Healthy',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFF22C55E),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Gauge bar
          _buildMiniGauge(
            ratio ?? 0.45,
            min: 0.30,
            max: 0.60,
            hasData: hasData,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.30', style: AppStyles.text9Px.poppins.w400.textGrey),
              Text('0.40', style: AppStyles.text9Px.poppins.w400.textGrey),
              Text('0.50', style: AppStyles.text9Px.poppins.w400.textGrey),
              Text('0.60', style: AppStyles.text9Px.poppins.w400.textGrey),
            ],
          ),
          const SizedBox(height: 10),

          // 2x2 Legend
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFF22C55E),
                      'Low Risk',
                      '< 0.40',
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFF10B981),
                      'Healthy',
                      '0.40-0.50',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFFF59E0B),
                      'Moderate',
                      '0.50-0.60',
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      const Color(0xFFEF4444),
                      'High Risk',
                      '> 0.60',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Expandable About & Calculation
          InkWell(
            onTap: () => setState(() => _showWhtrInfo = !_showWhtrInfo),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'About & Calculation',
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Icon(
                  _showWhtrInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          if (_showWhtrInfo) ...[
            const SizedBox(height: 6),
            Text(
              'Calculated as Waist (cm) / Height (cm). Keeps track of central adiposity and cardiovascular health.',
              style: AppStyles.text10Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniGauge(
    double value, {
    required double min,
    required double max,
    required bool hasData,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double percent = ((value - min) / (max - min)).clamp(0.0, 1.0);
        final double pinLeft = (width * percent).clamp(5.0, width - 5.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                width: width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF10B981),
                      Color(0xFFF59E0B),
                      Color(0xFFEF4444),
                    ],
                  ),
                ),
              ),
            ),
            if (hasData)
              Positioned(
                left: pinLeft - 4,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E293B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.text10Px.poppins.w500.copyWith(
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                sub,
                style: AppStyles.text9Px.poppins.w400.copyWith(
                  color: const Color(0xFF94A3B8),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== Body Measurements Section ====================
  Widget _buildMeasurementsSection({
    required String height,
    required String weight,
    required String neck,
    required String waist,
    required String hip,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Measurements',
            style: AppStyles.text16Px.poppins.w700.copyWith(
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.swap_vert,
                  iconColor: const Color(0xFFEF4444),
                  label: 'Height',
                  value: height,
                  unit: 'cm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: const Color(0xFFEF4444),
                  label: 'Weight',
                  value: weight,
                  unit: 'kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.format_line_spacing,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'Neck',
                  value: neck,
                  unit: neck != '--' ? 'cm' : '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.straighten,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Waist',
                  value: waist,
                  unit: waist != '--' ? 'cm' : '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.accessibility,
                  iconColor: const Color(0xFF10B981),
                  label: 'Hip',
                  value: hip,
                  unit: hip != '--' ? 'cm' : '',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  text: value,
                  style: AppStyles.text15Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                  children: [
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Medical Disclaimer ====================
  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF64748B),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Results are estimates and not a substitute for professional medical advice.',
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
