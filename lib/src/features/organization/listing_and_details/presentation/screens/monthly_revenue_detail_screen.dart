import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class MonthlyRevenueDetailScreen extends StatefulWidget {
  const MonthlyRevenueDetailScreen({
    required this.orgId,
    super.key,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
    this.initialRevenues,
    this.initialPlanRevenueBreakdown,
    this.initialPaymentModes,
    this.initialRevenueCategories,
  });

  final int orgId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;
  final List<Map<String, dynamic>>? initialRevenues;
  final List<dynamic>? initialPlanRevenueBreakdown;
  final List<dynamic>? initialPaymentModes;
  final List<Map<String, dynamic>>? initialRevenueCategories;

  @override
  State<MonthlyRevenueDetailScreen> createState() =>
      _MonthlyRevenueDetailScreenState();
}

class _MonthlyRevenueDetailScreenState
    extends State<MonthlyRevenueDetailScreen> {
  bool _isLoading = false;
  bool _isRecentRevenueExpanded = false;
  bool _isPaymentModeExpanded = false;
  bool _hasChanges = false;

  List<Map<String, dynamic>> _revenues = [];
  List<dynamic> _planRevenueBreakdown = [];
  List<dynamic> _paymentModes = [];
  List<Map<String, dynamic>> _revenueCategories = [];

  @override
  void initState() {
    super.initState();
    _revenues = widget.initialRevenues != null
        ? List<Map<String, dynamic>>.from(widget.initialRevenues!)
        : [];
    _planRevenueBreakdown = widget.initialPlanRevenueBreakdown != null
        ? List<dynamic>.from(widget.initialPlanRevenueBreakdown!)
        : [];
    _paymentModes = widget.initialPaymentModes != null
        ? List<dynamic>.from(widget.initialPaymentModes!)
        : [];
    _revenueCategories = widget.initialRevenueCategories != null
        ? List<Map<String, dynamic>>.from(widget.initialRevenueCategories!)
        : [];

    if (_revenues.isEmpty && _planRevenueBreakdown.isEmpty && _paymentModes.isEmpty) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final year = widget.year ?? now.year;
    final month = widget.month ?? now.month;

    var queryParams = 'organization_id=${widget.orgId}&year=$year&month=$month';
    if (widget.startDate != null && widget.endDate != null) {
      final startStr = DateFormat('yyyy-MM-dd').format(widget.startDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(widget.endDate!);
      queryParams += '&start_date=$startStr&end_date=$endStr';
    }

    try {
      // 1. Fetch reports for breakdown
      final reportsResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.reports}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (reportsResponse.statusCode == 200 && reportsResponse.data is Map) {
        final reportsData = reportsResponse.data as Map<dynamic, dynamic>;
        final financial = reportsData['financial_metrics'] as Map<dynamic, dynamic>?;
        final plans = financial?['plan_revenue_breakdown'] as List<dynamic>? ?? [];

        final paymentModeData = financial?['payment_mode_breakdown'] ??
            financial?['payment_modes'] ??
            reportsData['payment_mode_breakdown'] ??
            reportsData['payment_modes'];

        final parsedPaymentModes = <Map<String, dynamic>>[];
        if (paymentModeData is Map) {
          paymentModeData.forEach((key, value) {
            final amt = double.tryParse(value.toString()) ?? 0.0;
            parsedPaymentModes.add({
              'mode': key.toString(),
              'amount': amt,
            });
          });
        } else if (paymentModeData is List) {
          for (final item in paymentModeData) {
            if (item is Map) {
              final mode = item['payment_mode'] ?? item['mode'] ?? 'Unknown';
              final amt = double.tryParse((item['amount'] ?? item['total'] ?? 0.0).toString()) ?? 0.0;
              parsedPaymentModes.add({
                'mode': mode.toString(),
                'amount': amt,
              });
            }
          }
        }
        parsedPaymentModes.sort((a, b) =>
            (b['amount'] as double).compareTo(a['amount'] as double));

        if (mounted) {
          setState(() {
            _planRevenueBreakdown = plans;
            _paymentModes = parsedPaymentModes;
          });
        }
      }
    } catch (_) {}

    try {
      // 2. Fetch revenues list
      final revenuesResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenues}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (revenuesResponse.statusCode == 200) {
        final data = revenuesResponse.data;
        var list = <dynamic>[];
        if (data is List) {
          list = data;
        } else if (data is Map && data['results'] is List) {
          list = data['results'] as List;
        } else if (data is Map && data['revenues'] is List) {
          list = data['revenues'] as List;
        }
        if (mounted) {
          setState(() {
            _revenues =
                list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        }
      }
    } catch (_) {}

    try {
      // 3. Fetch categories
      final catResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenueCategories}?organization_id=${widget.orgId}',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (catResponse.statusCode == 200) {
        final data = catResponse.data;
        var list = <dynamic>[];
        if (data is List) {
          list = data;
        } else if (data is Map && data['results'] is List) {
          list = data['results'] as List;
        }
        if (mounted) {
          setState(() {
            _revenueCategories =
                list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddOrEditRevenueSheet({Map<String, dynamic>? revenue}) {
    final isEdit = revenue != null;
    final revId = isEdit
        ? (revenue['id'] as int? ??
            int.tryParse(revenue['id']?.toString() ?? '') ??
            0)
        : 0;

    final titleController = TextEditingController(
      text: (revenue?['title'] as String?) ??
          (revenue?['name'] as String?) ??
          '',
    );
    final amountController = TextEditingController(
      text: revenue?['amount']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: (revenue?['notes'] as String?) ??
          (revenue?['description'] as String?) ??
          '',
    );

    var selectedCategory = (revenue?['category'] as String?) ??
        (revenue?['category_name'] as String?) ??
        'Membership Fee';

    var selectedDate = revenue?['revenue_date'] != null ||
            revenue?['date'] != null
        ? DateTime.tryParse(
                (revenue?['revenue_date'] ?? revenue?['date']).toString(),
              ) ??
            DateTime.now()
        : DateTime.now();

    final defaultCategories = [
      'Membership Fee',
      'Admission Fee',
      'Product Sales',
      'Others',
    ];

    for (final cat in _revenueCategories) {
      final catName = cat['name']?.toString() ?? cat['title']?.toString();
      if (catName != null &&
          catName.isNotEmpty &&
          !defaultCategories.contains(catName)) {
        defaultCategories.add(catName);
      }
    }

    if (!defaultCategories.contains(selectedCategory)) {
      defaultCategories.add(selectedCategory);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Revenue' : 'Add Revenue',
                          style: AppStyles.text18Px.poppins.w600.dark,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title / Description',
                        hintText: 'e.g. Membership, Protein powder',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        hintText: 'e.g. 5000',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: defaultCategories.contains(selectedCategory)
                          ? selectedCategory
                          : 'Others',
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: defaultCategories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: AppStyles.text14Px.poppins.w500.dark,
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount =
                              double.tryParse(amountController.text.trim()) ??
                              0.0;
                          if (title.isEmpty || amount <= 0) {
                            unawaited(Dialogs.showSnack(
                              msg: 'Please provide valid title and amount.',
                            ));
                            return;
                          }

                          Navigator.pop(context);

                          final body = {
                            'organization_id': widget.orgId,
                            'title': title,
                            'category': selectedCategory,
                            'amount': amount,
                            'revenue_date': DateFormat('yyyy-MM-dd').format(
                              selectedDate,
                            ),
                            'notes': notesController.text.trim(),
                          };

                          try {
                            Response<dynamic>? res;
                            if (isEdit) {
                              res = await DioClient().dio.patch<dynamic>(
                                ApiUris.revenueDetail(revId),
                                data: body,
                                options: Options(
                                  headers: {'X-Platform': platformSource},
                                ).token,
                              );
                            } else {
                              res = await DioClient().dio.post<dynamic>(
                                ApiUris.revenues,
                                data: body,
                                options: Options(
                                  headers: {'X-Platform': platformSource},
                                ).token,
                              );
                            }

                            if (res.statusCode == 200 ||
                                res.statusCode == 201) {
                              _hasChanges = true;
                              unawaited(Dialogs.showSnack(
                                msg: isEdit
                                    ? 'Revenue updated successfully!'
                                    : 'Revenue added successfully!',
                              ));
                              await _fetchData();
                            } else {
                              unawaited(Dialogs.showSnack(
                                msg: isEdit
                                    ? 'Failed to update revenue: ${res.statusCode}'
                                    : 'Failed to add revenue: ${res.statusCode}',
                              ));
                            }
                          } catch (e) {
                            unawaited(Dialogs.showSnack(msg: 'Error: $e'));
                          }
                        },
                        child: Text(
                          isEdit ? 'Update Revenue' : 'Save Revenue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteRevenue(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Revenue'),
        content: const Text(
          'Are you sure you want to delete this revenue record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.revenueDetail(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _hasChanges = true;
        if (mounted) {
          setState(() {
            _revenues.removeWhere(
              (r) =>
                  r['id'] == id ||
                  r['id']?.toString() == id.toString(),
            );
          });
        }
        unawaited(Dialogs.showSnack(
          msg: 'Revenue record deleted successfully',
        ));
        await _fetchData();
      } else {
        unawaited(Dialogs.showSnack(
          msg: 'Failed to delete revenue record',
        ));
      }
    } catch (_) {
      unawaited(Dialogs.showSnack(
        msg: 'Error deleting revenue record',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: PopButton(
            onPressed: () => Navigator.pop(context, _hasChanges),
          ).center,
        title: Text(
          'Monthly Revenue',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        centerTitle: true,
      ),
      body: _isLoading && _revenues.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: [
                  _buildRecentRevenueSection(),
                  const SizedBox(height: 24),
                  _buildPlanRevenueBreakdownSection(),
                  const SizedBox(height: 24),
                  _buildPaymentModeSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      ),
    );
  }

  // ================= 1. RECENT REVENUE SECTION =================
  Widget _buildRecentRevenueSection() {
    final displayList = _isRecentRevenueExpanded
        ? _revenues
        : _revenues.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Revenue',
              style: AppStyles.text18Px.poppins.w600.dark,
            ),
            GestureDetector(
              onTap: _showAddOrEditRevenueSheet,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xff27AE60),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _revenues.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No recent revenues recorded',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xffF2F2F2)),
                      itemBuilder: (context, index) {
                        final rev = displayList[index];
                        final id = rev['id'] as int? ??
                            int.tryParse(rev['id']?.toString() ?? '') ??
                            0;
                        final title = rev['title']?.toString() ??
                            rev['name']?.toString() ??
                            'Membership';
                        final category = rev['category']?.toString() ??
                            rev['category_name']?.toString() ??
                            'Plan';
                        final dateStr = rev['revenue_date']?.toString() ??
                            rev['date']?.toString() ??
                            '';
                        final notes = rev['notes']?.toString() ?? '';

                        final subtitleText = notes.isNotEmpty
                            ? '$notes | $dateStr'
                            : '$category | $dateStr';

                        final amountVal = rev['amount'] ?? 0.0;
                        final amount = amountVal is num
                            ? amountVal.toDouble()
                            : double.tryParse(amountVal.toString()) ?? 0.0;

                        final formattedAmount = NumberFormat('#,##,###')
                            .format(amount.round());

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: AppStyles
                                          .text14Px
                                          .poppins
                                          .w600
                                          .dark,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitleText,
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+₹$formattedAmount',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xff27AE60),
                                ),
                              ),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showAddOrEditRevenueSheet(revenue: rev);
                                  } else if (val == 'delete') {
                                    _deleteRevenue(id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (_revenues.length > 3) ...[
                      const Divider(height: 1, color: Color(0xffF2F2F2)),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isRecentRevenueExpanded =
                                !_isRecentRevenueExpanded;
                          });
                        },
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isRecentRevenueExpanded
                                          ? 'collapse'
                                          : 'expand',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isRecentRevenueExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 14,
                                      color: AppColors.textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLeadingAvatar({required bool isProduct, String? avatarUrl}) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xffEFEFEF),
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    if (isProduct) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xffD9D9D9),
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xffE5E7EB),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Color(0xff6B7280),
        size: 22,
      ),
    );
  }

  // ================= 2. PLAN REVENUE BREAKDOWN SECTION =================
  Widget _buildPlanRevenueBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Revenue Breakdown',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _planRevenueBreakdown.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No plan revenue breakdown available',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                )
              : _buildDonutChartWithLegend(_planRevenueBreakdown),
        ),
      ],
    );
  }

  Widget _buildDonutChartWithLegend(List<dynamic> plans) {
    const palette = [
      Color(0xff486CC2),
      Color(0xffC2486C),
      Color(0xffF39C12),
      Color(0xff527F50),
      Color(0xff9C51BF),
      Color(0xffE74C3C),
      Color(0xff1ABC9C),
      Color(0xff34495E),
    ];

    final slices =
        <({String label, double percentage, String subtext, Color color})>[];

    for (var i = 0; i < plans.length; i++) {
      final plan = plans[i] as Map<dynamic, dynamic>;
      final name = plan['plan_name']?.toString() ?? 'Plan';
      final type = plan['package_type']?.toString() ?? '';
      final subscribers = plan['subscribers_count'] ?? 0;
      final pctStr = plan['percentage']?.toString() ?? '0%';

      var pct = 0.0;
      try {
        pct = double.parse(pctStr.replaceAll('%', ''));
      } catch (_) {}

      slices.add((
        label: name,
        percentage: pct,
        subtext: '$type • $subscribers subscribers',
        color: palette[i % palette.length],
      ));
    }

    return Row(
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: CustomPaint(
            painter: _RevenueDonutChartPainter(
              slices: slices
                  .map((s) => (percentage: s.percentage, color: s.color))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices.map((slice) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: slice.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slice.label,
                            style: AppStyles.text13Px.poppins.w600.dark,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            slice.subtext,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${slice.percentage.toStringAsFixed(1)}%',
                      style: AppStyles.text12Px.poppins.w600.dark,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ================= 3. PAYMENT MODE SECTION =================
  Widget _buildPaymentModeSection() {
    // If empty, supply fallback common payment modes with 0 amount
    final modesList = <Map<String, dynamic>>[];
    if (_paymentModes.isNotEmpty) {
      for (final item in _paymentModes) {
        if (item is Map) {
          modesList.add(Map<String, dynamic>.from(item));
        }
      }
    } else {
      modesList.addAll([
        {'mode': 'Cash Payment', 'amount': 0.0},
        {'mode': 'UPI Payment', 'amount': 0.0},
        {'mode': 'EMI Payment', 'amount': 0.0},
      ]);
    }

    final displayModes = _isPaymentModeExpanded
        ? modesList
        : modesList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Mode',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayModes.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xffF2F2F2)),
                itemBuilder: (context, index) {
                  final item = displayModes[index];
                  final rawMode = item['mode']?.toString() ?? 'Other';
                  final amountVal = item['amount'] ?? 0.0;
                  final amount = amountVal is num
                      ? amountVal.toDouble()
                      : double.tryParse(amountVal.toString()) ?? 0.0;

                  final title = _formatPaymentModeTitle(rawMode);
                  final style = _getPaymentModeStyle(rawMode);

                  final formattedAmount =
                      NumberFormat('#,##,###').format(amount.round());
                  final amountString = amount > 0
                      ? (rawMode.toLowerCase().contains('cash')
                          ? '+₹$formattedAmount'
                          : '₹$formattedAmount')
                      : '₹0';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: style.bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            style.icon,
                            color: style.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: AppStyles.text14Px.poppins.w600.dark,
                          ),
                        ),
                        Text(
                          amountString,
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: const Color(0xff27AE60),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (modesList.length > 3) ...[
                const Divider(height: 1, color: Color(0xffF2F2F2)),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPaymentModeExpanded = !_isPaymentModeExpanded;
                    });
                  },
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isPaymentModeExpanded ? 'collapse' : 'expand',
                                style: AppStyles.text12Px.poppins.w400
                                    .copyWith(color: AppColors.textGrey),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isPaymentModeExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatPaymentModeTitle(String rawMode) {
    final lower = rawMode.toLowerCase();
    if (lower.contains('cash')) return 'Cash Payment';
    if (lower.contains('upi') ||
        lower.contains('gpay') ||
        lower.contains('phonepe') ||
        lower.contains('paytm')) {
      return 'UPI Payment';
    }
    if (lower.contains('emi')) return 'EMI Payment';
    if (lower.contains('card') ||
        lower.contains('credit') ||
        lower.contains('debit')) {
      return 'Card Payment';
    }
    if (lower.contains('net') ||
        lower.contains('bank') ||
        lower.contains('transfer')) {
      return 'Bank Transfer';
    }
    return rawMode;
  }

  ({IconData icon, Color bgColor, Color iconColor}) _getPaymentModeStyle(
    String rawMode,
  ) {
    final lower = rawMode.toLowerCase();
    if (lower.contains('cash')) {
      return (
        icon: Icons.payments_rounded,
        bgColor: const Color(0xffE8F8F0),
        iconColor: const Color(0xff27AE60),
      );
    }
    if (lower.contains('upi') ||
        lower.contains('gpay') ||
        lower.contains('phonepe') ||
        lower.contains('paytm')) {
      return (
        icon: Icons.qr_code_scanner_rounded,
        bgColor: const Color(0xffE8F4FD),
        iconColor: const Color(0xff2980B9),
      );
    }
    if (lower.contains('emi')) {
      return (
        icon: Icons.credit_card_rounded,
        bgColor: const Color(0xffFBF0F8),
        iconColor: const Color(0xff9B59B6),
      );
    }
    if (lower.contains('card')) {
      return (
        icon: Icons.credit_card,
        bgColor: const Color(0xffFDEDEC),
        iconColor: const Color(0xffE74C3C),
      );
    }
    return (
      icon: Icons.account_balance_wallet_rounded,
      bgColor: const Color(0xffFEF9E7),
      iconColor: const Color(0xffF39C12),
    );
  }
}

class _RevenueDonutChartPainter extends CustomPainter {
  _RevenueDonutChartPainter({required this.slices});

  final List<({double percentage, Color color})> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total =
        slices.fold<double>(0, (sum, item) => sum + item.percentage);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 18.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    if (total <= 0) {
      final bgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0xffEEEEEE);
      canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);
      return;
    }

    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.percentage <= 0) continue;
      final sweepAngle = (slice.percentage / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = slice.color
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueDonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
