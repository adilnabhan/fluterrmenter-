import 'package:mentor_mobile_app/imports_bindings.dart';

class SentOtpScreen extends StatelessWidget {
  const SentOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SentOtpCubit(), child: const _SentOtpScreen());
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
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [AppBar(toolbarHeight: context.height * .3, title: SvgPicture.asset('assets/images/svg/vectors/logo.svg', height: 40, width: 40)), Container(color: AppColors.dark.withAlpha(50))],
        ),
        bottomSheet: _buildBottomSheet(),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: context.width,
      decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Login', style: AppStyles.text22Px.poppins.w600.copyWith(color: const Color(0xFF020202))),
          const SizedBox(height: 8),
          Text('Enter your mobile number to Log in', style: AppStyles.text14Px.poppins.w400.copyWith(color: const Color(0xFF666666))),
          const SizedBox(height: 24),
          // Phone number input field
          BlocBuilder<SentOtpCubit, SentOtpState>(
            buildWhen: (p, c) => p.sentOtp != c.sentOtp,
            builder: (context, state) {
              final error = state.sentOtp?.fold(() => null, (t) => t.fold((l) => l, (r) => null));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xFFE8E8E8), width: 1.w))),
                    child: Row(
                      children: [
                        Text('+91', style: AppStyles.text14Px.poppins.w500),
                        const SizedBox(width: 8),
                        Container(width: 2, height: 20, color: const Color(0xFFE8E8E8)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Mobile Number',
                              hintStyle: AppStyles.text14Px.poppins.w400.copyWith(color: const Color(0xFF999999)),
                              filled: false,
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (error != null) Text(error.msg, style: AppStyles.text14Px.poppins.w400.error).pOnly(top: 8),
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
                isLoading: state.sentOtp?.isNone() ?? false,
                ontap: () {
                  context.read<SentOtpCubit>().sentOtp(phone: _phoneController.text);
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
