import 'package:mentor_mobile_app/imports_bindings.dart';

/// A reusable month & year picker bottom sheet matching the trainers tab design.
class AppMonthPickerBottomSheet extends StatefulWidget {
  const AppMonthPickerBottomSheet({
    required this.selectedDate,
    required this.onMonthSelected,
    super.key,
  });

  /// The currently selected date.
  final DateTime selectedDate;

  /// Callback when a month is selected.
  final ValueChanged<DateTime> onMonthSelected;

  /// Shows the reusable month picker modal bottom sheet.
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    ValueChanged<DateTime>? onSelected,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return AppMonthPickerBottomSheet(
          selectedDate: initialDate,
          onMonthSelected: (date) {
            onSelected?.call(date);
            Navigator.pop(ctx, date);
          },
        );
      },
    );
  }

  @override
  State<AppMonthPickerBottomSheet> createState() =>
      _AppMonthPickerBottomSheetState();
}

class _AppMonthPickerBottomSheetState extends State<AppMonthPickerBottomSheet> {
  late int _pickerYear;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _pickerYear = widget.selectedDate.year;
  }

  @override
  Widget build(BuildContext context) {
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
                    setState(() {
                      _pickerYear--;
                    });
                  },
                ),
                Text(
                  '$_pickerYear',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _pickerYear++;
                    });
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = widget.selectedDate.year == _pickerYear &&
                    widget.selectedDate.month == index + 1;
                return InkWell(
                  onTap: () {
                    widget.onMonthSelected(
                      DateTime(_pickerYear, index + 1),
                    );
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
                      _months[index],
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
  }
}
