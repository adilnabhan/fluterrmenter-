import 'package:mentor_mobile_app/imports_bindings.dart';

///*
@immutable
sealed class AppThemes {
  // ///* Set status bar color
  // static void setStatusBarColor() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: AppColors.primary,
  //       statusBarIconBrightness: Brightness.light,
  //     ),
  //   );
  // }

  ///*
  static final light = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.light,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: AppStyles.text16Px.w500.light,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Set your desired radius
        ),
        backgroundColor: AppColors.button,
        disabledBackgroundColor: AppColors.disabledButton,
        foregroundColor: AppColors.light,
        disabledForegroundColor: AppColors.light,
      ),
    ),
    splashColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: AppStyles.text18Px.w500.dark.copyWith(
        fontWeight: FontWeight.w500,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldFillColor,
      //   //   prefixStyle: AppStyles.text14Px.w400.kcolor(AppColors.darkBlue),
      //   //   labelStyle: AppStyles.text14Px.w400.kcolor(AppColors.darkBlue),
      //   //   hintStyle: AppStyles.text14Px.w400.kcolor(AppColors.lightGrey),
      //   //   fillColor: AppColors.light,
      //   //   filled: true,
      //   //   contentPadding: const EdgeInsets.all(20),
      errorStyle: AppStyles.text14Px.poppins400.error,
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    //   // progressIndicatorTheme: const ProgressIndicatorThemeData(
    //   //   color: AppColors.dark,
    //   // ),
    //   // textTheme: TextTheme(
    //   //   displaySmall: AppStyles.text13Px.w400.dark,
    // ),
  );

  ///*
  static final dark = ThemeData.dark().copyWith(
    // scaffoldBackgroundColor: AppColors.backgroundColorF4F1EA,
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ElevatedButton.styleFrom(
    //     textStyle: AppStyles.text16Px.w500.light,
    //     padding: const EdgeInsets.all(16),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(4), // Set your desired radius
    //     ),
    //     backgroundColor: AppColors.primary,
    //     disabledBackgroundColor: AppColors.disableColorD6D6DC,
    //     foregroundColor: AppColors.light,
    //     disabledForegroundColor: AppColors.light,
    //   ),
    // ),
    // appBarTheme: AppBarTheme(
    //   centerTitle: true,
    //   titleTextStyle: AppStyles.text18Px.w500.light,
    //   iconTheme: const IconThemeData(color: Colors.white),
    //   backgroundColor: AppColors.dark,
    //   surfaceTintColor: AppColors.dark,
    //   elevation: 0,
    // ),
    // splashColor: Colors.transparent,
    // inputDecorationTheme: InputDecorationTheme(
    //   prefixStyle: AppStyles.text14Px.w400.kcolor(AppColors.darkBlue),
    //   labelStyle: AppStyles.text14Px.w400.kcolor(AppColors.darkBlue),
    //   hintStyle: AppStyles.text14Px.w400.kcolor(AppColors.lightGrey),
    //   errorStyle: AppStyles.text14Px.w400.error,
    //   contentPadding: const EdgeInsets.all(20),
    //   border: const OutlineInputBorder(
    //     borderSide: BorderSide(color: AppColors.disableColorD6D6DC),
    //     // borderRadius: BorderRadius.all(Radius.circular(40)),
    //   ),
    //   enabledBorder: const OutlineInputBorder(
    //     borderSide: BorderSide(color: AppColors.disableColorD6D6DC),
    //     // borderRadius: BorderRadius.all(Radius.circular(40)),
    //   ),
    //   errorBorder: const OutlineInputBorder(
    //     borderSide: BorderSide(color: AppColors.error),
    //     // borderRadius: BorderRadius.all(Radius.circular(40)),
    //   ),
    //   focusedBorder: const OutlineInputBorder(
    //     borderSide: BorderSide(color: AppColors.primary),
    //     // borderRadius: BorderRadius.all(Radius.circular(40)),
    //   ),
    // ),
    // progressIndicatorTheme: const ProgressIndicatorThemeData(
    //   color: AppColors.dark,
    // ),
    // textTheme: TextTheme(
    //   displaySmall: AppStyles.text13Px.w500.light,
    // ),
  );
}
