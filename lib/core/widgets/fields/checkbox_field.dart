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

  @override
  State<CheckboxField<T>> createState() => _CheckboxFieldState<T>();
}

class _CheckboxFieldState<T> extends State<CheckboxField<T>> with ChangeNotifier {
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

  void showOverlay(BuildContext context) {
    if (_overlyEntry != null) {
      _overlyEntry?.remove();
      _overlyEntry = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
      return;
    }

    final field = _fieldKey.currentContext!.findRenderObject()! as RenderBox;
    final fildPositionInScreen = field.localToGlobal(Offset.zero);
    final fieldSize = field.size;
    final overlyState = Overlay.of(context);

    // Calculate available space below the button
    final sheetHeight = (widget.items.length < widget.tileShowCount ? widget.items.length : widget.tileShowCount) * widget.tileHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableSpaceBelow = screenHeight - fildPositionInScreen.dy - fieldSize.height;
    // Determine if there is enough space below, otherwise show above
    final showBelow = availableSpaceBelow >= sheetHeight;

    _overlyEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: fildPositionInScreen.dx,
          top: showBelow ? fildPositionInScreen.dy + fieldSize.height + widget.dividerHeight : fildPositionInScreen.dy - sheetHeight - widget.dividerHeight,
          child: CompositedTransformFollower(
            link: this._layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, showBelow ? fieldSize.height + widget.dividerHeight : -sheetHeight - widget.dividerHeight),
            child: Material(
              color: Colors.transparent,
              child: TapRegion(
                onTapOutside: (v) {
                  final buttonBounds = Rect.fromLTWH(fildPositionInScreen.dx, fildPositionInScreen.dy, fieldSize.width, fieldSize.height);

                  if (buttonBounds.contains(v.localPosition)) {
                    return;
                  }
                  _overlyEntry?.remove();
                  _overlyEntry = null;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {});
                  });
                },
                child: Container(
                  height: sheetHeight,
                  width: field.size.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.light, border: Border.all(color: const Color(0xffE2E4FF))),
                  child: Scrollbar(
                    radius: const Radius.circular(24),
                    thickness: 4,
                    child: ValueListenableBuilder(
                      valueListenable: _ctrl,
                      builder: (context, values, child) {
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ...widget.items.map((e) {
                              final isSelected = values.contains(e);
                              return InkWell(
                                onTap: () {
                                  if (isSelected) {
                                    _ctrl.value.remove(e);
                                  } else {
                                    _ctrl.value.add(e);
                                  }
                                  _ctrl.notifyListeners();
                                  widget.onValueChanged?.call(_ctrl.value);
                                },
                                child: SizedBox(
                                  height: widget.tileHeight,
                                  width: double.maxFinite,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          child: Text(
                                            e.label,
                                            textAlign: TextAlign.start,
                                            style: AppStyles.text14Px.w400.kcolor(const Color(0xff3F3F3F)).copyWith(fontWeight: isSelected ? FontWeight.w500 : null),
                                          ),
                                        ).pxy(x: 16),
                                      ),
                                      SvgPicture.asset(isSelected ? 'assets/images/icons/checkbox_filled.svg' : 'assets/images/icons/checkbox_outlined.svg', width: 20, height: 20).pxy(x: 16),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (_overlyEntry != null) {
      overlyState.insert(_overlyEntry!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !(widget.enabled ?? true),
      child: Column(
        children: [
          InkWell(
            key: _fieldKey,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            onTap: () {
              showOverlay(context);
            },
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
                  decoration: (widget.decoration ?? const InputDecoration()).copyWith(
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedSwitcher(
                          duration: 500.milliseconds,
                          child: switch (_overlyEntry == null) {
                            true => SvgPicture.asset('assets/images/icons/down_arrow.svg', width: 14, height: 14, key: const Key('down')),
                            false => SvgPicture.asset('assets/images/icons/top_arrow.svg', width: 14, height: 14, key: const Key('up')),
                          },
                        ),
                        20.horizontalSpace,
                      ],
                    ),
                    disabledBorder:
                        _overlyEntry != null
                            ? widget.decoration?.focusedBorder ?? context.theme.inputDecorationTheme.focusedBorder
                            : widget.decoration?.disabledBorder ?? context.theme.inputDecorationTheme.disabledBorder,
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
          ValueListenableBuilder(
            valueListenable: _ctrl,
            builder: (context, values, child) {
              if (values.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                width: context.width,
                child: Wrap(
                  spacing: 8,
                  children:
                      values.map((item) {
                        return Chip(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
                          side: BorderSide.none,
                          backgroundColor: AppColors.primary,
                          deleteIcon: const Icon(color: AppColors.light, Icons.clear, size: 15),
                          label: Text(item.label, style: AppStyles.text12Px.w400.light.copyWith(fontWeight: FontWeight.w400)),
                          onDeleted: () {
                            _ctrl.value.remove(item);
                            _ctrl.notifyListeners();
                          },
                        );
                      }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
