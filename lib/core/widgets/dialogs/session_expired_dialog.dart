import 'package:mentor_mobile_app/imports_bindings.dart';

class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: AppColors.light,
        title: Text('Session Expired', style: AppStyles.text24Px.w400.primary),
        content: Text('Your session has expired or someone has logged in with the same account. Please log in again.', style: AppStyles.text14Px.w400.primary),
        actions: <Widget>[
          SizedBox(
            width: double.maxFinite,
            child: OutlinedButton(
              onPressed: () {
                // context.pushAndRemoveUntil(const LoginScreen());
              },
              child: Text('OK', style: AppStyles.text14Px.w500.primary),
            ),
          ),
        ],
      ),
    );
  }
}
