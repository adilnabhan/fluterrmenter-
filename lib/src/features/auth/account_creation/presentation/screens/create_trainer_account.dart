import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerAccountScreen extends StatelessWidget {
  const CreateTrainerAccountScreen({required this.sentOtpEntity, super.key});

  final SentOtpEntity sentOtpEntity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      //to be changed to trainer account cubit
      create: (context) => CreateAccountCubit(sentOtp: sentOtpEntity),
      child: const _CreateTrainerAccountScreen(),
    );
  }
}

class _CreateTrainerAccountScreen extends StatefulWidget {
  const _CreateTrainerAccountScreen();

  @override
  State<_CreateTrainerAccountScreen> createState() => __CreateTrainerAccountScreenState();
}

class __CreateTrainerAccountScreenState extends State<_CreateTrainerAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _firstName;
  late final FieldData<dynamic> _lastName;
  late final FieldData<dynamic> _email;
  late final FieldData<dynamic> _mobileNumber;
  late final FieldData<String> _gender;
  late final FieldData<dynamic> _dob;

  @override
  void initState() {
    _firstName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Name',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'First name is required';
        }
        return null;
      },
      onSubmitted: (value) {
        _lastName.focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'First Name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      ),
    );

    _lastName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Last name is required';
        }
        return null;
      },
      onSubmitted: (value) {
        _email.focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Last Name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      ),
    );

    _email = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Email',
      controller: TextEditingController(),
      focusNode: FocusNode(),
      keyboardType: TextInputType.emailAddress,
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
        _mobileNumber.focusNode?.requestFocus();
      },
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      ),
    );

    _mobileNumber = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Mobile Number',
      requiredLabel: true,
      controller: TextEditingController(),
      focusNode: FocusNode(),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Mobile number is required';
        }
        if (value?.trim().length != 10) {
          return 'Invalid mobile number';
        }
        return null;
      },
      onSubmitted: (value) {
        _gender.focusNode?.requestFocus();
      },
      decoration: InputDecoration(
        hintText: 'Number',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      ),
    );

    _gender = FieldData<String>(
      type: FieldType.radio,
      label: 'Gender',
      requiredLabel: true,
      items: [
        (label: 'Male', value: 'male'),
        (label: 'Female', value: 'female'),
        (label: 'Other', value: 'other'),
      ],
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Gender is required';
        }
        return null;
      },
      onValueChanged: (p0) {
        _dob.focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Select your Gender',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      ),
    );

    _dob = FieldData(
      type: FieldType.date,
      label: 'Date of Birth',
      requiredLabel: true,
      controller: TextEditingController(),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Date of Birth is required';
        }
        return null;
      },
      onSubmitted: (value) {
        _onContinue();
      },
      decoration: InputDecoration(
        hintText: 'dd/mm/yyyy',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_firstName.focusNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    _firstName.controller?.dispose();
    _lastName.controller?.dispose();
    _email.controller?.dispose();
    _mobileNumber.controller?.dispose();
    _gender.controller?.dispose();
    _dob.controller?.dispose();
    _firstName.focusNode?.dispose();
    _lastName.focusNode?.dispose();
    _email.focusNode?.dispose();
    _mobileNumber.focusNode?.dispose();
    _gender.focusNode?.dispose();
    _dob.focusNode?.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // final firstName = _firstName.controller?.text.trim();
      // final lastName = _lastName.controller?.text.trim();
      // final email = _email.controller?.text.trim();

      // context.read<CreateAccountCubit>().onboardUser(
      //   firstName: firstName ?? '',
      //   lastName: lastName ?? '',
      //   email: email ?? '',
      // );
      
      // Directly navigate to professional details as per user request to not call API
      context.push(const CreateTrainerProfessionalDetailsScreen());
    } else {
      Dialogs.showSnack(msg: 'Please fill all the required fields');
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
              context.push(const CreateTrainerProfessionalDetailsScreen());
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (index) {
                  bool isActive = index == 0;
                  return Row(
                    children: [
                      Container(
                        width: 25,
                        height: 1,
                        color:
                            isActive
                                ? AppColors.primary
                                : AppColors.borderGrey,
                      ),
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          width: 8,
                          height: 8,
                          color:
                              isActive
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
                'Let’s Create Your\nTrainer Profile 💪',
                style: AppStyles.text30Px.poppins.w600.dark,
              ),
              const SizedBox(height: 16),
              Text(
                'Show your expertise to fitness centers\nand clients',
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    BrandLogoPicker(
                      isEdit: true,
                      onChanged: (image) {},
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set Profile',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Field(data: _firstName),
              const SizedBox(height: 8),
              Field(data: _lastName),
              const SizedBox(height: 16),
              Field(data: _email),
              const SizedBox(height: 16),
              Field(data: _mobileNumber),
              const SizedBox(height: 16),
              Field(data: _gender),
              const SizedBox(height: 16),
              Field(data: _dob),
              const SizedBox(height: 32),
              BlocBuilder<CreateAccountCubit, CreateAccountState>(
                buildWhen: (p, c) {
                  return p.onboardingUser != c.onboardingUser;
                },
                builder: (context, state) {
                  return Button.filled(
                    title: 'Build My Trainer Profile',
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

