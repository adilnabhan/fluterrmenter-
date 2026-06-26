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
  late final FieldData<String> _daysField;
  late final FieldData<String> _packageTypeField;
  PackageType? _selectedPackageType;
  late final FieldData<dynamic> _actualPriceField;
  late final FieldData<dynamic> _offerPriceField;
  // Added description field
  late final FieldData<String> _descriptionField;
  late List<({FieldData<String> month, FieldData<String> price})> _emiOptions;
  bool _showOfferPrice = false;
  bool _isEmi = false;
  int _calculatedMonths = 0;

  // 🔹 Added variables for commission display
  double _razorpayCommissionPercent = 4.0;
  double _calculatedCommission = 0.0;
  double _creditedAmount = 0.0;
  String _commissionMessage = '';

  double _offerCalculatedCommission = 0.0;
  double _offerCreditedAmount = 0.0;
  String _offerCommissionMessage = '';

  /// 🧩 Helper: builds month FieldData with existing controller
  FieldData<String> _buildMonthFieldWithController(
    TextEditingController controller, {
    String label = 'Month',
  }) {
    return FieldData<String>(
      type: FieldType.radio,
      items: List.generate(
        _calculatedMonths > 0 ? _calculatedMonths : 12,
        (index) => (label: '${index + 1}', value: '${index + 1}'),
      ),
      textInputAction: TextInputAction.done,
      label: label,
      requiredLabel: true,
      controller: controller,
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
  }

  /// 🧩 Creates a blank EMI option with month & price fields
  ({FieldData<String> month, FieldData<String> price}) _createEmptyEmiOption() {
    final monthController = TextEditingController();
    final priceController = TextEditingController();

    void listener() {
      if (mounted) setState(() {});
    }

    monthController.addListener(listener);
    priceController.addListener(listener);

    final monthField = _buildMonthFieldWithController(monthController);

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

    _membershipNameField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      // label: 'Membership Name',
      label: 'Plan Name',
      requiredLabel: true,
      keyboardType: TextInputType.name,
      controller: TextEditingController(
        text: widget.membershipPackage?.name ?? '',
      ),
      validator:
          (value) => value?.isEmpty ?? true ? 'Plan Name is required!' : null,
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        // hintText: 'Enter membership name',
        hintText: 'Enter Plan Name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    _daysField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      // label: 'Duration Days',
      label: 'Duration in Days',
      requiredLabel: true,
      keyboardType: TextInputType.number,
      controller: TextEditingController(
        text: widget.membershipPackage?.durationDays.toString() ?? '',
      ),
      validator:
          (value) =>
              value?.isEmpty ?? true ? 'Duration in Days is required!' : null,
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        // hintText: 'Enter Duration Days',
        hintText: 'Enter Duration in Days',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    // 👇 Listen for days change → calculate months and update EMI options
    _daysField.controller!.addListener(() {
      final text = _daysField.controller?.text ?? '';
      final days = int.tryParse(text) ?? 0;
      final months = (days / 30).floor();

      if (mounted) {
        setState(() {
          _calculatedMonths = months > 0 ? months : 0;

          // rebuild month field for each EMI
          for (var i = 0; i < _emiOptions.length; i++) {
            final existing = _emiOptions[i];
            final existingMonthController = existing.month.controller!;
            final selected = existingMonthController.text;
            final selectedInt = int.tryParse(selected) ?? 0;
            if (_calculatedMonths > 0 && selectedInt > _calculatedMonths) {
              existingMonthController.text = '';
            }

            final newMonthField = _buildMonthFieldWithController(
              existingMonthController,
            );
            _emiOptions[i] = (month: newMonthField, price: existing.price);
          }
        });
      }
    });

    // ---------- Actual price field ----------------
    _actualPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      // label: 'Amount',
      label: 'Actual Price',
      requiredLabel: true,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: TextEditingController(
        // set initial text from package (if any)
        text: widget.membershipPackage?.actualPrice ?? '',
      ),
      validator:
          (value) =>
              value?.isEmpty ?? true ? 'Actual Price is required!' : null,
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        // hintText: 'Enter Amount',
        hintText: 'Enter Actual Price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    // 1) Attach listener to controller (calls helper below)
    _actualPriceField.controller!.addListener(_calculateCommission);

    // 2) Trigger calculation once after first frame so initial value is processed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCommission();
    });

    // ---------------- Offer price + EMI init below (unchanged) ----------------
    _offerPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Offer Price',
      // requiredLabel: true,
      requiredLabel: false,
      controller: TextEditingController(
        text: widget.membershipPackage?.offerPrice ?? '',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // validator:
      //    (value) => value?.isEmpty ?? true ? 'Offer price is required' : null,
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        // hintText: 'Enter offer price',
        hintText: 'Enter Offer Price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    _offerPriceField.controller!.addListener(_calculateOfferCommission);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateOfferCommission();
    });

    // Initializing description field
    _descriptionField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Description / Inclusions',
      requiredLabel: false,
      controller: TextEditingController(
        text: widget.membershipPackage?.description ?? '',
      ),
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Description',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );

    _showOfferPrice = widget.membershipPackage?.offerPrice?.isNotEmpty ?? false;

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

        // 🔥 FIX: Add listeners so UI updates when editing
        monthController.addListener(() {
          if (mounted) setState(() {});
        });
        priceController.addListener(() {
          if (mounted) setState(() {});
        });

        final monthField = _buildMonthFieldWithController(monthController);

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
          validator:
              (value) => value?.isEmpty ?? true ? 'Price is required!' : null,
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
    }
  }

  /// Helper that computes commission & credited amount and updates message
  void _calculateCommission() {
    final text = _actualPriceField.controller?.text.trim() ?? '';
    final amount = double.tryParse(text) ?? 0.0;

    if (!mounted) return;

    setState(() {
      _calculatedCommission = amount * (_razorpayCommissionPercent / 100);
      _creditedAmount = amount - _calculatedCommission;

      _commissionMessage =
          amount > 0
              ? 'After $_razorpayCommissionPercent% payment gateway charges (₹${_calculatedCommission.toStringAsFixed(2)}), '
                  '₹${_creditedAmount.toStringAsFixed(2)} will be credited to your account.'
              : '';
    });
  }

  void _calculateOfferCommission() {
    final text = _offerPriceField.controller?.text.trim() ?? '';
    final amount = double.tryParse(text) ?? 0.0;

    if (!mounted) return;

    setState(() {
      _offerCalculatedCommission = amount * (_razorpayCommissionPercent / 100);
      _offerCreditedAmount = amount - _offerCalculatedCommission;

      _offerCommissionMessage =
          amount > 0
              ? 'After $_razorpayCommissionPercent% payment gateway charges '
                  '(₹${_offerCalculatedCommission.toStringAsFixed(2)}), '
                  '₹${_offerCreditedAmount.toStringAsFixed(2)} will be credited to your account.'
              : '';
    });
  }

  @override
  void dispose() {
    // Remove listener before disposing to avoid memory leaks
    try {
      _actualPriceField.controller?.removeListener(_calculateCommission);
      _offerPriceField.controller?.removeListener(_calculateOfferCommission);
    } catch (_) {}

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
    return BlocListener<MembershipCubit, MembershipState>(
      bloc: _cubit,
      listenWhen: (p, c) => p.createOrUpdatePackage != c.createOrUpdatePackage,
      listener: (context, state) {
        state.createOrUpdatePackage?.fold(
          () {},
          (either) => either.fold(
            (error) => Dialogs.showSnack(msg: error.msg),
            (success) {
              Dialogs.showSnack(msg: 'Package added successfully');
              context.pop();
            },
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text(
            '${widget.membershipPackage == null ? 'Add' : 'Edit'} Package',
            style: AppStyles.text16Px.poppins.w500,
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // _ShadowCard(
              //   child: Column(
              //     spacing: 16,
              //     children: [
              //       Field(data: _membershipNameField),
              //       Field(data: _daysField),
              //     ],
              //   ),
              // ),
              // const _Divider(),
              // _ShadowCard(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Field(data: _actualPriceField),
              //       if (_commissionMessage.isNotEmpty) ...[
              //         const SizedBox(height: 8),
              //         Text(
              //           _commissionMessage,
              //           style: AppStyles.text13Px.poppins.w400.copyWith(
              //             color: AppColors.error,
              //           ),
              //         ),
              //       ],
              //     ],
              //   ),
              // ),
              // const _Divider(),
              // _ShadowCard(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Subscription', style: AppStyles.text15Px.w600.dark),
              //       const SizedBox(height: 28),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             'Monthly EMI',
              //             style: AppStyles.text14Px.poppins.w500.dark,
              //           ),
              //           Switch(
              //             value: _isEmi,
              //             activeColor: AppColors.primary,
              //             onChanged: (value) {
              //               setState(() {
              //                 _isEmi = value;
              //                 if (!_isEmi) {
              //                   for (final emi in _emiOptions) {
              //                     emi.month.controller?.dispose();
              //                     emi.price.controller?.dispose();
              //                   }
              //                   _emiOptions.clear();
              //                 } else if (_emiOptions.isEmpty) {
              //                   _emiOptions.add(_createEmptyEmiOption());
              //                 }
              //               });
              //             },
              //           ),
              //         ],
              //       ),
              //       if (_isEmi)
              //         ..._emiOptions.asMap().entries.map((entry) {
              //           final i = entry.key;
              //           final emi = entry.value;
              //           final isLast = i == _emiOptions.length - 1;
              //           final showAdd =
              //               isLast &&
              //               emi.month.controller!.text.isNotEmpty &&
              //               emi.price.controller!.text.isNotEmpty;
              //           final total = _emiTotalForOption(emi);
              //           return Padding(
              //             padding: const EdgeInsets.only(top: 16),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.end,
              //               children: [
              //                 Row(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Expanded(child: Field(data: emi.month)),
              //                     const SizedBox(width: 16),
              //                     Expanded(child: Field(data: emi.price)),
              //                     if (isLast == true)
              //                       IconButton.filled(
              //                         style: IconButton.styleFrom(
              //                           backgroundColor: AppColors.lightPrimary,
              //                           foregroundColor: Colors.red,
              //                           shape: const CircleBorder(),
              //                         ),
              //                         icon: const Icon(
              //                           Icons.close,
              //                           color: Colors.red,
              //                         ),
              //                         onPressed: () {
              //                           setState(() {
              //                             emi.month.controller?.dispose();
              //                             emi.price.controller?.dispose();
              //                             _emiOptions.removeAt(i);
              //                             if (_emiOptions.isEmpty) {
              //                               _isEmi = false;
              //                             }
              //                           });
              //                         },
              //                       ).pOnly(top: 24, left: 8)
              //                     else
              //                       SizedBox(),
              //                     if (showAdd)
              //                       IconButton.filled(
              //                         style: IconButton.styleFrom(
              //                           backgroundColor: Colors.green,
              //                           foregroundColor: Colors.white,
              //                           shape: const CircleBorder(),
              //                         ),
              //                         icon: const Icon(Icons.add),
              //                         onPressed: () {
              //                           setState(() {
              //                             _emiOptions.add(
              //                               _createEmptyEmiOption(),
              //                             );
              //                           });
              //                         },
              //                       ).pOnly(top: 24, left: 8),
              //                   ],
              //                 ),
              //                 if (emi.price.controller!.text.isNotEmpty)
              //                   Text(
              //                     _emiCommissionMessage(
              //                       emi.price.controller!.text,
              //                     ),
              //                     style: AppStyles.text13Px.poppins.w400
              //                         .copyWith(color: AppColors.error),
              //                   ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(top: 5),
              //                   child: Text(
              //                     'Total: ${total.toStringAsFixed(2)}',
              //                     style: AppStyles.text14Px.w600,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           );
              //         }),
              //     ],
              //   ),
              //   color: Colors.transparent,
              // ),

              // New Layout matching the image
              Field(data: _membershipNameField),
              const SizedBox(height: 16),
              Field(data: _daysField),
              const SizedBox(height: 16),
              Field(data: _actualPriceField),
              if (_commissionMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _commissionMessage,
                  style: AppStyles.text13Px.poppins.w500.copyWith(
                    fontSize: 10,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Field(data: _offerPriceField),
              if (_offerCommissionMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _offerCommissionMessage,
                  style: AppStyles.text13Px.poppins.w500.copyWith(
                    fontSize: 10,
                    color: AppColors.error,
                  ),
                ),
              ],
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
                    activeColor: AppColors.error, // Red color from image
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
              if (_isEmi)
                ..._emiOptions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final emi = entry.value;
                  final total = _emiTotalForOption(emi);
                  final isLast = i == _emiOptions.length - 1;
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

                            /// ❌ Close button only for last item
                            if (isLast)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (_emiOptions.isNotEmpty) {
                                        final lastEmi =
                                            _emiOptions.removeLast();

                                        /// Dispose controllers
                                        lastEmi.month.controller?.dispose();
                                        lastEmi.price.controller?.dispose();
                                      }

                                      /// If no EMI left → auto switch OFF
                                      if (_emiOptions.isEmpty) {
                                        _isEmi = false;
                                      }
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        if (emi.price.controller!.text.isNotEmpty)
                          Text(
                            _emiCommissionMessage(emi.price.controller!.text),
                            style: AppStyles.text13Px.poppins.w500.copyWith(
                              fontSize: 10,
                              color: AppColors.error,
                            ),
                          ),

                        if (emi.price.controller!.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Total Amount = ${total.toStringAsFixed(2)}',
                              style: AppStyles.text13Px.w600.copyWith(
                                fontSize: 10,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );

                  //   Padding(
                  //   padding: const EdgeInsets.only(top: 16),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Expanded(child: Field(data: emi.month)),
                  //           const SizedBox(width: 16),
                  //           Expanded(child: Field(data: emi.price)),
                  //         ],
                  //       ),
                  //       if (emi.price.controller!.text.isNotEmpty)
                  //         Text(
                  //           _emiCommissionMessage(emi.price.controller!.text),
                  //           style: AppStyles.text13Px.poppins.w500.copyWith(
                  //             fontSize: 10,
                  //             color: AppColors.error,
                  //           ),
                  //         ),
                  //       if (emi.price.controller!.text.isNotEmpty)
                  //         Padding(
                  //           padding: const EdgeInsets.only(top: 5),
                  //           child: Text(
                  //             'Total Amount= ${total.toStringAsFixed(2)}',
                  //             style: AppStyles.text13Px.w600.copyWith(
                  //               fontSize: 10,
                  //               color: AppColors.error,
                  //             ),
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  // );
                }),
              if (_isEmi)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _emiOptions.add(_createEmptyEmiOption());
                      });
                    },
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: Text(
                      'Add More',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
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
              buttonColor: AppColors.primary, // Red color from image
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

                if (!_formKey.currentState!.validate()) {
                  Dialogs.showSnack(
                    msg: 'Please fill all required fields correctly.',
                  );
                  return;
                }

                _cubit.createOrUpdateMembershipPackage(
                  membershipId: widget.membershipPackage?.id,
                  packageType: _daysField.controller!.text.trim(),
                  name: _membershipNameField.controller!.text.trim(),
                  // description:
                  //    'Package for ${_membershipNameField.controller!.text.trim()}',
                  description: _descriptionField.controller!.text.trim(),
                  actualPrice: _actualPriceField.controller!.text.trim(),
                  offerPrice: _offerPriceField.controller!.text.trim(),
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

String _emiCommissionMessage(String priceText) {
  final price = double.tryParse(priceText.trim()) ?? 0.0;

  if (price <= 0) return '';

  final commission = price * (4.0 / 100);
  final credited = price - commission;

  return 'After ${4.0}% payment gateway charges '
      '(₹${commission.toStringAsFixed(2)}), '
      '₹${credited.toStringAsFixed(2)} will be credited to your account.';
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(color: Color(0xffF7F7F7), height: 12, thickness: 1);
}

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
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
