import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:flutter/scheduler.dart';

class WordField extends StatefulWidget {
  const WordField({
    this.autofillHints,
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
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
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
    this.borderRadius,
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
  final void Function()? onTap;
  final bool onTapAlwaysCalled;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
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
  final BorderRadius? borderRadius;
  final Iterable<String>? autofillHints;

  @override
  State<WordField> createState() => _WordFieldState();
}

class _WordFieldState extends State<WordField> {
  late final WidgetStatesController _stateController;

  @override
  void initState() {
    _stateController = WidgetStatesController();
    _stateController.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller?.text;
    final errorText = widget.validator?.call(text);
    if ((widget.label?.isEmpty ?? true) && widget.labelStyle != null) {
      throw Exception('Label != null && Label.isEmpty != true');
    }
    final labelStyle = widget.labelStyle ?? AppStyles.text14Px.poppins500.dark;
    var border =
        widget.decoration?.border ?? context.theme.inputDecorationTheme.border;
    var errorBorder =
        widget.decoration?.errorBorder ??
        context.theme.inputDecorationTheme.errorBorder;
    var focusedBorder =
        widget.decoration?.focusedBorder ??
        context.theme.inputDecorationTheme.focusedBorder;
    var enabledBorder =
        widget.decoration?.enabledBorder ??
        context.theme.inputDecorationTheme.enabledBorder;
    var focusedErrorBorder =
        widget.decoration?.focusedErrorBorder ??
        context.theme.inputDecorationTheme.focusedErrorBorder;
    var disabledBorder =
        widget.decoration?.disabledBorder ??
        context.theme.inputDecorationTheme.disabledBorder;
    if (border is OutlineInputBorder) {
      border = border.copyWith(
        borderRadius: widget.borderRadius,
        borderSide: border.borderSide,
        gapPadding: border.gapPadding,
      );
    }
    if (errorBorder is OutlineInputBorder) {
      errorBorder = errorBorder.copyWith(
        borderRadius: widget.borderRadius,
        borderSide: errorBorder.borderSide,
        gapPadding: errorBorder.gapPadding,
      );
    }
    if (focusedBorder is OutlineInputBorder) {
      focusedBorder = focusedBorder.copyWith(
        borderRadius: widget.borderRadius,
        borderSide: focusedBorder.borderSide,
        gapPadding: focusedBorder.gapPadding,
      );
    }
    if (enabledBorder is OutlineInputBorder) {
      enabledBorder = enabledBorder.copyWith(
        borderRadius: widget.borderRadius,
        borderSide: enabledBorder.borderSide,
        gapPadding: enabledBorder.gapPadding,
      );
    }
    if (focusedErrorBorder is OutlineInputBorder) {
      focusedErrorBorder = focusedErrorBorder.copyWith(
        borderRadius: widget.borderRadius,
        borderSide: focusedErrorBorder.borderSide,
        gapPadding: focusedErrorBorder.gapPadding,
      );
    }
    if (disabledBorder is OutlineInputBorder) {
      disabledBorder = disabledBorder.copyWith(
        borderRadius: widget.borderRadius,
        borderSide: disabledBorder.borderSide,
        gapPadding: disabledBorder.gapPadding,
      );
    }

    return TapRegion(
      onTapOutside: (t) {
        widget.onTapOutside?.call(t);
        if (widget.onTapOutside != null) {
          widget.focusNode?.unfocus();
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: AbsorbPointer(
        absorbing: !(widget.enabled ?? true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label?.isNotEmpty ?? false) ...[
              RichText(
                text: TextSpan(
                  text: widget.label ?? '',
                  style: labelStyle,
                  children: [
                    if (widget.requiredLabel ?? false)
                      TextSpan(
                        text: '*',
                        style: labelStyle.kcolor(AppColors.primary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              key: widget.fieldKey,
              controller: widget.controller,
              initialValue: widget.initialValue,
              focusNode: widget.focusNode,
              decoration: (widget.decoration ?? const InputDecoration())
                  .copyWith(
                    errorMaxLines: 1,
                    border: border,
                    errorBorder: errorBorder,
                    focusedBorder: focusedBorder,
                    enabledBorder: enabledBorder,
                    focusedErrorBorder: focusedErrorBorder,
                    disabledBorder: disabledBorder,

                    errorStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                      height: 0,
                    ),
                  ),
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              style: (widget.style ?? AppStyles.text14Px.poppins500).copyWith(
                color:
                    widget.enabled ?? true
                        ? AppColors.dark
                        : const Color(0xff9D9A9F),
              ),
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
              onTap: widget.onTap,
              onTapAlwaysCalled: widget.onTapAlwaysCalled,
              onTapOutside: widget.onTapOutside,
              onEditingComplete: widget.onEditingComplete,
              onFieldSubmitted: widget.onFieldSubmitted,
              onSaved: widget.onSaved,
              inputFormatters: widget.inputFormatters,
              enabled: widget.enabled,
              cursorWidth: widget.cursorWidth,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              cursorColor: widget.cursorColor ?? AppColors.dark,
              cursorErrorColor: widget.cursorErrorColor ?? AppColors.dark,
              keyboardAppearance: widget.keyboardAppearance,
              autovalidateMode: widget.autovalidateMode,
              obscureText: widget.obscureText,
              statesController: _stateController,
            ),

            //*
            if (widget.controller != null && widget.validator != null)
              switch ((errorText?.isEmpty ?? true) ||
                  !_stateController.value.contains(WidgetState.error)) {
                true => const SizedBox.shrink(),
                false => Text(
                  errorText ?? '',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ).pxy(y: 8.r),
              },
          ],
        ),
      ),
    );
  }
}
