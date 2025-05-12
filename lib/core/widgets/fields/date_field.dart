import 'package:mentor_mobile_app/imports_bindings.dart';

class DateField extends StatefulWidget {
  const DateField({
    this.label,
    super.key,
    this.labelStyle,
    this.requiredLabel,
    this.fieldKey,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLengthEnforcement,
    this.maxLines,
    this.minLines,
    this.expands,
    this.maxLength,
    this.onChanged,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onEditingComplete,
    this.onDateFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.autovalidateMode,
    this.obscureText = false,
    this.startTime,
    this.endTime,
    this.borderRadius,
    this.dateTimeShowFormat,
  });

  final Key? fieldKey;
  final String? label;
  final TextStyle? labelStyle;
  final bool? requiredLabel;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool? expands;
  final int? maxLength;
  final void Function(String)? onChanged;
  final bool onTapAlwaysCalled;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;
  final void Function(String)? onDateFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String? text)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final Brightness? keyboardAppearance;
  final AutovalidateMode? autovalidateMode;
  final bool obscureText;
  final DateTime? startTime;
  final DateTime? endTime;
  final BorderRadius? borderRadius;
  final DateFormat? dateTimeShowFormat;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  DateTime? selectedDate;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    _ctrl = widget.controller ?? TextEditingController(text: widget.initialValue);
    final initialDateAsString = widget.initialValue ?? _ctrl.text;
    if (initialDateAsString.trim().isNotEmpty) {
      selectedDate = widget.dateTimeShowFormat != null ? widget.dateTimeShowFormat!.parse(initialDateAsString) : DateFormat('yyyy/MM/dd').parse(initialDateAsString);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !(widget.enabled ?? true),
      child: InkWell(
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: selectedDate ?? widget.endTime ?? DateTime.now(),
            firstDate: widget.startTime ?? DateTime(0000),
            lastDate: widget.endTime ?? DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    // onSurface: Colors.yellow,
                  ),
                  dialogBackgroundColor: AppColors.primary,
                ),
                child: child!,
              );
            },
          ).then((newDate) {
            if (newDate != null) {
              setState(() {
                selectedDate = newDate;
                if (widget.dateTimeShowFormat != null) {
                  _ctrl.value = TextEditingValue(text: widget.dateTimeShowFormat!.format(newDate));
                } else {
                  _ctrl.value = TextEditingValue(text: selectedDate?.yyyyMMDDslash ?? '');
                }
              });
            }
          });
          // showDialog<void>(
          //   context: context,
          //   builder: (context) {
          //     return Dialog(
          //       backgroundColor: AppColors.light,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //       child: DatePickerWidget(
          //         selectedDate: selectedDate ?? widget.endTime ?? DateTime.now(),
          //         startTime: widget.startTime,
          //         endTime: widget.endTime,
          //         onDateSelected: (newDate) {
          //           selectedDate = newDate;
          //           if (widget.dateTimeShowFormat != null) {
          //             _ctrl.value = TextEditingValue(text: widget.dateTimeShowFormat!.format(newDate));
          //           } else {
          //             _ctrl.value = TextEditingValue(text: selectedDate?.yyyyMMDDslash ?? '');
          //           }
          //         },
          //       ),
          //     );
          //   },
          // );
        },
        child: AbsorbPointer(
          child: WordField(
            key: widget.fieldKey,
            controller: _ctrl,
            focusNode: widget.focusNode,
            initialValue: widget.initialValue,
            expands: widget.expands,
            fieldKey: widget.fieldKey,
            label: widget.label,
            labelStyle: widget.labelStyle,
            requiredLabel: widget.requiredLabel,
            decoration: (widget.decoration ?? const InputDecoration()).copyWith(
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600), // Updated for demo
                ],
              ),
            ),
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            style: widget.style,
            strutStyle: widget.strutStyle,
            textDirection: widget.textDirection,
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            maxLengthEnforcement: widget.maxLengthEnforcement,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            onTapAlwaysCalled: widget.onTapAlwaysCalled,
            onTapOutside: widget.onTapOutside,
            onEditingComplete: widget.onEditingComplete,
            onFieldSubmitted: widget.onDateFieldSubmitted,
            onSaved: widget.onSaved,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: widget.cursorColor,
            cursorErrorColor: widget.cursorErrorColor,
            keyboardAppearance: widget.keyboardAppearance,
            autovalidateMode: widget.autovalidateMode,
            obscureText: widget.obscureText,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}
