import 'package:flutter/gestures.dart';
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
                      // Mobile OTP Login
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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

                      const SizedBox(height: 16),

                      // Terms & Conditions and Privacy Policy Text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppStyles.text14Px.poppins.w400.copyWith(
                            color: const Color(0xFF666666),
                            fontSize: 12.sp,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to our\n',
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse(
                                          'https://thediscipl.com/terms-conditions',
                                        ),
                                      );
                                    },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy.',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse(
                                          'https://thediscipl.com/privacy-policy',
                                        ),
                                      );
                                    },
                            ),
                          ],
                        ),
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
