import 'package:mentor_mobile_app/imports_bindings.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image Layer
          Positioned(
            right: 0,
            bottom: 0,
            height: 600.h, // Fixed responsive height to control size
            child: Image.asset(
              'assets/images/png/icons/mascotfinal.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),

          // Foreground Content Layer
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80.h), // Push text down
                  // Top Text
                  Text(
                    'Welcome to\nFuture of\nFitness 👋',
                    style: AppStyles.text24Px.poppins.w600.copyWith(
                      color: Colors.black,
                      fontSize: 34.sp, // Increased font size
                      height: 1.2,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Buttons
                  Column(
                    children: [
                      // Google Signin (Commented out)
                      /*
                      Button.outlined(
                        title: 'Continue with Google',
                        ontap: () {},
                        icon: SvgPicture.asset(
                          'assets/images/svg/icons/google.svg',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      */
                      
                      // Mobile OTP Login
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Button.outlined(
                          title: 'Continue with Mobile OTP',
                          ontap: () {
                            context.push(const SentOtpScreen());
                          },
                          icon: const Icon( 
                            Icons.phone_android_outlined,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Footer Text
                      Text(
                        "You've already taken the first step -\nlet's keep the momentum!",
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: const Color(0xFF666666),
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
