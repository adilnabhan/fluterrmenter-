import 'package:mentor_mobile_app/imports_bindings.dart';

class AddOrEditTrainerScreen extends StatefulWidget {
  const AddOrEditTrainerScreen({this.leadeDetails, super.key});

  final LeadsListingModel? leadeDetails;

  @override
  State<AddOrEditTrainerScreen> createState() => _AddOrEditTrainerScreenState();
}

class _AddOrEditTrainerScreenState extends State<AddOrEditTrainerScreen> {
  late final List<FieldData<dynamic>> _basicDetails;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _basicDetails = [
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Full Name',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Member name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _basicDetails[1].focusNode?.requestFocus();
        },
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintText: 'Enter Name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Email Address',
        requiredLabel: true,
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
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Mobile Number',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        validator: (value) {
          if (value?.trim().length != 10) {
            return 'Mobile number must be 10 digits';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Expirience',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Expriece must be selected';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Expriece',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Blood Group',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Blood Group must be selected';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Blood Group',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Gender',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Geneder must be selected';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Gender',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Date of Birth',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Date of Birth must be selected';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Date of Birth',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Emergency Contact',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Emergency Contact is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _basicDetails[3].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
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
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Add Trainer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileImage(isEdit: true, onChanged: (image) {}, radius: 80).pOnly(bottom: 16),
            ListView.separated(
              itemCount: _basicDetails.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 22);
              },
              itemBuilder: (BuildContext context, int index) {
                return Field(
                  data: _basicDetails[index].copyWith(
                    decoration: _basicDetails[index].decoration?.copyWith(
                      filled: false,
                      border: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(8)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                      errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.error)),
                      focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Button.filled(title: 'Save', buttonColor: AppColors.primary, ontap: _onContinue).pad(16).pxy(y: 16),
    );
  }
}
