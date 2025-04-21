import 'package:mentor_mobile_app/imports_bindings.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({
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
  final void Function(XFile image)? onChanged;
  final bool isEdit;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  XFile? _localImage;

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius ?? 111.r;
    return InkWell(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: () => widget.isEdit ? _showBottomSheet(context) : null,
      child: SizedBox.square(
        dimension: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ///*
            if (_localImage?.path.isNotEmpty ?? false)
              ClipRRect(
                borderRadius: BorderRadius.circular(10000),
                child: Image.file(
                  File(_localImage!.path),
                  fit: widget.fit,
                  height: radius,
                  width: radius,
                ),
              )
            else if ((widget.url?.isNotEmpty ?? true) && widget.url != '')
              ClipRRect(
                borderRadius: BorderRadius.circular(10000),
                child: ImageNetwork(
                  widget.url,
                  fit: widget.fit,
                  errorWidget: isEmpty(radius),
                ),
              )
            else
              isEmpty(radius),

            ///*
            if (widget.onChanged != null && widget.isEdit)
              Container(
                height: 42.w,
                width: 42.w,
                decoration: const BoxDecoration(
                  color: AppColors.dark,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/images/icons/camera_icon.svg',
                ).pad(10.r),
              ).align(Alignment.bottomRight),
          ],
        ),
      ),
    ).center;
  }

  SvgPicture isEmpty(double radius) {
    return SvgPicture.asset(
      'assets/images/svg/profile_place_holder.svg',
      height: radius,
      width: radius,
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensures it takes only necessary space
            children: [
              InkWell(
                onTap:
                    widget.onChanged == null
                        ? null
                        : () {
                          ImagePicker()
                              .pickImage(source: ImageSource.camera)
                              .then((xFile) {
                                if (xFile != null) {
                                  setState(() {
                                    widget.onChanged?.call(xFile);
                                    _localImage = xFile;
                                  });
                                }
                              });
                          context.pop();
                        },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.disabledButton),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/icons/media_camera.svg'),
                      16.horizontalSpace,
                      Text(
                        'Click Photo',
                        style: AppStyles.text10Px.lato.w400.dark,
                      ),
                    ],
                  ).pad(16.r),
                ),
              ),
              30.verticalSpace,
              InkWell(
                onTap:
                    widget.onChanged == null
                        ? null
                        : () {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((xFile) {
                                if (xFile != null) {
                                  setState(() {
                                    widget.onChanged?.call(xFile);
                                    _localImage = xFile;
                                  });
                                }
                              });
                          context.pop();
                        },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.disabledButton),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/icons/media_gallery.svg'),
                      16.horizontalSpace,
                      Text(
                        'Upload image from Gallery',
                        style: AppStyles.text10Px.lato.w400.dark,
                      ),
                    ],
                  ).pad(16.r),
                ),
              ),
            ],
          ).pad(36.r),
        );
      },
    );
  }
}
