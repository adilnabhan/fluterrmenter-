import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/domain/models/payment_history/payment_history_model.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({
    required this.orgId,
    this.showBackButton = true,
    super.key,
  });
  final int orgId;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: PaymentHistoryList(orgId: orgId, showBackButton: showBackButton),
    );
  }
}

class PaymentHistoryList extends StatefulWidget {
  const PaymentHistoryList({
    required this.orgId,
    this.showBackButton = true,
    super.key,
  });
  final int orgId;
  final bool showBackButton;
  @override
  State<PaymentHistoryList> createState() => _PaymentHistoryListState();
}

class _PaymentHistoryListState extends State<PaymentHistoryList> {
  late final MembersAndLeadsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedPaymentMode;
  String? _selectedDate;

  final _paymentFilterCategories = const [
    FilterCategory(
      title: 'Payment Mode',
      isSingleSelect: true,
      items: [
        (label: 'Cash', value: 'cash'),
        (label: 'UPI', value: 'upi'),
      ],
    ),
    FilterCategory(
      title: 'Date',
      isSingleSelect: true,
      items: [
        (label: 'Today', value: 'today'),
        (label: 'Yesterday', value: 'yesterday'),
        (label: 'This Month', value: 'month'),
      ],
    ),
  ];

  List<({String label, String value})>? get _selectedFilters {
    final list = <({String label, String value})>[];
    if (_selectedPaymentMode != null) {
      final label = _selectedPaymentMode == 'cash' ? 'Cash' : 'UPI';
      list.add((label: label, value: _selectedPaymentMode!));
    }
    if (_selectedDate != null) {
      final label = _selectedDate == 'today'
          ? 'Today'
          : _selectedDate == 'yesterday'
              ? 'Yesterday'
              : 'This Month';
      list.add((label: label, value: _selectedDate!));
    }
    return list.isNotEmpty ? list : null;
  }

  void _openFilterSheet() {
    FilterSelectionSheet(
      title: 'Filter Payments',
      categories: _paymentFilterCategories,
      selectedFilters: _selectedFilters,
      onFilterSelected: (values) {
        if (values == null || values.isEmpty) {
          _selectedPaymentMode = null;
          _selectedDate = null;
        } else {
          final modeValues = {'cash', 'upi'};
          final dateValues = {'today', 'yesterday', 'month'};

          String? mode;
          String? date;

          for (final v in values) {
            if (modeValues.contains(v.value)) mode = v.value;
            if (dateValues.contains(v.value)) date = v.value;
          }

          _selectedPaymentMode = mode;
          _selectedDate = date;
        }
        _fetch();
        if (!mounted) return;
        setState(() {});
      },
    ).show(context);
  }

