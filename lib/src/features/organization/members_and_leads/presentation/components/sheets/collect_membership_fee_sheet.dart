import 'dart:async';
import 'package:dio/dio.dart' show DioException, Options, Response;
import 'package:flutter/services.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class _PaymentSplit {
  _PaymentSplit({required this.method});

  final String method;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
}

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
  final _notesController = TextEditingController();

  final List<_PaymentSplit> _paymentSplits = [];
  bool _isSubmitting = false;
  double? _pendingAmount;
  double? _totalPayable;
  bool _isLoadingDetails = false;

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
    _pendingAmount = widget.pendingAmount;
    _totalPayable = widget.totalPayable;

    if (_pendingAmount != null && _pendingAmount! > 0) {
      _initSplitsWithAmount(_pendingAmount!);
    } else if (widget.pendingAmount == null) {
      _isLoadingDetails = true;
    } else if (_totalPayable != null && _totalPayable! > 0) {
      _initSplitsWithAmount(_totalPayable!);
    }

    if (widget.pendingAmount == null || widget.totalPayable == null) {
      _fetchMembershipDetails();
    }
  }

  void _initSplitsWithAmount(double amount) {
    if (_paymentSplits.isEmpty) {
      final s = _PaymentSplit(method: 'Cash');
      s.amountController.text = amount == amount.toInt()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);
      _paymentSplits.add(s);
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
              if (_paymentSplits.isEmpty) {
                _initSplitsWithAmount(pending);
              } else if (_paymentSplits.length == 1 &&
                  (_paymentSplits.first.amountController.text.isEmpty ||
                      _paymentSplits.first.amountController.text == '0')) {
                _paymentSplits.first.amountController.text =
                    pending == pending.toInt()
                        ? pending.toInt().toString()
                        : pending.toStringAsFixed(2);
              }
            }
            if (payable != null) {
              _totalPayable = payable;
            }
          });
        }
      }
    } catch (_) {
      if (mounted && _paymentSplits.isEmpty && _totalPayable != null) {
        _initSplitsWithAmount(_totalPayable!);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  @override
  void dispose() {
    for (final split in _paymentSplits) {
      split.amountController.dispose();
      split.referenceController.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  double get _totalCollected {
    double sum = 0;
    for (final split in _paymentSplits) {
      sum += double.tryParse(split.amountController.text.trim()) ?? 0;
    }
    return sum;
  }

  double get _remainingDue {
    final p = _pendingAmount ?? _totalPayable ?? 0;
    return (p - _totalCollected).clamp(0.0, double.infinity);
  }

  List<String> get _availableMethods {
    final usedMethods = _paymentSplits.map((s) => s.method).toSet();
    return _allPaymentMethods.where((m) => !usedMethods.contains(m)).toList();
  }

  void _addPaymentSplit(String method) {
    setState(() {
      final split = _PaymentSplit(method: method);
      if (_remainingDue > 0) {
        split.amountController.text = _remainingDue == _remainingDue.toInt()
            ? _remainingDue.toInt().toString()
            : _remainingDue.toStringAsFixed(2);
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

  ({Color bgColor, Color textColor, Color borderColor, IconData icon})
  _getPaymentMethodStyle(String method) {
    switch (method) {
      case 'Cash':
        return (
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          borderColor: const Color(0xFFA5D6A7),
          icon: Icons.payments_outlined,
        );
      case 'UPI':
        return (
          bgColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
          borderColor: const Color(0xFF90CAF9),
          icon: Icons.qr_code_2_rounded,
        );
      case 'Debit Card':
      case 'Credit Card':
      case 'Card':
        return (
          bgColor: const Color(0xFFEDE7F6),
          textColor: const Color(0xFF4527A0),
          borderColor: const Color(0xFFB39DDB),
          icon: Icons.credit_card_outlined,
        );
      case 'Net Banking':
        return (
          bgColor: const Color(0xFFFFF3E0),
          textColor: const Color(0xFFE65100),
          borderColor: const Color(0xFFFFCC80),
          icon: Icons.account_balance_outlined,
        );
      default:
        return (
          bgColor: const Color(0xFFF5F5F5),
          textColor: const Color(0xFF424242),
          borderColor: const Color(0xFFBDBDBD),
          icon: Icons.payment_outlined,
        );
    }
  }

  Future<void> _submit() async {
    final validSplits = _paymentSplits.where((s) {
      final amt = double.tryParse(s.amountController.text.trim()) ?? 0;
      return amt > 0;
    }).toList();

    if (validSplits.isEmpty) {
      unawaited(Dialogs.showSnack(msg: 'Please enter a valid amount'));
      return;
    }

    final total = _totalCollected;
    if (_pendingAmount != null &&
        _pendingAmount! > 0 &&
        total > (_pendingAmount! + 0.01)) {
      unawaited(
        Dialogs.showSnack(
          msg:
              'Total amount to collect (₹${total == total.toInt() ? total.toInt() : total.toStringAsFixed(2)}) cannot exceed pending due (₹${_pendingAmount == _pendingAmount!.toInt() ? _pendingAmount!.toInt() : _pendingAmount!.toStringAsFixed(2)}).',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payments = validSplits.map((s) {
        final amt = double.tryParse(s.amountController.text.trim()) ?? 0;
        final map = <String, dynamic>{
          'payment_method': s.method,
          'amount': amt,
        };
        final ref = s.referenceController.text.trim();
        if (ref.isNotEmpty) {
          map['reference'] = ref;
        }
        return map;
      }).toList();

      final payload = <String, dynamic>{
        'payments': payments,
        'amount': total,
        'payment_method': payments.first['payment_method'],
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
          // Fallback to updateCustomerMembership with new_payments
          response = await DioClient().dio.patch<dynamic>(
            ApiUris.updateCustomerMembership(widget.customerMembershipId),
            data: {'new_payments': payments},
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
                            'Collect Pending Fee',
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

              // Split Payment Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Payment Details',
                        style: AppStyles.text14Px.poppins.w600.dark,
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

              // Split Payment Cards
              if (_paymentSplits.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Center(
                    child: Text(
                      'No payment method selected',
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(_paymentSplits.length, (index) {
                  final split = _paymentSplits[index];
                  final style = _getPaymentMethodStyle(split.method);
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(style.icon, size: 14, color: style.textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    split.method,
                                    style: AppStyles.text12Px.poppins.w600.copyWith(
                                      color: style.textColor,
                                    ),
                                  ),
                                ],
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
                            if (_paymentSplits.length > 1)
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
                        // Amount Field
                        TextField(
                          controller: split.amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                          style: AppStyles.text16Px.poppins.w600.dark,
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 6),
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff27AE60),
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(),
                            hintText: '0.00',
                            hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: const Color(0xffF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xffEEEEEE)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xffEEEEEE)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: style.textColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                        if (needsRef) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: split.referenceController,
                            style: AppStyles.text12Px.poppins.w400.dark,
                            decoration: InputDecoration(
                              hintText: 'Reference / Transaction ID (Optional)',
                              hintStyle:
                                  AppStyles.text12Px.poppins.w400.copyWith(
                                color: Colors.grey.shade400,
                              ),
                              filled: true,
                              fillColor: const Color(0xffF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xffEEEEEE)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xffEEEEEE)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: style.textColor,
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

              // Quick Add Buttons for Available Methods
              if (_availableMethods.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableMethods.map((method) {
                    return InkWell(
                      onTap: () => _addPaymentSplit(method),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              method,
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF424242),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Summary Card (Total Collecting vs Remaining Due)
              if (_paymentSplits.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _remainingDue == 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _remainingDue == 0
                          ? const Color(0xFFA5D6A7)
                          : const Color(0xFFFFE082),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Collecting',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_totalCollected == _totalCollected.toInt() ? _totalCollected.toInt() : _totalCollected.toStringAsFixed(2)}',
                            style: AppStyles.text15Px.poppins.w700.copyWith(
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _remainingDue == 0 ? 'Settlement' : 'Remaining Due',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _remainingDue == 0
                                ? 'Full Settlement ✓'
                                : '₹${_remainingDue == _remainingDue.toInt() ? _remainingDue.toInt() : _remainingDue.toStringAsFixed(2)}',
                            style: AppStyles.text13Px.poppins.w600.copyWith(
                              color: _remainingDue == 0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC0392B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Notes / Remarks (Optional)
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
                  hintText: 'e.g., Collected at counter via split payment',
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
                              _totalCollected > 0
                                  ? 'Collect ₹${_totalCollected == _totalCollected.toInt() ? _totalCollected.toInt() : _totalCollected.toStringAsFixed(2)} Fee'
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
