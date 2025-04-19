import 'package:mentor_mobile_app/imports_bindings.dart';

class GymWorkingDetailsScreen extends StatefulWidget {
  const GymWorkingDetailsScreen({super.key});

  @override
  State<GymWorkingDetailsScreen> createState() =>
      _GymWorkingDetailsScreenState();
}

class _GymWorkingDetailsScreenState extends State<GymWorkingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 22),
          const GymProfileCompletionStatusCard(progress: 4),
          const SizedBox(height: 32),
          Button.filled(
            title: 'Continue',
            ontap: () {},
            // isLoading: state.sentOtp?.isNone() ?? false,
            // ontap: () {
            //   context.read<SentOtpCubit>().sentOtp(
            //     phone: _phoneController.text,
            //   );
            // },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 84,
        child: FloatingActionButton(
          onPressed: () {},
          shape: const StadiumBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.light,
          elevation: 0,
          child: const Icon(Icons.keyboard_arrow_right_outlined),
        ),
      ),
    );
  }
}
