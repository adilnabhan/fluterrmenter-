import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class RenewMembershipScreen extends StatefulWidget {
  const RenewMembershipScreen({
    required this.orgId,
    required this.memberId,
    required this.memberName,
    super.key,
    this.memberDetails,
    this.onRenewed,
    this.isAddNew = false,
    this.initialPlanId,
    this.initialStartDate,
  });

  final int orgId;
  final int memberId;
  final String memberName;
  final MemberDetailsModel? memberDetails;
  final VoidCallback? onRenewed;
  final bool isAddNew;
  final int? initialPlanId;
  final DateTime? initialStartDate;

  @override
  State<RenewMembershipScreen> createState() => _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends State<RenewMembershipScreen> {
  List<MembershipPackageModel> _packages = [];
  bool _isLoadingPackages = false;
  MembershipPackageModel? _selectedPlan;
  bool _isPlanDropdownOpen = false;

  final TextEditingController _discountController = TextEditingController(
    text: '0',
  );

  late DateTime _startDate;
  bool _isSubmitting = false;

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
    _startDate = widget.initialStartDate ?? DateTime.now();
    _fetchPackages();
    _discountController.addListener(_onDiscountChanged);
  }

  @override
  void dispose() {
    _discountController.removeListener(_onDiscountChanged);
    _discountController.dispose();
    for (final split in _paymentSplits) {
      split.amountController.dispose();
      split.referenceController.dispose();
    }
    super.dispose();
  }

  void _onDiscountChanged() {
    setState(() {});
  }

  double get _planAmount {
    if (_selectedPlan == null) return 0;
    return double.tryParse(
          _selectedPlan?.offerPrice ?? _selectedPlan?.actualPrice ?? '0',
        ) ??
        0;
  }

  double get _discount =>
      double.tryParse(_discountController.text.trim()) ?? 0;

  double get _totalPayable =>
      (_planAmount - _discount).clamp(0.0, double.infinity);

  double get _totalPaid {
    double sum = 0;
    for (final split in _paymentSplits) {
      sum += double.tryParse(split.amountController.text.trim()) ?? 0;
    }
    return sum;
  }

  double get _pendingDue =>
      (_totalPayable - _totalPaid).clamp(0.0, double.infinity);

  List<String> get _availableMethods {
    final usedMethods = _paymentSplits.map((s) => s.method).toSet();
    return _allPaymentMethods.where((m) => !usedMethods.contains(m)).toList();
  }

  void _addPaymentSplit(String method) {
    setState(() {
      final split = _PaymentSplit(method: method);
      // Prepopulate remaining due amount into the split if applicable
      final remaining = _pendingDue;
      if (remaining > 0) {
        split.amountController.text =
            remaining == remaining.toInt()
                ? remaining.toInt().toString()
                : remaining.toStringAsFixed(2);
      }
      _paymentSplits.add(split);
    });
  }

  void _removePaymentSplit(int index) {
    setState(() {
      _paymentSplits[index].amountController.dispose();
      _paymentSplits[index].referenceController.dispose();
      _paymentSplits.removeAt(index);
    });
  }

  Future<void> _fetchPackages() async {
    if (!mounted) return;
    setState(() => _isLoadingPackages = true);
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.listMembershipPackages,
        queryParameters: {'organization_id': widget.orgId},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data;
        if (response.data is Map) {
          data = List<dynamic>.from(
            (response.data as Map)['results'] as List? ?? [],
          );
        } else {
          data = response.data as List<dynamic>;
        }

        final parsed =
            data
                .map(
                  (e) => MembershipPackageModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();

        MembershipPackageModel? initialMatch;
        if (widget.initialPlanId != null) {
          for (final plan in parsed) {
            if (plan.id == widget.initialPlanId) {
              initialMatch = plan;
              break;
            }
          }
        }

        if (mounted) {
          setState(() {
            _packages = parsed;
            if (initialMatch != null) {
              _selectedPlan = initialMatch;
            }
            _isLoadingPackages = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingPackages = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPackages = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedPlan == null) {
      unawaited(Dialogs.showSnack(msg: 'Please select a membership plan'));
      return;
    }

    final expiryDays = _selectedPlan?.durationDays ?? 30;

    // Build payments list from splits
    final payments =
        _paymentSplits
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
            .where((p) => (p['amount'] as num) > 0)
            .toList();

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'customer_id': widget.memberId,
        'membership_plan_id': _selectedPlan!.id,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'expiry_days': expiryDays,
        'discount': _discount,
        'payments': payments,
        // Backward-compatible fallback fields
        'amount': _totalPaid,
        'payment_method':
            _paymentSplits.isNotEmpty ? _paymentSplits.first.method : 'Cash',
      };

      Response<dynamic>? response;
      try {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.renewMembership,
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.manualMembershipEntry,
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        unawaited(
          Dialogs.showSnack(
            msg:
                widget.isAddNew
                    ? 'New membership activated successfully'
                    : 'Membership renewed successfully',
          ),
        );
        widget.onRenewed?.call();
        if (mounted) {
          final methodsStr =
              _paymentSplits
                  .map((s) => s.method)
                  .where((m) => m.isNotEmpty)
                  .join(', ');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => MemberOnboardPaymentSuccessScreen(
                    memberDetails: widget.memberDetails,
                    clientName: widget.memberName,
                    clientPhone: widget.memberDetails?.mobileNumber,
                    planName: _selectedPlan?.name,
                    planAmount: _planAmount,
                    discount: _discount,
                    amountPaid: _totalPaid,
                    pendingDue: _pendingDue,
                    startDate: _startDate,
                    endDate:
                        _selectedPlan?.durationDays != null
                            ? _startDate.add(
                              Duration(days: _selectedPlan!.durationDays!),
                            )
                            : null,
                    paymentMethod: methodsStr.isNotEmpty ? methodsStr : null,
                    isRenewal: !widget.isAddNew,
                    title:
                        widget.isAddNew
                            ? 'New Membership Added Successfully!'
                            : null,
                    subtitle:
                        widget.isAddNew
                            ? 'Membership has been activated for ${widget.memberName}'
                            : null,
                    onDone: () {
                      widget.onRenewed?.call();
                      Navigator.pop(context);
                    },
                  ),
            ),
          );
        }
      } else {
        if (mounted) setState(() => _isSubmitting = false);
        unawaited(Dialogs.showSnack(msg: 'Failed to renew membership'));
      }
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      unawaited(Dialogs.showSnack(msg: 'Error renewing membership: $e'));
    }
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

  Widget _buildFieldCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
      prefixIconConstraints: const BoxConstraints(),
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

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileImage(
            url: widget.memberDetails?.profilePicture,
            radius: 28,
            isEdit: false,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memberName.isNotEmpty
                      ? widget.memberName
                      : 'Client Details',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.isAddNew
                      ? 'Assign an additional active plan'
                      : (widget.memberDetails?.mobileNumber?.isNotEmpty ?? false)
                          ? widget.memberDetails!.mobileNumber!
                          : 'Renew / extend membership',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
              ],
            ),
          ),
        ],
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
                  color: Colors.black.withValues(alpha: 0.04),
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
                    style:
                        _selectedPlan != null
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
                  color: Colors.black.withValues(alpha: 0.08),
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
                separatorBuilder:
                    (context, index) =>
                        const Divider(height: 1, color: Color(0xffEEEEEE)),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = _selectedPlan?.id == plan.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan;
                        _isPlanDropdownOpen = false;
                        // Auto-fill first payment split amount to match total payable if only 1 split
                        if (_paymentSplits.length == 1) {
                          final due = _totalPayable;
                          _paymentSplits[0].amountController.text =
                              due == due.toInt()
                                  ? due.toInt().toString()
                                  : due.toStringAsFixed(2);
                        }
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
                            '${plan.name ?? ''} (₹${plan.actualPrice})',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color:
                                  isSelected
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text(
          widget.isAddNew ? 'Add Membership Plan' : 'Renew Membership',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),

            Text(
              'Fill details',
              style: AppStyles.text20Px.poppins.w600.copyWith(
                color: Colors.black87,
              ),
            ),
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
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingPackages)
              const Center(child: CircularProgressIndicator()).pad(16)
            else if (_packages.isEmpty)
              Text(
                'No membership plans found',
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ).pad(8)
            else
              _buildPlanSelector(_packages),

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
                      _buildFieldCard(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text:
                                _planAmount == _planAmount.toInt()
                                    ? _planAmount.toInt().toString()
                                    : _planAmount.toStringAsFixed(2),
                          ),
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black54,
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
                          onChanged: (_) => setState(() {}),
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
            const SizedBox(height: 16),

            // Total Payable Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB8E8CA)),
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
                          const Icon(
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
                  border: Border.all(color: const Color(0xFFE0E0E0)),
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
                final needsRef =
                    split.method == 'UPI' ||
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
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: style.textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Split ${index + 1}',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
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
                        onChanged: (_) => setState(() {}),
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
                              style: AppStyles.text14Px.poppins.w500.textGrey,
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
                children:
                    _availableMethods.map((method) {
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
                                style: AppStyles.text12Px.poppins.w500.copyWith(
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
                            color:
                                _pendingDue > 0
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF43A047),
                          ),
                        ),
                        Text(
                          '₹ ${_pendingDue == _pendingDue.toInt() ? _pendingDue.toInt().toString() : _pendingDue.toStringAsFixed(2)}',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color:
                                _pendingDue > 0
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
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
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
                    color: Colors.black.withValues(alpha: 0.04),
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
            Button.filled(
              size: Size(double.maxFinite, 42.h),
              title:
                  widget.isAddNew ? 'Activate Membership' : 'Renew Membership',
              isLoading: _isSubmitting,
              buttonColor: AppColors.primary,
              ontap: _submit,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Helper class to hold state for each payment split entry.
class _PaymentSplit {
  _PaymentSplit({required this.method});

  final String method;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
}
