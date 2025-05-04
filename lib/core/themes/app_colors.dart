// ignore_for_file: public_member_api_docs

import 'package:feggy_core/imports_bindings.dart';

///* Store colors using this application
@immutable
abstract class AppColors {
  //*Theme primary color
  //
  static const Color primary = Color(0xffCF0B10);
  static const Color lightPrimary = Color(0xffFFD0D0);
  static const Color light = Colors.white;
  static const Color dark = Colors.black;
  static const Color button = Color(0xff222222);
  static const Color disabledButton = Color(0xffD0D0D0);
  static const Color error = Color(0xffFF3434);
  static const Color grey = Color(0xffEEEEEE);

  // Add new colors
  static const Color textDark = Color(0xFF020202);
  static const Color textGrey = Color(0xFF666666);
  static const Color borderGrey = Color(0xFFE8E8E8);
  static const Color iconBackground = Color(0xffE6E6E6);
  static const Color lightGrey = Color(0xFFE8E8E8);
  static const Color fieldFillColor = Color(0xFFF4F5FA);
}
