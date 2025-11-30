import 'package:mentor_mobile_app/imports_bindings.dart';

class CheckboxField<T> extends StatefulWidget {
  const CheckboxField({
    required this.items,
    this.onValueChanged,
    this.selectedValues,
    this.tileHeight = 48,
    this.tileShowCount = 4,
    this.dividerHeight = 8,
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
    this.onCheckboxFieldSubmitted,
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
    this.obscureText = false,
    this.autovalidateMode,
    this.borderRadius,
    this.onTap,
  });

  final List<({String label, T value})> items;
  final ValueChanged<List<({String label, T value})>>? onValueChanged;
  final ValueNotifier<List<({String label, T value})>>? selectedValues;
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
  final void Function(String)? onCheckboxFieldSubmitted;
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
  final double tileHeight;
  final int tileShowCount;
  final double dividerHeight;
  final BorderRadius? borderRadius;
  final void Function()? onTap;

  @override
  State<CheckboxField<T>> createState() => _CheckboxFieldState<T>();
}

class _CheckboxFieldState<T> extends State<CheckboxField<T>>
    with ChangeNotifier {
  // T selectedRadio;
  late final ValueNotifier<List<({String label, T value})>> _ctrl;
  OverlayEntry? _overlyEntry;
  final _fieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    _ctrl = widget.selectedValues ?? ValueNotifier([]);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.selectedValues == null) {
      _ctrl.dispose();
    }
    _overlyEntry?.remove();
    _overlyEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AbsorbPointer(
        absorbing: !(widget.enabled ?? true),
        child: Column(
          children: [
            InkWell(
              key: _fieldKey,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: AbsorbPointer(
                  child: WordField(
                    key: widget.fieldKey,
                    focusNode: widget.focusNode,
                    initialValue: widget.initialValue,
                    expands: widget.expands,
                    fieldKey: widget.fieldKey,
                    label: widget.label,
                    labelStyle: widget.labelStyle,
                    requiredLabel: widget.requiredLabel,
                    decoration: (widget.decoration ?? const InputDecoration())
                        .copyWith(
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              switch (_overlyEntry == null) {
                                true => const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  size: 24,
                                ),
                                false => const Icon(
                                  Icons.keyboard_arrow_up_outlined,
                                  size: 24,
                                ),
                              },
                              20.horizontalSpace,
                            ],
                          ),
                          disabledBorder:
                              _overlyEntry != null
                                  ? widget.decoration?.focusedBorder ??
                                      context
                                          .theme
                                          .inputDecorationTheme
                                          .focusedBorder
                                  : widget.decoration?.disabledBorder ??
                                      context
                                          .theme
                                          .inputDecorationTheme
                                          .disabledBorder,
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
                    onFieldSubmitted: widget.onCheckboxFieldSubmitted,
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
            ),
            if (widget.selectedValues != null)
              ValueListenableBuilder(
                valueListenable: widget.selectedValues!,
                builder: (context, values, child) {
                  if (values.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          widget.selectedValues!.value.length,
                          (index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffF7F7F7),
                                borderRadius: BorderRadius.circular(80000),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.selectedValues!.value[index].label,
                                    style: AppStyles.text14Px.poppins.w400.dark,
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () {
                                      widget.selectedValues!.value =
                                          widget.selectedValues!.value
                                              .where(
                                                (element) =>
                                                    element.value !=
                                                    widget
                                                        .selectedValues!
                                                        .value[index]
                                                        .value,
                                              )
                                              .toList();
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/svg/icons/close_outlined.svg',
                                      height: 16,
                                      width: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
