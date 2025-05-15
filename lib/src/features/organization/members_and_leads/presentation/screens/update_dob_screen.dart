import 'package:mentor_mobile_app/imports_bindings.dart';

class UpdateDOBScreen extends StatefulWidget {
  const UpdateDOBScreen({required this.details, super.key});

  final Either<LeadDetailsModel, MemberDetailsModel>? details;

  @override
  State<UpdateDOBScreen> createState() => _UpdateDOBScreenState();
}

class _UpdateDOBScreenState extends State<UpdateDOBScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final FieldData<dynamic> _fieldData;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _cubit = context.read<MembersAndLeadsCubit>();
    final leadDetails = widget.details?.fold((l) => l, (r) => null);
    final memebrDetails = widget.details?.fold((l) => null, (r) => r);
    _fieldData = FieldData(
      type: FieldType.date,
      textInputAction: TextInputAction.done,
      label: 'Date of Birth',
      dateTimeShowFormat: DateFormat('dd MMM yyyy'),
      requiredLabel: true,
      controller: TextEditingController(text: (leadDetails?.dateOfBirth ?? memebrDetails?.dateOfBirth)?.format('dd MMM yyyy')),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Date of Birth must be selected';
        }
        return null;
      },
      onChanged: (p0) {},
      decoration: InputDecoration(
        hintText: 'Select Date of Birth',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        filled: false,
        border: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.error)),
        focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _fieldData.controller?.dispose();
  }

  void _onContinue() {
    if (_cubit.state.createOrUpdateLead?.isNone() ?? false) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final dob = _fieldData.selectedDateTime?.format('yyyy-MM-dd');

      widget.details?.fold(
        (l) {
          if (l.id == null) {
            Dialogs.showSnack(msg: 'Lead not found!');
            return;
          }
          _cubit.updateLeadDob(leadId: l.id!, dob: dob);
        },
        (r) {
          if (r.id == null) {
            Dialogs.showSnack(msg: 'Member not found!');
            return;
          }
          _cubit.updateMemberDob(memberId: r.id!, dob: dob);
        },
      );
    } else {
      Dialogs.showSnack(msg: 'Please enter valid date of birth');
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
        appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Add Trainer')),
        body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [Field(data: _fieldData)])),
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
