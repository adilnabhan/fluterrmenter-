import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';

class TrainerClientOtherDetailsScreen extends StatelessWidget {
  const TrainerClientOtherDetailsScreen({
    required this.clientData,
    this.bodyMatrixData,
    this.customerId,
    super.key,
  });

  final Map<String, dynamic> clientData;
  final Map<String, dynamic>? bodyMatrixData;
  final dynamic customerId;

  int _calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty || dobString == 'null') return 0;
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age > 0 ? age : 0;
    } catch (_) {
      return 0;
    }
  }

  String _formatHeight(dynamic rawHeight, Map<dynamic, dynamic> inputs) {
    final inputVal = inputs['height_cm'];
    final val = inputVal ?? rawHeight;
    if (val == null) return 'N/A';
    final s = val.toString().replaceAll(RegExp(r'[^\d.]'), '').trim();
    final d = double.tryParse(s);
    if (d != null) {
      return '${d.toStringAsFixed(2)} CM';
    }
    final str = val.toString().trim();
    return str.isEmpty || str == 'null'
        ? 'N/A'
        : (str.toUpperCase().contains('CM')
            ? str.toUpperCase()
            : '$str CM');
  }

  String _formatWeight(dynamic rawWeight, Map<dynamic, dynamic> inputs) {
    final inputVal = inputs['weight_kg'];
    final val = inputVal ?? rawWeight;
    if (val == null) return 'N/A';
    final s = val.toString().replaceAll(RegExp(r'[^\d.]'), '').trim();
    final d = double.tryParse(s);
    if (d != null) {
      return '${d.toStringAsFixed(2)} KG';
    }
    final str = val.toString().trim();
    return str.isEmpty || str == 'null'
        ? 'N/A'
        : (str.toUpperCase().contains('KG')
            ? str.toUpperCase()
            : '$str KG');
  }

  String _formatTargetWeight(dynamic rawTargetWeight) {
    if (rawTargetWeight == null) return 'N/A';
    final s = rawTargetWeight.toString().replaceAll(RegExp(r'[^\d.]'), '').trim();
    final d = double.tryParse(s);
    if (d != null) {
      return '${d.toStringAsFixed(2)} KG';
    }
    final str = rawTargetWeight.toString().trim();
    return str.isEmpty || str == 'null'
        ? 'N/A'
        : (str.toUpperCase().contains('KG')
            ? str.toUpperCase()
            : '$str KG');
  }

  String _formatTitle(dynamic val) {
    if (val == null) return 'N/A';
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'N/A') return 'N/A';
    return str
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatHealthIssues(dynamic val) {
    if (val == null) return 'NO';
    final s = val.toString().trim();
    if (s.isEmpty || s == 'null' || s == 'false' || s.toUpperCase() == 'NO') {
      return 'NO';
    }
    return s.toUpperCase() == 'YES' ? 'YES' : s;
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        clientData['profile'] as Map<dynamic, dynamic>? ?? clientData;
    final inputsMap =
        bodyMatrixData?['inputs'] as Map<dynamic, dynamic>? ?? {};

    // Health Style values
    final rawDob = profile['date_of_birth'] as String? ??
        clientData['date_of_birth'] as String?;
    final int calculatedAge = _calculateAge(rawDob);
    final String ageStr = calculatedAge > 0
        ? calculatedAge.toString()
        : (profile['age'] ?? clientData['age'] ?? 'N/A').toString();

    final String heightStr = _formatHeight(
      profile['height'] ?? clientData['height'],
      inputsMap,
    );
    final String weightStr = _formatWeight(
      profile['weight'] ?? clientData['weight'],
      inputsMap,
    );
    final String healthIssuesStr = _formatHealthIssues(
      profile['health_issues'] ?? clientData['health_issues'],
    );
    final String activityLevelStr = _formatTitle(
      profile['activity_level'] ?? clientData['activity_level'],
    );
    final String fitnessLevelStr = _formatTitle(
      profile['fitness_level'] ?? clientData['fitness_level'],
    );
    final String targetWeightStr = _formatTargetWeight(
      profile['target_weight'] ?? clientData['target_weight'],
    );

    // Lifestyle values
    final String professionStr = (profile['profession'] ??
            clientData['profession'] ??
            'N/A')
        .toString();
    final String workConditionStr = (profile['work_condition'] ??
            clientData['work_condition'] ??
            '')
        .toString();
    final String workingHourStr = (profile['work_hour'] ??
            clientData['work_hour'] ??
            profile['working_hour'] ??
            clientData['working_hour'] ??
            'N/A')
        .toString();
    final String sleepingHourStr = (profile['sleep_hour'] ??
            clientData['sleep_hour'] ??
            profile['sleeping_hour'] ??
            clientData['sleeping_hour'] ??
            'N/A')
        .toString();

    return Scaffold(
      backgroundColor:
          context.isDarkMode ? context.colors.background : const Color(0xffF9FAFB),
      appBar: AppBar(
        backgroundColor:
            context.isDarkMode ? context.colors.background : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 14),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.grey.shade800
                    : const Color(0xffF2F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: context.isDarkMode
                    ? Colors.white
                    : const Color(0xff1F2937),
              ),
            ),
          ),
        ),
        title: Text(
          'Other Details',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.isDarkMode
                ? context.colors.textPrimary
                : const Color(0xff111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Style Header
            Text(
              'Health Style',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: context.isDarkMode
                    ? context.colors.textPrimary
                    : const Color(0xff111827),
              ),
            ),
            const SizedBox(height: 12),

            // Health Style Card
            _buildDetailsCard(
              context,
              children: [
                _buildRow(context, 'Age', ageStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Height', heightStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Weight', weightStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Health Issues', healthIssuesStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Activity Level', activityLevelStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Fitness Level', fitnessLevelStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Target Weight', targetWeightStr),
              ],
            ),

            const SizedBox(height: 24),

            // Lifestyle Header
            Text(
              'Lifestyle',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: context.isDarkMode
                    ? context.colors.textPrimary
                    : const Color(0xff111827),
              ),
            ),
            const SizedBox(height: 12),

            // Lifestyle Card
            _buildDetailsCard(
              context,
              children: [
                _buildRow(context, 'Profession', professionStr),
                const SizedBox(height: 16),
                _buildWorkConditionRow(workConditionStr, context),
                const SizedBox(height: 16),
                _buildRow(context, 'Working Hour (avg)', workingHourStr),
                const SizedBox(height: 16),
                _buildRow(context, 'Sleeping Hour (avg)', sleepingHourStr),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.colors.card : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? context.colors.border
              : const Color(0xffEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: context.isDarkMode
                ? context.colors.textSecondary
                : const Color(0xff4B5563),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: context.isDarkMode
                  ? context.colors.textPrimary
                  : const Color(0xff111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkConditionRow(String? workCondition, BuildContext context) {
    final normalized =
        (workCondition ?? '').toLowerCase().replaceAll('_', ' ').trim();

    final emojis = [
      {'label': 'very happy', 'emoji': '😁', 'alias': ['great', 'excellent', 'very_happy', '1']},
      {'label': 'happy', 'emoji': '🙂', 'alias': ['good', 'satisfied', '2']},
      {'label': 'neutral', 'emoji': '😐', 'alias': ['normal', 'average', 'okay', 'ok', '3']},
      {'label': 'sad', 'emoji': '🙁', 'alias': ['unhappy', 'stressed', '4']},
      {'label': 'depressed', 'emoji': '😢', 'alias': ['very sad', 'crying', 'terrible', 'very stressed', '5']},
    ];

    int selectedIndex = -1;
    for (int i = 0; i < emojis.length; i++) {
      final item = emojis[i];
      final aliasList = item['alias'] as List<String>;
      if (normalized == item['label'] || aliasList.contains(normalized)) {
        selectedIndex = i;
        break;
      }
    }

    if (selectedIndex == -1 && normalized.isNotEmpty) {
      for (int i = 0; i < emojis.length; i++) {
        if (normalized.contains(emojis[i]['label'] as String)) {
          selectedIndex = i;
          break;
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Work Condition',
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: context.isDarkMode
                ? context.colors.textSecondary
                : const Color(0xff4B5563),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(emojis.length, (index) {
            final isSelected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xffEF4444) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : const Color(0xffF9FAFB),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xffEF4444).withOpacity(0.3)
                          : (context.isDarkMode
                              ? Colors.grey.shade700
                              : const Color(0xffE5E7EB)),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    emojis[index]['emoji'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
