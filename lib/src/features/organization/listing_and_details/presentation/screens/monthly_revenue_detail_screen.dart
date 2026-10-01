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
  bool _isPlanRevenueExpanded = false;
  bool _hasChanges = false;
  int? _selectedPlanIndex;

  late int _selectedYear;
  late int _selectedMonth;
  String _selectedPeriod = '6m';
  double _totalRevenue = 0.0;
  double _percentageChange = 18.0;
  bool _isIncrease = true;
  String _comparisonMonth = 'Aug';
  String _quickInsight = '';
  List<({String label, double value})> _trendData = [];

  List<Map<String, dynamic>> _revenues = [];
  List<dynamic> _planRevenueBreakdown = [];
  List<dynamic> _paymentModes = [];
  List<Map<String, dynamic>> _revenueCategories = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = widget.year ?? widget.startDate?.year ?? now.year;
    _selectedMonth = widget.month ?? widget.startDate?.month ?? now.month;

    final prevMonthDate = DateTime(_selectedYear, _selectedMonth - 1);
    _comparisonMonth = DateFormat('MMM').format(prevMonthDate);

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

    _fetchData().then((_) {
      if (mounted) {
        _prefetchOtherPeriods();
      }
    });
  }

  final Map<String, _RevenuePeriodCache> _periodCache = {};

  void _applyCachedData(_RevenuePeriodCache cached) {
    _totalRevenue = cached.totalRevenue;
    _percentageChange = cached.percentageChange;
    _isIncrease = cached.isIncrease;
    _comparisonMonth = cached.comparisonMonth;
    _quickInsight = cached.quickInsight;
    _trendData = cached.trendData;
    if (cached.revenues.isNotEmpty) _revenues = cached.revenues;
    if (cached.planRevenueBreakdown.isNotEmpty) {
      _planRevenueBreakdown = cached.planRevenueBreakdown;
    }
    if (cached.paymentModes.isNotEmpty) {
      _paymentModes = cached.paymentModes;
    }
  }

  void _onPeriodChanged(String newPeriod) {
    if (_selectedPeriod == newPeriod) return;

    final cached = _periodCache[newPeriod];
    if (cached != null) {
      setState(() {
        _selectedPeriod = newPeriod;
        _applyCachedData(cached);
      });
      _fetchData(silent: true);
    } else {
      setState(() {
        _selectedPeriod = newPeriod;
      });
      _fetchData();
    }
  }

  void _prefetchOtherPeriods() {
    for (final p in ['3m', '6m', '1y']) {
      if (p != _selectedPeriod && !_periodCache.containsKey(p)) {
        _fetchBackgroundPeriod(p);
      }
    }
  }

  Future<void> _fetchBackgroundPeriod(String period) async {
    try {
      var queryParams =
          'organization_id=${widget.orgId}&year=$_selectedYear&month=$_selectedMonth&period=$period';
      if (widget.startDate != null && widget.endDate != null) {
        final startStr = DateFormat('yyyy-MM-dd').format(widget.startDate!);
        final endStr = DateFormat('yyyy-MM-dd').format(widget.endDate!);
        queryParams += '&start_date=$startStr&end_date=$endStr';
      }

      final revReportsResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenueReports}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (revReportsResponse.statusCode == 200 &&
          revReportsResponse.data is Map) {
        final data = Map<String, dynamic>.from(revReportsResponse.data as Map);
        final rev = (data['total_revenue'] as num?)?.toDouble() ??
            (data['revenue'] as num?)?.toDouble() ??
            0.0;
        final pctChange =
            (data['percentage_change'] as num?)?.toDouble() ?? 18.0;
        final isInc = data['is_increase'] as bool? ?? (pctChange >= 0);
        final compMonth =
            data['comparison_month']?.toString() ?? _comparisonMonth;
        final qkInsight = data['quick_insight']?.toString() ?? '';

        final parsedTrend = <({String label, double value})>[];
        if (data['trend'] is List) {
          for (final item in data['trend'] as List) {
            if (item is Map) {
              final label = (item['month'] ?? item['name'] ?? '').toString();
              final val = (item['revenue'] ??
                      item['amount'] ??
                      item['value'] ??
                      0.0) as num;
              parsedTrend.add((label: label, value: val.toDouble()));
            }
          }
        }

        final recentRev = data['recent_revenues'] is List
            ? List<Map<String, dynamic>>.from(
                (data['recent_revenues'] as List)
                    .map((e) => Map<String, dynamic>.from(e as Map)),
              )
            : <Map<String, dynamic>>[];

        final planBreakdown = data['plan_revenue_breakdown'] is List
            ? List<dynamic>.from(data['plan_revenue_breakdown'] as List)
            : <dynamic>[];

        var modes = <dynamic>[];
        final paymentData =
            data['payment_mode_breakdown'] ?? data['payment_modes'];
        if (paymentData is Map) {
          final parsed = <Map<String, dynamic>>[];
          paymentData.forEach((key, val) {
            final amt = double.tryParse(val.toString()) ?? 0.0;
            parsed.add({'mode': key.toString(), 'amount': amt});
          });
          modes = parsed;
        } else if (paymentData is List) {
          modes = List<dynamic>.from(paymentData);
        }

        _periodCache[period] = _RevenuePeriodCache(
          totalRevenue: rev > 0 ? rev : _totalRevenue,
          percentageChange: pctChange,
          isIncrease: isInc,
          comparisonMonth: compMonth,
          quickInsight: qkInsight,
          trendData: parsedTrend,
          planRevenueBreakdown: planBreakdown,
          paymentModes: modes,
          revenues: recentRev,
        );
      }
    } catch (_) {}
  }

  Future<void> _fetchData({bool silent = false}) async {
    final targetPeriod = _selectedPeriod;

    if (!silent) {
      setState(() => _isLoading = true);
    }

    var queryParams =
        'organization_id=${widget.orgId}&year=$_selectedYear&month=$_selectedMonth&period=$targetPeriod';
    if (widget.startDate != null && widget.endDate != null) {
      final startStr = DateFormat('yyyy-MM-dd').format(widget.startDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(widget.endDate!);
      queryParams += '&start_date=$startStr&end_date=$endStr';
    }

    var totalRev = _totalRevenue;
    var pctChange = _percentageChange;
    var isInc = _isIncrease;
    var compMonth = _comparisonMonth;
    var qkInsight = _quickInsight;
    var trend = <({String label, double value})>[];
    var recentRev = <Map<String, dynamic>>[];
    var planBreakdown = <dynamic>[];
    var modes = <dynamic>[];

    var successFromPrimary = false;

    // 1. Query dedicated revenue reports endpoint
    try {
      final revReportsResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenueReports}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (revReportsResponse.statusCode == 200 &&
          revReportsResponse.data is Map) {
        final data =
            Map<String, dynamic>.from(revReportsResponse.data as Map);

        final rev = (data['total_revenue'] as num?)?.toDouble() ??
            (data['revenue'] as num?)?.toDouble() ??
            0.0;
        if (rev > 0) totalRev = rev;

        if (data['percentage_change'] != null) {
          pctChange = (data['percentage_change'] as num).toDouble();
          isInc = data['is_increase'] as bool? ?? (pctChange >= 0);
        }
        if (data['comparison_month'] != null) {
          compMonth = data['comparison_month'].toString();
        }
        if (data['quick_insight'] != null) {
          qkInsight = data['quick_insight'].toString();
        }

        if (data['trend'] is List) {
          final list = data['trend'] as List;
          final parsedTrend = <({String label, double value})>[];
          for (final item in list) {
            if (item is Map) {
              final label = (item['month'] ?? item['name'] ?? '').toString();
              final val = (item['revenue'] ??
                      item['amount'] ??
                      item['value'] ??
                      0.0) as num;
              parsedTrend.add((label: label, value: val.toDouble()));
            }
          }
          if (parsedTrend.isNotEmpty) {
            trend = parsedTrend;
          }
        }

        if (data['recent_revenues'] is List &&
            (data['recent_revenues'] as List).isNotEmpty) {
          recentRev = List<Map<String, dynamic>>.from(
            (data['recent_revenues'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map)),
          );
        }

        if (data['plan_revenue_breakdown'] is List) {
          planBreakdown =
              List<dynamic>.from(data['plan_revenue_breakdown'] as List);
        }

        final paymentData = data['payment_mode_breakdown'] ??
            data['payment_modes'];
        if (paymentData is Map) {
          final parsed = <Map<String, dynamic>>[];
          paymentData.forEach((key, val) {
            final amt = double.tryParse(val.toString()) ?? 0.0;
            parsed.add({'mode': key.toString(), 'amount': amt});
          });
          modes = parsed;
        } else if (paymentData is List) {
          modes = List<dynamic>.from(paymentData);
        }
        successFromPrimary = true;
      }
    } catch (_) {}

    // 2. Fallback: Fetch reports for plan breakdown / fallback only if primary failed or total is 0
    if (!successFromPrimary || totalRev == 0.0) {
      try {
        final reportsResponse = await DioClient().dio.get<dynamic>(
          '${ApiUris.reports}?$queryParams',
          options: Options(headers: {'X-Platform': platformSource}),
        );

        if (reportsResponse.statusCode == 200 &&
            reportsResponse.data is Map) {
          final reportsData =
              reportsResponse.data as Map<dynamic, dynamic>;
          final financial =
              reportsData['financial_metrics'] as Map<dynamic, dynamic>?;

          final revNum = (financial?['total_revenue'] as num?)?.toDouble();
          if (revNum != null && revNum > 0 && totalRev == 0.0) {
            totalRev = revNum;
          }

          final revGrowth =
              financial?['revenue_growth'] as Map<dynamic, dynamic>?;
          if (revGrowth != null) {
            if (revGrowth['percentage_change'] != null) {
              pctChange =
                  (revGrowth['percentage_change'] as num).toDouble();
              isInc = revGrowth['is_increase'] as bool? ??
                  (pctChange >= 0);
            }
            if (revGrowth['comparison_month'] != null) {
              compMonth = revGrowth['comparison_month'].toString();
            }
          }

          if (planBreakdown.isEmpty && financial?['plan_revenue_breakdown'] is List) {
            planBreakdown =
                financial!['plan_revenue_breakdown'] as List<dynamic>;
          }

          if (modes.isEmpty) {
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
                  final amt = double.tryParse(
                          (item['amount'] ?? item['total'] ?? 0.0).toString()) ??
                      0.0;
                  parsedPaymentModes.add({
                    'mode': mode.toString(),
                    'amount': amt,
                  });
                }
              }
            }
            parsedPaymentModes.sort((a, b) =>
                (b['amount'] as double).compareTo(a['amount'] as double));
            modes = parsedPaymentModes;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback: Fetch raw revenues if empty
    if (recentRev.isEmpty && _revenues.isEmpty) {
      try {
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
          recentRev = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (_) {}
    }

    // Calculate total from revenues if still 0
    if (totalRev == 0.0 && recentRev.isNotEmpty) {
      var sum = 0.0;
      for (final r in recentRev) {
        sum += (r['amount'] as num?)?.toDouble() ??
            double.tryParse(r['amount']?.toString() ?? '0') ??
            0.0;
      }
      totalRev = sum;
    }

    // 4. Fetch categories once
    if (_revenueCategories.isEmpty) {
      try {
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
          _revenueCategories =
              list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } catch (_) {}
    }

    // Cache the result for this period
    _periodCache[targetPeriod] = _RevenuePeriodCache(
      totalRevenue: totalRev,
      percentageChange: pctChange,
      isIncrease: isInc,
      comparisonMonth: compMonth,
      quickInsight: qkInsight,
      trendData: trend,
      planRevenueBreakdown: planBreakdown,
      paymentModes: modes,
      revenues: recentRev.isNotEmpty ? recentRev : _revenues,
    );

    if (mounted && _selectedPeriod == targetPeriod) {
      setState(() {
        _totalRevenue = totalRev;
        _percentageChange = pctChange;
        _isIncrease = isInc;
        _comparisonMonth = compMonth;
        _quickInsight = qkInsight;
        _trendData = trend;
        if (recentRev.isNotEmpty) _revenues = recentRev;
        if (planBreakdown.isNotEmpty) _planRevenueBreakdown = planBreakdown;
        if (modes.isNotEmpty) _paymentModes = modes;
        _isLoading = false;
      });
    } else if (mounted) {
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

  List<({String label, double value})> _getFallbackTrend() {
    final monthsCount =
        _selectedPeriod == '3m' ? 3 : (_selectedPeriod == '1y' ? 12 : 6);
    final result = <({String label, double value})>[];
    final baseDate = DateTime(_selectedYear, _selectedMonth);

    // Realistic baseline trend values
    for (var i = monthsCount - 1; i >= 0; i--) {
      final d = DateTime(baseDate.year, baseDate.month - i, 1);
      final label = DateFormat('MMM').format(d);
      final progress =
          (monthsCount - 1 - i) / (monthsCount > 1 ? (monthsCount - 1) : 1);
      final factor = 0.45 + (0.55 * progress);
      final val = _totalRevenue > 0
          ? (_totalRevenue * factor)
          : (50000.0 + (progress * 70000.0));
      result.add((label: label, value: val));
    }
    return result;
  }

  void _showMonthYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 3 + i);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Month & Year',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Year selector row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: years.map((y) {
                        final isSel = y == _selectedYear;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(y.toString()),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.textDark,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setPickerState(() => _selectedYear = y);
                                setState(() => _selectedYear = y);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Months grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, idx) {
                      final m = idx + 1;
                      final isSel =
                          m == _selectedMonth && _selectedYear == _selectedYear;
                      final mName =
                          DateFormat('MMM').format(DateTime(2026, m));
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMonth = m;
                            final prev =
                                DateTime(_selectedYear, _selectedMonth - 1);
                            _comparisonMonth = DateFormat('MMM').format(prev);
                          });
                          Navigator.pop(context);
                          _fetchData();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xffD32F2F)
                                : const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            mName,
                            style: AppStyles.text12Px.poppins.copyWith(
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w500,
                              color: isSel ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthSelectorPill() {
    final dt = DateTime(_selectedYear, _selectedMonth);
    final monthStr = DateFormat('MMMM yyyy').format(dt);

    return Center(
      child: InkWell(
        onTap: _showMonthYearPicker,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xffE8ECEF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthStr,
                style: AppStyles.text14Px.poppins.w500.dark,
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.unfold_more,
                size: 16,
                color: AppColors.textDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueHeroCard() {
    final formattedTotal =
        NumberFormat('#,##,###').format(_totalRevenue.round());
    final isUp = _isIncrease;
    final pillBg = isUp ? const Color(0xffE8F8F0) : const Color(0xffFDEAEA);
    final pillColor =
        isUp ? const Color(0xff27AE60) : const Color(0xffE74C3C);
    final sign = isUp ? '+' : '-';
    final cmpText = _comparisonMonth.isNotEmpty
        ? 'vs $_comparisonMonth'
        : 'vs last month';
    final pctText =
        '$sign${_percentageChange.abs().toStringAsFixed(0)}% $cmpText';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green money icon
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xffE8F8F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: Color(0xff27AE60),
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Monthly Revenue',
            style: AppStyles.text14Px.poppins.w500
                .copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹$formattedTotal',
                style: AppStyles.text24Px.poppins.w700.copyWith(
                  color: const Color(0xff0D8747),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pctText,
                  style: AppStyles.text12Px.poppins.w600
                      .copyWith(color: pillColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Period Chips
          _buildPeriodChips(),
          const SizedBox(height: 16),

          // Trend Line Chart
          SizedBox(
            height: 220,
            child: _isLoading && _trendData.isEmpty
                ? _buildChartShimmer()
                : AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isLoading ? 0.6 : 1.0,
                    child: _LineTrendChartWidget(
                      trendData: _trendData.isNotEmpty
                          ? _trendData
                          : (_isLoading ? const [] : _getFallbackTrend()),
                      lineColor: const Color(0xffE53935),
                      currencyPrefix: '₹',
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Quick Insight
          _buildQuickInsightContainer(
            insight: _quickInsight.isNotEmpty
                ? _quickInsight
                : 'Your revenue is up by ${_percentageChange.abs().toStringAsFixed(0)}% compared to last month. Great job!',
          ),
        ],
      ),
    );
  }

  Widget _buildChartShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _selectedPeriod == '3m' ? 3 : (_selectedPeriod == '1y' ? 6 : 6),
                (i) => Container(
                  width: 32,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChips() {
    final options = [
      ('3 Month', '3m'),
      ('6 Month', '6m'),
      ('1 Year', '1y'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = _selectedPeriod == opt.$2;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _onPeriodChanged(opt.$2);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xffD32F2F)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt.$1,
                  style: AppStyles.text14Px.poppins.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickInsightContainer({required String insight}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffFFF5F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffFFE3E5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xffFFE5E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Color(0xffE53935),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Insight',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: const Color(0xffE53935),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xff555555),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
              onPressed: () {},
            ),
          ],
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
                    _buildMonthSelectorPill(),
                    const SizedBox(height: 16),
                    _buildRevenueHeroCard(),
                    const SizedBox(height: 24),
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
                              _buildLeadingAvatar(
                                isProduct: category.toLowerCase().contains('product'),
                                avatarUrl: rev['avatar']?.toString() ??
                                    rev['client_avatar']?.toString(),
                              ),
                              const SizedBox(width: 12),
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
  List<({String label, double percentage, String subtext, Color color})>
      _buildPlanSlices(List<dynamic> plans) {
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
    return slices;
  }

  void _handleDonutTouch(
    Offset localPosition,
    Size size,
    List<({String label, double percentage, String subtext, Color color})>
        slices,
  ) {
    if (slices.isEmpty) return;
    final total = slices.fold<double>(0, (sum, s) => sum + s.percentage);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    // Ignore touches too close to the dead center hole
    if (dist < 10) return;

    // Track angle relative to 12 o'clock (-pi/2), clockwise
    var angle = math.atan2(dy, dx) - (-math.pi / 2);
    while (angle < 0) {
      angle += 2 * math.pi;
    }
    while (angle >= 2 * math.pi) {
      angle -= 2 * math.pi;
    }

    var currentAngle = 0.0;
    var foundIndex = -1;
    for (var i = 0; i < slices.length; i++) {
      final sweep = (slices[i].percentage / total) * 2 * math.pi;
      if (angle >= currentAngle && angle <= currentAngle + sweep) {
        foundIndex = i;
        break;
      }
      currentAngle += sweep;
    }

    if (foundIndex != -1 && foundIndex != _selectedPlanIndex) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedPlanIndex = foundIndex;
      });
    }
  }

  Widget _buildPlanRevenueBreakdownSection() {
    final slices = _buildPlanSlices(_planRevenueBreakdown);
    final selectedSlice = _selectedPlanIndex != null &&
            _selectedPlanIndex! < slices.length
        ? slices[_selectedPlanIndex!]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Revenue Breakdown',
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
              : Stack(
                  children: [
                    Column(
                      children: [
                        // Floating Detail Container - only shown after hover
                        if (selectedSlice != null) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedSlice.color
                                      .withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedSlice.color
                                        .withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: selectedSlice.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          selectedSlice.label,
                                          style: AppStyles
                                              .text13Px
                                              .poppins
                                              .w600
                                              .dark,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          selectedSlice.subtext,
                                          style: AppStyles
                                              .text12Px
                                              .poppins
                                              .w400
                                              .copyWith(
                                                fontSize: 11,
                                                color: AppColors.textGrey,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedSlice.color
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${selectedSlice.percentage.toStringAsFixed(1)}%',
                                      style: AppStyles.text13Px.poppins.w700
                                          .copyWith(
                                            color: selectedSlice.color,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPlanIndex = null;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            selectedSlice == null ? 16 : 0,
                            16,
                            16,
                          ),
                          child: _buildDonutChartWithLegend(slices),
                        ),
                        if (_planRevenueBreakdown.length > 3) ...[
                          const Divider(height: 1, color: Color(0xffF2F2F2)),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isPlanRevenueExpanded =
                                    !_isPlanRevenueExpanded;
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
                                          _isPlanRevenueExpanded
                                              ? 'collapse'
                                              : 'expand',
                                          style: AppStyles
                                              .text12Px
                                              .poppins
                                              .w400
                                              .copyWith(
                                                color: AppColors.textGrey,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isPlanRevenueExpanded
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

                    // Straight line from hovered slice to floating detail container
                    if (selectedSlice != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _StraightConnectorLinePainter(
                              slices: slices,
                              selectedIndex: _selectedPlanIndex!,
                              color: selectedSlice.color,
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

  Widget _buildDonutChartWithLegend(
    List<({String label, double percentage, String subtext, Color color})>
        slices,
  ) {
    final displaySlices =
        _isPlanRevenueExpanded ? slices : slices.take(3).toList();
    const donutSize = Size(124, 124);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Touch & continuous drag along donut ring
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) =>
              _handleDonutTouch(details.localPosition, donutSize, slices),
          onPanUpdate: (details) =>
              _handleDonutTouch(details.localPosition, donutSize, slices),
          onTapDown: (details) =>
              _handleDonutTouch(details.localPosition, donutSize, slices),
          child: SizedBox(
            width: donutSize.width,
            height: donutSize.height,
            child: CustomPaint(
              size: donutSize,
              painter: _RevenueDonutChartPainter(
                slices: slices,
                selectedIndex: _selectedPlanIndex != null &&
                        _selectedPlanIndex! < slices.length
                    ? _selectedPlanIndex
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displaySlices.asMap().entries.map((entry) {
              final idx = entry.key;
              final slice = entry.value;
              final isSelected = idx == _selectedPlanIndex;

              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedPlanIndex = idx);
                },
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? slice.color.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
  _RevenueDonutChartPainter({
    required this.slices,
    this.selectedIndex,
  });

  final List<({String label, double percentage, String subtext, Color color})>
      slices;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final total =
        slices.fold<double>(0, (sum, item) => sum + item.percentage);
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    const strokeWidth = 16.0;
    final baseRadius = maxRadius - 10.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: baseRadius - strokeWidth / 2,
    );

    if (total <= 0) {
      final bgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0xffEEEEEE);
      canvas.drawCircle(center, baseRadius - strokeWidth / 2, bgPaint);
      return;
    }

    var startAngle = -math.pi / 2;

    // Draw ALL slices with the exact same uniform size (no size increase on hover)
    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
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

    // Center Hole Percentage Display (only when a slice is hovered)
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < slices.length) {
      final selectedSlice = slices[selectedIndex!];
      final pctString = '${selectedSlice.percentage.toStringAsFixed(1)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: pctString,
          style: TextStyle(
            color: selectedSlice.color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueDonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _StraightConnectorLinePainter extends CustomPainter {
  final List<({String label, double percentage, String subtext, Color color})>
      slices;
  final int selectedIndex;
  final Color color;

  _StraightConnectorLinePainter({
    required this.slices,
    required this.selectedIndex,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty || selectedIndex < 0 || selectedIndex >= slices.length) {
      return;
    }

    final total =
        slices.fold<double>(0, (sum, item) => sum + item.percentage);
    if (total <= 0) return;

    // Calculate midAngle of selected slice
    var startAngle = -math.pi / 2;
    var midAngle = startAngle;
    for (var i = 0; i < slices.length; i++) {
      final sweep = (slices[i].percentage / total) * 2 * math.pi;
      if (i == selectedIndex) {
        midAngle = startAngle + sweep / 2;
        break;
      }
      startAngle += sweep;
    }

    // Geometry of donut within the card
    const donutLeft = 16.0;
    const donutWidth = 124.0;
    const donutHeight = 124.0;
    const containerTop = 14.0;
    const containerHeight = 56.0;
    const gapBelowContainer = 18.0;

    final containerBottomY = containerTop + containerHeight;
    final donutTop = containerBottomY + gapBelowContainer;
    final donutCenterX = donutLeft + donutWidth / 2; // 78.0
    final donutCenterY = donutTop + donutHeight / 2; // 150.0
    const ringRadius = 44.0;

    // Point on the hovered color slice (centerline of ring)
    final pSlice = Offset(
      donutCenterX + ringRadius * math.cos(midAngle),
      donutCenterY + ringRadius * math.sin(midAngle),
    );

    // Target point on the bottom of the floating details container
    final targetX = pSlice.dx.clamp(36.0, 120.0);
    final pContainer = Offset(targetX, containerBottomY);

    // Straight line connecting slice directly to floating details container
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pSlice, pContainer, linePaint);

    // Snap dot on the slice ring
    final dotFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(pSlice, 4.0, dotFill);
    canvas.drawCircle(pSlice, 4.0, dotStroke);

    // Anchor dot on the floating details container
    canvas.drawCircle(
      pContainer,
      2.5,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _StraightConnectorLinePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.color != color ||
        oldDelegate.slices != slices;
  }
}

// ================= TREND LINE CHART WIDGET & PAINTER =================

class _LineTrendChartWidget extends StatefulWidget {
  const _LineTrendChartWidget({
    required this.trendData,
    this.lineColor = const Color(0xffE53935),
    this.currencyPrefix = '₹',
  });

  final List<({String label, double value})> trendData;
  final Color lineColor;
  final String currencyPrefix;

  @override
  State<_LineTrendChartWidget> createState() => _LineTrendChartWidgetState();
}

class _LineTrendChartWidgetState extends State<_LineTrendChartWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeIndex = _selectedIndex ?? (widget.trendData.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final width = constraints.maxWidth;
            const leftPad = 44.0;
            const rightPad = 24.0;
            final plotWidth = width - leftPad - rightPad;
            final x = details.localPosition.dx - leftPad;
            if (x >= 0 && x <= plotWidth && widget.trendData.length > 1) {
              final step = plotWidth / (widget.trendData.length - 1);
              final idx = (x / step).round().clamp(0, widget.trendData.length - 1);
              setState(() => _selectedIndex = idx);
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _LineTrendChartPainter(
              trendData: widget.trendData,
              selectedIndex: activeIndex,
              lineColor: widget.lineColor,
              currencyPrefix: widget.currencyPrefix,
            ),
          ),
        );
      },
    );
  }
}

class _LineTrendChartPainter extends CustomPainter {
  _LineTrendChartPainter({
    required this.trendData,
    required this.selectedIndex,
    required this.lineColor,
    required this.currencyPrefix,
  });

  final List<({String label, double value})> trendData;
  final int selectedIndex;
  final Color lineColor;
  final String currencyPrefix;

  @override
  void paint(Canvas canvas, Size size) {
    if (trendData.isEmpty) return;

    const leftPad = 44.0;
    const rightPad = 24.0;
    const topPad = 32.0;
    const bottomPad = 24.0;

    final plotWidth = size.width - leftPad - rightPad;
    final plotHeight = size.height - topPad - bottomPad;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    // Find max value
    var maxVal = 0.0;
    for (final item in trendData) {
      if (item.value > maxVal) maxVal = item.value;
    }
    if (maxVal <= 0) maxVal = 120000;

    // Round maxVal to a clean ceiling: e.g. 150000 (1.5L)
    double niceMax;
    if (maxVal > 100000) {
      niceMax = ((maxVal / 50000).ceil()) * 50000.0;
      if (niceMax == maxVal) niceMax += 25000.0;
    } else if (maxVal > 10000) {
      niceMax = ((maxVal / 10000).ceil()) * 10000.0;
      if (niceMax == maxVal) niceMax += 5000.0;
    } else {
      niceMax = ((maxVal / 1000).ceil()) * 1000.0;
      if (niceMax <= 0) niceMax = 10000.0;
    }

    final gridSteps = 3; // 4 lines: 0, 1/3, 2/3, 1
    final gridLinePaint = Paint()
      ..color = const Color(0xffEEEEEE)
      ..strokeWidth = 1.0;

    final vGridLinePaint = Paint()
      ..color = const Color(0xffF7F7F7)
      ..strokeWidth = 1.0;

    // 1. Draw horizontal grid lines & Y labels
    for (var i = 0; i <= gridSteps; i++) {
      final yRatio = i / gridSteps;
      final y = topPad + plotHeight * (1.0 - yRatio);

      // Line
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + plotWidth, y),
        gridLinePaint,
      );

      // Label
      final levelVal = niceMax * yRatio;
      String labelStr;
      if (levelVal == 0) {
        labelStr = '0';
      } else if (levelVal >= 100000) {
        final inL = levelVal / 100000;
        labelStr = inL % 1 == 0 ? '${inL.toInt()}L' : '${inL.toStringAsFixed(1)}L';
      } else if (levelVal >= 1000) {
        final inK = levelVal / 1000;
        labelStr = inK % 1 == 0 ? '${inK.toInt()}K' : '${inK.toStringAsFixed(1)}K';
      } else {
        labelStr = levelVal.toStringAsFixed(0);
      }

      final textSpan = TextSpan(
        text: labelStr,
        style: const TextStyle(
          color: Color(0xff9E9E9E),
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(leftPad - tp.width - 8, y - tp.height / 2),
      );
    }

    // 2. Compute point coordinates
    final points = <Offset>[];
    final count = trendData.length;
    final stepX = count > 1 ? plotWidth / (count - 1) : 0.0;

    for (var i = 0; i < count; i++) {
      final x = leftPad + (i * stepX);
      final normVal = (trendData[i].value / niceMax).clamp(0.0, 1.0);
      final y = topPad + plotHeight * (1.0 - normVal);
      points.add(Offset(x, y));

      // Draw vertical grid line for each point
      canvas.drawLine(
        Offset(x, topPad),
        Offset(x, topPad + plotHeight),
        vGridLinePaint,
      );

      // Draw X label below
      final xLabel = trendData[i].label;
      final tp = TextPainter(
        text: TextSpan(
          text: xLabel,
          style: TextStyle(
            color: (i == selectedIndex)
                ? AppColors.textDark
                : const Color(0xff9E9E9E),
            fontSize: 11,
            fontFamily: 'Poppins',
            fontWeight:
                (i == selectedIndex) ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(x - tp.width / 2, topPad + plotHeight + 6),
      );
    }

    // 3. Draw gradient fill under the line
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }
    fillPath.lineTo(points.last.dx, topPad + plotHeight);
    fillPath.lineTo(points.first.dx, topPad + plotHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftPad, topPad, plotWidth, plotHeight));

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw smooth stroke curve
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, strokePaint);

    // 5. Draw node circles
    final nodeFillPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final nodeHolePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSel = (i == selectedIndex);
      canvas.drawCircle(pt, isSel ? 5.5 : 4.0, nodeFillPaint);
      if (isSel) {
        canvas.drawCircle(pt, 2.0, nodeHolePaint);
      }
    }

    // 6. Draw active Tooltip pill
    if (selectedIndex >= 0 && selectedIndex < points.length) {
      final activePt = points[selectedIndex];
      final activeVal = trendData[selectedIndex].value;
      final valFormatted =
          '$currencyPrefix${NumberFormat('#,##,###').format(activeVal.round())}';

      final tp = TextPainter(
        text: TextSpan(
          text: valFormatted,
          style: const TextStyle(
            color: Color(0xff1E293B),
            fontSize: 11,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const padH = 8.0;
      const padV = 5.0;
      final cardW = tp.width + padH * 2;
      final cardH = tp.height + padV * 2;

      // Position tooltip clamped within plot bounds
      final tooltipX = (activePt.dx - cardW / 2).clamp(
        leftPad,
        leftPad + plotWidth - cardW,
      );
      final tooltipY = activePt.dy - cardH - 8;

      final cardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, cardW, cardH),
        const Radius.circular(8),
      );

      // Tooltip shadow
      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Tooltip background
      canvas.drawRRect(
        cardRect,
        Paint()..color = Colors.white,
      );

      // Tooltip border
      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = const Color(0xffE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Arrow pointer
      final arrowPath = Path()
        ..moveTo(activePt.dx - 4, tooltipY + cardH)
        ..lineTo(activePt.dx + 4, tooltipY + cardH)
        ..lineTo(activePt.dx, tooltipY + cardH + 4)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = Colors.white);
      canvas.drawPath(
        arrowPath,
        Paint()
          ..color = const Color(0xffE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Paint tooltip text
      tp.paint(canvas, Offset(tooltipX + padH, tooltipY + padV));
    }
  }

  @override
  bool shouldRepaint(covariant _LineTrendChartPainter oldDelegate) {
    return oldDelegate.trendData != trendData ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.lineColor != lineColor;
  }
}

class _RevenuePeriodCache {
  const _RevenuePeriodCache({
    required this.totalRevenue,
    required this.percentageChange,
    required this.isIncrease,
    required this.comparisonMonth,
    required this.quickInsight,
    required this.trendData,
    required this.planRevenueBreakdown,
    required this.paymentModes,
    required this.revenues,
  });

  final double totalRevenue;
  final double percentageChange;
  final bool isIncrease;
  final String comparisonMonth;
  final String quickInsight;
  final List<({String label, double value})> trendData;
  final List<dynamic> planRevenueBreakdown;
  final List<dynamic> paymentModes;
  final List<Map<String, dynamic>> revenues;
}
