import 'package:mentor_mobile_app/imports_bindings.dart';

class GymCreationSuccessScreen extends StatefulWidget {
  const GymCreationSuccessScreen({super.key});

  @override
  State<GymCreationSuccessScreen> createState() => _GymCreationSuccessScreenState();
}

class _GymCreationSuccessScreenState extends State<GymCreationSuccessScreen> {
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
                SvgPicture.asset('assets/images/svg/vectors/onboarding_success.svg', height: 140)
                    .animate(
                      onComplete: (controller) {
                        context.pushAndRemoveUntil(const HomeScreen());
                      },
                    )
                    .scale(duration: const Duration(seconds: 2), curve: Curves.elasticOut, begin: Offset.zero, end: const Offset(1, 1)),
                const SizedBox(height: 16),
                Text('Profile Created Successfully!', style: AppStyles.text16Px.poppins.w700.dark),
              ],
            ),
            // ignore: prefer_const_constructors
            false => Column(mainAxisAlignment: MainAxisAlignment.center, children: const [GymProfileCompletionStatusCard(progress: 5)]),
          },
        ).pad(16),
      ),
    );
  }
}
