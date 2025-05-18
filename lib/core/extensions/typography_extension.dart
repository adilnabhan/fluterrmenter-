// ignore_for_file: public_member_api_docs

import 'package:mentor_mobile_app/imports_bindings.dart';

///* For store global typography properties and methords
extension TextStyleX on TextStyle {
  //* Font Styles
  TextStyle get montserrat => copyWith(fontFamily: 'Montserrat');
  TextStyle get lato => copyWith(fontFamily: 'Lato');
  TextStyle get poppins => copyWith(fontFamily: 'Poppins');
  TextStyle get titanOne => copyWith(fontFamily: 'TitanOne');

  //* Font weights
  TextStyle get w100 => copyWith(fontWeight: FontWeight.w100);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);

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
  TextStyle opacity(double opacity) => copyWith(color: color?.withOpacity(opacity));
}
