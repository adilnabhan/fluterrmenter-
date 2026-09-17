import 'package:dio/dio.dart' show Response;
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class CollectMembershipFeeSheet extends StatefulWidget {
  const CollectMembershipFeeSheet({
    required this.customerMembershipId,
    this.membershipName,
    this.memberName,
    this.totalPayable,
    this.pendingAmount,
    this.onFeeCollected,
    super.key,
  });

  final int customerMembershipId;
  final String? membershipName;
  final String? memberName;
  final double? totalPayable;
  final double? pendingAmount;
  final VoidCallback? onFeeCollected;

  static Future<void> show({
    required BuildContext context,
    required int customerMembershipId,
    String? membershipName,
    String? memberName,
    double? totalPayable,
    double? pendingAmount,
    VoidCallback? onFeeCollected,
  }) async {
    double? resolvedPending = pendingAmount;
    double? resolvedPayable = totalPayable;

    // Resolve accurate pending fee and total payable first to avoid any visual flicker/glitch
    if (resolvedPending == null) {
      try {
        final res = await DioClient()
            .dio
            .get<dynamic>(
              ApiUris.updateCustomerMembership(customerMembershipId),
            )
            .timeout(const Duration(seconds: 3));
        if (res.statusCode == 200 && res.data is Map) {
          final data = res.data as Map<String, dynamic>;
          if (data['pending_amount'] != null) {
            resolvedPending =
                double.tryParse(data['pending_amount'].toString());
          }
          if (data['total_payable'] != null) {
            resolvedPayable =
                double.tryParse(data['total_payable'].toString());
          }
        }
      } catch (_) {}
    }

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CollectMembershipFeeSheet(
        customerMembershipId: customerMembershipId,
        membershipName: membershipName,
        memberName: memberName,
        totalPayable: resolvedPayable,
        pendingAmount: resolvedPending,
        onFeeCollected: onFeeCollected,
      ),
    );
  }

  @override
  State<CollectMembershipFeeSheet> createState() =>
      _CollectMembershipFeeSheetState();
}

