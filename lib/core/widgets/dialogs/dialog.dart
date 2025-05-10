import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

enum SnackType { success, error, warning }

@immutable
///
abstract class Dialogs {
  ///Show snackbar withoud context
  static Future<void> showSnack({String? msg, Widget? action, Duration? duration, SnackType type = SnackType.success, bool showIcon = false}) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Fluttertoast.showToast(
        msg: msg ?? 'Something went wrong! Please try again later.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        fontSize: 16,
        fontAsset: 'assets/fonts/Poppins-Regular.ttf',
      );
      return;
    }
    ScaffoldMessenger.of(Feggy.context!).showSnackBar(
      SnackBar(
        content:
            ClipRRect(
              borderRadius: BorderRadius.circular(10000),
              child: ColoredBox(
                color: AppColors.primary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(msg ?? 'Something went wrong! Please try again later.', textAlign: TextAlign.center, style: AppStyles.text14Px.w400.light)),
                    if (showIcon) CircleAvatar(radius: 12, backgroundColor: AppColors.light, child: SvgPicture.asset('assets/images/icons/tick_icon.svg')).pOnly(left: 8),
                  ],
                ).pxy(x: 16, y: 12),
              ),
            ).center,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        duration: duration ?? 1.seconds,
      ),
    );
  }

  ///Show session expired dialog
  static Future<void> showSessionExpiredDialog() async {
    await showDialog<void>(
      context: Feggy.context!,
      barrierDismissible: false,
      builder: (context) {
        return const SessionExpiredDialog();
      },
    );
  }
}
