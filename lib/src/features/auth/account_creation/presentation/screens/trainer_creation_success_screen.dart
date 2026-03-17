import 'package:mentor_mobile_app/imports_bindings.dart';

class TrainerCreationSuccessScreen extends StatefulWidget {
  const TrainerCreationSuccessScreen({super.key});

  @override
  State<TrainerCreationSuccessScreen> createState() => _TrainerCreationSuccessScreenState();
}

class _TrainerCreationSuccessScreenState extends State<TrainerCreationSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (index) {
                  return Row(
                    children: [
                      Container(
                        width: 15,
                        height: 1.5,
                        color: AppColors.primary,
                      ),
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          width: 8,
                          height: 8,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to\nDiscipl,\nTrainer! 🚀',
                      style: AppStyles.text36Px.poppins.w600.dark.copyWith(
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You’re now part of the Future of Fitness. Build clients, connect with centers, and grow your fitness career.',
                      style: AppStyles.text14Px.poppins.w400.textGrey,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // ============ STACKED IMAGE AND BUTTON ============
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Mascot Image
                    Image.asset(
                      'assets/debug/allset.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain, // Fits available space perfectly
                    ),
                    
                    // Button on top
                    Positioned(
                      bottom: 40,
                      left: 24,
                      right: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Button.filled(
                            title: 'Go to Trainer Dashboard →',
                            ontap: () {
                              Dialogs.showSnack(msg: 'Navigating to Dashboard...');
                            },
                            buttonColor: AppColors.primary,
                            raduis: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ============ END STACKED IMAGE AND BUTTON ============
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
