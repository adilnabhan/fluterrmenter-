import 'package:mentor_mobile_app/imports_bindings.dart';

///
class AppLogoutDialog extends StatelessWidget {
  ///
  const AppLogoutDialog({super.key});

  void show(BuildContext context) {
    showDialog<Widget>(barrierDismissible: false, context: context, builder: (_) => this);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.light,
      content: const Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: context.pop,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), foregroundColor: AppColors.primary),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), backgroundColor: AppColors.primary, shape: const StadiumBorder()),
          onPressed: () {},
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
