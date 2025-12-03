import 'package:mentor_mobile_app/imports_bindings.dart';

class SubscriptionSuccessScreen extends StatelessWidget {
  const SubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // ============ PROGRESS BAR ============
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      const bool isActive = true; // All steps completed
                      return Row(
                        children: [
                          Container(
                            width: 25,
                            height: 1,
                            color:
                                isActive
                                    ? const Color(0xFFE22121)
                                    : Colors.grey,
                          ),
                          Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 8,
                              height: 8,
                              color:
                                  isActive
                                      ? const Color(0xFFE22121)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  // ============ END PROGRESS BAR ============
                  const SizedBox(height: 40),
                  const Text(
                    "You're all set,\n[First Name]! 🚀",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Discipl — the Future of Fitness. You\'ve taken the first step towards digitalizing your fitness center.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ============ STACKED IMAGE AND BUTTON ============
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Image behind
                      Image.asset(
                        'assets/debug/allset.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      // Button on top
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: Button.filled(
                          title: 'Go to Dashboard →',
                          ontap: () {
                            // ============ NAVIGATE TO DASHBOARD ============
                            context.pushAndRemoveUntil(
                              // const OrganizationListingScreen(),
                              const OrganizationCreationSuccessScreen(),
                            );
                            // ============ END NAVIGATE TO DASHBOARD ============
                          },
                          buttonColor: const Color(0xFFE22121),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          raduis: 12,
                        ),
                      ),
                    ],
                  ),
                  // ============ END STACKED IMAGE AND BUTTON ============
                  const SizedBox(height: 16),
                  // ============ WHATSAPP INVITE COMMENTED OUT ============
                  // Button.outlined(
                  //   title: '📱 Invite Your Trainers →',
                  //   ontap: () {
                  //     // WhatsApp invite logic
                  //   },
                  //   borderColor: const Color(0xFF25D366),
                  //   style: const TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w600,
                  //     color: Color(0xFF25D366),
                  //   ),
                  //   raduis: 12,
                  // ),
                  // ============ END WHATSAPP INVITE COMMENTED OUT ============
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
