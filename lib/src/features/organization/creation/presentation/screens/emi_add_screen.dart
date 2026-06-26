import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationEmiAddScreen extends StatefulWidget {
  const OrganizationEmiAddScreen({super.key});

  @override
  State<OrganizationEmiAddScreen> createState() => _OrganizationEmiAddScreenState();
}

class _OrganizationEmiAddScreenState extends State<OrganizationEmiAddScreen> {
  bool completedAnimation = false;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        completedAnimation = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: switch (completedAnimation) {
            true => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SvgPicture.asset('assets/images/svg/vectors/onboarding_success.svg', height: 140)
                //     .animate(
                //       onComplete: (controller) {
                //         context.pushAndRemoveUntil(const OrganizationListingScreen());
                //       },
                //     )
                //     .scale(duration: const Duration(seconds: 2), curve: Curves.elasticOut, begin: Offset.zero, end: const Offset(1, 1)),
                // const SizedBox(height: 16),
                Text('Emi Screen Here', style: AppStyles.text16Px.poppins.w700.dark, textAlign: TextAlign.center),
              ],
            ),
            // ignore: prefer_const_constructors
            false => Column(mainAxisAlignment: MainAxisAlignment.center, children: const [OrganizationCreationCompletionStatusCard(progress: 5)]),
          },
        ).pad(16),
      ),
    );
  }
}







