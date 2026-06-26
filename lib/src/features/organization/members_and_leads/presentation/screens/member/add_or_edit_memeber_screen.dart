import 'package:mentor_mobile_app/imports_bindings.dart';

class AddOrEditMemeberScreen extends StatefulWidget {
  const AddOrEditMemeberScreen({
    required this.orgId,
    this.memberDetails,
    super.key,
  });

  final MemberDetailsModel? memberDetails;
  final int orgId;

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
      // ---------------------------------------------------------
      // 0 — FULL NAME
      // ---------------------------------------------------------
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
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 1 — EMAIL
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Email Address',
        requiredLabel: false,
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
          _fields[2].focusNode?.requestFocus();
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 2 — MOBILE NUMBER
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Mobile Number',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: (value) {
          if (value?.trim().length != 10) {
            return 'Mobile number must be 10 digits';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[3].focusNode?.requestFocus(); // ADDRESS
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 3 — ADDRESS (NEW FIELD)
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Address',
        requiredLabel: false,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        maxLines: 3,
        keyboardType: TextInputType.streetAddress,
        // validator: (value) {
        //   if (value?.trim().isEmpty ?? true) {
        //     return 'Address is required';
        //   }
        //   return null;
        // },
        onSubmitted: (value) {
          _fields[4].focusNode?.requestFocus(); // BLOOD GROUP
        },
        decoration: InputDecoration(
          hintText: 'Enter Address',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 4 — BLOOD GROUP
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.next,
        label: 'Blood Group',
        requiredLabel: false,
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
        onSubmitted: (value) {
          _fields[5].focusNode?.requestFocus(); // GENDER
        },
        decoration: InputDecoration(
          hintText: 'Select Blood Group',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 5 — GENDER
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.next,
        label: 'Gender',
        requiredLabel: false,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        items: [
          (label: 'Male', value: 'male'),
          (label: 'Female', value: 'female'),
          (label: 'Other', value: 'other'),
        ],
        onSubmitted: (value) {
          _fields[6].focusNode?.requestFocus(); // DOB
        },
        decoration: InputDecoration(
          hintText: 'Select Gender',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 6 — DOB
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.date,
        textInputAction: TextInputAction.next,
        label: 'Date of Birth',
        requiredLabel: false,
        dateTimeShowFormat: DateFormat('dd MMM yyyy'),
        controller: TextEditingController(),
        focusNode: FocusNode(),
        onChanged: (value) {
          _fields[7].focusNode?.requestFocus(); // EMERGENCY CONTACT
        },
        decoration: InputDecoration(
          hintText: 'Select Date of Birth',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 7 — EMERGENCY CONTACT
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Emergency Contact',
        requiredLabel: false,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        onSubmitted: (value) {
          _fields[8].focusNode?.requestFocus(); // HEIGHT
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 8 — HEIGHT
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Height',
        requiredLabel: false,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.number,
        maxLength: 3,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        onSubmitted: (value) {
          _fields[9].focusNode?.requestFocus(); // WEIGHT
        },
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          suffixIcon: SizedBox.square(
            dimension: 22,
            child: Center(
              child: Text('CM', style: AppStyles.text14Px.poppins.w400.dark),
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 9 — WEIGHT
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Weight',
        requiredLabel: false,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.number,
        maxLength: 3,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        onSubmitted: (value) {
          _fields[10].focusNode?.requestFocus(); // PROFESSION
        },
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          suffixIcon: SizedBox.square(
            dimension: 22,
            child: Center(
              child: Text('KG', style: AppStyles.text14Px.poppins.w400.dark),
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      // ---------------------------------------------------------
      // 10 — PROFESSION (LAST FIELD)
      // ---------------------------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Profession',
        requiredLabel: false,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.name,
        onSubmitted: (value) {
          _onContinue();
        },
        decoration: InputDecoration(
          hintText: 'Enter Profession',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
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
    if (_cubit.state.createOrUpdateMember?.isNone() ?? false) {
      Dialogs.showSnack(msg: 'Please wait');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fields[0].controller?.text;
      final email = _fields[1].controller?.text;
      final mobileNumber = _fields[2].controller?.text;
      final address = _fields[3].controller?.text;
      final bloodGroup = _fields[4].controller?.text;
      final gender = _fields[5].controller?.text.toLowerCase();
      final dateOfBirth = _fields[6].selectedDateTime;
      final emergencyContactNumber = _fields[7].controller?.text;
      final height = _fields[8].controller?.text;
      final weight = _fields[9].controller?.text;
      final profession = _fields[10].controller?.text;

      final memberDetails = MemberDetailsModel(
        fullName: fullName,
        email: email,
        mobileNumber: mobileNumber,
        address: address,
        bloodGroup: bloodGroup,
        gender: gender,
        dateOfBirth: dateOfBirth,
        emergencyContactNumber: emergencyContactNumber,
        height: height,
        weight: weight,
        profession: profession,
        profilePicture: _profilePicture?.path,
      );
      print('member is---$memberDetails');
      context.push(
        BlocProvider.value(
          value: _cubit,
          child: SubscriptionSelectionScreen(
            orgId: widget.orgId,
            memberDetails: memberDetails,
          ),
        ),
      );
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen:
          (p, c) =>
              p.memberOnboardedAnimationCompleted !=
              c.memberOnboardedAnimationCompleted,
      listener: (context, state) {
        if (state.memberOnboardedAnimationCompleted ?? false) {
          context.pop();
        }
      },
      child: BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
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
                  Dialogs.showSnack(msg: 'Member details updated successfully');
                } else {
                  Dialogs.showSnack(msg: 'Member added successfully');
                }
              },
            );
          });
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const PopButton().center,
            titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
            title: const Text('Add Member'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProfileImage(
                  isEdit: true,
                  onChanged: (image) => _profilePicture = image,
                  radius: 80,
                ).pOnly(bottom: 16),
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
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.borderGrey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: AppColors.borderGrey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: AppColors.borderGrey),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: AppColors.error),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: AppColors.borderGrey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen:
                    (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
                builder: (context, state) {
                  return Button.filled(
                    title: 'Continue',
                    isLoading: state.createOrUpdateMember?.isNone() ?? false,
                    buttonColor: AppColors.primary,
                    ontap: _onContinue,
                  );
                },
              ).pad(16).pxy(y: 16),
        ),
      ),
    );
  }
}
