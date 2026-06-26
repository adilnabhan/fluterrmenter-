import 'package:mentor_mobile_app/imports_bindings.dart';

///
extension WidgetX on Widget {
  ///
  Widget pad(double pad) => Padding(padding: EdgeInsets.all(pad), child: this);

  ///
  Widget pxy({double x = 0, double y = 0}) => Padding(padding: EdgeInsets.symmetric(horizontal: x, vertical: y), child: this);

  ///
  Widget pOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);

  ///
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);

  ///
  Widget visible({required bool isVisible, Widget replacer = const SizedBox.shrink()}) => Visibility(visible: isVisible, replacement: replacer, child: this);

  ///
  Widget get center => Center(child: this);
}
