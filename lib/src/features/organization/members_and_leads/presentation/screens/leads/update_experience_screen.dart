import 'package:mentor_mobile_app/imports_bindings.dart';

class UpdateExperienceScreen extends StatefulWidget {
  const UpdateExperienceScreen({required this.details, super.key});

  final LeadDetailsModel? details;

  @override
  State<UpdateExperienceScreen> createState() => _UpdateExperienceScreenState();
}

class _UpdateExperienceScreenState extends State<UpdateExperienceScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final FieldData<dynamic> _fieldData;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _cubit = context.read<MembersAndLeadsCubit>();
    _fieldData = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Expirience',
      requiredLabel: true,
      controller: TextEditingController(text: widget.details?.mentorProfile?.experience?.toString()),
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      maxLength: 2,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Expriece is required';
        }
        return null;
      },
      onSubmitted: (value) {
        _cubit.updateLeadExperience(leadId: widget.details!.id!, experience: value);
      },
      decoration: InputDecoration(
        hintText: '4',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        suffixIcon: SizedBox.square(dimension: 22, child: Center(child: Text('YEARS   ', style: AppStyles.text14Px.poppins.w400.dark))),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
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
      final experience = _fieldData.controller?.text;
      if (widget.details?.id == null) {
        Dialogs.showSnack(msg: 'Lead not found!');
        return;
      }
      _cubit.updateLeadExperience(leadId: widget.details!.id!, experience: experience);
    } else {
      Dialogs.showSnack(msg: 'Please enter valid experience');
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
        appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Add Date of Birth')),
        body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [Field(data: _fieldData)])),
        bottomNavigationBar: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
          buildWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead || p.createOrUpdateMember != c.createOrUpdateMember,
          builder: (context, state) {
            return Button.filled(title: 'Save', isLoading: state.createOrUpdateLead?.isNone() ?? false, buttonColor: AppColors.primary, ontap: _onContinue);
          },
        ).pad(16).pxy(y: 16),
      ),
    );
  }
}
