import 'package:mentor_mobile_app/imports_bindings.dart';

class MemberOnboardPaymentSuccessScreen extends StatefulWidget {
  const MemberOnboardPaymentSuccessScreen({
    this.memberDetails,
    this.clientName,
    this.clientPhone,
    this.planName,
    this.planAmount,
    this.discount,
    this.amountPaid,
    this.pendingDue,
    this.startDate,
    this.endDate,
    this.paymentMethod,
    this.isRenewal = false,
    this.title,
    this.subtitle,
    this.onDone,
    super.key,
  });

  final MemberDetailsModel? memberDetails;
  final String? clientName;
  final String? clientPhone;
  final String? planName;
  final double? planAmount;
  final double? discount;
  final double? amountPaid;
  final double? pendingDue;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final bool isRenewal;
  final String? title;
  final String? subtitle;
  final VoidCallback? onDone;

  @override
  State<MemberOnboardPaymentSuccessScreen> createState() =>
      _MemberOnboardPaymentSuccessScreenState();
}

class _MemberOnboardPaymentSuccessScreenState
    extends State<MemberOnboardPaymentSuccessScreen> {
  String get _fitnessCenterName {
    final user = LocalStorageService().getUser();
    return user?.organizationName ??
        user?.mentor?.org?.name ??
        'Fitness Center';
  }

  String get _clientName {
    if (widget.clientName != null && widget.clientName!.trim().isNotEmpty) {
      return widget.clientName!.trim();
    }
    final name = widget.memberDetails?.fullName ??
        '${widget.memberDetails?.firstName ?? ''} ${widget.memberDetails?.lastName ?? ''}'
            .trim();
    return name.isNotEmpty ? name : 'Client';
  }

  String get _clientPhone {
    if (widget.clientPhone != null && widget.clientPhone!.trim().isNotEmpty) {
      return widget.clientPhone!.trim();
    }
    return widget.memberDetails?.mobileNumber ?? '';
  }

  String get _resolvedPlanName {
    if (widget.planName != null && widget.planName!.isNotEmpty) {
      return widget.planName!;
    }
    if (widget.memberDetails?.memberships?.isNotEmpty == true) {
      return widget.memberDetails!.memberships!.first.membershipName ??
          'Membership Plan';
    }
    return 'Membership Plan';
  }

  DateTime? get _resolvedStartDate {
    if (widget.startDate != null) return widget.startDate;
    if (widget.memberDetails?.memberships?.isNotEmpty == true) {
      return widget.memberDetails!.memberships!.first.startDate;
    }
    return DateTime.now();
  }

  DateTime? get _resolvedEndDate {
    DateTime? rawEnd;
    if (widget.endDate != null) {
      rawEnd = widget.endDate;
    } else if (widget.memberDetails?.memberships?.isNotEmpty == true) {
      rawEnd = widget.memberDetails!.memberships!.first.endDate;
    }
    if (rawEnd == null) return null;
    final start = _resolvedStartDate;
    if (start != null && rawEnd.isAfter(start)) {
      return rawEnd.subtract(const Duration(days: 1));
    }
    return rawEnd;
  }

  double get _resolvedPlanAmount {
    if (widget.planAmount != null) return widget.planAmount!;
    if (widget.memberDetails?.memberships?.isNotEmpty == true) {
      return double.tryParse(
            widget.memberDetails!.memberships!.first.amount ?? '0',
          ) ??
          0;
    }
    return 0;
  }

  double get _resolvedDiscount => widget.discount ?? 0.0;

  double get _resolvedAmountPaid {
    if (widget.amountPaid != null) return widget.amountPaid!;
    return (_resolvedPlanAmount - _resolvedDiscount).clamp(
      0.0,
      double.infinity,
    );
  }

  double get _resolvedPendingDue => widget.pendingDue ?? 0.0;

  void _shareInvoiceViaWhatsApp() {
    final cleanPhone = _clientPhone.replaceAll(RegExp(r'[^\d+]'), '');

    final startDateStr = _resolvedStartDate != null
        ? DateFormat('dd MMM yyyy').format(_resolvedStartDate!)
        : 'N/A';
    final endDateStr = _resolvedEndDate != null
        ? DateFormat('dd MMM yyyy').format(_resolvedEndDate!)
        : 'N/A';

    final buffer = StringBuffer();
    buffer.writeln(
      widget.isRenewal
          ? '🧾 *MEMBERSHIP RENEWAL RECEIPT*'
          : '🧾 *INVOICE & MEMBERSHIP RECEIPT*',
    );
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🏋️ *Fitness Center:* $_fitnessCenterName');
    buffer.writeln('👤 *Member Name:* $_clientName');
    if (_clientPhone.isNotEmpty) {
      buffer.writeln('📱 *Phone:* $_clientPhone');
    }
    buffer.writeln('📋 *Plan:* $_resolvedPlanName');
    buffer.writeln('📅 *Duration:* $startDateStr to $endDateStr');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
      '💰 *Plan Amount:* ₹${_resolvedPlanAmount.toStringAsFixed(0)}',
    );
    if (_resolvedDiscount > 0) {
      buffer.writeln(
        '🏷️ *Discount Applied:* -₹${_resolvedDiscount.toStringAsFixed(0)}',
      );
    }
    buffer.writeln(
      '✅ *Amount Paid:* ₹${_resolvedAmountPaid.toStringAsFixed(0)}',
    );
    if (_resolvedPendingDue > 0) {
      buffer.writeln(
        '⚠️ *Pending Due:* ₹${_resolvedPendingDue.toStringAsFixed(0)}',
      );
      buffer.writeln('📌 *Payment Status:* Partial / Pending Due');
    } else {
      buffer.writeln('📌 *Payment Status:* Fully Paid ✅');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
      widget.isRenewal
          ? 'Thank you for renewing with $_fitnessCenterName! Stay fit, stay disciplined. 💪'
          : 'Thank you for choosing $_fitnessCenterName! Stay fit, stay disciplined. 💪',
    );

    final encodedText = Uri.encodeComponent(buffer.toString());
    final url = cleanPhone.isNotEmpty
        ? 'https://wa.me/$cleanPhone?text=$encodedText'
        : 'https://wa.me/?text=$encodedText';

    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _onDone() {
    if (widget.onDone != null) {
      widget.onDone!();
      return;
    }
    if (widget.isRenewal) {
      Navigator.pop(context);
      return;
    }
    context.pushAndRemoveUntil(const OrganizationListingScreen());
  }

  @override
  Widget build(BuildContext context) {
    final startDateStr = _resolvedStartDate != null
        ? DateFormat('dd MMM yyyy').format(_resolvedStartDate!)
        : 'N/A';
    final endDateStr = _resolvedEndDate != null
        ? DateFormat('dd MMM yyyy').format(_resolvedEndDate!)
        : 'N/A';

    final hasDiscount = _resolvedDiscount > 0;
    final hasPendingDue = _resolvedPendingDue > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onDone();
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Success Vector
                SvgPicture.asset(
                  'assets/images/svg/vectors/onboarding_success.svg',
                  height: 110,
                )
                    .animate()
                    .scale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      begin: Offset.zero,
                      end: const Offset(1, 1),
                    )
                    .fadeIn(duration: const Duration(milliseconds: 300)),
                const SizedBox(height: 12),
                Text(
                  widget.title ??
                      (widget.isRenewal
                          ? 'Membership Renewed Successfully!'
                          : 'Client Added Successfully!'),
                  style: AppStyles.text18Px.poppins.w700.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle ??
                      (widget.isRenewal
                          ? 'Membership has been renewed for $_clientName'
                          : 'Membership has been activated for $_clientName'),
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ============ INVOICE CARD ============
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDarkMode ? 0.2 : 0.04,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isRenewal
                                    ? 'RENEWAL SUMMARY'
                                    : 'INVOICE SUMMARY',
                                style: AppStyles.text12Px.poppins.w700.copyWith(
                                  letterSpacing: 0.8,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasPendingDue
                                  ? const Color(0xffFFF8E1)
                                  : const Color(0xffE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasPendingDue
                                      ? Icons.schedule
                                      : Icons.check_circle_rounded,
                                  size: 13,
                                  color: hasPendingDue
                                      ? const Color(0xFFD1AC19)
                                      : const Color(0xFF238644),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasPendingDue ? 'Due Pending' : 'Paid',
                                  style:
                                      AppStyles.text10Px.poppins.w600.copyWith(
                                    color: hasPendingDue
                                        ? const Color(0xFFD1AC19)
                                        : const Color(0xFF238644),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: context.colors.border,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 14),

                      // Details list
                      _buildInvoiceRow(
                        label: 'Fitness Center',
                        value: _fitnessCenterName,
                        isBold: true,
                      ),
                      _buildInvoiceRow(
                        label: 'Client Name',
                        value: _clientName,
                      ),
                      if (_clientPhone.isNotEmpty)
                        _buildInvoiceRow(
                          label: 'Contact',
                          value: _clientPhone,
                        ),
                      _buildInvoiceRow(
                        label: 'Plan',
                        value: _resolvedPlanName,
                      ),
                      _buildInvoiceRow(
                        label: 'Validity',
                        value: '$startDateStr – $endDateStr',
                      ),
                      if (widget.paymentMethod != null &&
                          widget.paymentMethod!.isNotEmpty)
                        _buildInvoiceRow(
                          label: 'Payment Method',
                          value: widget.paymentMethod!,
                        ),

                      const SizedBox(height: 6),
                      Divider(
                        color: context.colors.border,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 14),

                      // Financial breakdown
                      _buildFinancialRow(
                        label: 'Plan Price',
                        value: '₹${_resolvedPlanAmount.toStringAsFixed(0)}',
                      ),
                      if (hasDiscount)
                        _buildFinancialRow(
                          label: 'Discount',
                          value: '-₹${_resolvedDiscount.toStringAsFixed(0)}',
                          valueColor: const Color(0xFF238644),
                        ),
                      _buildFinancialRow(
                        label: 'Amount Paid',
                        value: '₹${_resolvedAmountPaid.toStringAsFixed(0)}',
                        isBold: true,
                        valueColor: context.colors.textPrimary,
                      ),
                      if (hasPendingDue)
                        _buildFinancialRow(
                          label: 'Pending Due',
                          value: '₹${_resolvedPendingDue.toStringAsFixed(0)}',
                          isBold: true,
                          valueColor: const Color(0xFFD32F2F),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ============ ACTION BUTTONS ============
                // 1. WhatsApp Share Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _shareInvoiceViaWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/icons/whatsapp.svg',
                          height: 22,
                          width: 22,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Share Invoice on WhatsApp',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Done Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _onDone,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.colors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: isBold
                  ? AppStyles.text13Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    )
                  : AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.colors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppStyles.text13Px.poppins.w600.copyWith(
                    color: context.colors.textPrimary,
                  )
                : AppStyles.text12Px.poppins.w400.copyWith(
                    color: context.colors.textSecondary,
                  ),
          ),
          Text(
            value,
            style: isBold
                ? AppStyles.text14Px.poppins.w700.copyWith(
                    color: valueColor ?? context.colors.textPrimary,
                  )
                : AppStyles.text13Px.poppins.w600.copyWith(
                    color: valueColor ?? context.colors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}
