// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

///
class Button extends StatefulWidget {
  ///
  factory Button.filled({
    required String title,
    required void Function() ontap,
    TextStyle? style,
    double raduis = 8,
    bool isLoading = false,
    bool isDisabled = false,
    Size? size,
    Widget? icon,
    Color? buttonColor,
    Color? disabledButtonColor,
    Color? loadingColor,
  }) {
    return Button._(
      title: title,
      ontap: ontap,
      raduis: raduis,
      isLoading: isLoading,
      style: style,
      isDisabled: isDisabled,
      size: size,
      icon: icon,
      color: switch (isDisabled) {
        true => disabledButtonColor ?? AppColors.disabledButton,
        false => buttonColor ?? AppColors.button,
      },
      side: BorderSide.none,
      loadingColor: loadingColor ?? AppColors.light,
    );
  }

  ///
  factory Button.outlined({required String title, required void Function() ontap, TextStyle? style, double raduis = 8, bool isLoading = false, bool isDisabled = false, Size? size, Widget? icon}) {
    return Button._(
      title: title,
      ontap: ontap,
      raduis: raduis,
      isLoading: isLoading,
      outlined: true,
      style: style,
      isDisabled: isDisabled,
      color: Colors.transparent,
      side: const BorderSide(color: AppColors.button),
      icon: icon,
      size: size,
    );
  }

  const Button._({
    required this.title,
    required this.ontap,
    required this.raduis,
    required this.isLoading,
    required this.isDisabled,
    required this.color,
    required this.side,
    this.style,
    this.size,
    this.outlined,
    this.icon,
    this.loadingColor = AppColors.light,
  });

  final String title;
  final void Function() ontap;
  final TextStyle? style;
  final double raduis;
  final bool isLoading;
  final bool isDisabled;
  final Size? size;
  final Color color;
  final Color loadingColor;
  final BorderSide side;
  final bool? outlined;
  final Widget? icon;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child:
          widget.outlined ?? false
              ? GestureDetector(
                onTap: widget.ontap,
                child: Container(
                  height: 48.h,
                  width: context.width,
                  decoration: BoxDecoration(border: Border.all(color: AppColors.disabledButton), color: Colors.transparent, borderRadius: BorderRadius.circular(widget.raduis)),
                  child: Center(
                    child:
                        widget.isLoading
                            ? const CupertinoActivityIndicator(color: AppColors.dark)
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[widget.icon!, SizedBox(width: 8.w)],
                                Text(widget.title, style: widget.style ?? AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xff444444))),
                              ],
                            ),
                  ),
                ),
              )
              : GestureDetector(
                onTap: (!widget.isLoading && !widget.isDisabled) ? () => widget.ontap() : null,
                child: Container(
                  height: 48.h,
                  width: context.width,
                  decoration: BoxDecoration(border: Border.all(color: widget.color), color: widget.color, borderRadius: BorderRadius.circular(widget.raduis)),
                  child: Center(
                    child:
                        widget.isLoading
                            ? CupertinoActivityIndicator(color: widget.loadingColor)
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[widget.icon!, SizedBox(width: 8.w)],
                                Text(widget.title, style: widget.style ?? AppStyles.text14Px.poppins.w600.light),
                              ],
                            ),
                  ),
                ),
              ),
    );
  }
}
