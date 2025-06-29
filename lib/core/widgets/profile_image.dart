import 'package:mentor_mobile_app/imports_bindings.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({required this.isEdit, this.fit = BoxFit.cover, this.url, this.onChanged, this.radius, super.key});

  final String? url;
  final double? radius;
  final BoxFit fit;
  final void Function(XFile? image)? onChanged;
  final bool isEdit;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  XFile? _localImage;

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius ?? 111.r;
    final iconSize = widget.radius != null ? widget.radius! * .4 : 42.w;
    return InkWell(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap:
          () =>
              widget.isEdit
                  ? ImagePickerDialog(
                    needRemove: _localImage?.path.isNotEmpty ?? false,
                    onPickedImage: (image) {
                      if (image != null) {
                        _localImage = image;
                        widget.onChanged?.call(_localImage);
                      } else {
                        _localImage = XFile('');
                      }
                      setState(() {});
                    },
                  ).show(context)
                  : null,
      child: SizedBox.square(
        dimension: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ///*
            if (_localImage?.path.isNotEmpty ?? false)
              ClipRRect(borderRadius: BorderRadius.circular(10000), child: Image.file(File(_localImage!.path), fit: widget.fit, height: radius, width: radius))
            else if ((widget.url?.isNotEmpty ?? true) && widget.url != '')
              ClipRRect(borderRadius: BorderRadius.circular(10000), child: ImageNetwork(widget.url, fit: widget.fit, errorWidget: isEmpty(radius)))
            else
              isEmpty(radius),

            ///*
            if (widget.onChanged != null && widget.isEdit)
              Container(
                height: iconSize,
                width: iconSize,
                decoration: BoxDecoration(color: AppColors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: iconSize * 0.05)),
                child: SvgPicture.asset('assets/images/svg/icons/camera_outlined.svg').pad(iconSize * 0.2),
              ).align(Alignment.bottomRight),
          ],
        ),
      ),
    ).center;
  }

  Widget isEmpty(double radius) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: radius * 0.03)),
      child: SvgPicture.asset('assets/images/svg/icons/person_filled.svg', height: radius, width: radius),
    );
  }
}
