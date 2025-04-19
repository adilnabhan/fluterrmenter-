// ignore_for_file: public_member_api_docs

import 'package:mentor_mobile_app/imports_bindings.dart';

///* For store global typography properties and methords
extension TextStyleX on TextStyle {
  //*Montserrat
  TextStyle get w100 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w100);
  TextStyle get w300 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w300);
  TextStyle get w400 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  TextStyle get w500 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  TextStyle get w600 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  TextStyle get w700 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  TextStyle get w800 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w800);
  TextStyle get w900 =>
      copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w900);

  //*Lato
  TextStyle get lato100 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w100);
  TextStyle get lato300 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w300);
  TextStyle get lato400 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w400);
  TextStyle get lato500 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w500);
  TextStyle get lato600 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w600);
  TextStyle get lato700 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w700);
  TextStyle get lato800 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w800);
  TextStyle get lato900 =>
      copyWith(fontFamily: 'Lato', fontWeight: FontWeight.w900);

  //*Poppins
  TextStyle get poppins100 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w100);
  TextStyle get poppins300 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w300);
  TextStyle get poppins400 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w400);
  TextStyle get poppins500 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w500);
  TextStyle get poppins600 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600);
  TextStyle get poppins700 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w700);
  TextStyle get poppins800 =>
      copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w800);

  //*Colors
  TextStyle get dark => copyWith(color: AppColors.dark);
  TextStyle get light => copyWith(color: AppColors.light);
  TextStyle get primary => copyWith(color: AppColors.primary);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get textGrey => copyWith(color: AppColors.textGrey);

  //* Custom methords
  TextStyle kcolor(Color color) => copyWith(color: color);
  // Adaptive
  // TextStyle get adaptive => copyWith(fontSize: fontSize);
  //opacity methods
  ///
  TextStyle opacity(double opacity) =>
      copyWith(color: color?.withOpacity(opacity));
}
