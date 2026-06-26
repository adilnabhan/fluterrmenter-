import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({required this.sentOtpEntity, super.key});

  final SentOtpEntity sentOtpEntity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateAccountCubit(sentOtp: sentOtpEntity),
      child: const _CreateAccountScreen(),
    );
  }
}

class _CreateAccountScreen extends StatefulWidget {
  const _CreateAccountScreen();

  @override
  State<_CreateAccountScreen> createState() => __CreateAccountScreenState();
}

class __CreateAccountScreenState extends State<_CreateAccountScreen> {
  late final List<FieldData<dynamic>> _basicDetails;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _basicDetails = [
      /*
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'First Name ',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'First name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _basicDetails[1].focusNode?.requestFocus();
        },
        controller: TextEditingController(),
        focusNode: FocusNode(),
        decoration: InputDecoration(
          hintText: 'Enter your first name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Last Name ',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Last name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _basicDetails[2].focusNode?.requestFocus();
        },
        controller: TextEditingController(),
        focusNode: FocusNode(),
        decoration: InputDecoration(
          hintText: 'Enter your last name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      */
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Owner\'s First Name',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Owner\'s name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _basicDetails[1].focusNode?.requestFocus();
        },
        controller: TextEditingController(),
        focusNode: FocusNode(),
        decoration: InputDecoration(
          hintText: 'Owner\'s name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      //To be removed
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Last Name ',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Last name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _basicDetails[2].focusNode?.requestFocus();
        },
        controller: TextEditingController(),
        focusNode: FocusNode(),
        decoration: InputDecoration(
          hintText: 'Enter your last name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        requiredLabel: true,
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Email',
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isNotEmpty ?? false) {
            if (!RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value!)) {
              return 'Invalid email address!';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[1].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      // FieldData(
      //   type: FieldType.word,
      //   textInputAction: TextInputAction.done,
      //   label: 'Referral Code',
      //   controller: TextEditingController(),
      //   focusNode: FocusNode(),
      //   decoration: InputDecoration(
      //     hintText: 'Code',
      //     hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      //     border: const OutlineInputBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(8)),
      //       borderSide: BorderSide(color: AppColors.borderGrey),
      //     ),
      //   ),
      // ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_basicDetails[0].focusNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in _basicDetails) {
      element.controller?.dispose();
      element.focusNode?.dispose();
    }
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      /*
      final firstName = _basicDetails[0].controller?.text;
      final lastName = _basicDetails[1].controller?.text;
      final email = _basicDetails[2].controller?.text;
      context.read<CreateAccountCubit>().onboardUser(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        email: email ?? '',
      );
      */
      final firstName = _basicDetails[0].controller?.text.trim();
      final lastName = _basicDetails[1].controller?.text.trim();
      final email = _basicDetails[2].controller?.text.trim();
      context.read<CreateAccountCubit>().onboardUser(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        email: email ?? '',
      );
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateAccountCubit, CreateAccountState>(
      listener: (context, state) {
        state.onboardingUser?.fold(
          () => null,
          (t) => t.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              context.read<AppCubit>().addUser(r);
              context.push(const CreateOrganizationBasicDetailsScreen());
            },
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              /*
              const SizedBox(height: 22),
              Text(
                'Create Account',
                style: AppStyles.text22Px.poppins.w600.dark,
                textAlign: TextAlign.center,
              ),
              SvgPicture.asset(
                'assets/images/svg/vectors/create_account.svg',
                height: 162,
              ),
              */
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (index) {
                  return Row(
                    children: [
                      Container(
                        width: 25,
                        height: 1,
                        color:
                            index == 0
                                ? AppColors.primary
                                : AppColors.borderGrey,
                      ),
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          width: 8,
                          height: 8,
                          color:
                              index == 0
                                  ? AppColors.primary
                                  : AppColors.borderGrey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'Let’s Build\nYour Fitness\nIdentity 🏋️‍♂️',
                style: AppStyles.text30Px.poppins.w600.dark,
              ),
              const SizedBox(height: 16),
              Text(
                'Show your expertise to fitness centers\nand clients',
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ),
              const SizedBox(height: 32),
              ListView.separated(
                itemCount: _basicDetails.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 22);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Field(data: _basicDetails[index]);
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<CreateAccountCubit, CreateAccountState>(
                buildWhen: (p, c) {
                  return p.onboardingUser != c.onboardingUser;
                },
                builder: (context, state) {
                  return Button.filled(
                    title: 'Next → Let’s Set Up Your Space',
                    ontap: _onContinue,
                    isLoading: state.onboardingUser?.isNone() ?? false,
                    buttonColor: AppColors.primary,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
