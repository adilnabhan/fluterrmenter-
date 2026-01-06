import 'package:mentor_mobile_app/imports_bindings.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({required this.orgId, super.key});
  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembersAndLeadsCubit(orgId: orgId),
      child: PaymentHistoryList(orgId: orgId),
    );
  }
}

class PaymentHistoryList extends StatefulWidget {
  const PaymentHistoryList({required this.orgId});
  final int orgId;
  @override
  State<PaymentHistoryList> createState() => _PaymentHistoryListState();
}

class _PaymentHistoryListState extends State<PaymentHistoryList>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MembersAndLeadsCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchPaymentHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for name or date of payment',
                hintStyle: AppStyles.text14Px.poppins.copyWith(
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.zero,
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

          BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
            buildWhen: (p, c) => p.paymentHistory != c.paymentHistory,
            builder: (context, state) {
              return state.paymentHistory.data.fold(
                () => const Center(
                  child: Center(child: CircularProgressIndicator()),
                ),
                (either) => either.fold(
                  (error) => error.maybeWhen(
                    network: (e) => ErrorUi.network(onTap: _fetch),
                    notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                    orElse: () => ErrorUi.server(onTap: _fetch),
                  ),
                  (data) {
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              padding: const EdgeInsets.only(left: 10),
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              labelStyle: AppStyles.text14Px.poppins.w600,
                              indicatorColor: Colors.transparent,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: _FolderTabIndicator(
                                color: const Color(0xfff9f9f9),
                                borderColor: Colors.grey.shade300,
                                radius: 12,
                              ),
                              tabs: const [
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text('All Payments'),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    // child: Text('Processing'),
                                    child: Text('Pending'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: const Color(0xfff9f9f9),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  if (data.allPayments.results.isEmpty)
                                    ErrorUi.empty().center
                                  else
                                    _ProcessingPaymentsTab(),

                                  if (data.pendingPayments.results.isEmpty)
                                    ErrorUi.empty().center
                                  else
                                    _AllPaymentsTab(),
                                ],
                              ),
                            ),
                          ),
                        ],
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
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allPaymentsData.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Filter x',
                      onTap: () {},
                      textColor: const Color(0xffEF5350),
                      borderColor: const Color(0xffEF5350).withOpacity(0.2),
                      backgroundColor: const Color(0xffFFEBEE),
                      icon: Icons.filter_list,
                      iconColor: const Color(0xffEF5350),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Today',
                      onTap: () {},
                      textColor: const Color(0xffEF5350),
                      borderColor: const Color(0xffEF5350).withOpacity(0.2),
                      backgroundColor: const Color(0xffFFEBEE),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Type: All',
                      onTap: () {},
                      textColor: const Color(0xffEF5350),
                      borderColor: const Color(0xffEF5350).withOpacity(0.2),
                      backgroundColor: const Color(0xffFFEBEE),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_allPaymentsData.length} payments today',
                    style: AppStyles.text14Px.poppins.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Total: ',
                      style: AppStyles.text14Px.poppins.copyWith(
                        color: Colors.grey,
                      ),
                      children: [
                        TextSpan(
                          text: '₹5,500',
                          style: AppStyles.text16Px.poppins.w700.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        final item = _allPaymentsData[index - 1];
        return _PaymentCard.fromModel(item);
      },
    );
  }
}

class _ProcessingPaymentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _processingPaymentsData.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _FilterChip(
                    label: 'Filter x',
                    onTap: () {},
                    textColor: const Color(0xffEF5350),
                    borderColor: const Color(0xffEF5350).withOpacity(0.2),
                    backgroundColor: const Color(0xffFFEBEE),
                    icon: Icons.filter_list,
                    iconColor: const Color(0xffEF5350),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Today',
                    onTap: () {},
                    textColor: const Color(0xffEF5350),
                    borderColor: const Color(0xffEF5350).withOpacity(0.2),
                    backgroundColor: const Color(0xffFFEBEE),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
            ],
          );
        }
        final item = _processingPaymentsData[index - 1];
        return _PaymentCard.fromModel(item);
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
                          name,
                          style: AppStyles.text16Px.poppins.w600.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          time,
                          style: AppStyles.text12Px.poppins.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      planName,
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
                  description,
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.black,
                  ),
                ),
                Text(
                  amount ?? '',
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
                  platformFee ?? '',
                  style: AppStyles.text14Px.poppins.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  platformFeeAmount ?? '',
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
                  totalLabel ?? 'Total :',
                  style: AppStyles.text14Px.poppins.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  totalAmount ?? '',
                  style: AppStyles.text20Px.poppins.w700.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (footerNote != null) ...[
              const SizedBox(height: 12),
              Text(
                footerNote!,
                style: AppStyles.text12Px.poppins.copyWith(color: Colors.grey),
              ),
            ],
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  description,
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.black,
                  ),
                ),
                if (showAmountPill && amount != null)
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
                      amount!,
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
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor ?? Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status!,
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: statusTextColor ?? Colors.grey.shade700,
                      ),
                    ),
                  ),
                if (statusPendingText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    statusPendingText!,
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
  _PaymentUIModel(
    name: 'Marcus Lee',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1,000',
    status: 'Cash',
    statusColor: const Color(0xffE8F5E9),
    statusTextColor: const Color(0xff2E7D32),
    showAmountPill: true,
  ),
  _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1,000',
    status: 'UPI',
    statusColor: const Color(0xffE3F2FD),
    statusTextColor: const Color(0xff1565C0),
    showAmountPill: true,
  ),
  _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹1500',
    status: 'Online',
    statusColor: const Color(0xffFFEBEE),
    statusTextColor: const Color(0xffC62828),
    statusPendingText: 'Status: Pending',
    showAmountPill: true,
  ),
  _PaymentUIModel(
    name: 'Sarah Lopez',
    time: '07:30 AM, Today',
    planName: '1 Month Plan',
    description: 'Membership + 1 Month Plan',
    amount: '₹2,000',
    status: 'EMI',
    statusColor: const Color(0xffF3E5F5),
    statusTextColor: const Color(0xff7B1FA2),
    showAmountPill: true,
  ),
];

final _processingPaymentsData = [
  _PaymentUIModel(
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
  _PaymentUIModel(
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