class _CollectMembershipFeeSheetState extends State<CollectMembershipFeeSheet> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'UPI';
  bool _isSubmitting = false;
  double? _pendingAmount;
  double? _totalPayable;
  bool _isLoadingDetails = false;

  final List<({String method, IconData icon})> _paymentMethods = [
    (method: 'UPI', icon: Icons.qr_code_2_rounded),
    (method: 'Cash', icon: Icons.payments_outlined),
    (method: 'Card', icon: Icons.credit_card_outlined),
    (method: 'Net Banking', icon: Icons.account_balance_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _pendingAmount = widget.pendingAmount;
    _totalPayable = widget.totalPayable;

    if (_pendingAmount != null && _pendingAmount! > 0) {
      final val = _pendingAmount!;
      _amountController.text =
          val == val.toInt() ? val.toInt().toString() : val.toStringAsFixed(2);
    } else if (widget.pendingAmount == null) {
      // Pending amount is unknown; wait for fetch rather than prefilling full totalPayable
      _isLoadingDetails = true;
    } else if (_totalPayable != null && _totalPayable! > 0) {
      final val = _totalPayable!;
      _amountController.text =
          val == val.toInt() ? val.toInt().toString() : val.toStringAsFixed(2);
    }

    if (widget.pendingAmount == null || widget.totalPayable == null) {
      _fetchMembershipDetails();
    }
  }

  Future<void> _fetchMembershipDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final res = await DioClient().dio.get<dynamic>(
        ApiUris.updateCustomerMembership(widget.customerMembershipId),
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        final pending = data['pending_amount'] != null
            ? double.tryParse(data['pending_amount'].toString())
            : null;
        final payable = data['total_payable'] != null
            ? double.tryParse(data['total_payable'].toString())
            : null;

        if (mounted) {
          setState(() {
            if (pending != null) {
              _pendingAmount = pending;
              _amountController.text = pending == pending.toInt()
                  ? pending.toInt().toString()
                  : pending.toStringAsFixed(2);
            }
            if (payable != null) {
              _totalPayable = payable;
            }
          });
        }
      }
    } catch (_) {
      // If request fails and amount was never set, fall back to totalPayable
      if (mounted && _amountController.text.isEmpty && _totalPayable != null) {
        final val = _totalPayable!;
        _amountController.text =
            val == val.toInt() ? val.toInt().toString() : val.toStringAsFixed(2);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      unawaited(Dialogs.showSnack(msg: 'Please enter a valid amount'));
      return;
    }

    if (_pendingAmount != null &&
        _pendingAmount! > 0 &&
        amount > (_pendingAmount! + 0.01)) {
      unawaited(
        Dialogs.showSnack(
          msg:
              'Amount to collect (₹${amount == amount.toInt() ? amount.toInt() : amount.toStringAsFixed(2)}) cannot exceed pending due (₹${_pendingAmount == _pendingAmount!.toInt() ? _pendingAmount!.toInt() : _pendingAmount!.toStringAsFixed(2)}).',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = <String, dynamic>{
        'amount': amount,
        'payment_method': _selectedPaymentMethod,
        if (_referenceController.text.trim().isNotEmpty)
          'reference': _referenceController.text.trim(),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      Response<dynamic> response;
      try {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.collectMembershipFee(widget.customerMembershipId),
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          // Fallback to updateCustomerMembership with new_payment
          response = await DioClient().dio.patch<dynamic>(
            ApiUris.updateCustomerMembership(widget.customerMembershipId),
            data: {'new_payment': payload},
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map ? response.data as Map : <String, dynamic>{};
        final msg = data['message']?.toString() ?? 'Fee collected successfully.';

        if (mounted) {
          Navigator.pop(context);
        }

        unawaited(Dialogs.showSnack(msg: msg));
        widget.onFeeCollected?.call();
      } else {
        unawaited(Dialogs.showSnack(msg: 'Failed to collect fee'));
      }
    } catch (e) {
      var errMsg = 'Failed to collect fee';
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          errMsg = 'You are not authorized to collect fees for this organization.';
        } else if (e.response?.data is Map &&
            (e.response!.data as Map)['error'] != null) {
          errMsg = (e.response!.data as Map)['error'].toString();
        } else if (e.response?.data is Map &&
            (e.response!.data as Map)['message'] != null) {
          errMsg = (e.response!.data as Map)['message'].toString();
        } else if (e.response?.data is Map &&
            (e.response!.data as Map)['detail'] != null) {
          errMsg = (e.response!.data as Map)['detail'].toString();
        }
      }
      unawaited(Dialogs.showSnack(msg: errMsg));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xff27AE60).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: Color(0xff27AE60),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collect Membership Fee',
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                          if (widget.memberName != null ||
                              widget.membershipName != null)
                            Text(
                              [widget.memberName, widget.membershipName]
                                  .where((s) => s != null && s.isNotEmpty)
                                  .join(' • '),
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textGrey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overview Banner
              if (_isLoadingDetails && _pendingAmount == null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF9E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xffF39C12).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xffE67E22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Checking pending dues...',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xffD35400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_pendingAmount != null || _totalPayable != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF9E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xffF39C12).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_totalPayable != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Payable',
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${_totalPayable == _totalPayable!.toInt() ? _totalPayable!.toInt() : _totalPayable!.toStringAsFixed(2)}',
                              style: AppStyles.text14Px.poppins.w600.dark,
                            ),
                          ],
                        ),
                      if (_pendingAmount != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pending Due',
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: const Color(0xffC0392B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${_pendingAmount == _pendingAmount!.toInt() ? _pendingAmount!.toInt() : _pendingAmount!.toStringAsFixed(2)}',
                              style: AppStyles.text16Px.poppins.w700.copyWith(
                                color: const Color(0xffE74C3C),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Amount Field
              Text(
                'Amount to Collect *',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: AppStyles.text18Px.poppins.w600.dark,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 6),
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff27AE60),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(),
                  hintText: '0.00',
                  hintStyle: AppStyles.text18Px.poppins.w400.copyWith(
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: const Color(0xffF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff27AE60), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Payment Method
              Text(
                'Payment Method *',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final item = _paymentMethods[idx];
                    final isSelected = _selectedPaymentMethod == item.method;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedPaymentMethod = item.method);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff2471A3)
                              : const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xff2471A3)
                                : const Color(0xffE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 15,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xff2471A3),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.method,
                              style: AppStyles.text12Px.poppins.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Reference (Optional)
              Text(
                'Reference / Transaction ID (Optional)',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _referenceController,
                decoration: InputDecoration(
                  hintText: 'e.g., UPI9823749823, UTR or Cheque No.',
                  hintStyle: AppStyles.text13Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: const Color(0xffF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff2471A3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                style: AppStyles.text14Px.poppins.w400.dark,
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              Text(
                'Notes / Remarks (Optional)',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., Collected at counter',
                  hintStyle: AppStyles.text13Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: const Color(0xffF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff2471A3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                style: AppStyles.text14Px.poppins.w400.dark,
              ),
              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff27AE60),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting ||
                          (_isLoadingDetails && _pendingAmount == null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            if (_isLoadingDetails && !_isSubmitting) ...[
                              const SizedBox(width: 8),
                              const Text(
                                'Loading Fee...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _amountController.text.trim().isNotEmpty
                                  ? 'Collect ₹${_amountController.text.trim()} Fee'
                                  : 'Collect Fee',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
