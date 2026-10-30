import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';

class EditCustomerMembershipScreen extends StatefulWidget {
  final int orgId;
  final int memberId;
  final String memberName;
  final String? memberAvatar;
  final String? memberPhone;
  final MembershipDataModel currentMembership;
  final VoidCallback? onUpdated;

  const EditCustomerMembershipScreen({
    super.key,
    required this.orgId,
    required this.memberId,
    required this.memberName,
    this.memberAvatar,
    this.memberPhone,
    required this.currentMembership,
    this.onUpdated,
  });

  @override
  State<EditCustomerMembershipScreen> createState() =>
      _EditCustomerMembershipScreenState();
}

class _EditCustomerMembershipScreenState
    extends State<EditCustomerMembershipScreen> {
  List<MembershipPackageModel> _packages = [];
  bool _isLoadingPackages = false;
  MembershipPackageModel? _selectedPlan;
  bool _isPlanDropdownOpen = false;

  final TextEditingController _discountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _dueDate;
  bool _isSubmitting = false;

  /// Payment breakdown entries
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
    // Pre-fill from current membership in local timezone
    _startDate = widget.currentMembership.startDate?.toLocal() ?? DateTime.now();
    _endDate = widget.currentMembership.endDate?.toLocal() ??
        DateTime.now().add(const Duration(days: 30));
    _dueDate = DateTime.now().add(const Duration(days: 7));

    _discountController.addListener(_onDiscountChanged);
    _fetchPackages();
  }

  @override
  void dispose() {
    _discountController.removeListener(_onDiscountChanged);
    _discountController.dispose();
    _notesController.dispose();
    for (final split in _paymentSplits) {
      split.amountController.dispose();
      split.referenceController.dispose();
    }
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

  double get _planAmount {
    if (_selectedPlan != null) {
      final actual = double.tryParse(_selectedPlan?.actualPrice ?? '');
      final offer = double.tryParse(_selectedPlan?.offerPrice ?? '');
      if (actual != null && actual > 0) return actual;
      if (offer != null && offer > 0) return offer;
    }
    return double.tryParse(widget.currentMembership.amount ?? '0') ?? 0;
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

        final parsed = data
            .map(
              (e) => MembershipPackageModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        if (mounted) {
          setState(() {
            _packages = parsed;
            _isLoadingPackages = false;
            // Auto-select the current membership plan
            final currentPlanId = widget.currentMembership.membership;
            if (currentPlanId != null) {
              _selectedPlan =
                  parsed.where((p) => p.id == currentPlanId).firstOrNull;

              // Pre-fill discount if current membership was discounted
              final planActual =
                  double.tryParse(_selectedPlan?.actualPrice ?? '') ?? 0;
              final currentAmount =
                  double.tryParse(widget.currentMembership.amount ?? '') ?? 0;
              if (planActual > currentAmount && currentAmount > 0) {
                final diff = planActual - currentAmount;
                _discountController.text = _formatAmount(diff);
              }

              // Initial payment split pre-fill with paid amount
              final initialPay = currentAmount > 0 ? currentAmount : _totalPayable;
              if (initialPay > 0 && _paymentSplits.isEmpty) {
                final cashSplit = _PaymentSplit(method: 'Cash');
                cashSplit.amountController.text = _formatAmount(initialPay);
                _paymentSplits.add(cashSplit);
              }
            }
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingPackages = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPackages = false);
    }
  }

  void _onPlanSelected(MembershipPackageModel plan) {
    setState(() {
      _selectedPlan = plan;
      _isPlanDropdownOpen = false;
      // Auto-update end date based on plan duration
      final duration = plan.durationDays ?? 30;
      _endDate = _startDate.add(Duration(days: duration));

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
        // Recalculate end date if plan selected
        if (_selectedPlan != null) {
          final duration = _selectedPlan!.durationDays ?? 30;
          _endDate = _startDate.add(Duration(days: duration));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (_selectedPlan == null) {
      Dialogs.showSnack(msg: 'Please select a membership plan');
      return;
    }

    final membershipId = widget.currentMembership.id;
    if (membershipId == null) {
      Dialogs.showSnack(msg: 'Membership ID not found');
      return;
    }

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

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final payload = <String, dynamic>{
        'membership': _selectedPlan!.id,
        if (_selectedPlan?.name != null) 'membership_name': _selectedPlan!.name,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
        'plan_amount': _planAmount,
        'discount_amount': _discount,
        'amount': _totalPayable,
        'payments': payments,
        if (_pendingDue > 0 && _dueDate != null)
          'due_date': DateFormat('yyyy-MM-dd').format(_dueDate!),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      final result = await MembershipRepository().updateCustomerMembership(
        customerMembershipId: membershipId,
        body: payload,
      );

      result.fold(
        (error) {
          if (mounted) setState(() => _isSubmitting = false);
          Dialogs.showSnack(msg: error.msg ?? 'Failed to update membership');
        },
        (_) {
          Dialogs.showSnack(msg: 'Membership updated successfully');
          widget.onUpdated?.call();
          if (mounted) Navigator.pop(context, true);
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
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
        titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
        title: const Text('Edit Membership'),
      ),
      backgroundColor: AppColors.grey,
      body: _isLoadingPackages
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Client summary card
                _buildClientSummary(),
                const SizedBox(height: 20),

                // Current membership info
                _buildCurrentMembershipInfo(),
                const SizedBox(height: 20),

                // Plan selector
                _buildPlanSelector(),
                const SizedBox(height: 16),

                // Date selectors (Start Date & End Date side by side)
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Start Date', _startDate, _pickStartDate),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField('End Date', _endDate, _pickEndDate),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Plan Amount & Discount Row
                _buildPlanAmountAndDiscountRow(),
                const SizedBox(height: 16),

                // Total Payable Banner
                _buildTotalPayableBanner(),
                const SizedBox(height: 24),

                // Payment Breakdown Section
                _buildPaymentBreakdownSection(),

                // Due Date selector if there is pending due
                if (_pendingDue > 0) ...[
                  const SizedBox(height: 20),
                  _buildDueDateCard(),
                ],

                const SizedBox(height: 32),

                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Update Membership Plan',
                            style: AppStyles.text16Px.poppins.w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildClientSummary() {
    return _buildFieldCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: widget.memberAvatar != null &&
                      widget.memberAvatar!.isNotEmpty
                  ? NetworkImage(widget.memberAvatar!)
                  : null,
              child: widget.memberAvatar == null ||
                      widget.memberAvatar!.isEmpty
                  ? Text(
                      widget.memberName.isNotEmpty
                          ? widget.memberName[0].toUpperCase()
                          : '?',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.memberName,
                    style: AppStyles.text16Px.poppins.w600.dark,
                  ),
                  if (widget.memberPhone != null &&
                      widget.memberPhone!.isNotEmpty)
                    Text(
                      widget.memberPhone!,
                      style: AppStyles.text12Px.poppins.w400.textGrey,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMembershipInfo() {
    final status = widget.currentMembership.status?.toLowerCase() ?? 'unknown';
    final isCancelled = status == 'cancelled';
    final isExpired = status == 'expired';

    Color statusColor;
    if (isCancelled) {
      statusColor = Colors.red.shade700;
    } else if (isExpired) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.green;
    }

    return _buildFieldCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Current Membership',
                  style: AppStyles.text14Px.poppins.w600.dark,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCancelled
                        ? 'CANCELLED'
                        : (widget.currentMembership.status?.toUpperCase() ??
                            'UNKNOWN'),
                    style: AppStyles.text10Px.poppins.w600.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.currentMembership.membershipName ?? 'Unknown Plan',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.currentMembership.startDate?.format('dd MMM yyyy') ?? 'N/A'} — ${widget.currentMembership.inclusiveEndDate?.format('dd MMM yyyy') ?? 'N/A'}',
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Plan',
          style: AppStyles.text14Px.poppins.w600.dark,
        ).pOnly(bottom: 8),
        _buildFieldCard(
          child: InkWell(
            onTap: () => setState(() => _isPlanDropdownOpen = !_isPlanDropdownOpen),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPlan?.name ?? 'Select a plan',
                          style: AppStyles.text14Px.poppins.w500.dark,
                        ),
                        if (_selectedPlan != null)
                          Text(
                            '₹${_selectedPlan?.offerPrice ?? _selectedPlan?.actualPrice ?? '0'} • ${_selectedPlan?.durationDays ?? 0} days',
                            style: AppStyles.text12Px.poppins.w400.textGrey,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isPlanDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isPlanDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: _packages.map((plan) {
                  final isSelected = _selectedPlan?.id == plan.id;
                  return InkWell(
                    onTap: () => _onPlanSelected(plan),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : null,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name ?? 'Unknown',
                                  style: AppStyles.text14Px.poppins.w500.dark,
                                ),
                                Text(
                                  '₹${plan.offerPrice ?? plan.actualPrice ?? '0'} • ${plan.durationDays ?? 0} days',
                                  style:
                                      AppStyles.text12Px.poppins.w400.textGrey,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w600.dark,
        ).pOnly(bottom: 8),
        _buildFieldCard(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      date.format('dd MMM yyyy'),
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanAmountAndDiscountRow() {
    return Row(
      children: [
        // Plan Amount
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
        // Discount
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
    );
  }

  Widget _buildTotalPayableBanner() {
    return Container(
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
    );
  }

  Widget _buildPaymentBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                onTap: () => _addPaymentSplit(_availableMethods.first),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
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

        // Split Cards or Empty Placeholder
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
                  'Submitting without payment marks the membership as pending',
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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

                  // Amount
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
                          style: AppStyles.text14Px.poppins.w500.textGrey,
                        ),
                      ),
                    ),
                  ),

                  // Reference field
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

        // Summary Banner (Total Paid & Pending Due)
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
      ],
    );
  }

  Widget _buildDueDateCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Balance Due Date',
              style: AppStyles.text14Px.poppins.w600.dark,
            ),
            const SizedBox(width: 6),
            Text(
              '(for pending amount)',
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
          ],
        ).pOnly(bottom: 8),
        _buildFieldCard(
          child: InkWell(
            onTap: _pickDueDate,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    color: Color(0xFFE53935),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _dueDate != null
                          ? _dueDate!.format('dd MMM yyyy')
                          : 'Select Due Date',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
