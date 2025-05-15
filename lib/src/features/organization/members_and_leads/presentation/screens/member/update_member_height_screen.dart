import 'package:mentor_mobile_app/imports_bindings.dart';

class UpdateHeightScreen extends StatefulWidget {
  const UpdateHeightScreen({required this.details, super.key});

  final MemberDetailsModel? details;

  @override
  State<UpdateHeightScreen> createState() => _UpdateHeightScreenState();
}

class _UpdateHeightScreenState extends State<UpdateHeightScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final FieldData<dynamic> _fieldData;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _cubit = context.read<MembersAndLeadsCubit>();
    _fieldData = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Height',
      requiredLabel: true,
      controller: TextEditingController(text: widget.details?.height?.toNum.toInt().toString() ?? ''),
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
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        suffixIcon: SizedBox.square(dimension: 22, child: Center(child: Text('CM', style: AppStyles.text14Px.poppins.w400.dark))),
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
    if (_cubit.state.createOrUpdateMember?.isNone() ?? false) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final height = _fieldData.controller?.text;
      if (widget.details?.id == null) {
        Dialogs.showSnack(msg: 'Member not found!');
        return;
      }
      _cubit.updateMemberHeight(memberId: widget.details!.id!, height: height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
            return Button.filled(title: 'Save', isLoading: state.createOrUpdateMember?.isNone() ?? false, buttonColor: AppColors.primary, ontap: _onContinue);
          },
        ).pad(16).pxy(y: 16),
      ),
    );
  }
}
