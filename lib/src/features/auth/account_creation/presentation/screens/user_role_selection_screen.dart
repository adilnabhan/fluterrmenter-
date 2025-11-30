import 'package:mentor_mobile_app/imports_bindings.dart';

class UserRoleSelectionScreen extends StatelessWidget {
  const UserRoleSelectionScreen({required this.sentOtpEntity, super.key});
  //  UserRoleSelectionScreen(this.sentOtpEntity, {super.key});

  final SentOtpEntity sentOtpEntity;
  // late  SentOtpEntity sentOtpEntity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: const PopButton().center,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              // Title Text
              Text(
                'Who are you in\nthe Fitness\nRevolution?',
                style: AppStyles.text24Px.poppins.w600.copyWith(
                  color: Colors.black,
                  fontSize: 34.sp,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10.h),
              // Subtitle
              Text(
                'Choose your path to power.',
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: const Color(0xFF666666),
                  fontSize: 14.sp,
                ),
              ),

              // const Spacer(),
              SizedBox(height: 40.h),

              // Role Options
              Column(
                children: [
                  // Fitness Center Option
                  _RoleOptionCard(
                    icon: 'assets/images/png/icons/dumbell.png',
                    title: 'Fitness Center',
                    description:
                        'Manage members, automate payments,\n& grow your business.',
                    buttonText: 'Continue as Fitness Center →',
                    buttonColor: const Color(0xFFDC2626), // Red color
                    onTap: () {
                      context.push(
                        CreateAccountScreen(sentOtpEntity: sentOtpEntity),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Trainer Option (Commented out)
                  /*
                  _RoleOptionCard(
                    icon: 'assets/images/png/icons/arm.png',
                    title: 'Trainer/Coach',
                    description: 'Connect with clients, create plans, and\nbuild your reputation.',
                    buttonText: 'Continue as Trainer →',
                    buttonColor: const Color(0xFFFBBF24), // Yellow color
                    onTap: () {
                      // Navigate to trainer flow
                    },
                  ),
                  */
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Image.asset(icon, height: 60.h, width: 60.w, fit: BoxFit.contain),

          SizedBox(height: 16.h),

          // Title
          Text(
            title,
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: Colors.black,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          // Description
          Text(
            description,
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: const Color(0xFF666666),
              fontSize: 12.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20.h),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
