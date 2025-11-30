import 'package:flutter/cupertino.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class BrandLogoPicker extends StatefulWidget {
  const BrandLogoPicker({
    required this.isEdit,
    this.fit = BoxFit.cover,
    this.url,
    this.onChanged,
    this.radius,
    super.key,
  });

  final String? url;
  final double? radius;
  final BoxFit fit;
  final void Function(XFile? image)? onChanged;
  final bool isEdit;

  @override
  State<BrandLogoPicker> createState() => _BrandLogoPickerState();
}

class _BrandLogoPickerState extends State<BrandLogoPicker> {
  XFile? _localImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius ?? 111.r;
    return InkWell(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap:
          () =>
              widget.isEdit
                  ? ImagePickerDialog(
                    needRemove: _localImage != null,
                    // onPickedImage: (image) {
                    //   widget.onChanged?.call(image);
                    //   setState(() => _localImage = image);
                    // },
                    onPickStart: () => setState(() => _isLoading = true),
                    onPickEnd: () => setState(() => _isLoading = false),
                    onPickedImage: (image) {
                      widget.onChanged?.call(image);
                      setState(() => _localImage = image);
                    },
                  ).show(context)
                  : null,
      child: SizedBox.square(
        dimension: 80,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ///*
            if (_localImage?.path.isNotEmpty ?? false)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10000),
                  color: AppColors.primary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000),
                  child: Image.file(
                    File(_localImage!.path),
                    fit: widget.fit,
                    height: radius,
                    width: radius,
                  ),
                ).pad(1.5),
              )
            else if ((widget.url?.isNotEmpty ?? true) && widget.url != '')
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10000),
                  color: AppColors.primary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000),
                  child: ImageNetwork(
                    widget.url,
                    fit: widget.fit,
                    errorWidget: isEmpty(radius),
                  ).pad(1.5),
                ),
              )
            else
              isEmpty(radius),

            if (_isLoading) const Center(child: CupertinoActivityIndicator()),

            ///*
            // if (widget.onChanged != null &&
            //     widget.isEdit &&
            //     (_localImage != null || widget.url != null))
            //   SvgPicture.asset(
            //     'assets/images/svg/icons/photo_update.svg',
            //     height: 20,
            //   ).pad(1).align(Alignment.bottomRight),
            if (!_isLoading &&
                widget.onChanged != null &&
                widget.isEdit &&
                (_localImage != null || widget.url != null))
              SvgPicture.asset(
                'assets/images/svg/icons/photo_update.svg',
                height: 20,
              ).pad(1).align(Alignment.bottomRight),
          ],
        ),
      ),
    ).center;
  }

  Widget isEmpty(double radius) {
    return CircleAvatar(
      backgroundColor: AppColors.lightPrimary,
      child: SvgPicture.asset(
        'assets/images/svg/icons/camera_plus.svg',
        height: 24,
      ),
    );
  }
}
