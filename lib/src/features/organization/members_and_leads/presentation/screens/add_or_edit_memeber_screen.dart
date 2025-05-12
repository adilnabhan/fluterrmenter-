import 'package:mentor_mobile_app/imports_bindings.dart';

class AddOrEditMemeberScreen extends StatefulWidget {
  const AddOrEditMemeberScreen({this.memberDetails, super.key});

  final MemberDetailsModel? memberDetails;

  @override
  State<AddOrEditMemeberScreen> createState() => _AddOrEditMemeberScreenState();
}

class _AddOrEditMemeberScreenState extends State<AddOrEditMemeberScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final List<FieldData<dynamic>> _fields;
  final _formKey = GlobalKey<FormState>();
  XFile? _profilePicture;

  @override
  void initState() {
    _cubit = context.read<MembersAndLeadsCubit>();
    _fields = [
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
          _fields[1].focusNode?.requestFocus();
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
          _fields[2].focusNode?.requestFocus();
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
          _fields[3].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.done,
        label: 'Blood Group',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        items: [
          (label: 'A+', value: 'A+'),
          (label: 'A-', value: 'A-'),
          (label: 'B+', value: 'B+'),
          (label: 'B-', value: 'B-'),
          (label: 'AB+', value: 'AB+'),
          (label: 'AB-', value: 'AB-'),
          (label: 'O+', value: 'O+'),
          (label: 'O-', value: 'O-'),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Blood Group must be selected';
          }
          return null;
        },
        onValueChanged: (p0) {
          _fields[4].focusNode?.requestFocus();
        },
        onSubmitted: (value) {
          _fields[4].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Blood Group',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.done,
        label: 'Gender',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        items: [(label: 'Male', value: 'male'), (label: 'Female', value: 'female'), (label: 'Other', value: 'other')],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Geneder must be selected';
          }
          return null;
        },
        onValueChanged: (p0) {
          _fields[5].key;
          _fields[5].requestToFocus();
        },
        onSubmitted: (value) {
          _fields[5].requestToFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Gender',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.date,
        textInputAction: TextInputAction.done,
        label: 'Date of Birth',
        dateTimeShowFormat: DateFormat('dd MMM yyyy'),
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Date of Birth must be selected';
          }
          return null;
        },
        onChanged: (p0) {
          _fields[6].focusNode?.requestFocus();
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
          _fields[7].focusNode?.requestFocus();
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
        label: 'Height',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.number,
        maxLength: 3,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Height is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[8].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Weight',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.number,
        maxLength: 3,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Weight is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[9].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Profession',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Profession is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[8].focusNode?.unfocus();
          _onContinue();
        },
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintText: 'Enter Profession',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        ),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_fields[0].focusNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in _fields) {
      element.controller?.dispose();
      element.focusNode?.dispose();
    }
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fields[0].controller?.text;
      final email = _fields[1].controller?.text;
      final mobileNumber = _fields[2].controller?.text;
      final bloodGroup = _fields[3].controller?.text;
      final gender = _fields[4].controller?.text;
      final dateOfBirth = _fields[5].controller?.text;
      final emergencyContactNumber = _fields[6].controller?.text;
      final height = _fields[7].controller?.text;
      final weight = _fields[8].controller?.text;
      final profession = _fields[9].controller?.text;
      // _cubit.cerateOrUpdateMemberDetails(memberId: widget.memberDetails?.id, fullName: fullName,  mobileNumber: mobileNumber, email: email, dateOfBirth: dateOfBirth, gender: gender, bloodGroup: bloodGroup,   emergencyContactNumber: emergencyContactNumber, height: height?.toNum.toDouble(), weight: weight?.toNum.toDouble(), profession: profession, membershipPlanId: membershipPlanId, profilePicture: profilePicture)
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
      bloc: _cubit,
      listener: (context, state) {
        state.createOrUpdateMember?.fold(() => null, (t) {
          return t.fold(
            (l) {
              return Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              if (widget.memberDetails?.id != null) {
                Dialogs.showSnack(msg: 'Trainer details updated successfully');
              } else {
                Dialogs.showSnack(msg: 'Trainer added successfully');
              }
              context.pop();
            },
          );
        });
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Add Member')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileImage(isEdit: true, onChanged: (image) => _profilePicture = image, radius: 80).pOnly(bottom: 16),
              ListView.separated(
                itemCount: _fields.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 22);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Field(
                    data: _fields[index].copyWith(
                      decoration: _fields[index].decoration?.copyWith(
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
        bottomNavigationBar: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
          buildWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
          builder: (context, state) {
            return Button.filled(title: 'Continue', isLoading: state.createOrUpdateMember?.isNone() ?? false, buttonColor: AppColors.primary, ontap: _onContinue);
          },
        ).pad(16).pxy(y: 16),
      ),
    );
  }
}
