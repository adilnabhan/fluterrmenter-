import 'package:mentor_mobile_app/imports_bindings.dart';

class SentOtpScreen extends StatelessWidget {
  const SentOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SentOtpCubit(),
      child: const _SentOtpScreen(),
    );
  }
}

class _SentOtpScreen extends StatefulWidget {
  const _SentOtpScreen();

  @override
  State<_SentOtpScreen> createState() => __SentOtpScreenState();
}

class __SentOtpScreenState extends State<_SentOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SentOtpCubit, SentOtpState>(
      listenWhen: (p, c) {
        return p.sentOtp != c.sentOtp || p.googleSignIn != c.googleSignIn;
      },
      listener: (context, state) {
        state.sentOtp?.fold(
          () => null,
          (t) => t.fold((l) {}, (sentOtpEntity) {
            context.push(VerifyOtpScreen(sentOtpEntity: sentOtpEntity));
          }),
        );
        state.googleSignIn?.fold(
          () => null,
          (t) => t.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              // context.push(VerifyOtpScreen(phone: _phoneController.text, ));
            },
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEE), Colors.white],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const PopButton().center,
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: Align(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset(
                  'assets/images/svg/vectors/logo.svg',
                  height: 54,
                  width: 54,
                ),
              ),
            ),
            bottomSheet: _buildBottomSheet(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: context.width,
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login',
            style: AppStyles.text22Px.poppins.w600.copyWith(
              color: const Color(0xFF020202),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your mobile number to Log in',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          // Phone number input field
          BlocBuilder<SentOtpCubit, SentOtpState>(
            buildWhen: (p, c) => p.sentOtp != c.sentOtp,
            builder: (context, state) {
              final error = state.sentOtp?.fold(
                () => null,
                (t) => t.fold((l) => l, (r) => null),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'IN ',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              '+91',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 1.w,
                          height: 22.h,
                          color: const Color(0xFFE5E7EB),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            style: AppStyles.text16Px.poppins.w600.copyWith(
                              color: const Color(0xFF111827),
                              letterSpacing: 0.5,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Mobile Number',
                              hintStyle: AppStyles.text14Px.poppins.w400
                                  .copyWith(color: const Color(0xFF9CA3AF)),
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _phoneController,
                          builder: (context, value, child) {
                            if (value.text.length == 10) {
                              return Container(
                                margin: EdgeInsets.only(left: 8.w),
                                padding: EdgeInsets.all(3.r),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFECFDF5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF10B981),
                                  size: 14,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  if (error != null)
                    Text(
                      error.msg,
                      style: AppStyles.text14Px.poppins.w400.error,
                    ).pOnly(top: 8),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          BlocBuilder<SentOtpCubit, SentOtpState>(
            buildWhen: (p, c) => p.sentOtp != c.sentOtp,
            builder: (context, state) {
              return Button.filled(
                title: 'Send OTP',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                raduis: 16.r,
                buttonColor: const Color(0xFF111827),
                isLoading: state.sentOtp?.isNone() ?? false,
                ontap: () {
                  context.read<SentOtpCubit>().sentOtp(
                    phone: _phoneController.text,
                  );
                },
              );
            },
          ),
          // const SizedBox(height: 16),
          // BlocBuilder<SentOtpCubit, SentOtpState>(
          //   buildWhen: (p, c) => p.googleSignIn != c.googleSignIn,
          //   builder: (context, state) {
          //     return Button.outlined(
          //       title: 'Or continue with Google',
          //       isLoading: state.googleSignIn?.isNone() ?? false,
          //       ontap: context.read<SentOtpCubit>().googleSignIn,
          //       icon: SvgPicture.asset('assets/images/svg/icons/google.svg', height: 24, width: 24),
          //     );
          //   },
          // ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
