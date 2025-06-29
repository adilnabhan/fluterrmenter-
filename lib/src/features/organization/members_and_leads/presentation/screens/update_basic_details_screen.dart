import 'package:mentor_mobile_app/imports_bindings.dart';

class UpdateBasicDetailsScreen extends StatefulWidget {
  const UpdateBasicDetailsScreen({required this.details, super.key});

  final Either<LeadDetailsModel, MemberDetailsModel>? details;

  @override
  State<UpdateBasicDetailsScreen> createState() => _UpdateBasicDetailsScreenState();
}

class _UpdateBasicDetailsScreenState extends State<UpdateBasicDetailsScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final List<FieldData<dynamic>> _fields;
  final _formKey = GlobalKey<FormState>();
  XFile? _profilePicture;

  @override
  void initState() {
    _cubit = context.read<MembersAndLeadsCubit>();
    final leadDetails = widget.details?.fold((l) => l, (r) => null);
    final memebrDetails = widget.details?.fold((l) => null, (r) => r);
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
        controller: TextEditingController(text: leadDetails?.firstName ?? memebrDetails?.firstName),
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
        controller: TextEditingController(text: leadDetails?.email ?? memebrDetails?.email),
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
        controller: TextEditingController(text: (leadDetails?.mobileNumber ?? memebrDetails?.mobileNumber)?.replaceAll('+91', '')),
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
        label: 'Gender',
        requiredLabel: true,
        controller: TextEditingController(text: (leadDetails?.gender ?? memebrDetails?.gender)?.toUpperCase()),
        focusNode: FocusNode(),
        items: [(label: 'Male', value: 'male'), (label: 'Female', value: 'female'), (label: 'Other', value: 'other')],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Geneder must be selected';
          }
          return null;
        },
        onValueChanged: (p0) {
          _fields[6].focusNode?.requestFocus();
        },
        onSubmitted: (value) {
          _fields[6].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Gender',
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
    if (_cubit.state.createOrUpdateLead?.isNone() ?? false) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fields[0].controller?.text;
      final emailAddress = _fields[1].controller?.text;
      final mobileNo = _fields[2].controller?.text;
      final gender = _fields[3].controller?.text;
      final profilePicuture = _profilePicture?.path;
      widget.details?.fold(
        (l) {
          if (l.id == null) {
            Dialogs.showSnack(msg: 'Lead not found!');
            return;
          }
          _cubit.updateLeadBasicDetails(leadId: l.id!, fullName: fullName, mobileNumber: mobileNo, email: emailAddress, gender: gender, profilePicture: profilePicuture);
        },
        (r) {
          if (r.id == null) {
            Dialogs.showSnack(msg: 'Member not found!');
            return;
          }
          _cubit.updateMemberBasicDetails(memberId: r.id!, fullName: fullName, mobileNumber: mobileNo, email: emailAddress, gender: gender, profilePicture: profilePicuture);
        },
      );
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
          listenWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead,
          bloc: _cubit,
          listener: (context, state) {
            state.createOrUpdateLead?.fold(() => null, (t) {
              t.fold(
                (l) {
                  Dialogs.showSnack(msg: l.msg);
                },
                (r) {
                  Dialogs.showSnack(msg: 'Trainer details updated successfully');
                  context.pop();
                },
              );
            });
          },
        ),
        BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
          listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
          bloc: _cubit,
          listener: (context, state) {
            state.createOrUpdateMember?.fold(() => null, (t) {
              t.fold(
                (l) {
                  Dialogs.showSnack(msg: l.msg);
                },
                (r) {
                  Dialogs.showSnack(msg: 'Member details updated successfully');
                  context.pop();
                },
              );
            });
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: Text('Update ${widget.details?.fold((l) => 'Trainer', (r) => 'Member')}')),
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
              const SizedBox(height: 22),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
          buildWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead || p.createOrUpdateMember != c.createOrUpdateMember,
          builder: (context, state) {
            return Button.filled(
              title: 'Save',
              isLoading: widget.details?.fold((l) => state.createOrUpdateLead, (r) => state.createOrUpdateMember)?.isNone() ?? false,
              buttonColor: AppColors.primary,
              ontap: _onContinue,
            );
          },
        ).pad(16).pxy(y: 16),
      ),
    );
  }
}
