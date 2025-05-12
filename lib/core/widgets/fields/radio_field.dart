import 'package:mentor_mobile_app/imports_bindings.dart';

class RadioField<T> extends StatefulWidget {
  const RadioField({
    required this.items,
    this.onValueChanged,
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
    this.onRadioFieldSubmitted,
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
  final ValueChanged<({String label, T value})>? onValueChanged;
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
  final void Function(String)? onRadioFieldSubmitted;
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
  State<RadioField<T>> createState() => _RadioFieldState<T>();
}

class _RadioFieldState<T> extends State<RadioField<T>> {
  // T selectedRadio;
  late final TextEditingController _ctrl;
  OverlayEntry? _overlyEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    _ctrl = widget.controller ?? TextEditingController(text: widget.initialValue);
    widget.focusNode?.addListener(() {
      showOverlay(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
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
    final field = context.findRenderObject()! as RenderBox;
    final fildPositionInScreen = field.localToGlobal(Offset.zero);
    final fieldSize = field.size;
    final overlyState = Overlay.of(context);

    // Calculate available space below the button
    final screenHeight = MediaQuery.of(context).size.height;
    final availableSpaceBelow = screenHeight - fildPositionInScreen.dy - fieldSize.height;
    final sheetHeight = (widget.items.length < widget.tileShowCount ? widget.items.length : widget.tileShowCount) * widget.tileHeight;
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
                      builder: (context, value, child) {
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ...widget.items.map((e) {
                              final isSelected = e.label == value.text;
                              return InkWell(
                                onTap: () {
                                  _ctrl.value = TextEditingValue(text: e.label);
                                  widget.onValueChanged?.call(e);
                                  _overlyEntry?.remove();
                                  _overlyEntry = null;
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    setState(() {});
                                  });
                                },
                                child: SizedBox(
                                  height: widget.tileHeight,
                                  width: double.maxFinite,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          child: Text(e.label, textAlign: TextAlign.start, style: isSelected ? AppStyles.text14Px.poppins.w500 : AppStyles.text14Px.poppins.w400),
                                        ).pxy(x: 16),
                                      ),
                                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20).pxy(x: 16),
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
      child: InkWell(
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: () {
          showOverlay(context);
        },
        child: CompositedTransformTarget(
          link: _layerLink,
          child: AbsorbPointer(
            child: WordField(
              key: widget.fieldKey,
              controller: _ctrl,
              initialValue: widget.initialValue,
              expands: widget.expands,
              fieldKey: widget.fieldKey,
              label: widget.label,
              labelStyle: widget.labelStyle,
              requiredLabel: widget.requiredLabel,
              focusNode: widget.focusNode,
              decoration: (widget.decoration ?? const InputDecoration()).copyWith(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    switch (_overlyEntry == null) {
                      true => const Icon(Icons.keyboard_arrow_down_outlined, size: 24),
                      false => const Icon(Icons.keyboard_arrow_up_outlined, size: 24),
                    },
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
              onFieldSubmitted: widget.onRadioFieldSubmitted,
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
    );
  }
}
