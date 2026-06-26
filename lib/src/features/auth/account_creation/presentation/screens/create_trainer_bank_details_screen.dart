import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerBankDetailsScreen extends StatefulWidget {
  const CreateTrainerBankDetailsScreen({super.key});

  @override
  State<CreateTrainerBankDetailsScreen> createState() => _CreateTrainerBankDetailsScreenState();
}

class _CreateTrainerBankDetailsScreenState extends State<CreateTrainerBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final FieldData<String> _bankNameField;
  late final FieldData<String> _branchNameField;
  late final FieldData<String> _accountHolderField;
  late final FieldData<String> _panCardNameField;
  late final FieldData<String> _panCardNumberField;
  late final FieldData<String> _ifscCodeField;
  late final FieldData<String> _accountNumberField;
  late final FieldData<String> _confirmAccountNumberField;

  @override
  void initState() {
    super.initState();

    _bankNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Bank Name',
      requiredLabel: true,
      controller: TextEditingController(),
      decoration: _inputDecoration('Enter Bank name'),
    );

    _branchNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Branch Name',
      requiredLabel: true,
      controller: TextEditingController(),
      decoration: _inputDecoration('Enter Branch name'),
    );

    _accountHolderField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Account Holder Name',
      requiredLabel: true,
      controller: TextEditingController(),
      decoration: _inputDecoration('Enter Account holder name'),
    );

    _panCardNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'PAN Card Name',
      requiredLabel: true,
      controller: TextEditingController(),
      decoration: _inputDecoration('Enter PAN Card Name'),
    );

    _panCardNumberField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'PAN Card Number',
      requiredLabel: true,
      controller: TextEditingController(),
      decoration: _inputDecoration('Enter PAN Card Number'),
    );

    _ifscCodeField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'IFSC Code',
      requiredLabel: true,
      controller: TextEditingController(),
      decoration: _inputDecoration('Enter IFSC code'),
    );

    _accountNumberField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Account Number',
      requiredLabel: true,
      controller: TextEditingController(),
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('Enter Account Number'),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    _confirmAccountNumberField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Re-write Account Number',
      requiredLabel: true,
      controller: TextEditingController(),
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('Re-write Account Number'),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  @override
  void dispose() {
    _bankNameField.controller?.dispose();
    _branchNameField.controller?.dispose();
    _accountHolderField.controller?.dispose();
    _panCardNameField.controller?.dispose();
    _panCardNumberField.controller?.dispose();
    _ifscCodeField.controller?.dispose();
    _accountNumberField.controller?.dispose();
    _confirmAccountNumberField.controller?.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: const BorderSide(color: Color(0xffEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: const BorderSide(color: Color(0xffEEEEEE)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 10),
                  // Progress Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      bool isActive = index <= 6; 
                      return Row(
                        children: [
                          Container(
                            width: 25,
                            height: 1,
                            color: isActive ? AppColors.primary : AppColors.borderGrey,
                          ),
                          Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 8,
                              height: 8,
                              color: isActive ? AppColors.primary : AppColors.borderGrey,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    'Unlock\nYour Earnings 💳',
                    style: AppStyles.text30Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add your bank details to start receiving earnings directly safely.',
                    style: AppStyles.text14Px.poppins.w400.textGrey,
                  ),
                  const SizedBox(height: 32),

                  Field(data: _bankNameField),
                  const SizedBox(height: 16),
                  Field(data: _branchNameField),
                  const SizedBox(height: 16),
                  Field(data: _accountHolderField),
                  const SizedBox(height: 16),
                  Field(data: _panCardNameField),
                  const SizedBox(height: 16),
                  Field(data: _panCardNumberField),
                  const SizedBox(height: 16),
                  Field(data: _ifscCodeField),
                  const SizedBox(height: 16),
                  Field(data: _accountNumberField),
                  const SizedBox(height: 16),
                  Field(data: _confirmAccountNumberField),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Button.filled(
                title: 'Save',
                ontap: () => context.push(const CreateTrainerPackagesScreen()),
                buttonColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
