import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/emi_options_model.dart';

class GymAddOrEditPackageScreen extends StatefulWidget {
  const GymAddOrEditPackageScreen({super.key, this.membershipPackage});

  final MembershipPackageModel? membershipPackage;

  @override
  State<GymAddOrEditPackageScreen> createState() =>
      _GymAddOrEditPackageScreenState();
}

class _GymAddOrEditPackageScreenState extends State<GymAddOrEditPackageScreen> {
  late final MembershipCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  String _selectedPriceType = 'Monthly Price';
  late final FieldData<String> _membershipNameField;
  late final FieldData<String> _packageTypeField;
  PackageType? _selectedPackageType;
  late final FieldData<dynamic> _actualPriceField;
  late final FieldData<dynamic> _offerPriceField;
  late List<({FieldData<String> month, FieldData<String> price})> _emiOptions;
  bool _showOfferPrice = false;
  bool _isEmi = false;

  ({FieldData<String> month, FieldData<String> price}) _createEmptyEmiOption() {
    final monthController = TextEditingController();
    final priceController = TextEditingController();

    void listener() {
      if (mounted) {
        setState(() {});
      }
    }

    monthController.addListener(listener);
    priceController.addListener(listener);

    final monthField = FieldData<String>(
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
      controller: monthController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Month is required!';
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter month',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    final priceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Price',
      requiredLabel: true,
      controller: priceController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Price is required!';
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    return (month: monthField, price: priceField);
  }

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _emiOptions = [];
    _selectedPackageType =
        PackageType.fromLabel(widget.membershipPackage?.packageType) ??
        PackageType.monthly;

    if (widget.membershipPackage == null) {
      _emiOptions = [];
      _isEmi = false;
    } else if (widget.membershipPackage?.emiPlans != null &&
        widget.membershipPackage!.emiPlans.isNotEmpty) {
      for (final plan in widget.membershipPackage!.emiPlans) {
        final monthController = TextEditingController(
          text: plan.month.toString(),
        );
        final priceController = TextEditingController(
          text: plan.price.toString(),
        );

        final monthField = FieldData<String>(
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
          controller: monthController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Month is required!';
            return null;
          },
          onValueChanged: (p0) {},
          onSubmitted: (value) {},
          decoration: InputDecoration(
            hintText: 'Enter month',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        );

        final priceField = FieldData<String>(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'Price',
          requiredLabel: true,
          controller: priceController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Price is required!';
            return null;
          },
          onValueChanged: (p0) {},
          onSubmitted: (value) {},
          decoration: InputDecoration(
            hintText: 'Enter price',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        );

        _emiOptions.add((month: monthField, price: priceField));
      }
      _isEmi = true;
    } else if ((widget.membershipPackage?.isEmiAvailable ?? false)) {
      _emiOptions.add(_createEmptyEmiOption());
      _isEmi = true;
    }

    _membershipNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Membership Name',
      requiredLabel: true,
      keyboardType: TextInputType.name,
      controller: TextEditingController(
        text: widget.membershipPackage?.name ?? '',
      ),
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _packageTypeField = FieldData<String>(
      type: FieldType.radio,
      textInputAction: TextInputAction.done,
      label: 'Package Type',
      requiredLabel: true,
      controller: TextEditingController(text: _selectedPackageType?.label),
      items:
          PackageType.values
              .map((e) => (label: e.label, value: e.name))
              .toList(),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Package type must be selected';
        }
        return null;
      },
      onValueChanged: (value) {
        setState(() {
          _selectedPackageType = PackageType.fromLabel(value.first.label);

          _isEmi = false;
          for (final emi in _emiOptions) {
            emi.month.controller?.dispose();
            emi.price.controller?.dispose();
          }
          _emiOptions.clear();
        });
      },
      decoration: InputDecoration(
        hintText: 'Select Package Type',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _actualPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Actual Price',
      requiredLabel: true,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: TextEditingController(
        text: widget.membershipPackage?.actualPrice ?? '',
      ),
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _offerPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Offer Price',
      requiredLabel: true,
      controller: TextEditingController(
        text: widget.membershipPackage?.offerPrice ?? '',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _showOfferPrice = widget.membershipPackage?.offerPrice?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _membershipNameField.controller?.dispose();
    _packageTypeField.controller?.dispose();
    _actualPriceField.controller?.dispose();
    _offerPriceField.controller?.dispose();
    for (final emi in _emiOptions) {
      emi.month.controller?.dispose();
      emi.price.controller?.dispose();
    }
    super.dispose();
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
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text(
            '${widget.membershipPackage == null ? 'Add' : 'Edit'} Package',
            style: AppStyles.text16Px.poppins.w500,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              _ShadowCard(
                child: Column(
                  spacing: 16,
                  children: [
                    Field(data: _membershipNameField),
                    Field(data: _packageTypeField),
                  ],
                ),
              ),
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
                    if (_showOfferPrice)
                      Field(data: _offerPriceField).pOnly(top: 16),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          right: 8,
                        ),
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
                      label: Text(
                        _showOfferPrice
                            ? 'Remove Offer Price'
                            : 'Add Offer Price',
                      ),
                      icon: Icon(_showOfferPrice ? Icons.close : Icons.add),
                    ),
                  ],
                ),
              ),
              if (_selectedPackageType == PackageType.quarterly ||
                  _selectedPackageType == PackageType.yearly) ...[
                const _Divider(),
                _ShadowCard(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subscription', style: AppStyles.text15Px.w600.dark),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monthly EMI',
                            style: AppStyles.text14Px.poppins.w500.dark,
                          ),
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
                                } else {
                                  if (_emiOptions.isEmpty) {
                                    _emiOptions.add(_createEmptyEmiOption());
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isEmi) ...[
                        ..._emiOptions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final emi = entry.value;
                          final isLast = i == _emiOptions.length - 1;

                          final monthText = emi.month.controller!.text;
                          final priceText = emi.price.controller!.text;

                          final showAddButton =
                              isLast &&
                              monthText.isNotEmpty &&
                              priceText.isNotEmpty;

                          double emiTotal() {
                            final month = int.tryParse(monthText) ?? 0;
                            final price = double.tryParse(priceText) ?? 0.0;
                            return month * price;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: Field(data: emi.month)),
                                    const SizedBox(width: 16),
                                    Expanded(child: Field(data: emi.price)),

                                    IconButton.filled(
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.lightPrimary,
                                        foregroundColor: Colors.red,
                                        shape: const CircleBorder(),
                                      ),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          emi.month.controller?.dispose();
                                          emi.price.controller?.dispose();
                                          _emiOptions.removeAt(i);
                                          if (_emiOptions.isEmpty) {
                                            _isEmi = false;
                                          }
                                        });
                                      },
                                    ).pOnly(top: 24, left: 8),
                                    if (showAddButton)
                                      IconButton.filled(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: const CircleBorder(),
                                        ),
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            _emiOptions.add(
                                              _createEmptyEmiOption(),
                                            );
                                          });
                                        },
                                      ).pOnly(top: 24, left: 8),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Total: ${emiTotal().toStringAsFixed(2)}',
                                    style: AppStyles.text14Px.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<MembershipCubit, MembershipState>(
          buildWhen:
              (p, c) => p.createOrUpdatePackage != c.createOrUpdatePackage,
          builder: (context, state) {
            final isLoading = state.createOrUpdatePackage?.isNone() ?? false;
            return Button.filled(
              title: 'Save',
              isLoading: isLoading,
              buttonColor: AppColors.primary,
              ontap: () {
                final List<EmiOptionsModel> emiData;
                if (_isEmi) {
                  emiData =
                      _emiOptions
                          .where(
                            (e) =>
                                e.month.controller!.text.trim().isNotEmpty &&
                                e.price.controller!.text.trim().isNotEmpty,
                          )
                          .map(
                            (e) => EmiOptionsModel(
                              month: int.parse(e.month.controller!.text.trim()),
                              price: double.parse(
                                e.price.controller!.text.trim(),
                              ),
                            ),
                          )
                          .toList();
                } else {
                  emiData = [];
                }

                if (isLoading) {
                  return;
                }
                if (!_formKey.currentState!.validate()) {
                  Dialogs.showSnack(
                    msg: 'Please fill all required fields correctly.',
                  );
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
                if (_isEmi) {
                  for (final emi in _emiOptions) {
                    if (emi.month.controller!.text.trim().isEmpty ||
                        emi.price.controller!.text.trim().isEmpty) {
                      Dialogs.showSnack(
                        msg: 'All EMI month and price fields must be filled.',
                      );
                      return;
                    }
                  }
                }
                final membershipName =
                    _membershipNameField.controller!.text.trim();
                final actualPrice = _actualPriceField.controller!.text.trim();
                final offerPrice = _offerPriceField.controller!.text.trim();
                final packageType = _selectedPackageType!.label;
                if (_showOfferPrice) {
                  final actualPriceValue = double.tryParse(actualPrice);
                  final offerPriceValue = double.tryParse(offerPrice);
                  if (actualPriceValue != null &&
                      offerPriceValue != null &&
                      offerPriceValue >= actualPriceValue) {
                    Dialogs.showSnack(
                      msg: 'Offer price must be less than actual price.',
                    );
                    return;
                  }
                }
                _cubit.createOrUpdateMembershipPackage(
                  membershipId: widget.membershipPackage?.id,
                  packageType: packageType,
                  name: membershipName,
                  description: 'Package for $membershipName',
                  actualPrice: actualPrice,
                  offerPrice: offerPrice,
                  features: [],
                  isEmiAvailable: _isEmi,
                  emiOptions: emiData,
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

  double _emiTotalForOption(
    ({FieldData<String> month, FieldData<String> price}) emi,
  ) {
    final monthText = emi.month.controller?.text.trim() ?? '0';
    final priceText = emi.price.controller?.text.trim() ?? '0';
    final month = int.tryParse(monthText) ?? 0;
    final price = double.tryParse(priceText) ?? 0.0;
    return month * price;
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color ?? Colors.grey.withValues(alpha: 0.2),
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
