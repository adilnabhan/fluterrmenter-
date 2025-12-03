import 'package:mentor_mobile_app/imports_bindings.dart';

class AddEditBankAccountScreenView extends StatefulWidget {
  const AddEditBankAccountScreenView({
    this.bankDetails,
    super.key,
    this.progress = 0,
  });

  final BankDetailsModel? bankDetails;
  final int? progress;
  @override
  State<AddEditBankAccountScreenView> createState() =>
      _BankAccountDetailsScreenState();
}

class _BankAccountDetailsScreenState
    extends State<AddEditBankAccountScreenView> {
  final _formKey = GlobalKey<FormState>();

  late final FieldData<String> _bankNameField;
  late final FieldData<String> _branchNameField;
  late final FieldData<String> _accountHolderField;
  late final FieldData<String> _ifscCodeField;
  late final FieldData<String> _accountNumberField;
  late final FieldData<String> _confirmAccountNumberField;

  late final MembershipCubit
  _cubit; // you can replace this with your own cubit if needed

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();

    _bankNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Bank Name',
      requiredLabel: true,
      controller: TextEditingController(text: widget.bankDetails?.bankName),
      validator:
          (value) => value?.isEmpty ?? true ? 'Bank name is required' : null,
      onValueChanged: (_) {},
      onSubmitted: (_) {},
      decoration: _inputDecoration('Enter bank name'),
    );

    _branchNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Branch Name',
      requiredLabel: true,
      controller: TextEditingController(text: widget.bankDetails?.branchName),
      validator:
          (value) => value?.isEmpty ?? true ? 'Branch name is required' : null,
      onValueChanged: (_) {},
      onSubmitted: (_) {},
      decoration: _inputDecoration('Enter branch name'),
    );

    _accountHolderField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Account Holder Name',
      requiredLabel: true,
      controller: TextEditingController(
        text: widget.bankDetails?.accountHolderName,
      ),
      validator:
          (value) =>
              value?.isEmpty ?? true ? 'Account holder name is required' : null,
      onValueChanged: (_) {},
      onSubmitted: (_) {},
      decoration: _inputDecoration('Enter account holder name'),
    );

    _ifscCodeField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'IFSC Code',
      requiredLabel: true,
      controller: TextEditingController(text: widget.bankDetails?.ifscCode),
      validator:
          (value) => value?.isEmpty ?? true ? 'Enter a valid IFSC code' : null,
      //     (value) {
      //   if (value?.isEmpty ?? true) return 'IFSC code is required';
      //   final regex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
      //   if (!regex.hasMatch(value!.toUpperCase()))
      //     return 'Enter a valid IFSC code';
      //   return null;
      // },
      onValueChanged: (_) {},
      onSubmitted: (_) {},
      decoration: _inputDecoration('Enter IFSC code'),
    );

    _accountNumberField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Account Number',
      requiredLabel: true,
      controller: TextEditingController(
        text: widget.bankDetails?.accountNumber,
      ),
      keyboardType: TextInputType.number,
      validator:
          (value) =>
              value?.isEmpty ?? true ? 'Account number is required' : null,
      onValueChanged: (_) {},
      onSubmitted: (_) {},
      decoration: _inputDecoration('Enter account number'),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    _confirmAccountNumberField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Confirm Account Number',
      requiredLabel: true,
      controller: TextEditingController(
        text: widget.bankDetails?.accountNumber,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Confirm account number is required';
        if (value != _accountNumberField.controller?.text)
          return 'Account numbers do not match';
        return null;
      },
      onValueChanged: (_) {},
      onSubmitted: (_) {},
      decoration: _inputDecoration('Re-enter account number'),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  @override
  void dispose() {
    _bankNameField.controller?.dispose();
    _branchNameField.controller?.dispose();
    _accountHolderField.controller?.dispose();
    _ifscCodeField.controller?.dispose();
    _accountNumberField.controller?.dispose();
    _confirmAccountNumberField.controller?.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.borderGrey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembershipCubit, MembershipState>(
      bloc: _cubit,
      listenWhen: (p, c) => p.createOrUpdateBank != c.createOrUpdateBank,
      listener: (context, state) {
        state.createOrUpdateBank?.fold(
          () {},
          (either) => either.fold(
            (error) {
              Dialogs.showSnack(msg: error.msg);
            },
            (success) {
              Dialogs.showSnack(msg: 'Bank added successfully');
              if (widget.progress == 0) {
                context.pop();
              } else {
                var dat = context.read<AppCubit>().state;
                print('org id is--${dat.currentUser?.mentor?.org}');
                print('org id is--${_cubit.orgId}');
                context.read<AppCubit>().onboardingUpdate(
                  body: {'profile_completeness': 6},
                  id: int.parse(_cubit.orgId),
                );

                context.pushAndRemoveUntil(
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create:
                            (_) => MembershipCubit(orgId: _cubit.orgId ?? ''),
                      ),
                    ],
                    child: GymPackagesScreen(
                      progress: 6,
                      orgDetails: OrganizationDetailsModel(
                        id: int.parse(_cubit.orgId),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
      child: Scaffold(
        appBar:
            widget.progress == 0
                ? AppBar(
                  leading: const PopButton().center,
                  title: Text(
                    'Bank Account Details',
                    style: AppStyles.text16Px.poppins.w500,
                  ),
                )
                : null,

        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              _ShadowCard(
                child: Column(
                  spacing: 16,
                  children: [
                    if (widget.progress != 0)
                      Column(
                        children: [
                          const SizedBox(height: 22),
                          OrganizationCreationCompletionStatusCard(
                            progress: widget.progress ?? 0,
                          ),
                          const SizedBox(height: 28),
                        ],
                      )
                    else
                      SizedBox(),
                    Field(data: _bankNameField),
                    Field(data: _branchNameField),
                    Field(data: _accountHolderField),
                    Field(data: _ifscCodeField),
                    Field(data: _accountNumberField),
                    Field(data: _confirmAccountNumberField),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<MembershipCubit, MembershipState>(
          buildWhen:
              (previous, current) =>
                  previous.createOrUpdateBank != current.createOrUpdateBank,
          builder: (context, state) {
            final isLoading = state.createOrUpdateBank?.isNone() ?? false;
            return Button.filled(
              title: 'Save',
              isLoading: isLoading,
              buttonColor: AppColors.primary,
              ontap: () {
                if (isLoading) return;

                if (!_formKey.currentState!.validate()) {
                  Dialogs.showSnack(
                    msg: 'Please fill all required fields correctly.',
                  );
                  return;
                }

                final bankName = _bankNameField.controller!.text.trim();
                final branchName = _branchNameField.controller!.text.trim();
                final holderName = _accountHolderField.controller!.text.trim();
                final ifsc = _ifscCodeField.controller!.text.trim();
                final accountNumber =
                    _accountNumberField.controller!.text.trim();

                _cubit.createOrUpdateBankDetails(
                  detailsId: widget.bankDetails?.id,
                  bankName: bankName,
                  branchName: branchName,
                  holderName: holderName,
                  ifsc: ifsc,
                  accountNumber: accountNumber,
                );
              },
            ).pad(16).pxy(y: 16);
          },
        ),
      ),
    );
  }
}

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 10,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}
