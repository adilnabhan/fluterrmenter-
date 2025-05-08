import 'package:flutter/gestures.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({required this.sentOtpEntity, super.key});

  final SentOtpEntity sentOtpEntity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => VerifyOtpCubit(sentOtpEntity: sentOtpEntity), child: const _VerifyOtpScreen());
  }
}

class _VerifyOtpScreen extends StatefulWidget {
  const _VerifyOtpScreen();

  @override
  State<_VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<_VerifyOtpScreen> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyOtpCubit, VerifyOtpState>(
      listener: (context, state) {
        state.resentOtp?.fold(
          () => null,
          (t) => t.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              context.read<VerifyOtpCubit>().startResentOtpTimer();
            },
          ),
        );
        state.verifyOtp?.fold(
          () => null,
          (t) => t.fold((l) {}, (r) {
            if (state.sentOtpEntity.process == 'registration') {
              context.push(CreateAccountScreen(sentOtpEntity: state.sentOtpEntity));
              return;
            }
            final isLogin = state.sentOtpEntity.process == 'login';
            if (isLogin && !(r?.isProfileCompleted ?? false)) {
              context.read<AppCubit>().addUser(r!);
              context.pushAndRemoveUntil(const CreateOrganizationBasicDetailsScreen());
              return;
            }
            if (isLogin) {
              context.read<AppCubit>().addUser(r!);
              context.pushAndRemoveUntil(const OrganizationListingAndDetailsScreen());
              return;
            }
          }),
        );
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 22),
            Text('Verify Phone', style: AppStyles.text22Px.poppins.w600.dark, textAlign: TextAlign.center),
            Text('Enter the verification code sent to', style: AppStyles.text14Px.poppins.w400.textGrey, textAlign: TextAlign.center).pxy(y: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
                  builder: (context, state) {
                    final mobileNumber = state.sentOtpEntity.mobileNumber ?? '';
                    if (mobileNumber.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Text(mobileNumber, style: AppStyles.text16Px.poppins.w500.dark);
                  },
                ),
                IconButton(onPressed: context.pop, icon: SvgPicture.asset('assets/images/svg/icons/pen.svg', height: 18)),
              ],
            ),
            const SizedBox(height: 40),
            BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
              buildWhen: (p, c) {
                return p.verifyOtp != c.verifyOtp;
              },
              builder: (context, state) {
                final error = state.verifyOtp?.fold(() => null, (t) => t.fold((l) => l, (r) => null));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pinput(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      defaultPinTheme: PinTheme(
                        width: 65,
                        height: 65,
                        textStyle: AppStyles.text16Px.poppins.w500.dark,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          border: Border.all(color: error != null ? AppColors.error : AppColors.borderGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(color: AppColors.lightGrey, border: Border.all(color: error != null ? AppColors.error : AppColors.dark), borderRadius: BorderRadius.circular(8)),
                      ),
                      onCompleted: (pin) {
                        context.read<VerifyOtpCubit>().verifyOtp(otp: pin);
                      },
                    ),
                    if (error != null) Text(error.msg, style: AppStyles.text14Px.poppins.w400.error).pOnly(top: 12),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
              buildWhen: (p, c) {
                return p.verifyOtp != c.verifyOtp;
              },
              builder: (context, state) {
                return Button.filled(
                  title: 'Verify',
                  isLoading: state.verifyOtp?.isNone() ?? false,
                  ontap: () {
                    context.read<VerifyOtpCubit>().verifyOtp(otp: _pinController.text);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
              buildWhen: (p, c) {
                return p.resentOtpReminigTime != c.resentOtpReminigTime;
              },
              builder: (context, state) {
                if (state.resentOtpReminigTime == 0) {
                  return const SizedBox();
                }
                return Text(
                  '00:${state.resentOtpReminigTime < 10 ? '0' : ''}${state.resentOtpReminigTime}',
                  style: AppStyles.text16Px.poppins.w500.textGrey,
                  textAlign: TextAlign.center,
                ).pOnly(bottom: 8);
              },
            ),
            RichText(
              text: TextSpan(
                text: "Didn't receive the code? ",
                style: AppStyles.text14Px.poppins.w400.textGrey,
                children: [
                  TextSpan(
                    text: 'Resend',
                    style: AppStyles.text14Px.poppins.w400.textGrey.copyWith(decoration: TextDecoration.underline),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            context.read<VerifyOtpCubit>().resentOtp();
                          },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
