// import 'package:mentor_mobile_app/imports_bindings.dart';

// class DeleteConfirmationDialog extends StatelessWidget {
//   final String itemName;
//   final VoidCallback onConfirm;
//   final String titleText;
//   final String confirmText;
//   final String cancelText;

//   const DeleteConfirmationDialog({
//     super.key,
//     required this.itemName,
//     required this.onConfirm,
//     this.titleText = 'Are you sure you want to delete',
//     this.confirmText = 'Yes',
//     this.cancelText = 'No',
//   });

//   static void show(
//     BuildContext context, {
//     required String itemName,
//     required VoidCallback onConfirm,
//     String titleText = 'Are you sure you want to delete',
//     String confirmText = 'Yes',
//     String cancelText = 'No',
//   }) {
//     showDialog<void>(
//       context: context,
//       builder: (_) => DeleteConfirmationDialog(
//         itemName: itemName,
//         onConfirm: onConfirm,
//         titleText: titleText,
//         confirmText: confirmText,
//         cancelText: cancelText,
//       ),
//     );
//   }

//   String get trimmedItemName {
//     if (itemName.length > 12) {
//       return '${itemName.substring(0, 12)}...';
//     }
//     return itemName;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: EdgeInsets.symmetric(horizontal: 16.r),
//       backgroundColor: AppColors.light,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       child: Padding(
//         padding: EdgeInsets.all(20.r),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '$titleText $trimmedItemName?',
//               style: AppStyles.text14Px.w500.textColor,
//               textAlign: TextAlign.center,
//             ),
//             24.verticalSpace,
//             Row(
//               children: [
//                 Expanded(
//                   child: Button.outlined(
//                     outlined: true,
//                     raduis: 4,
//                     title: cancelText,
//                     ontap: context.pop,
//                   ),
//                 ),
//                 16.horizontalSpace,
//                 Expanded(
//                   child: Button.filled(
//                     raduis: 4,
//                     title: confirmText,
//                     ontap: () {
//                       context.pop();
//                       onConfirm();
//                     },
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
