import 'package:mentor_mobile_app/imports_bindings.dart';

class TimePickerField extends StatelessWidget {
  const TimePickerField({required this.label, required this.controller, required this.focusNotifier, this.decoration, this.requiredLabel, super.key});

  final String label;
  final TextEditingController controller;
  final ValueNotifier<bool> focusNotifier;
  final InputDecoration? decoration;
  final bool? requiredLabel;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppStyles.text14Px.w400.kcolor(AppColors.button);
    final formattedTime = DateFormat('hh:mm a').format(DateTime(0, 0, 0, TimeOfDay.now().hour, TimeOfDay.now().minute));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(text: TextSpan(text: label, style: labelStyle, children: [if (requiredLabel ?? false) TextSpan(text: '*', style: labelStyle.kcolor(AppColors.primary))])),
          14.verticalSpace,
        ],
        ValueListenableBuilder<bool>(
          valueListenable: focusNotifier,
          builder: (context, hasFocus, child) {
            return SizedBox(
              height: 50,
              child: TextField(
                controller: controller,
                readOnly: true,
                style: AppStyles.text14Px.w400.kcolor(AppColors.primary),
                cursorColor: AppColors.primary,
                onTap: () async {
                  focusNotifier.value = true;
                  final selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  focusNotifier.value = false;
                  if (selectedTime != null) {
                    controller.text = selectedTime.format(context);
                  }
                },
                decoration:
                    decoration ??
                    InputDecoration(
                      hintText: formattedTime, //TimeOfDay.now().toString(),
                      contentPadding: const EdgeInsets.all(14),
                      hintStyle: AppStyles.text14Px.w400.kcolor(AppColors.disabledButton),
                      fillColor: Colors.transparent,
                      suffixIcon: const Icon(Icons.access_time_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xffD8D8D8)), borderRadius: BorderRadius.all(Radius.circular(8))),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xffD8D8D8)), borderRadius: BorderRadius.all(Radius.circular(8))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xff17477A)), borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}
