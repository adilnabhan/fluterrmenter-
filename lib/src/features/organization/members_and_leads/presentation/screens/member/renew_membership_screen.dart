import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';

class RenewMembershipScreen extends StatefulWidget {
  final int orgId;
  final int memberId;
  final String memberName;
  final MemberDetailsModel? memberDetails;
  final VoidCallback? onRenewed;

  const RenewMembershipScreen({
    super.key,
    required this.orgId,
    required this.memberId,
    required this.memberName,
    this.memberDetails,
    this.onRenewed,
  });

  @override
  State<RenewMembershipScreen> createState() => _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends State<RenewMembershipScreen> {
  List<MembershipPackageModel> _packages = [];
  bool _isLoadingPackages = false;
  MembershipPackageModel? _selectedPlan;
  bool _isPlanDropdownOpen = false;

  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _amountToPayController = TextEditingController(text: '0');

  String _paymentMethod = 'Cash';
  DateTime _startDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _paymentMethods = [
    'Cash',
    'UPI',
    'Debit Card',
    'Credit Card',
    'Net Banking',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _discountController.addListener(_updateAmountToPay);
  }

  @override
  void dispose() {
    _discountController.removeListener(_updateAmountToPay);
    _discountController.dispose();
    _amountToPayController.dispose();
    super.dispose();
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

        if (mounted) {
          setState(() {
            _packages = parsed;
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

  void _updateAmountToPay() {
    if (_selectedPlan == null) return;
    final rawPrice = double.tryParse(
          _selectedPlan?.offerPrice ?? _selectedPlan?.actualPrice ?? '0',
        ) ??
        0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final finalAmount = (rawPrice - discount).clamp(0.0, double.infinity);

    final formattedAmount =
        finalAmount == finalAmount.toInt()
            ? finalAmount.toInt().toString()
            : finalAmount.toStringAsFixed(2);

    if (_amountToPayController.text != formattedAmount) {
      _amountToPayController.text = formattedAmount;
    }
  }

  Future<void> _submit() async {
    if (_selectedPlan == null) {
      Dialogs.showSnack(msg: 'Please select a membership plan');
      return;
    }

    final amount = double.tryParse(_amountToPayController.text.trim());
    if (amount == null || amount < 0) {
      Dialogs.showSnack(msg: 'Please enter a valid amount');
      return;
    }

    final expiryDays = _selectedPlan?.durationDays ?? 30;

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'customer_id': widget.memberId,
        'membership_plan_id': _selectedPlan!.id,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'expiry_days': expiryDays,
        'amount': amount,
        'payment_method': _paymentMethod,
        'discount': double.tryParse(_discountController.text.trim()) ?? 0,
      };

      final response = await DioClient().dio.post<dynamic>(
        ApiUris.manualMembershipEntry,
        data: payload,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Membership renewed successfully');
        widget.onRenewed?.call();
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) setState(() => _isSubmitting = false);
        Dialogs.showSnack(msg: 'Failed to renew membership');
      }
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      Dialogs.showSnack(msg: 'Error renewing membership: ${e.toString()}');
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

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  widget.memberName.isNotEmpty ? widget.memberName : 'Client Details',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: Colors.black87,
                  ),
                ),
                if (widget.memberDetails?.mobileNumber?.isNotEmpty ?? false)
                  Text(
                    widget.memberDetails!.mobileNumber!,
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
                        _updateAmountToPay();
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

  Widget _buildPaymentMethodPill(String method) {
    final isSelected = _paymentMethod == method;
    final style = _getPaymentMethodStyle(method, isSelected);

    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: style.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: style.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: style.iconColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              method,
              style: AppStyles.text13Px.poppins.w500.copyWith(
                color: style.textColor,
              ),
            ),
          ],
        ),
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
        title: const Text('Renew Membership'),
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
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
            Row(
              children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount to Pay',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFieldCard(
                        child: TextField(
                          controller: _amountToPayController,
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

            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Payment Method',
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _paymentMethods.map((method) {
                    return _buildPaymentMethodPill(method);
                  }).toList(),
            ),

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
            Button.filled(
              size: Size(double.maxFinite, 42.h),
              title: 'Renew Membership',
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
