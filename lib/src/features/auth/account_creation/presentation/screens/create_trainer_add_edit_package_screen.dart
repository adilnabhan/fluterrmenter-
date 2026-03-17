import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerAddEditPackageScreen extends StatefulWidget {
  const CreateTrainerAddEditPackageScreen({super.key, this.membershipPackage});

  final MembershipPackageModel? membershipPackage;

  @override
  State<CreateTrainerAddEditPackageScreen> createState() =>
      _CreateTrainerAddEditPackageScreenState();
}

class _CreateTrainerAddEditPackageScreenState extends State<CreateTrainerAddEditPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<String> _membershipNameField;
  late final FieldData<String> _daysField;
  late final FieldData<dynamic> _actualPriceField;
  late final FieldData<dynamic> _offerPriceField;
  late final FieldData<String> _descriptionField;
  late List<({FieldData<String> month, FieldData<String> price})> _emiOptions;
  bool _isEmi = false;
  int _calculatedMonths = 0;

  double _razorpayCommissionPercent = 4.0;
  String _commissionMessage = '';
  String _offerCommissionMessage = '';

  @override
  void initState() {
    super.initState();
    _emiOptions = [];

    _membershipNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Plan Name',
      requiredLabel: true,
      controller: TextEditingController(
        text: widget.membershipPackage?.name ?? '',
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Plan Name is required!' : null,
      decoration: _inputDecoration('Enter Plan Name'),
    );

    _daysField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Duration in Days',
      requiredLabel: true,
      keyboardType: TextInputType.number,
      controller: TextEditingController(
        text: widget.membershipPackage?.durationDays.toString() ?? '',
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Duration in Days is required!' : null,
      decoration: _inputDecoration('Enter Duration in Days'),
    );

    _daysField.controller!.addListener(() {
      final days = int.tryParse(_daysField.controller?.text ?? '') ?? 0;
      final months = (days / 30).floor();
      if (mounted) {
        setState(() {
          _calculatedMonths = months > 0 ? months : 0;
          for (var i = 0; i < _emiOptions.length; i++) {
            final existing = _emiOptions[i];
            _emiOptions[i] = (
              month: _buildMonthFieldWithController(existing.month.controller!),
              price: existing.price,
            );
          }
        });
      }
    });

    _actualPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Actual Price',
      requiredLabel: true,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: TextEditingController(text: widget.membershipPackage?.actualPrice ?? ''),
      validator: (value) => value?.isEmpty ?? true ? 'Actual Price is required!' : null,
      decoration: _inputDecoration('Enter Actual Price'),
    );

    _actualPriceField.controller!.addListener(_calculateCommission);

    _offerPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Offer Price',
      requiredLabel: false,
      controller: TextEditingController(text: widget.membershipPackage?.offerPrice ?? ''),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration('Enter Offer Price'),
    );

    _offerPriceField.controller!.addListener(_calculateOfferCommission);

    _descriptionField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Description / Inclusions',
      requiredLabel: false,
      controller: TextEditingController(text: widget.membershipPackage?.description ?? ''),
      decoration: _inputDecoration('Description'),
    );

    if (widget.membershipPackage?.emiPlans != null && widget.membershipPackage!.emiPlans.isNotEmpty) {
      for (final plan in widget.membershipPackage!.emiPlans) {
        final monthController = TextEditingController(text: plan.month.toString());
        final priceController = TextEditingController(text: plan.price.toString());
        monthController.addListener(() => setState(() {}));
        priceController.addListener(() => setState(() {}));
        
        final monthField = _buildMonthFieldWithController(monthController);
        final priceField = _buildPriceFieldWithController(priceController);
        _emiOptions.add((month: monthField, price: priceField));
      }
      _isEmi = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCommission();
      _calculateOfferCommission();
    });
  }

  void _calculateCommission() {
    final amount = double.tryParse(_actualPriceField.controller?.text.trim() ?? '') ?? 0.0;
    if (!mounted) return;
    setState(() {
      final commission = amount * (_razorpayCommissionPercent / 100);
      _commissionMessage = amount > 0 
          ? 'After $_razorpayCommissionPercent% gateway charges (₹${commission.toStringAsFixed(2)}), ₹${(amount - commission).toStringAsFixed(2)} will be credited.' 
          : '';
    });
  }

  void _calculateOfferCommission() {
    final amount = double.tryParse(_offerPriceField.controller?.text.trim() ?? '') ?? 0.0;
    if (!mounted) return;
    setState(() {
      final commission = amount * (_razorpayCommissionPercent / 100);
      _offerCommissionMessage = amount > 0 
          ? 'After $_razorpayCommissionPercent% gateway charges (₹${commission.toStringAsFixed(2)}), ₹${(amount - commission).toStringAsFixed(2)} will be credited.' 
          : '';
    });
  }

  FieldData<String> _buildMonthFieldWithController(TextEditingController controller) {
    return FieldData<String>(
      type: FieldType.radio,
      items: List.generate(_calculatedMonths > 0 ? _calculatedMonths : 12, (index) => (label: '${index + 1}', value: '${index + 1}')),
      label: 'Month',
      requiredLabel: true,
      controller: controller,
      validator: (value) => value?.isEmpty ?? true ? 'Required!' : null,
      decoration: _inputDecoration('Month'),
    );
  }

  FieldData<String> _buildPriceFieldWithController(TextEditingController controller) {
    return FieldData<String>(
      type: FieldType.word,
      label: 'Price',
      requiredLabel: true,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      validator: (value) => value?.isEmpty ?? true ? 'Required!' : null,
      decoration: _inputDecoration('Price'),
    );
  }

  ({FieldData<String> month, FieldData<String> price}) _createEmptyEmiOption() {
    final m = TextEditingController();
    final p = TextEditingController();
    m.addListener(() => setState(() {}));
    p.addListener(() => setState(() {}));
    return (month: _buildMonthFieldWithController(m), price: _buildPriceFieldWithController(p));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderGrey)),
    );
  }

  @override
  void dispose() {
    _membershipNameField.controller?.dispose();
    _daysField.controller?.dispose();
    _actualPriceField.controller?.dispose();
    _offerPriceField.controller?.dispose();
    _descriptionField.controller?.dispose();
    for (final emi in _emiOptions) {
      emi.month.controller?.dispose();
      emi.price.controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text('${widget.membershipPackage == null ? 'Add' : 'Edit'} Package', style: AppStyles.text16Px.poppins.w500),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Field(data: _membershipNameField),
            const SizedBox(height: 16),
            Field(data: _daysField),
            const SizedBox(height: 16),
            Field(data: _actualPriceField),
            if (_commissionMessage.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_commissionMessage, style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.error)),
            ),
            const SizedBox(height: 16),
            Field(data: _offerPriceField),
            if (_offerCommissionMessage.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_offerCommissionMessage, style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.error)),
            ),
            const SizedBox(height: 16),
            Field(data: _descriptionField),
            const SizedBox(height: 24),
            Text('Subscription', style: AppStyles.text16Px.w600.dark),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add EMI', style: AppStyles.text14Px.poppins.w500.dark),
                Switch(
                  value: _isEmi,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _isEmi = value;
                      if (!_isEmi) {
                        for (final emi in _emiOptions) {
                          emi.month.controller?.dispose();
                          emi.price.controller?.dispose();
                        }
                        _emiOptions.clear();
                      } else if (_emiOptions.isEmpty) {
                        _emiOptions.add(_createEmptyEmiOption());
                      }
                    });
                  },
                ),
              ],
            ),
            if (_isEmi) ..._emiOptions.asMap().entries.map((entry) {
              final i = entry.key;
              final emi = entry.value;
              final isLast = i == _emiOptions.length - 1;
              final total = (int.tryParse(emi.month.controller!.text) ?? 0) * (double.tryParse(emi.price.controller!.text) ?? 0.0);
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Field(data: emi.month)),
                        const SizedBox(width: 16),
                        Expanded(child: Field(data: emi.price)),
                        if (isLast) Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                final last = _emiOptions.removeLast();
                                last.month.controller?.dispose();
                                last.price.controller?.dispose();
                                if (_emiOptions.isEmpty) _isEmi = false;
                              });
                            },
                            child: const Icon(Icons.close, color: AppColors.error, size: 20),
                          ),
                        ),
                      ],
                    ),
                    if (emi.price.controller!.text.isNotEmpty) ...[
                      Text(_emiCommissionMessage(emi.price.controller!.text), style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.error)),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text('Total Amount = ${total.toStringAsFixed(2)}', style: AppStyles.text10Px.w600.copyWith(color: AppColors.error)),
                      ),
                    ]
                  ],
                ),
              );
            }),
            if (_isEmi) Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _emiOptions.add(_createEmptyEmiOption())),
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: Text('Add More', style: AppStyles.text14Px.poppins.w500.primary),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Button.filled(
          title: 'Save',
          buttonColor: AppColors.primary,
          ontap: () {
            if (!_formKey.currentState!.validate()) {
              Dialogs.showSnack(msg: 'Please fill all required fields correctly.');
              return;
            }
            Dialogs.showSnack(msg: 'Plan saved (Offline UI)');
            context.pop();
          },
        ),
      ),
    );
  }
}

String _emiCommissionMessage(String priceText) {
  final price = double.tryParse(priceText.trim()) ?? 0.0;
  if (price <= 0) return '';
  final commission = price * (4.0 / 100);
  return 'After 4% gateway charges (₹${commission.toStringAsFixed(2)}), ₹${(price - commission).toStringAsFixed(2)} will be credited.';
}
