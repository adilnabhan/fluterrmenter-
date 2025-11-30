import 'package:mentor_mobile_app/imports_bindings.dart';

class TimeField extends StatefulWidget {
  const TimeField({
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
    this.onTimeFieldSubmitted,
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
    this.autovaliTimeMode,
    this.obscureText = false,
    this.borderRadius,
    this.timeShowFormat,
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
  final void Function(String)? onTimeFieldSubmitted;
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
  final AutovalidateMode? autovaliTimeMode;
  final bool obscureText;
  final BorderRadius? borderRadius;
  final DateFormat? timeShowFormat;

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  TimeOfDay? selectedTime;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    _ctrl =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    final initialDateAsString = widget.initialValue ?? _ctrl.text;
    if (initialDateAsString.trim().isNotEmpty) {
      selectedTime = TimeOfDay.fromDateTime(
        widget.timeShowFormat != null
            ? widget.timeShowFormat!.parse(initialDateAsString)
            : DateFormat('hh:mm a').parse(initialDateAsString),
      );
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
        onTap: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            selectedTime = pickedTime;
            _ctrl.value = TextEditingValue(
              text:
                  widget.timeShowFormat != null
                      ? widget.timeShowFormat!.format(
                        DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute),
                      )
                      : DateFormat('hh:mm a').format(
                        DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute),
                      ),
            );
          }
        },
        child: AbsorbPointer(
          child: WordField(
            key: widget.fieldKey,
            controller: _ctrl,
            borderRadius: widget.borderRadius,
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
                  SvgPicture.asset(
                    'assets/images/svg/icons/clock.svg',
                    height: 20,
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.dark,
                      BlendMode.srcIn,
                    ),
                  ),
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
            onFieldSubmitted: widget.onTimeFieldSubmitted,
            onSaved: widget.onSaved,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: widget.cursorColor,
            cursorErrorColor: widget.cursorErrorColor,
            keyboardAppearance: widget.keyboardAppearance,
            autovalidateMode: widget.autovaliTimeMode,
            obscureText: widget.obscureText,
          ),
        ),
      ),
    );
  }
}
