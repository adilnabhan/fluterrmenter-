import 'package:mentor_mobile_app/imports_bindings.dart';

class PopButton extends StatelessWidget {
  const PopButton({this.onPressed, super.key});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (Navigator.canPop(context) == false) {
      return const SizedBox.shrink();
    }
    return IconButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }
}
