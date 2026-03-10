// import 'package:mentor_mobile_app/imports_bindings.dart';
//
// class ImagePickerDialog extends StatelessWidget {
//   const ImagePickerDialog({
//     super.key,
//     this.onPickedImage,
//     this.needRemove = true,
//     this.onPickStart,
//     this.onPickEnd,
//   });
//
//   final bool needRemove;
//   final void Function(XFile? image)? onPickedImage;
//   final VoidCallback? onPickStart;
//   final VoidCallback? onPickEnd;
//
//   Future<void> show(BuildContext context) async {
//     await showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => this,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final contents = [
//       (
//         label: 'Take Photo',
//         onTap: () {
//           // ImagePicker().pickImage(source: ImageSource.camera).then((xFile) {
//           //   if (xFile != null) {
//           //     if (context.mounted) {
//           //       onPickedImage?.call(xFile);
//           //       context.pop();
//           //     }
//           //   }
//           // });
//           onPickStart?.call();
//           ImagePicker().pickImage(source: ImageSource.camera).then((xFile) {
//             onPickEnd?.call();
//             if (xFile != null) {
//               if (context.mounted) {
//                 onPickedImage?.call(xFile);
//                 context.pop();
//               }
//             }
//           });
//         },
//       ),
//       (
//         label: 'Choose from gallery',
//         onTap: () {
//           // ImagePicker().pickImage(source: ImageSource.gallery).then((xFile) {
//           //   if (xFile != null) {
//           //     if (context.mounted) {
//           //       onPickedImage?.call(xFile);
//           //       context.pop();
//           //     }
//           //   }
//           // });
//           onPickStart?.call();
//           ImagePicker().pickImage(source: ImageSource.gallery).then((xFile) {
//             onPickEnd?.call();
//             if (xFile != null) {
//               if (context.mounted) {
//                 onPickedImage?.call(xFile);
//                 context.pop();
//               }
//             }
//           });
//         },
//       ),
//       if (needRemove)
//         (
//           label: 'Remove Photo',
//           onTap: () {
//             if (context.mounted) {
//               onPickedImage?.call(null);
//               context.pop();
//             }
//           },
//         ),
//       (
//         label: 'Cancel',
//         onTap: () {
//           context.pop();
//         },
//       ),
//     ];
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.light,
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: ListView.separated(
//         shrinkWrap: true,
//         itemCount: contents.length,
//         itemBuilder: (BuildContext context, int index) {
//           return InkWell(
//             onTap: () {
//               contents[index].onTap();
//             },
//             child: Text(
//               contents[index].label,
//               textAlign: TextAlign.center,
//               style: AppStyles.text16Px.poppins.w400.dark,
//             ).pxy(y: 22),
//           );
//         },
//         separatorBuilder: (BuildContext context, int index) {
//           return const Divider(
//             color: AppColors.borderGrey,
//             height: 1,
//             thickness: 1,
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:mentor_mobile_app/imports_bindings.dart';

class ImagePickerDialog extends StatelessWidget {
  const ImagePickerDialog({
    super.key,
    this.needRemove = true,
    this.allowMultiple = false,
    this.onPickedImage,
    this.onPickedImages,
    this.onPickStart,
    this.onPickEnd,
  });

  final bool needRemove;
  final bool allowMultiple;

  /// Single image callback
  final void Function(XFile? image)? onPickedImage;

  /// Multiple images callback
  final void Function(List<XFile> images)? onPickedImages;

  final VoidCallback? onPickStart;
  final VoidCallback? onPickEnd;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => this,
    );
  }

  // 📷 Camera → always single image
  Future<void> _pickFromCamera(BuildContext context) async {
    onPickStart?.call();

    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.camera);

    onPickEnd?.call();

    if (!context.mounted || image == null) return;

    onPickedImage?.call(image);
    context.pop();
  }

  // 🖼 Gallery → single OR multiple
  Future<void> _pickFromGallery(BuildContext context) async {
    onPickStart?.call();

    final picker = ImagePicker();

    if (allowMultiple) {
      final List<XFile> images =
      await picker.pickMultiImage(imageQuality: 80);

      onPickEnd?.call();

      if (!context.mounted || images.isEmpty) return;

      onPickedImages?.call(images);
    } else {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      onPickEnd?.call();

      if (!context.mounted || image == null) return;

      onPickedImage?.call(image);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final contents = [
      (
      label: 'Take Photo',
      onTap: () => _pickFromCamera(context),
      ),
      (
      label: 'Choose from gallery',
      onTap: () => _pickFromGallery(context),
      ),
      if (needRemove)
        (
        label: 'Remove Photo',
        onTap: () {
          onPickedImage?.call(null);
          context.pop();
        },
        ),
      (
      label: 'Cancel',
      onTap: () => context.pop(),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: contents.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: contents[index].onTap,
            child: Text(
              contents[index].label,
              textAlign: TextAlign.center,
              style: AppStyles.text16Px.poppins.w400.dark,
            ).pxy(y: 22),
          );
        },
        separatorBuilder: (_, __) => const Divider(
          color: AppColors.borderGrey,
          height: 1,
          thickness: 1,
        ),
      ),
    );
  }
}
