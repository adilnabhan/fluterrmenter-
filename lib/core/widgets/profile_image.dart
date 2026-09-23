import 'package:mentor_mobile_app/imports_bindings.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({
    required this.isEdit,
    this.fit = BoxFit.cover,
    this.url,
    this.onChanged,
    this.radius,
    this.canViewFullImage = false,
    this.name,
    this.onTap,
    super.key,
  });

  final String? url;
  final double? radius;
  final BoxFit fit;
  final void Function(XFile? image)? onChanged;
  final bool isEdit;
  final bool canViewFullImage;
  final String? name;
  final VoidCallback? onTap;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  XFile? _localImage;

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius ?? 111.r;
    final iconSize = widget.radius != null ? widget.radius! * .4 : 42.w;

    VoidCallback? resolvedOnTap;
    if (widget.onTap != null) {
      resolvedOnTap = widget.onTap;
    } else if (widget.isEdit) {
      resolvedOnTap = () {
        ImagePickerDialog(
          needRemove: _localImage?.path.isNotEmpty ?? false,
          onPickedImage: (image) {
            if (image != null) {
              _localImage = image;
              widget.onChanged?.call(_localImage);
            } else {
              _localImage = XFile('');
            }
            if (!mounted) return;
            setState(() {});
          },
        ).show(context);
      };
    } else if (widget.canViewFullImage) {
      resolvedOnTap = () {
        Dialogs.showEnlargedProfilePhoto(
          context,
          widget.url,
          name: widget.name,
        );
      };
    }

    return InkWell(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: resolvedOnTap,
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
            else if (widget.url != null &&
                widget.url!.trim().isNotEmpty &&
                widget.url!.trim() != 'null')
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
                height: iconSize,
                width: iconSize,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: iconSize * 0.05,
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/svg/icons/camera_outlined.svg',
                ).pad(iconSize * 0.2),
              ).align(Alignment.bottomRight),
          ],
        ),
      ),
    ).center;
  }

  Widget isEmpty(double radius) {
    if (widget.name != null && widget.name!.trim().isNotEmpty) {
      final trimmed = widget.name!.trim();
      String initial = trimmed[0].toUpperCase();
      for (final rune in trimmed.runes) {
        final char = String.fromCharCode(rune);
        if (RegExp(r'[a-zA-Z0-9]').hasMatch(char)) {
          initial = char.toUpperCase();
          break;
        }
      }
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: radius * 0.45,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.primary,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: radius * 0.03),
      ),
      child: SvgPicture.asset(
        'assets/images/svg/icons/person_filled.svg',
        height: radius,
        width: radius,
      ),
    );
  }
}
