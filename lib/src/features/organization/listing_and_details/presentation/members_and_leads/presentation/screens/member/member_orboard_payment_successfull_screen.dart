import 'package:mentor_mobile_app/imports_bindings.dart';

class MemberOnboardPaymentSuccessScreen extends StatefulWidget {
  const MemberOnboardPaymentSuccessScreen({super.key});

  @override
  State<MemberOnboardPaymentSuccessScreen> createState() => _MemberOnboardPaymentSuccessScreenState();
}

class _MemberOnboardPaymentSuccessScreenState extends State<MemberOnboardPaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.memberOnboardedAnimationCompleted != c.memberOnboardedAnimationCompleted,
      listener: (context, state) {
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            context.pop();
          }
        });
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/svg/vectors/onboarding_success.svg', height: 140)
                    .animate(
                      onComplete: (controller) {
                        context.pushAndRemoveUntil(const OrganizationListingScreen());
                      },
                    )
                    .scale(duration: const Duration(seconds: 2), curve: Curves.elasticOut, begin: Offset.zero, end: const Offset(1, 1)),
                const SizedBox(height: 16),
                Text('Payment Successfull', style: AppStyles.text16Px.poppins.w700.dark),
              ],
            ),
          ).pad(16),
        ),
      ),
    );
  }
}
