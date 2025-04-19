import 'package:feggy_core/imports_bindings.dart';

///* Store this application using styles
@immutable
abstract class AppStyles {
  ///* Text 8px
  static TextStyle get text8Px => const TextStyle(
    fontSize: 8,
    //height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    //height: calculateHeight(14, 12),
  );

  ///* Text 9px
  static TextStyle get text9Px => const TextStyle(
    fontSize: 9,
    //height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    //height: calculateHeight(14, 12),
  );

  ///* Text 10px
  static TextStyle get text10Px => const TextStyle(
    fontSize: 10,
    //height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    //height: calculateHeight(14, 12),
  );

  ///* Text 12px
  static TextStyle get text12Px => const TextStyle(
    fontSize: 11,
    //height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    //height: calculateHeight(14, 12),
  );

  ///* Text 13px
  static TextStyle get text13Px => const TextStyle(
    fontSize: 12,
    //height: calculateHeight(15, 13),
  );

  ///* Text 14px
  static TextStyle get text14Px => const TextStyle(
    fontSize: 14,
    //height: calculateHeight(15, 13),
  );

  ///* Text 15px
  static TextStyle get text15Px => const TextStyle(
    fontSize: 15,
    //height: calculateHeight(15, 13),
  );

  ///* Text 16px
  static TextStyle get text16Px => const TextStyle(
    fontSize: 16,
    //height: calculateHeight(15, 13),
  );

  ///* Text 18px
  static TextStyle get text18Px => const TextStyle(
    fontSize: 18,
    //height: calculateHeight(15, 13),
  );

  ///* Text 18px
  static TextStyle get text19Px => const TextStyle(
    fontSize: 19,
    //height: calculateHeight(15, 13),
  );

  ///* Text 20px
  static TextStyle get text20Px => const TextStyle(
    fontSize: 20,
    //height: calculateHeight(15, 13),
  );

  ///* Text 22px
  static TextStyle get text22Px => const TextStyle(
    fontSize: 22,
    //height: calculateHeight(15, 13),
  );

  ///* Text 24px
  static TextStyle get text24Px => const TextStyle(
    fontSize: 24,
    //height: calculateHeight(15, 13),
  );

  ///* Text 24px
  static TextStyle get text25Px => const TextStyle(
    fontSize: 25,
    //height: calculateHeight(15, 13),
  );

  ///* Text 24px
  static TextStyle get text26Px => const TextStyle(
    fontSize: 26,
    //height: calculateHeight(15, 13),
  );

  ///* Text 28px
  static TextStyle get text28Px => const TextStyle(
    fontSize: 28,
    //height: calculateHeight(15, 13),
  );

  ///* Text 28px
  static TextStyle get text29Px => const TextStyle(
    fontSize: 29,
    //height: calculateHeight(15, 13),
  );

  ///* Text 28px
  static TextStyle get text30Px => const TextStyle(
    fontSize: 30,
    //height: calculateHeight(15, 13),
  );

  ///* Text 32px
  static TextStyle get text32Px => const TextStyle(
    fontSize: 32,
    //height: calculateHeight(15, 13),
  );

  ///* Text 36px
  static TextStyle get text36Px => const TextStyle(
    fontSize: 36,
    //height: calculateHeight(15, 13),
  );

  ///* Calculate line height of text
  static double calculateHeight(double height, double fontSize) {
    return height / fontSize;
  }

  ///* Calculate letter spacing of text
  static double calculateSpacing(double em) {
    return 16 * em;
  }
}
