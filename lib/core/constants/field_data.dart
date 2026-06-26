import 'package:mentor_mobile_app/imports_bindings.dart';

part 'field_data.freezed.dart';

///*
enum FieldType { word, checkbox, radio, date, image, search, time, multValues }

@freezed
class FieldData<T> with _$FieldData<T> {
  factory FieldData({
    required FieldType type,
    void Function(List<({String label, T value})>)? onValueChanged,
    ValueNotifier<List<({String label, T value})>>? selectedValues,
    ValueNotifier<List<String>>? selectedMultiValues,
    double tileHeight = 48,
    int tileShowCount = 4,
    double dividerHeight = 8,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool readOnly = false,
    bool onTapAlwaysCalled = false,
    double cursorWidth = 2,
    bool obscureText = false,
    List<({String label, T value})>? items,
    String? label,
    TextStyle? labelStyle,
    bool? requiredLabel,
    Key? fieldKey,
    TextEditingController? controller,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlignVertical? textAlignVertical,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? minLines,
    bool? expands,
    int? maxLength,
    void Function(String)? onChanged,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onEditingComplete,
    void Function(String)? onSubmitted,
    void Function(String?)? onSaved,
    void Function()? onTap,
    String? Function(String? text)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Color? cursorErrorColor,
    Brightness? keyboardAppearance,
    AutovalidateMode? autovalidateMode,
    DateTime? startTime,
    DateTime? endTime,
    BorderRadius? borderRadius,
    Iterable<String>? autofillHints,
    DateFormat? dateTimeShowFormat,
  }) {
    final key = type == FieldType.date ? GlobalKey<DateFieldState>() : GlobalKey();
    return FieldData._(
      type: type,
      key: key,
      onValueChanged: onValueChanged,
      selectedValues: selectedValues,
      selectedMultiValues: selectedMultiValues,
      tileHeight: tileHeight,
      tileShowCount: tileShowCount,
      dividerHeight: dividerHeight,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      autofocus: autofocus,
      readOnly: readOnly,
      onTapAlwaysCalled: onTapAlwaysCalled,
      cursorWidth: cursorWidth,
      obscureText: obscureText,
      items: items,
      label: label,
      labelStyle: labelStyle,
      requiredLabel: requiredLabel,
      fieldKey: fieldKey,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlignVertical: textAlignVertical,
      maxLengthEnforcement: maxLengthEnforcement,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onTapOutside: onTapOutside,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      onSaved: onSaved,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      cursorErrorColor: cursorErrorColor,
      keyboardAppearance: keyboardAppearance,
      autovalidateMode: autovalidateMode,
      startTime: startTime,
      endTime: endTime,
      borderRadius: borderRadius,
      autofillHints: autofillHints,
      dateTimeShowFormat: dateTimeShowFormat,
    );
  }

  factory FieldData._({
    required FieldType type,
    @Default(null) Key? key,
    void Function(List<({String label, T value})>)? onValueChanged,
    ValueNotifier<List<({String label, T value})>>? selectedValues,
    ValueNotifier<List<String>>? selectedMultiValues,
    @Default(48) double tileHeight,
    @Default(4) int tileShowCount,
    @Default(8) double dividerHeight,
    @Default(1) int maxLines,
    @Default(TextCapitalization.none) TextCapitalization textCapitalization,
    @Default(TextAlign.start) TextAlign textAlign,
    @Default(false) bool autofocus,
    @Default(false) bool readOnly,
    @Default(false) bool onTapAlwaysCalled,
    @Default(2) double cursorWidth,
    @Default(false) bool obscureText,
    List<({String label, T value})>? items,
    String? label,
    TextStyle? labelStyle,
    bool? requiredLabel,
    Key? fieldKey,
    TextEditingController? controller,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlignVertical? textAlignVertical,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? minLines,
    bool? expands,
    int? maxLength,
    void Function(String)? onChanged,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onEditingComplete,
    void Function(String)? onSubmitted,
    void Function(String?)? onSaved,
    void Function()? onTap,
    String? Function(String? text)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Color? cursorErrorColor,
    Brightness? keyboardAppearance,
    AutovalidateMode? autovalidateMode,
    DateTime? startTime,
    DateTime? endTime,
    BorderRadius? borderRadius,
    Iterable<String>? autofillHints,

    ///* DateTime
    DateFormat? dateTimeShowFormat,
  }) = _FieldData<T>;
}

extension FieldDataExt<T> on FieldData<T> {
  DateTime? get selectedDateTime {
    if (type != FieldType.date) {
      return null;
    }
    if (controller?.text.isEmpty ?? true) {
      return null;
    }
    try {
      final dateFormat = dateTimeShowFormat ?? DateFormat('yyyy/MM/dd');
      return dateFormat.parse(controller!.text);
    } catch (e) {
      return null;
    }
  }

  TimeOfDay? get selectedTime {
    if (type != FieldType.time) {
      return null;
    }
    if (controller?.text.isEmpty ?? true) {
      return null;
    }
    try {
      final dateFormat = dateTimeShowFormat ?? DateFormat('hh:mm a');
      return TimeOfDay.fromDateTime(dateFormat.parse(controller!.text));
    } catch (e) {
      return null;
    }
  }

  Future<void> requestToFocus() async {
    if (key != null && key is GlobalKey<DateFieldState> && type == FieldType.date) {
      final context = (key! as GlobalKey<DateFieldState>).currentState?.context;
      if (context != null) {
        await (key! as GlobalKey<DateFieldState>).currentState?.showPicker(context);
      }
    }
  }
}
