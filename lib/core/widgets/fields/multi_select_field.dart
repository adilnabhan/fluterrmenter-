import 'package:mentor_mobile_app/imports_bindings.dart';

class MultiSelectField<T> extends StatefulWidget {
  const MultiSelectField({
    this.selectedMultiValues,
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
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
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

  final ValueNotifier<List<String>>? selectedMultiValues;
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
  final bool onTapAlwaysCalled;
  final void Function(PointerDownEvent)? onTapOutside;
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
  final BorderRadius? borderRadius;

  @override
  State<MultiSelectField<T>> createState() => _MultiSelectFieldState<T>();
}

class _MultiSelectFieldState<T> extends State<MultiSelectField<T>>
    with ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !(widget.enabled ?? true),
      child: Column(
        children: [
          WordField(
            controller: widget.controller,
            key: widget.fieldKey,
            focusNode: widget.focusNode,
            initialValue: widget.initialValue,
            expands: widget.expands,
            fieldKey: widget.fieldKey,
            label: widget.label,
            labelStyle: widget.labelStyle,
            requiredLabel: widget.requiredLabel,
            onFieldSubmitted: (_) {
              if (widget.selectedMultiValues != null &&
                  (widget.controller?.text.trim().isNotEmpty ?? false)) {
                widget.selectedMultiValues?.value.add(
                  widget.controller?.text ?? '',
                );
                widget.controller?.clear();
                widget.selectedMultiValues?.notifyListeners();
              }
            },
            decoration: (widget.decoration ?? const InputDecoration()).copyWith(
              // ============ OLD CODE - BLACK BUTTON COMMENTED OUT ============
              // suffixIcon: SizedBox.square(
              //   dimension: 20,
              //   child: Center(
              //     child: IconButton.filled(
              //       onPressed: () {
              //         if (widget.selectedMultiValues != null && (widget.controller?.text.trim().isNotEmpty ?? false)) {
              //           widget.selectedMultiValues?.value.add(widget.controller?.text ?? '');
              //           widget.controller?.clear();
              //           widget.selectedMultiValues?.notifyListeners();
              //         }
              //       },
              //       style: IconButton.styleFrom(
              //         backgroundColor: AppColors.dark,
              //         foregroundColor: AppColors.light,
              //         fixedSize: const Size.square(32),
              //         maximumSize: const Size.square(32),
              //         minimumSize: const Size.square(32),
              //         padding: EdgeInsets.zero,
              //       ),
              //       icon: const Icon(Icons.add),
              //     ),
              //   ),
              // ),
              // ============ END OLD CODE ============

              // ============ NEW CODE - RED CIRCULAR BUTTON ============
              suffixIcon: SizedBox.square(
                dimension: 20,
                child: Center(
                  child: IconButton.filled(
                    onPressed: () {
                      if (widget.selectedMultiValues != null &&
                          (widget.controller?.text.trim().isNotEmpty ??
                              false)) {
                        widget.selectedMultiValues?.value.add(
                          widget.controller?.text ?? '',
                        );
                        widget.controller?.clear();
                        widget.selectedMultiValues?.notifyListeners();
                      }
                    },
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors
                              .primary, // Changed from AppColors.dark to red
                      foregroundColor: AppColors.light,
                      fixedSize: const Size.square(32),
                      maximumSize: const Size.square(32),
                      minimumSize: const Size.square(32),
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
              // ============ END NEW CODE ============
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
            onTapAlwaysCalled: widget.onTapAlwaysCalled,
            onTapOutside: widget.onTapOutside,
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
          if (widget.selectedMultiValues != null)
            ValueListenableBuilder(
              valueListenable: widget.selectedMultiValues!,
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
                          // ============ OLD CODE - COMMENTED OUT ============
                          // return DecoratedBox(
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(4),
                          //     border: Border.all(
                          //       color: const Color(0xffE6E6E6),
                          //     ),
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     spacing: 16,
                          //     children: [
                          //       Text(item, style: AppStyles.text12Px.w500.dark),
                          //       IconButton.filled(
                          //         onPressed: () {
                          //           widget.selectedMultiValues?.value.remove(
                          //             item,
                          //           );
                          //           widget.selectedMultiValues
                          //               ?.notifyListeners();
                          //         },
                          //         style: IconButton.styleFrom(
                          //           backgroundColor: AppColors.dark,
                          //           foregroundColor: AppColors.light,
                          //           fixedSize: const Size.square(20),
                          //           maximumSize: const Size.square(20),
                          //           minimumSize: const Size.square(20),
                          //           iconSize: 16,
                          //           padding: EdgeInsets.zero,
                          //           tapTargetSize:
                          //               MaterialTapTargetSize.shrinkWrap,
                          //         ),
                          //         icon: const Icon(Icons.close),
                          //       ),
                          //     ],
                          //   ).pxy(y: 8, x: 12),
                          // ).pOnly(top: 8);
                          // ============ END OLD CODE ============

                          // ============ NEW CODE - CLEAN CHIP DESIGN ============
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
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
                                  item,
                                  style: AppStyles.text14Px.poppins.w400.dark,
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () {
                                    widget.selectedMultiValues?.value.remove(
                                      item,
                                    );
                                    widget.selectedMultiValues
                                        ?.notifyListeners();
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ],
                            ),
                          );
                          // ============ END NEW CODE ============
                          // return Chip(
                          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          //   side: BorderSide.none,
                          //   elevation: 0,
                          //   shadowColor: Colors.transparent,
                          //   surfaceTintColor: Colors.transparent,
                          //   deleteIconBoxConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          //   backgroundColor: Colors.transparent,
                          //   onDeleted: () {},
                          // );
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
