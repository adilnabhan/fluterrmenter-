import 'package:mentor_mobile_app/imports_bindings.dart';

class GymAddOrEditPackageScreen extends StatefulWidget {
  const GymAddOrEditPackageScreen({super.key, this.membershipPackage});

  final MembershipPackageModel? membershipPackage;

  @override
  State<GymAddOrEditPackageScreen> createState() => _GymAddOrEditPackageScreenState();
}

class _GymAddOrEditPackageScreenState extends State<GymAddOrEditPackageScreen> {
  late final MembershipCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  String _selectedPriceType = 'Monthly Price';
  late final FieldData<String> _membershipNameField;
  late final FieldData<String> _packageTypeField; // Stays FieldData<String>
  PackageType? _selectedPackageType; // New state variable for the actual enum
  late final FieldData<dynamic> _actualPriceField;
  late final FieldData<dynamic> _offerPriceField;
  late final List<({FieldData<String> month, FieldData<String> price})> _emiOptions;
  bool _showOfferPrice = false;
  bool _isEmi = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _emiOptions = [];
    _membershipNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Membership Name',
      requiredLabel: true,
      keyboardType: TextInputType.name,
      controller: TextEditingController(text: widget.membershipPackage?.name ?? ''), // Use the name from the package if available
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Membership name is required!';
        }
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter membership name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    _selectedPackageType = PackageType.fromName(widget.membershipPackage?.packageType) ?? PackageType.monthly; // Default to monthly if not set
    _packageTypeField = FieldData<String>(
      type: FieldType.radio,
      textInputAction: TextInputAction.done,
      label: 'Package Type',
      requiredLabel: true,
      controller: TextEditingController(text: _selectedPackageType?.label), // Controller might be used to set initial value by name
      items: PackageType.values.map((e) => (label: e.label, value: e.name)).toList(), // Value is enum name
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Package type must be selected';
        }
        return null;
      },
      onValueChanged: (value) {
        // value here is String? (the enum name)
        setState(() {
          _selectedPackageType = PackageType.fromName(value.first.value);
          _isEmi = false;
          _emiOptions.clear();
        });
      },
      decoration: InputDecoration(
        hintText: 'Select Package Type',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    _actualPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Actual Price',
      requiredLabel: true,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Allows only numbers and up to two decimal points
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: TextEditingController(text: widget.membershipPackage?.actualPrice ?? ''), // Use the actual price from the package if available
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Actual price is required!';
        }
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter actual price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    _offerPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Offer Price',
      requiredLabel: true,
      controller: TextEditingController(text: widget.membershipPackage?.offerPrice ?? ''), // Use the offer price from the package if available
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Allows only numbers and up to two decimal points
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Offer price is required';
        }
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter offer price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    _showOfferPrice = widget.membershipPackage?.offerPrice?.isNotEmpty ?? false; // Show offer price if it exists in the package
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembershipCubit, MembershipState>(
      bloc: _cubit,
      listenWhen: (p, c) => p.createOrUpdatePackage != c.createOrUpdatePackage,
      listener: (context, state) {
        state.createOrUpdatePackage?.fold(
          () {},
          (either) => either.fold(
            (error) {
              Dialogs.showSnack(msg: error.msg);
            },
            (success) {
              Dialogs.showSnack(msg: 'Package added successfully');
              context.pop();
            },
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center, title: Text('${widget.membershipPackage == null ? 'Add' : 'Edit'} Package', style: AppStyles.text16Px.poppins.w500)),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              _ShadowCard(child: Column(spacing: 16, children: [Field(data: _membershipNameField), Field(data: _packageTypeField)])),
              const _Divider(),
              _ShadowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedPackageType != PackageType.monthly)
                      Wrap(
                        spacing: 8,
                        children: [
                          ...['Monthly Price', 'Total Price'].map(_sortTile),
                        ],
                      ).pOnly(bottom: 32),
                    Field(data: _actualPriceField),
                    if (_showOfferPrice) Field(data: _offerPriceField).pOnly(top: 16),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.transparent),
                        shape: const StadiumBorder(),
                        foregroundColor: const Color(0xff3262DD),
                      ),
                      onPressed: () {
                        setState(() {
                          _showOfferPrice = !_showOfferPrice;
                        });
                      },
                      label: Text(_showOfferPrice ? 'Remove Offer Price' : 'Add Offer Price'),
                      icon: Icon(_showOfferPrice ? Icons.close : Icons.add),
                    ),
                  ],
                ),
              ),
              if (_selectedPackageType != PackageType.monthly && _selectedPackageType != null) ...[
                const _Divider(),
                _ShadowCard(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subscription', style: AppStyles.text15Px.w600.dark),
                      const SizedBox(height: 28),
                      // Conditionally render EMI options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly EMI', style: AppStyles.text14Px.poppins.w500.dark), // Changed label for clarity
                          Switch(
                            value: _isEmi,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                // Ensure setState is called
                                _isEmi = value;
                                if (!_isEmi) {
                                  _emiOptions.clear();
                                } else {
                                  // Add a default EMI option if toggled on and list is empty
                                  if (_emiOptions.isEmpty) {
                                    _emiOptions.add((
                                      month: FieldData<String>(
                                        type: FieldType.radio,
                                        items: [
                                          ...List.generate(switch (_selectedPackageType) {
                                            PackageType.yearly => 12,
                                            PackageType.quarterly => 3,
                                            _ => 0,
                                          }, (index) => (label: '${index + 1}', value: '${index + 1}')),
                                        ],
                                        textInputAction: TextInputAction.done,
                                        label: 'Month',
                                        requiredLabel: true,
                                        controller: TextEditingController(),
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Months are whole numbers
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Month is required!';
                                          }
                                          return null;
                                        },
                                        onValueChanged: (p0) {},
                                        onSubmitted: (value) {},
                                        decoration: InputDecoration(
                                          hintText: 'Enter month',
                                          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                                        ),
                                      ),
                                      price: FieldData<String>(
                                        type: FieldType.word,
                                        textInputAction: TextInputAction.done,
                                        label: 'Price',
                                        requiredLabel: true,
                                        controller: TextEditingController(),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Allows only numbers and up to two decimal points
                                        ],
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Price is required!';
                                          }
                                          return null;
                                        },
                                        onValueChanged: (p0) {},
                                        onSubmitted: (value) {},
                                        decoration: InputDecoration(
                                          hintText: 'Enter price',
                                          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                                        ),
                                      ),
                                    ));
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      // Iterate over EMI options if _isEmi is true
                      if (_isEmi)
                        for (var i = 0; i < _emiOptions.length; i++)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Field(data: _emiOptions[i].month)),
                              const SizedBox(width: 16),
                              Expanded(child: Field(data: _emiOptions[i].price)),
                              IconButton.filled(
                                style: IconButton.styleFrom(backgroundColor: AppColors.lightPrimary, foregroundColor: Colors.red, shape: const CircleBorder()),
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _emiOptions.removeAt(i);
                                    if (_emiOptions.isEmpty) {
                                      _isEmi = false; // Turn off switch if all EMIs removed
                                    }
                                  });
                                },
                              ).pOnly(top: 24, left: 8),
                            ],
                          ).pOnly(top: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<MembershipCubit, MembershipState>(
          buildWhen: (p, c) => p.createOrUpdatePackage != c.createOrUpdatePackage,
          builder: (context, state) {
            final isLoading = state.createOrUpdatePackage?.isNone() ?? false;
            return Button.filled(
              title: 'Save',
              isLoading: isLoading,
              buttonColor: AppColors.primary,
              // ontap: _onContinue,
              ontap: () {
                if (isLoading) {
                  return;
                }
                if (!_formKey.currentState!.validate()) {
                  Dialogs.showSnack(msg: 'Please fill all required fields correctly.');
                  return;
                }
                if (_selectedPackageType == null) {
                  Dialogs.showSnack(msg: 'Please select a package type.');
                  return;
                }
                if (_isEmi && _emiOptions.isEmpty) {
                  Dialogs.showSnack(msg: 'Please add at least one EMI option.');
                  return;
                }
                final membershipName = _membershipNameField.controller!.text.trim();
                final actualPrice = _actualPriceField.controller!.text.trim();
                final offerPrice = _offerPriceField.controller!.text.trim();
                final packageType = _selectedPackageType!.label; // Use the enum name
                if (_showOfferPrice) {
                  final actualPriceValue = double.tryParse(actualPrice);
                  final offerPriceValue = double.tryParse(offerPrice);
                  if (actualPriceValue != null && offerPriceValue != null && offerPriceValue >= actualPriceValue) {
                    Dialogs.showSnack(msg: 'Offer price must be less than actual price.');
                    return;
                  }
                }
                // final emiOptions = _isEmi ? _emiOptions.map((e) => {'month': e.month.controller!.text.trim(), 'price': e.price.controller!.text.trim()}).toList() : [];
                _cubit.createOrUpdateMembershipPackage(
                  membershipId: widget.membershipPackage?.id,
                  packageType: packageType,
                  name: membershipName,
                  description: 'Package for $membershipName', // Placeholder description, can be modified
                  actualPrice: actualPrice,
                  offerPrice: offerPrice,
                  features: [],
                  isEmiAvailable: _isEmi,
                );
              },
            );
          },
        ).pad(16).pxy(y: 16),
      ),
    );
  }

  Widget _sortTile(String priceType) {
    final isSelected = _selectedPriceType == priceType;
    if (isSelected) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
          backgroundColor: Colors.transparent,
          shape: const StadiumBorder(),
          foregroundColor: AppColors.primary,
        ),
        onPressed: () {},
        label: Text(priceType),
        icon: const Icon(Icons.radio_button_checked),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.transparent),
        shape: const StadiumBorder(),
        foregroundColor: const Color(0xff444444),
      ),
      onPressed: () {
        setState(() {
          _selectedPriceType = priceType;
        });
      },
      label: Text(priceType.pascalCase),
      icon: const Icon(Icons.radio_button_off),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Color(0xffF7F7F7), height: 12, thickness: 1);
  }
}

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: color ?? Colors.grey.withOpacity(0.2), spreadRadius: 10, blurRadius: 10, offset: const Offset(0, -2))]),
      child: child,
    );
  }
}
