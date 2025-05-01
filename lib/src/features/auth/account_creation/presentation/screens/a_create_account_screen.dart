import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({required this.sentOtpEntity, super.key});

  final SentOtpEntity sentOtpEntity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => CreateAccountCubit(sentOtp: sentOtpEntity), child: const _CreateAccountScreen());
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
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
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
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Email Address',
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isNotEmpty ?? false) {
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value!)) {
              return 'Invalid email address!';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
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
      final firstName = _basicDetails[0].controller?.text;
      final lastName = _basicDetails[1].controller?.text;
      final email = _basicDetails[2].controller?.text;
      context.read<CreateAccountCubit>().onboardUser(firstName: firstName ?? '', lastName: lastName ?? '', email: email ?? '');
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
              context.push(const GymProfileCreationScreen());
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
              const SizedBox(height: 22),
              Text('Create Account', style: AppStyles.text22Px.poppins.w600.dark, textAlign: TextAlign.center),
              SvgPicture.asset('assets/images/svg/vectors/create_account.svg', height: 162),
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
                  return Button.filled(title: 'Continue', ontap: _onContinue, isLoading: state.onboardingUser?.isNone() ?? false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
