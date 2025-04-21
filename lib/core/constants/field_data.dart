import 'package:mentor_mobile_app/imports_bindings.dart';

part 'field_data.freezed.dart';

///*
enum FieldType { word, checkbox, radio, date, image, search, time }

@freezed
class FieldData<T> with _$FieldData<T> {
  const factory FieldData({
    required FieldType type,
    void Function(List<({String label, T value})>)? onValueChanged,
    ValueNotifier<List<({String label, T value})>>? selectedValues,
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
}
