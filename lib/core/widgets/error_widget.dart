// // ignore_for_file: public_member_api_docs

// import 'package:mentor_mobile_app/imports_bindings.dart';

// @immutable
// class ErrorUi extends StatefulWidget {
//   ///* For using Empty notification widget
//   factory ErrorUi.noNotification() {
//     return ErrorUi._(
//       subtitle: 'We’ll let you know when there will be something to update you.',
//       img: ErrorPicturesInSvg().noNotification,
//       title: 'No Notifications',
//       imageHeight: 177.h,
//       imageWidth: 174.h,
//     );
//   }

//   ///* For using Authentication expired
//   factory ErrorUi.authenticationExpired() {
//     return ErrorUi._(
//       subtitle: 'Please refresh to continue interacting with your report',
//       img: ErrorPicturesInSvg().sessionExpired,
//       title: 'Your session has expired',
//       imageHeight: 328.h,
//       imageWidth: Feggy.context?.width,
//       buttonTitle: 'Refresh',
//       onTap: () {
//         // App.navKey.currentContext?.read<AuthCubit>().logout();
//       },
//     );
//   }

//   ///* For using 404 Client Error Widget
//   factory ErrorUi.notFound({
//     CallVoid? onTap,
//   }) {
//     return ErrorUi._(
//       subtitle: "We're sorry, but something went wrong.",
//       img: ErrorPicturesInSvg().pageNotFound,
//       title: 'PAGE NOT FOUND',
//       buttonTitle: 'Back home',
//       imageHeight: 328.h,
//       imageWidth: 328.w,
//       onTap: onTap,
//     );
//   }

//   ///* For using 500 Server Error Widget
//   factory ErrorUi.server({
//     CallVoid? onTap,
//   }) {
//     return ErrorUi._(
//       subtitle: "Oops! Something went wrong. We're on it. Please try again later..",
//       img: ErrorPicturesInSvg().serverError,
//       title: 'Internal server error',
//       buttonTitle: 'Retry',
//       imageHeight: 328.h,
//       imageWidth: 328.w,
//       onTap: onTap,
//     );
//   }

//   ///* For using Network Error Widget
//   factory ErrorUi.network({
//     CallVoid? onTap,
//   }) {
//     return ErrorUi._(
//       title: 'No internet',
//       subtitle: 'Could not connect to the network. Please check  your internet   ',
//       img: ErrorPicturesInSvg().noInternet,
//       buttonTitle: 'Retry',
//       imageHeight: 297.h,
//       imageWidth: 200.w,
//       onTap: onTap,
//     );
//   }

//   // ///* For using Empty bookinglist
//   // factory ErrorUi.emptyBookingList({
//   //   String? title,
//   //   String? subTitle,
//   //   void Function()? onTapBtn,
//   //   String? btnTitle,
//   // }) {
//   //   return ErrorUi._(
//   //     subtitle: subTitle,
//   //     img: ErrorPicturesInSvg().noBookedTrips,
//   //     title: title,
//   //     imageHeight: 80.h,
//   //     imageWidth: 125.w,
//   //     onTap: onTapBtn,
//   //     buttonTitle: btnTitle,
//   //   );
//   // }

//   const ErrorUi._({
//     this.title,
//     this.subtitle,
//     this.img,
//     this.buttonTitle,
//     this.onTap,
//     this.imageHeight,
//     this.imageWidth,
//   });
//   final String? title;
//   final String? subtitle;
//   final String? img;
//   final String? buttonTitle;
//   final CallVoid? onTap;
//   final double? imageHeight;
//   final double? imageWidth;

//   @override
//   State<ErrorUi> createState() => _ErrorUiState();
// }

// class _ErrorUiState extends State<ErrorUi> {
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SvgPicture.string(
//                   widget.img ?? '',
//                   fit: BoxFit.cover,
//                   height: widget.imageHeight ?? constraints.maxHeight * 0.4,
//                   width: widget.imageWidth ?? constraints.maxWidth * 0.4,
//                 ),
//                 20.verticalSpace,
//                 if (widget.title != null)
//                   Text(
//                     widget.title ?? '',
//                     style: AppStyles.text20Px.w600.copyWith(
//                       color: (widget.title == 'No Notifications') ? AppColors.textColor272930 : AppColors.secondaryColor525B77,
//                     ),
//                   ),
//                 if (widget.title != null) 10.verticalSpace,
//                 Text(
//                   widget.subtitle ?? '',
//                   textAlign: TextAlign.center,
//                   style: AppStyles.text14Px.w400.copyWith(
//                     color: AppColors.secondaryColor525B77,
//                   ),
//                 ).pxy(x: constraints.maxWidth * 0.1),
//                 28.verticalSpace,
//                 if (widget.buttonTitle?.isNotEmpty ?? false)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4.r),
//                     child: InkWell(
//                       overlayColor: const WidgetStatePropertyAll(Colors.transparent),
//                       onTap: widget.onTap,
//                       child: ColoredBox(
//                         color: AppColors.primaryColor03113E,
//                         child: Text(
//                           widget.buttonTitle ?? '',
//                           style: AppStyles.text14Px.w600.copyWith(color: AppColors.backgroundColorF4F1EA),
//                         ).pxy(x: 24.r, y: 10.r),
//                       ),
//                     ),
//                   ).center,
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
