import 'package:mentor_mobile_app/imports_bindings.dart';

class ImagePickerDialog extends StatelessWidget {
  const ImagePickerDialog({super.key, this.onPickedImage});

  final void Function(XFile? image)? onPickedImage;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    final contents = [
      (
        label: 'Take Photo',
        onTap: () {
          ImagePicker().pickImage(source: ImageSource.camera).then((xFile) {
            if (xFile != null) {
              if (context.mounted) {
                onPickedImage?.call(xFile);
                context.pop();
              }
            }
          });
        },
      ),
      (
        label: 'Choose from galley',
        onTap: () {
          ImagePicker().pickImage(source: ImageSource.gallery).then((xFile) {
            if (xFile != null) {
              if (context.mounted) {
                onPickedImage?.call(xFile);
                context.pop();
              }
            }
          });
        },
      ),
      (
        label: 'Cancel',
        onTap: () {
          context.pop();
        },
      ),
    ];
    return Container(
      decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(24)),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: contents.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              contents[index].onTap();
            },
            child: Text(contents[index].label, textAlign: TextAlign.center, style: AppStyles.text16Px.poppins.w400.dark).pxy(y: 22),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(color: AppColors.borderGrey, height: 1, thickness: 1);
        },
      ),
    );
  }
}
