import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/member_orboard_payment_successfull_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AddCustomerSearchScreen extends StatefulWidget {
  final int orgId;
  const AddCustomerSearchScreen({super.key, required this.orgId});

  @override
  State<AddCustomerSearchScreen> createState() =>
      _AddCustomerSearchScreenState();
}

class _AddCustomerSearchScreenState extends State<AddCustomerSearchScreen> {
  late MembersAndLeadsCubit _cubit;
  late MembershipCubit _membershipCubit;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(
    text: '0',
  );

  Timer? _debounce;
  MembershipPackageModel? _selectedPlan;
  bool _isPlanDropdownOpen = false;
  DateTime _startDate = DateTime.now();
  MemberDetailsModel? _manualMemberDetails;

  /// Split payment entries
  final List<_PaymentSplit> _paymentSplits = [];

  final List<String> _allPaymentMethods = [
    'Cash',
    'UPI',
    'Debit Card',
    'Credit Card',
    'Net Banking',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _membershipCubit = context.read<MembershipCubit>();
    _membershipCubit.fetchMembershipPackages();
    _cubit.clearSearchedCustomer();
    _discountController.addListener(_onDiscountChanged);
  }

  @override
  void dispose() {
    _discountController.removeListener(_onDiscountChanged);
    _searchController.dispose();
    _discountController.dispose();
    for (final split in _paymentSplits) {
      split.amountController.dispose();
      split.referenceController.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  void _onDiscountChanged() {
    setState(_syncPaymentSplitsWithTotalPayable);
  }

  String _formatAmount(double amount) {
    if (amount <= 0) return '0';
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  double _calculateRemainingForCash() {
    double otherMethodsTotal = 0;
    for (final split in _paymentSplits) {
      if (split.method != 'Cash') {
        otherMethodsTotal +=
            double.tryParse(split.amountController.text.trim()) ?? 0;
      }
    }
    return (_totalPayable - otherMethodsTotal).clamp(0.0, double.infinity);
  }

  void _autoAdjustCashAmount() {
    final cashIndex = _paymentSplits.indexWhere((s) => s.method == 'Cash');
    if (cashIndex == -1) return;

    final remainingCash = _calculateRemainingForCash();
    final newCashText = _formatAmount(remainingCash);

    if (_paymentSplits[cashIndex].amountController.text != newCashText) {
      _paymentSplits[cashIndex].amountController.text = newCashText;
    }
  }

  void _syncPaymentSplitsWithTotalPayable() {
    if (_totalPayable <= 0 && _selectedPlan == null) return;

    final cashIndex = _paymentSplits.indexWhere((s) => s.method == 'Cash');
    if (cashIndex == -1) {
      if (_paymentSplits.isEmpty && _totalPayable > 0) {
        final cashSplit = _PaymentSplit(method: 'Cash');
        cashSplit.amountController.text = _formatAmount(_totalPayable);
        _paymentSplits.add(cashSplit);
      }
    } else {
      _autoAdjustCashAmount();
    }
  }

  double get _planAmount {
    if (_selectedPlan == null) return 0;
    return double.tryParse(
          _selectedPlan?.actualPrice ?? '0',
        ) ??
        0;
  }

  double get _discount =>
      double.tryParse(_discountController.text.trim()) ?? 0;

  double get _totalPayable => (_planAmount - _discount).clamp(0.0, double.infinity);

  double get _totalPaid {
    double sum = 0;
    for (final split in _paymentSplits) {
      sum += double.tryParse(split.amountController.text.trim()) ?? 0;
    }
    return sum;
  }

  double get _pendingDue => (_totalPayable - _totalPaid).clamp(0.0, double.infinity);

  List<String> get _availableMethods {
    final usedMethods = _paymentSplits.map((s) => s.method).toSet();
    return _allPaymentMethods.where((m) => !usedMethods.contains(m)).toList();
  }

  void _addPaymentSplit(String method) {
    setState(() {
      final split = _PaymentSplit(method: method);
      if (method == 'Cash') {
        final remaining = _calculateRemainingForCash();
        if (remaining > 0) {
          split.amountController.text = _formatAmount(remaining);
        }
      }
      _paymentSplits.add(split);
    });
  }

  void _removePaymentSplit(int index) {
    setState(() {
      _paymentSplits[index].amountController.dispose();
      _paymentSplits[index].referenceController.dispose();
      _paymentSplits.removeAt(index);
      _autoAdjustCashAmount();
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 10) {
        // Assume at least 10 digits for a valid number search
        _cubit.searchCustomerByNumber(value.trim());
      } else {
        _cubit.clearSearchedCustomer();
      }
    });
  }

  void _submit() {
    if (_cubit.state.createOrUpdateMember?.isNone() ?? false) {
      Dialogs.showSnack(msg: 'Please wait');
      return;
    }

    // Determine the customer to add
    MemberDetailsModel? customerToAdd;
    if (_manualMemberDetails != null) {
      customerToAdd = _manualMemberDetails;
    } else {
      final searchResult = _cubit.state.searchedCustomer;
      searchResult?.fold(
        () {},
        (either) => either.fold((l) {}, (r) => customerToAdd = r),
      );
    }

    if (customerToAdd == null) {
      Dialogs.showSnack(
        msg: 'Please search for a client or enter details manually.',
      );
      return;
    }

    if (_selectedPlan == null) {
      Dialogs.showSnack(msg: 'Please select a membership plan.');
      return;
    }

    double? discount = double.tryParse(_discountController.text);

    // Build payments list from splits (excluding 0 amount splits)
    final payments = _paymentSplits
        .where((s) => (double.tryParse(s.amountController.text.trim()) ?? 0) > 0)
        .map((s) {
          final map = <String, dynamic>{
            'payment_method': s.method,
            'amount': double.tryParse(s.amountController.text.trim()) ?? 0,
          };
          final ref = s.referenceController.text.trim();
          if (ref.isNotEmpty) {
            map['reference'] = ref;
          }
          return map;
        })
        .toList();

    _cubit.cerateOrUpdateMemberDetails(
      memeberDetails: customerToAdd!,
      membershipPackageModel: _selectedPlan!,
      discountAmount: discount,
      payments: payments,
      membershipStartDate: DateFormat('yyyy-MM-dd').format(_startDate),
      memberId: customerToAdd!.id, // Will be null if it's a new manual user
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Widget _buildProfileCard(MemberDetailsModel customer) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileImage(url: customer.profilePicture, radius: 30, isEdit: false),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (customer.fullName?.isNotEmpty ?? false)
                      ? customer.fullName!
                      : '${customer.firstName ?? ''} ${customer.lastName ?? ''}'
                          .trim()
                          .isEmpty
                      ? 'Unknown'
                      : '${customer.firstName ?? ''} ${customer.lastName ?? ''}'
                          .trim(),
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                Text(
                  customer.mobileNumber ?? '',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (customer.gender != null &&
                        customer.gender!.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          customer.gender!.trim()[0].toUpperCase() +
                              customer.gender!.trim().substring(1),
                          style: AppStyles.text12Px.poppins.w500.textGrey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _fieldInputDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: const Text('Add Client'),
      ),
      body: BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
        listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
        listener: (context, state) {
          state.createOrUpdateMember?.fold(() => null, (t) {
            return t.fold(
              (l) {
                Dialogs.showSnack(msg: l.msg);
              },
              (r) {
                Dialogs.showSnack(msg: 'Member added successfully');
                final methodsStr = _paymentSplits
                    .map((s) => s.method)
                    .where((m) => m.isNotEmpty)
                    .join(', ');
                context.pushReplacement(
                  BlocProvider.value(
                    value: _cubit,
                    child: MemberOnboardPaymentSuccessScreen(
                      memberDetails: r,
                      planName: _selectedPlan?.name,
                      planAmount: _planAmount,
                      discount: _discount,
                      amountPaid: _totalPaid,
                      pendingDue: _pendingDue,
                      startDate: _startDate,
                      endDate: _selectedPlan?.durationDays != null
                          ? _startDate.add(
                              Duration(days: _selectedPlan!.durationDays!),
                            )
                          : null,
                      paymentMethod:
                          methodsStr.isNotEmpty ? methodsStr : null,
                    ),
                  ),
                );
              },
            );
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fill details',
                style: AppStyles.text20Px.poppins.w600.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              if (_manualMemberDetails == null) ...[
                Text(
                  'Search Client by number',
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFieldCard(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    keyboardType: TextInputType.phone,
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                    decoration: _fieldInputDecoration(
                      hintText: 'Search Client',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Icon(
                          Icons.search,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Client doesn't have Discipl app? ",
                      style: AppStyles.text12Px.poppins.w400.textGrey,
                    ),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BlocProvider.value(
                                  value: _cubit,
                                  child: AddOrEditMemeberScreen(
                                    orgId: widget.orgId,
                                    isFromSearch: true,
                                  ),
                                ),
                          ),
                        );
                        if (result != null && result is MemberDetailsModel) {
                          setState(() {
                            _manualMemberDetails = result;
                          });
                        }
                      },
                      child: Text(
                        'Click here',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                  buildWhen: (p, c) => p.searchedCustomer != c.searchedCustomer,
                  builder: (context, state) {
                    return state.searchedCustomer?.fold(
                          () => const SizedBox.shrink(),
                          (either) => either.fold(
                            (l) => Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'This number is not registered in customer app',
                                      style: AppStyles.text12Px.poppins.w500
                                          .copyWith(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 32,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final number =
                                            _searchController.text.trim();
                                        final message = Uri.encodeComponent(
                                          "Hi! Please download the Discipl Customer app to proceed.",
                                        );
                                        try {
                                          await launchUrl(
                                            Uri.parse(
                                              'https://wa.me/$number?text=$message',
                                            ),
                                            mode: LaunchMode.externalApplication,
                                          );
                                        } catch (_) {
                                          Dialogs.showSnack(
                                            msg: 'Could not open WhatsApp.',
                                          );
                                        }
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/images/svg/icons/whatsapp.svg',
                                        height: 16,
                                        width: 16,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF25D366),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: Text(
                                        'Invite',
                                        style: AppStyles.text12Px.poppins.w600
                                            .copyWith(
                                              color: const Color(0xFF25D366),
                                            ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Color(0xFF25D366),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            (customer) => _buildProfileCard(customer),
                          ),
                        ) ??
                        const SizedBox.shrink();
                  },
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manual Entry Mode',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _manualMemberDetails = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                _buildProfileCard(_manualMemberDetails!),
              ],

              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Select Plan',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlocBuilder<MembershipCubit, MembershipState>(
                bloc: _membershipCubit,
                buildWhen:
                    (p, c) => p.membershipPackages != c.membershipPackages,
                builder: (context, state) {
                  return state.membershipPackages.fold(
                    () => const CircularProgressIndicator(),
                    (either) => either.fold(
                      (l) => const Text('Error loading plans'),
                      (data) {
                        final plans = data.results ?? [];
                        return _buildPlanSelector(plans);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // Plan Amount & Discount Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Amount',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xffD0D5DD)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '₹',
                                style: AppStyles.text14Px.poppins.w500.textGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _planAmount > 0
                                    ? (_planAmount == _planAmount.toInt()
                                        ? _planAmount.toInt().toString()
                                        : _planAmount.toStringAsFixed(2))
                                    : '0',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discount',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFieldCard(
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: Colors.black87,
                            ),
                            decoration: _fieldInputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 6,
                                ),
                                child: Text(
                                  '₹',
                                  style: AppStyles.text14Px.poppins.w500.textGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Total Payable
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      '₹ ${_totalPayable == _totalPayable.toInt() ? _totalPayable.toInt().toString() : _totalPayable.toStringAsFixed(2)}',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              // Payment Breakdown Header
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Payment Breakdown',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      if (_paymentSplits.length > 1) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Split',
                            style: AppStyles.text10Px.poppins.w600.copyWith(
                              color: const Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_availableMethods.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _addPaymentSplit(_availableMethods.first);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add Method',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Payment Split Cards
              if (_paymentSplits.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No payment added',
                        style: AppStyles.text13Px.poppins.w500.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitting without payment creates an unpaid membership',
                        textAlign: TextAlign.center,
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(_paymentSplits.length, (index) {
                  final split = _paymentSplits[index];
                  final style = _getPaymentMethodStyle(split.method, true);
                  final needsRef = split.method == 'UPI' ||
                      split.method == 'Net Banking' ||
                      split.method == 'Debit Card' ||
                      split.method == 'Credit Card';
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: index < _paymentSplits.length - 1 ? 12 : 0,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: style.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Method pill + Split label + Delete
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: style.bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                split.method,
                                style:
                                    AppStyles.text12Px.poppins.w600.copyWith(
                                      color: style.textColor,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Split ${index + 1}',
                              style:
                                  AppStyles.text12Px.poppins.w400.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => _removePaymentSplit(index),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Amount field
                        TextField(
                          controller: split.amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {
                            if (split.method != 'Cash') {
                              _autoAdjustCashAmount();
                            }
                            setState(() {});
                          },
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                          decoration: _fieldInputDecoration(
                            hintText: 'Amount',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 6,
                              ),
                              child: Text(
                                '₹',
                                style:
                                    AppStyles.text14Px.poppins.w500.textGrey,
                              ),
                            ),
                          ),
                        ),
                        // Reference field (conditional)
                        if (needsRef) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: split.referenceController,
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: Colors.black87,
                            ),
                            decoration: _fieldInputDecoration(
                              hintText: '${split.method} Reference (optional)',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(
                                  left: 14,
                                  right: 8,
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  color: AppColors.textGrey,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

              // Available method chips to add
              if (_paymentSplits.isNotEmpty && _availableMethods.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableMethods.map((method) {
                    final style = _getPaymentMethodStyle(method, false);
                    return InkWell(
                      onTap: () => _addPaymentSplit(method),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: style.bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: style.borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: style.textColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              method,
                              style:
                                  AppStyles.text12Px.poppins.w500.copyWith(
                                    color: style.textColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Summary Banner
              if (_paymentSplits.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Paid',
                            style: AppStyles.text13Px.poppins.w500.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '₹ ${_totalPaid == _totalPaid.toInt() ? _totalPaid.toInt().toString() : _totalPaid.toStringAsFixed(2)}',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending Due',
                            style: AppStyles.text13Px.poppins.w500.copyWith(
                              color: _pendingDue > 0
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF43A047),
                            ),
                          ),
                          Text(
                            '₹ ${_pendingDue == _pendingDue.toInt() ? _pendingDue.toInt().toString() : _pendingDue.toStringAsFixed(2)}',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: _pendingDue > 0
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF43A047),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Start Date',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffD0D5DD)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.black87,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen:
                    (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
                builder: (context, state) {
                  return Button.filled(
                    size: Size(double.maxFinite, 42.h),
                    title: 'Add Member',
                    isLoading: state.createOrUpdateMember?.isNone() ?? false,
                    buttonColor: AppColors.primary,
                    ontap: _submit,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelector(List<MembershipPackageModel> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isPlanDropdownOpen = !_isPlanDropdownOpen;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffD0D5DD)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedPlan?.name ?? 'Select Plan',
                    style: _selectedPlan != null
                        ? AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          )
                        : AppStyles.text14Px.poppins.w400.textGrey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isPlanDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),
        if (_isPlanDropdownOpen) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffD0D5DD)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: plans.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Color(0xffEEEEEE),
                ),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = _selectedPlan?.id == plan.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan;
                        _isPlanDropdownOpen = false;

                        // Auto-fill discount if offer price exists
                        final actual = double.tryParse(plan.actualPrice ?? '') ?? 0;
                        final offer = double.tryParse(plan.offerPrice ?? '') ?? 0;
                        if (offer > 0 && actual > offer) {
                          final discount = actual - offer;
                          _discountController.text = discount == discount.toInt()
                              ? discount.toInt().toString()
                              : discount.toStringAsFixed(2);
                        } else {
                          _discountController.text = '0';
                        }

                        _syncPaymentSplitsWithTotalPayable();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name ?? '',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  ({Color bgColor, Color borderColor, Color iconColor, Color textColor})
  _getPaymentMethodStyle(String method, bool isSelected) {
    switch (method) {
      case 'Cash':
        return (
          bgColor: const Color(0xFFE8F8EE),
          borderColor:
              isSelected ? const Color(0xFF27AE60) : const Color(0xFFD5F5E3),
          iconColor:
              isSelected ? const Color(0xFF27AE60) : Colors.grey.shade600,
          textColor: const Color(0xFF1E8449),
        );
      case 'UPI':
        return (
          bgColor: const Color(0xFFEBF5FB),
          borderColor:
              isSelected ? const Color(0xFF2980B9) : const Color(0xFFD4EFDF),
          iconColor:
              isSelected ? const Color(0xFF2980B9) : Colors.grey.shade600,
          textColor: const Color(0xFF2471A3),
        );
      case 'Debit Card':
        return (
          bgColor: const Color(0xFFFEF9E7),
          borderColor:
              isSelected ? const Color(0xFFF39C12) : const Color(0xFFFCF3CF),
          iconColor:
              isSelected ? const Color(0xFFF39C12) : Colors.grey.shade600,
          textColor: const Color(0xFFB7950B),
        );
      case 'Credit Card':
        return (
          bgColor: const Color(0xFFF5EEF8),
          borderColor:
              isSelected ? const Color(0xFF8E44AD) : const Color(0xFFE8DAEF),
          iconColor:
              isSelected ? const Color(0xFF8E44AD) : Colors.grey.shade600,
          textColor: const Color(0xFF7D3C98),
        );
      case 'Net Banking':
        return (
          bgColor: const Color(0xFFE8F8F5),
          borderColor:
              isSelected ? const Color(0xFF16A085) : const Color(0xFFA3E4D7),
          iconColor:
              isSelected ? const Color(0xFF16A085) : Colors.grey.shade600,
          textColor: const Color(0xFF117A65),
        );
      default:
        return (
          bgColor: const Color(0xFFF5F5F5),
          borderColor:
              isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
          iconColor: isSelected ? AppColors.primary : Colors.grey.shade600,
          textColor: AppColors.dark,
        );
    }
  }
}

/// Helper class to hold state for each payment split entry.
class _PaymentSplit {
  _PaymentSplit({required this.method});

  final String method;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
}
