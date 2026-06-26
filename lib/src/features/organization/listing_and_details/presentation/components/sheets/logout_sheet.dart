import 'package:mentor_mobile_app/imports_bindings.dart';

class LogoutSheet extends StatelessWidget {
  const LogoutSheet({super.key});

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.white, builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Logout', style: AppStyles.text18Px.poppins.w600.dark), IconButton(onPressed: context.pop, icon: const Icon(Icons.close, color: AppColors.textGrey))],
        ),
        const SizedBox(height: 16),
        Text('Are you sure you want to logout?', style: AppStyles.text14Px.poppins.w400.dark),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Button.filled(ontap: context.pop, title: 'Cancel', style: AppStyles.text14Px.poppins.w500.dark, buttonColor: AppColors.disabledButton).pOnly(right: 8)),
            Flexible(
              child: Button.filled(
                buttonColor: AppColors.primary,
                ontap: () {
                  context.read<AppCubit>().removeUser();
                  context.pushAndRemoveUntil(const SentOtpScreen());
                },
                title: 'Logout',
                style: AppStyles.text14Px.poppins.w500.light,
              ).pOnly(left: 8),
            ),
          ],
        ),
      ],
    ).pad(16).pOnly(bottom: 32);
  }
}