  Widget _buildFilterIconButton() {
    final hasActiveFilter =
        _selectedPaymentMode != null || _selectedDate != null;

    return Material(
      color: hasActiveFilter
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openFilterSheet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasActiveFilter
                  ? AppColors.primary
                  : Colors.grey.shade200,
              width: hasActiveFilter ? 1.5 : 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 22,
                color: hasActiveFilter ? AppColors.primary : Colors.grey,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _fetch();
  }

  Future<void> _fetch({bool isPagination = false}) async {
    await _cubit.fetchPaymentHistory(
      orgId: widget.orgId,
      isPagination: isPagination,
      paymentMode: _selectedPaymentMode,
      date: _selectedDate,
      searchQuery: _searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: widget.showBackButton ? null : 16,
        leading: widget.showBackButton ? const PopButton().center : null,
        title: Text(
          'Payments',
          style: AppStyles.text18Px.poppins.w600.copyWith(color: Colors.black),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.settings_outlined, color: Colors.black),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) {
                      EasyDebounce.cancel('payment_search_query');
                      _searchQuery = val.trim();
                      _fetch();
                    },
                    onChanged: (val) {
                      setState(() {});
                      EasyDebounce.debounce(
                        'payment_search_query',
                        const Duration(milliseconds: 350),
                        () {
                          _searchQuery = val.trim();
                          _fetch();
                        },
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for name or phone number',
                      hintStyle: AppStyles.text14Px.poppins.copyWith(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                                setState(() {});
                                EasyDebounce.cancel('payment_search_query');
                                _fetch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildFilterIconButton(),
              ],
            ),
          ),
          BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
            buildWhen: (p, c) => p.paymentHistory != c.paymentHistory,
            builder: (context, state) {
              return state.paymentHistory.data.fold(
                () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Center(child: CircularProgressIndicator())],
                ),
                (either) => either.fold(
                  (error) => error.maybeWhen(
                    network: (e) => ErrorUi.network(onTap: _fetch),
                    notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                    orElse: () => ErrorUi.server(onTap: _fetch),
                  ),
                  (data) {
                    return Expanded(
                      child: ColoredBox(
                        color: const Color(0xfff9f9f9),
                        child: data.allPayments.results.isEmpty
                            ? ErrorUi.empty().center
                            : _AllPaymentsTab(
                                allPayment: data.allPayments,
                                dateFilter: _selectedDate,
                              ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AllPaymentsTab extends StatelessWidget {
  final bool isAllPayment;
  final String? dateFilter;
  const _AllPaymentsTab({
    super.key,
    this.allPayment,
    this.isAllPayment = true,
    this.dateFilter,
  });

  final PaymentHistorySection? allPayment;

  String _formatAmount(dynamic amount, num fallback) {
    if (amount != null) {
      if (amount is num) {
        if (amount % 1 == 0) return amount.toInt().toString();
        return amount.toStringAsFixed(2);
      }
      final str = amount.toString().trim();
      if (str.isNotEmpty && str != 'null') {
        final parsed = double.tryParse(str);
        if (parsed != null) {
          if (parsed % 1 == 0) return parsed.toInt().toString();
          return parsed.toStringAsFixed(2);
        }
        return str;
      }
    }
    if (fallback % 1 == 0) return fallback.toInt().toString();
    return fallback.toStringAsFixed(2);
  }

  String _getDateLabel() {
    if (dateFilter == 'today') return 'today';
    if (dateFilter == 'yesterday') return 'yesterday';
    if (dateFilter == 'month') return 'this month';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final count = (allPayment?.count != null && allPayment!.count > 0)
        ? allPayment!.count
        : (allPayment?.results.length ?? 0);
    final baseLabel = count == 1 ? '1 payment' : '$count payments';
    final dateLabel = _getDateLabel();
    final countText = dateLabel.isNotEmpty ? '$baseLabel $dateLabel' : baseLabel;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPayment?.results.length ?? 0,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) const SizedBox(height: 16),
            if (index == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    countText,
                    style: AppStyles.text14Px.poppins.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Total: ',
                      style: AppStyles.text14Px.poppins.copyWith(
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '₹${_formatAmount(allPayment?.totalAmount, allPayment?.totalPaidToday ?? 0)}',
                          style: AppStyles.text16Px.poppins.w700.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (index == 0) const SizedBox(height: 16),
            paymentCard(
              isAllPayments: isAllPayment,
              data: allPayment?.results[index],
            ),
          ],
        );
      },
    );
  }
}

({Color bg, Color text, Color border}) _getPaymentModeStyle(String? mode) {
  final clean = (mode ?? '').trim().toLowerCase();
  switch (clean) {
    case 'cash':
    case 'cod':
      return (
        bg: const Color(0xFFE8F5E9), // Light green
        text: const Color(0xFF2E7D32), // Deep green
        border: const Color(0xFFC8E6C9),
      );
    case 'upi':
      return (
        bg: const Color(0xFFEDE7F6), // Light purple / violet
        text: const Color(0xFF5E35B1), // Deep purple
        border: const Color(0xFFD1C4E9),
      );
    case 'card':
    case 'credit_card':
    case 'debit_card':
      return (
        bg: const Color(0xFFFFF3E0), // Warm amber / orange
        text: const Color(0xFFE65100), // Rich orange
        border: const Color(0xFFFFCC80),
      );
    case 'net_banking':
    case 'netbanking':
    case 'bank_transfer':
      return (
        bg: const Color(0xFFE0F7FA), // Light cyan / teal
        text: const Color(0xFF00838F), // Deep teal
        border: const Color(0xFF80DEEA),
      );
    case 'cheque':
      return (
        bg: const Color(0xFFFBE9E7), // Light coral / peach
        text: const Color(0xFFD84315), // Deep rust
        border: const Color(0xFFFFAB91),
      );
    case 'online':
      return (
        bg: const Color(0xFFE3F2FD), // Light blue
        text: const Color(0xFF1565C0), // Royal blue
        border: const Color(0xFFBBDEFB),
      );
    default:
      return (
        bg: const Color(0xFFF5F5F5), // Light neutral grey
        text: const Color(0xFF616161),
        border: const Color(0xFFE0E0E0),
      );
  }
}

Widget paymentCard({bool isAllPayments = true, PaymentHistoryItem? data}) {
  final modeStyle = _getPaymentModeStyle(data?.paymentMethod);
  final paymentMethodText = (data?.paymentMethod ?? '').trim();

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileImage(
              isEdit: false,
              url: data?.profilePhoto,
              radius: 36,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data?.customerName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.text15Px.poppins.w600.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Amount positioned at top-right with decreased font weight
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '₹${data?.amount ?? 0}',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: const Color(0xff2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (data?.membershipName != null &&
                      data!.membershipName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              data.membershipName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.text13Px.poppins.w500.copyWith(
                                fontSize: 12.5,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!isAllPayments) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Membership',
                style: AppStyles.text13Px.poppins.w500.copyWith(
                  color: Colors.black,
                ),
              ),
              Text(
                '₹${data?.amount ?? 0}',
                style: AppStyles.text13Px.poppins.w500.copyWith(
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform fee (${data?.platformFee ?? 0}%)',
                style: AppStyles.text13Px.poppins.copyWith(color: Colors.grey),
              ),
              Text(
                '-₹${data?.platformFeePercentage ?? 0}',
                style: AppStyles.text13Px.poppins.w600.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total :',
                style: AppStyles.text13Px.poppins.copyWith(color: Colors.grey),
              ),
              Text(
                '₹${data?.totalAmount ?? 0}',
                style: AppStyles.text16Px.poppins.w700.copyWith(
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (data?.settlementTime != null && data!.settlementTime!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data.settlementTime!,
                style: AppStyles.text12Px.poppins.copyWith(color: Colors.grey),
              ),
            ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (paymentMethodText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: modeStyle.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: modeStyle.border, width: 0.8),
                  ),
                  child: Text(
                    paymentMethodText.toUpperCase(),
                    style: AppStyles.text10Px.poppins.w600.copyWith(
                      color: modeStyle.text,
                      letterSpacing: 0.3,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              // Date & Time positioned at bottom-right (switched with amount)
              Text(
                formatPaymentDate(data?.paymentDate?.toString() ?? ''),
                style: AppStyles.text12Px.poppins.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

String formatPaymentDate(String isoDate) {
  final DateTime dateTime = DateTime.parse(isoDate).toLocal();
  final DateTime now = DateTime.now();

  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = today.subtract(const Duration(days: 1));
  final DateTime dateOnly = DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
  );

  final String time = DateFormat('hh:mm a').format(dateTime);

  if (dateOnly == today) {
    return '$time, Today';
  } else if (dateOnly == yesterday) {
    return '$time, Yesterday';
  } else {
    final String date = DateFormat('dd MMM yyyy').format(dateTime);
    return '$time, $date';
  }
}

class _ProcessingPaymentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _processingPaymentsData.length + 1,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     _FilterChip(
            //       label: 'Filter x',
            //       onTap: () {},
            //       textColor: const Color(0xffEF5350),
            //       borderColor: const Color(0xffEF5350).withOpacity(0.2),
            //       backgroundColor: const Color(0xffFFEBEE),
            //       icon: Icons.filter_list,
            //       iconColor: const Color(0xffEF5350),
            //     ),
            //     const SizedBox(width: 8),
            //     _FilterChip(
            //       label: 'Today',
            //       onTap: () {},
            //       textColor: const Color(0xffEF5350),
            //       borderColor: const Color(0xffEF5350).withOpacity(0.2),
            //       backgroundColor: const Color(0xffFFEBEE),
            //     ),
            //   ],
            // ),
            if (index == 0) const SizedBox(height: 16),
            if (index == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_processingPaymentsData.length} payments today',
                    style: AppStyles.text14Px.poppins.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Pending: ',
                      style: AppStyles.text14Px.poppins.copyWith(
                        color: Colors.grey,
                      ),
                      children: [
                        TextSpan(
                          text: '₹3,500',
                          style: AppStyles.text16Px.poppins.w700.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (index == 0) const SizedBox(height: 16),
            paymentCard(
              isAllPayments: false,
              data: PaymentHistoryItem.fromJson({
                "id": 133,
                "customer_name": "Arpan Subhjith",
                "membership_name": "TEST",
                "amount": "50.00",
                "status": "Successful",
                "payment_method": "upi",
                "payment_date": "2026-01-16T06:56:38.044003Z",
                "order_id": null,
                "payment_id": "pay_S4SUgw6nuS91Zv",
                "created_at": "2026-01-16T06:56:38.144488Z",
              }),
            ),
          ],
        );

        final item = _processingPaymentsData[index - 1];
        // return _PaymentCard.fromModel(item);
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.iconColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor ?? Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: textColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.name,
    required this.time,
    required this.planName,
    required this.description,
    this.amount,
    this.status,
    this.statusColor,
    this.statusTextColor,
    this.statusPendingText,
    this.showAmountPill = false,
    this.isDetailed = false,
    this.platformFee,
    this.platformFeeAmount,
    this.totalLabel,
    this.totalAmount,
    this.footerNote,
  });

  final String name;
  final String time;
  final String planName;
  final String description;
  final String? amount;
  final String? status;
  final Color? statusColor;
  final Color? statusTextColor;
  final String? statusPendingText;
  final bool showAmountPill;
  final bool isDetailed;

  // For Detailed View
  final String? platformFee;
  final String? platformFeeAmount;
  final String? totalLabel;
  final String? totalAmount;
  final String? footerNote;

  /* Factory to create card from model */
  factory _PaymentCard.fromModel(_PaymentUIModel model) {
    return _PaymentCard(
      name: model.name,
      time: model.time,
      planName: model.planName,
      description: model.description,
      amount: model.amount,
      status: model.status,
      statusColor: model.statusColor,
      statusTextColor: model.statusTextColor,
      statusPendingText: model.statusPendingText,
      showAmountPill: model.showAmountPill,
      isDetailed: model.isDetailed,
      platformFee: model.platformFee,
      platformFeeAmount: model.platformFeeAmount,
      totalLabel: model.totalLabel,
      totalAmount: model.totalAmount,
      footerNote: model.footerNote,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=32',
                ),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jisham',
                          style: AppStyles.text16Px.poppins.w600.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '07:30 AM, Today',
                          style: AppStyles.text12Px.poppins.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '1 Month Plan',
                      style: AppStyles.text14Px.poppins.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isDetailed) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Membership + 1 Month Plan',
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.black,
                  ),
                ),
                Text(
                  '₹1,000',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform fee (4%)',
                  style: AppStyles.text14Px.poppins.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '-₹60',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total :',
                  style: AppStyles.text14Px.poppins.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹1,440',
                  style: AppStyles.text20Px.poppins.w700.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Text(
              'The amount will be credited to your account within 3 working days.',
              style: AppStyles.text12Px.poppins.copyWith(color: Colors.grey),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Membership + 1 Month Plan',
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.black,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹1,000',
                    style: AppStyles.text16Px.poppins.w700.copyWith(
                      color: const Color(0xff2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE3F2FD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Cash',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xff1565C0),
                    ),
                  ),
                ),
                if (statusPendingText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'statusPendingText sdgts drgdrsf ',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

final _allPaymentsData = [
  const _PaymentUIModel(
    name: 'Marcus Lee',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1,000',
    status: 'Cash',
    statusColor: Color(0xffE8F5E9),
    statusTextColor: Color(0xff2E7D32),
    showAmountPill: true,
  ),
  const _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1,000',
    status: 'UPI',
    statusColor: Color(0xffE3F2FD),
    statusTextColor: Color(0xff1565C0),
    showAmountPill: true,
  ),
  const _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1500',
    status: 'Online',
    statusColor: Color(0xffFFEBEE),
    statusTextColor: Color(0xffC62828),
    statusPendingText: 'Status: Pending',
    showAmountPill: true,
  ),
  const _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹2,000',
    status: 'EMI',
    statusColor: Color(0xffF3E5F5),
    statusTextColor: Color(0xff7B1FA2),
    showAmountPill: true,
  ),
];

final _processingPaymentsData = [
  const _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1,500',
    isDetailed: true,
    platformFee: 'Platform fee (4%)',
    platformFeeAmount: '-₹60',
    totalLabel: 'Total :',
    totalAmount: '₹1,440',
    footerNote:
        'The amount will be credited to your account within 3 working days.',
  ),
  const _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1,500',
    isDetailed: true,
    platformFee: 'Platform fee (4%)',
    platformFeeAmount: '-₹60',
    totalLabel: 'Total :',
    totalAmount: '₹1,440',
    footerNote:
        'The amount will be credited to your account within 3 working days.',
  ),
];

class _PaymentUIModel {
  final String name;
  final String time;
  final String planName;
  final String description;
  final String? amount;
  final String? status;
  final Color? statusColor;
  final Color? statusTextColor;
  final String? statusPendingText;
  final bool showAmountPill;
  final bool isDetailed;
  final String? platformFee;
  final String? platformFeeAmount;
  final String? totalLabel;
  final String? totalAmount;
  final String? footerNote;

  const _PaymentUIModel({
    required this.name,
    required this.time,
    required this.planName,
    required this.description,
    this.amount,
    this.status,
    this.statusColor,
    this.statusTextColor,
    this.statusPendingText,
    this.showAmountPill = false,
    this.isDetailed = false,
    this.platformFee,
    this.platformFeeAmount,
    this.totalLabel,
    this.totalAmount,
    this.footerNote,
  });
}

class _FolderTabIndicator extends Decoration {
  final Color color;
  final Color borderColor;
  final double radius;

  const _FolderTabIndicator({
    required this.color,
    required this.borderColor,
    required this.radius,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FolderTabPainter(this, onChanged);
  }
}

class _FolderTabPainter extends BoxPainter {
  _FolderTabPainter(this.decoration, VoidCallback? onChanged)
    : super(onChanged);
  final _FolderTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final Paint paint =
        Paint()
          ..color = decoration.color
          ..style = PaintingStyle.fill;

    final Paint borderPaint =
        Paint()
          ..color = decoration.borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final radius = decoration.radius;
    final Path path = Path();

    // Extend bottom slightly to cover the underlying container border
    final double bottom = rect.bottom + 2;

    // Start from bottom left (extended)
    path
      ..moveTo(rect.left, bottom)
      // Bottom left curved flare
      ..quadraticBezierTo(
        rect.left + 4,
        bottom - 4,
        rect.left + 4,
        bottom - radius,
      )
      // Up to top left
      ..lineTo(rect.left + 4, rect.top + radius)
      // Top left corner
      ..quadraticBezierTo(
        rect.left + 4,
        rect.top,
        rect.left + 4 + radius,
        rect.top,
      )
      // Across top
      ..lineTo(rect.right - 4 - radius, rect.top)
      // Top right corner
      ..quadraticBezierTo(
        rect.right - 4,
        rect.top,
        rect.right - 4,
        rect.top + radius,
      )
      // Down to bottom right
      ..lineTo(rect.right - 4, bottom - radius)
      // Bottom right curved flare
      ..quadraticBezierTo(rect.right - 4, bottom - 4, rect.right, bottom)
      // Close at bottom
      ..lineTo(rect.left, bottom);

    // Draw fill
    canvas.drawPath(path, paint);

    // Draw border (exclude bottom line to merge)
    final borderPath =
        Path()
          ..moveTo(rect.left, rect.bottom)
          ..quadraticBezierTo(
            rect.left + 4,
            rect.bottom - 4,
            rect.left + 4,
            rect.bottom - radius,
          )
          ..lineTo(rect.left + 4, rect.top + radius)
          ..quadraticBezierTo(
            rect.left + 4,
            rect.top,
            rect.left + 4 + radius,
            rect.top,
          )
          ..lineTo(rect.right - 4 - radius, rect.top)
          ..quadraticBezierTo(
            rect.right - 4,
            rect.top,
            rect.right - 4,
            rect.top + radius,
          )
          ..lineTo(rect.right - 4, rect.bottom - radius)
          ..quadraticBezierTo(
            rect.right - 4,
            rect.bottom - 4,
            rect.right,
            rect.bottom,
          );

    canvas.drawPath(borderPath, borderPaint);
  }
}
