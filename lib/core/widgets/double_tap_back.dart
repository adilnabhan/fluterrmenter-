import 'package:mentor_mobile_app/imports_bindings.dart';

class DoubleTapBack extends StatefulWidget {
  const DoubleTapBack({required this.child, this.disable = false, super.key});

  final Widget child;
  final bool disable;

  @override
  State<DoubleTapBack> createState() => _DoubleTapBackState();
}

class _DoubleTapBackState extends State<DoubleTapBack> {
  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    if (widget.disable) {
      return widget.child;
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          Dialogs.showSnack(msg: 'Press back again to exit');
          return;
        }
        exit(0);
      },
      child: widget.child,
    );
  }
}
