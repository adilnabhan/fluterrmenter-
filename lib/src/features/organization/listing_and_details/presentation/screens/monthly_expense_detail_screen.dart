import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class MonthlyExpenseDetailScreen extends StatefulWidget {
  const MonthlyExpenseDetailScreen({
    required this.orgId,
    super.key,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
    this.initialExpenses,
    this.currentBudget,
  });

  final int orgId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;
  final List<Map<String, dynamic>>? initialExpenses;
  final double? currentBudget;

  @override
  State<MonthlyExpenseDetailScreen> createState() =>
      _MonthlyExpenseDetailScreenState();
}

class _MonthlyExpenseDetailScreenState
    extends State<MonthlyExpenseDetailScreen> {
  bool _isLoading = false;
  bool _isRecentExpenseExpanded = false;
  bool _isBreakdownExpanded = false;
  bool _hasChanges = false;

  late int _selectedYear;
  late int _selectedMonth;
  String _selectedPeriod = '6m';
  double _totalExpense = 0.0;
  double _percentageChange = -18.0;
  bool _isIncrease = false;
  String _comparisonMonth = 'Aug';
  String _quickInsight = '';
  List<({String label, double value})> _trendData = [];
  List<Map<String, dynamic>> _expenseBreakdown = [];

  List<Map<String, dynamic>> _expenses = [];

  static const List<String> _defaultCategories = [
    'Salary',
    'Rent',
    'Equipment',
    'Maintenance',
    'Utilities',
    'Marketing',
    'Others',
  ];

  static const Map<String, Color> _categoryColors = {
    'Salary': Color(0xffE53935),
    'Salaries': Color(0xffE53935),
    'Rent': Color(0xffC07A4A),
    'Equipment': Color(0xffFB8C00),
    'Maintenance': Color(0xffE91E63),
    'Utilities': Color(0xff2196F3),
    'Marketing': Color(0xff9C27B0),
    'Other': Color(0xff607D8B),
    'Others': Color(0xff607D8B),
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = widget.year ?? widget.startDate?.year ?? now.year;
    _selectedMonth = widget.month ?? widget.startDate?.month ?? now.month;

    final prevMonthDate = DateTime(_selectedYear, _selectedMonth - 1);
    _comparisonMonth = DateFormat('MMM').format(prevMonthDate);

    _expenses = widget.initialExpenses != null
        ? List<Map<String, dynamic>>.from(widget.initialExpenses!)
        : [];

    _fetchData().then((_) {
      if (mounted) {
        _prefetchOtherPeriods();
      }
    });
  }

  final Map<String, _ExpensePeriodCache> _periodCache = {};

  void _applyCachedData(_ExpensePeriodCache cached) {
    _totalExpense = cached.totalExpense;
    _percentageChange = cached.percentageChange;
    _isIncrease = cached.isIncrease;
    _comparisonMonth = cached.comparisonMonth;
    _quickInsight = cached.quickInsight;
    _trendData = cached.trendData;
    if (cached.expenses.isNotEmpty) _expenses = cached.expenses;
    if (cached.expenseBreakdown.isNotEmpty) {
      _expenseBreakdown = cached.expenseBreakdown;
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

      final expReportResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.expenseReports}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (expReportResponse.statusCode == 200 &&
          expReportResponse.data is Map) {
        final data = Map<String, dynamic>.from(expReportResponse.data as Map);
        final exp = (data['total_expense'] as num?)?.toDouble() ??
            (data['expense'] as num?)?.toDouble() ??
            0.0;
        final pctChange =
            (data['percentage_change'] as num?)?.toDouble() ?? -18.0;
        final isInc = data['is_increase'] as bool? ?? (pctChange >= 0);
        final compMonth =
            data['comparison_month']?.toString() ?? _comparisonMonth;
        final qkInsight = data['quick_insight']?.toString() ?? '';

        final parsedTrend = <({String label, double value})>[];
        if (data['trend'] is List) {
          for (final item in data['trend'] as List) {
            if (item is Map) {
              final label = (item['month'] ?? item['name'] ?? '').toString();
              final val = (item['expense'] ??
                      item['amount'] ??
                      item['value'] ??
                      0.0) as num;
              parsedTrend.add((label: label, value: val.toDouble()));
            }
          }
        }

        final recentExp = data['recent_expenses'] is List
            ? List<Map<String, dynamic>>.from(
                (data['recent_expenses'] as List)
                    .map((e) => Map<String, dynamic>.from(e as Map)),
              )
            : <Map<String, dynamic>>[];

        final expBreakdown = data['expense_breakdown'] is List
            ? List<Map<String, dynamic>>.from(
                (data['expense_breakdown'] as List)
                    .map((e) => Map<String, dynamic>.from(e as Map)),
              )
            : <Map<String, dynamic>>[];

        _periodCache[period] = _ExpensePeriodCache(
          totalExpense: exp > 0 ? exp : _totalExpense,
          percentageChange: pctChange,
          isIncrease: isInc,
          comparisonMonth: compMonth,
          quickInsight: qkInsight,
          trendData: parsedTrend,
          expenseBreakdown: expBreakdown,
          expenses: recentExp,
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

    var totalExp = _totalExpense;
    var pctChange = _percentageChange;
    var isInc = _isIncrease;
    var compMonth = _comparisonMonth;
    var qkInsight = _quickInsight;
    var trend = <({String label, double value})>[];
    var recentExp = <Map<String, dynamic>>[];
    var expBreakdown = <Map<String, dynamic>>[];

    var successFromPrimary = false;

    // 1. Fetch from dedicated expense reports endpoint
    try {
      final expReportResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.expenseReports}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (expReportResponse.statusCode == 200 &&
          expReportResponse.data is Map) {
        final data =
            Map<String, dynamic>.from(expReportResponse.data as Map);

        final exp = (data['total_expense'] as num?)?.toDouble() ??
            (data['expense'] as num?)?.toDouble() ??
            0.0;
        if (exp > 0) totalExp = exp;

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
              final val = (item['expense'] ??
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

        if (data['recent_expenses'] is List &&
            (data['recent_expenses'] as List).isNotEmpty) {
          recentExp = List<Map<String, dynamic>>.from(
            (data['recent_expenses'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map)),
          );
        }

        if (data['expense_breakdown'] is List) {
          expBreakdown = List<Map<String, dynamic>>.from(
            (data['expense_breakdown'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map)),
          );
        }
        successFromPrimary = true;
      }
    } catch (_) {}

    // 2. Fetch raw expenses if empty
    if (recentExp.isEmpty && _expenses.isEmpty) {
      try {
        final expensesResponse = await DioClient().dio.get<dynamic>(
          '${ApiUris.expenses}?$queryParams',
          options: Options(headers: {'X-Platform': platformSource}).token,
        );

        if (expensesResponse.statusCode == 200) {
          final data = expensesResponse.data;
          var list = <dynamic>[];
          if (data is List) {
            list = data;
          } else if (data is Map && data['results'] is List) {
            list = data['results'] as List;
          } else if (data is Map && data['expenses'] is List) {
            list = data['expenses'] as List;
          }
          recentExp = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (_) {}
    }

    // 3. Fallback to reports ONLY IF primary failed or total is 0
    if (!successFromPrimary || totalExp == 0.0) {
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

          final expNum = (financial?['total_expense'] as num?)?.toDouble();
          if (expNum != null && expNum > 0 && totalExp == 0.0) {
            totalExp = expNum;
          }

          final expGrowth =
              financial?['expense_growth'] as Map<dynamic, dynamic>?;
          if (expGrowth != null) {
            if (expGrowth['percentage_change'] != null) {
              pctChange =
                  (expGrowth['percentage_change'] as num).toDouble();
              isInc = expGrowth['is_increase'] as bool? ??
                  (pctChange >= 0);
            }
            if (expGrowth['comparison_month'] != null) {
              compMonth = expGrowth['comparison_month'].toString();
            }
          }
        }
      } catch (_) {}
    }

    // Calculate total from expenses if still 0
    if (totalExp == 0.0 && recentExp.isNotEmpty) {
      var sum = 0.0;
      for (final e in recentExp) {
        sum += (e['amount'] as num?)?.toDouble() ??
            double.tryParse(e['amount']?.toString() ?? '0') ??
            0.0;
      }
      totalExp = sum;
    }

    // Cache the result for this period
    _periodCache[targetPeriod] = _ExpensePeriodCache(
      totalExpense: totalExp,
      percentageChange: pctChange,
      isIncrease: isInc,
      comparisonMonth: compMonth,
      quickInsight: qkInsight,
      trendData: trend,
      expenseBreakdown: expBreakdown,
      expenses: recentExp.isNotEmpty ? recentExp : _expenses,
    );

    if (mounted && _selectedPeriod == targetPeriod) {
      setState(() {
        _totalExpense = totalExp;
        _percentageChange = pctChange;
        _isIncrease = isInc;
        _comparisonMonth = compMonth;
        _quickInsight = qkInsight;
        _trendData = trend;
        if (recentExp.isNotEmpty) _expenses = recentExp;
        if (expBreakdown.isNotEmpty) _expenseBreakdown = expBreakdown;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddOrEditExpenseSheet({Map<String, dynamic>? expense}) {
    final isEdit = expense != null;
    final titleController = TextEditingController(
      text: (expense?['title'] as String?) ?? '',
    );
    final amountController = TextEditingController(
      text: expense?['amount']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: (expense?['notes'] as String?) ?? '',
    );

    var selectedCategory = (expense?['category'] as String?) ?? 'Maintenance';
    if (!_defaultCategories.contains(selectedCategory)) {
      selectedCategory = 'Other';
    }

    var selectedDate = expense?['expense_date'] != null
        ? DateTime.tryParse(expense!['expense_date'].toString()) ??
            DateTime.now()
        : DateTime.now();

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
                          isEdit ? 'Edit Expense' : 'Add Expense',
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
                        labelText: 'Title *',
                        hintText: 'e.g. Equipment repair, Water bill',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Amount *',
                              hintText: 'e.g. 1500.00',
                              prefixText: '₹',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                            ),
                            items: _defaultCategories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expense Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Description (Optional)',
                        hintText: 'e.g. Repaired cable machine in room 2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Button.filled(
                        title: isEdit ? 'Update Expense' : 'Save Expense',
                        buttonColor: const Color(0xffE74C3C),
                        ontap: () async {
                          final title = titleController.text.trim();
                          final amountStr = amountController.text.trim();
                          final notes = notesController.text.trim();

                          if (title.isEmpty) {
                            unawaited(Dialogs.showSnack(msg: 'Title is required'));
                            return;
                          }
                          final amount = double.tryParse(amountStr);
                          if (amount == null || amount <= 0) {
                            unawaited(Dialogs.showSnack(msg: 'Valid amount is required'));
                            return;
                          }

                          final payload = <String, dynamic>{
                            'title': title,
                            'amount': amount,
                            'category': selectedCategory,
                            'expense_date':
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                            'notes': notes,
                            'organization_id': widget.orgId,
                          };

                          if (widget.currentBudget != null) {
                            payload['monthly_budget'] = widget.currentBudget;
                          }

                          Navigator.pop(context);
                          setState(() => _isLoading = true);

                          try {
                            Response<dynamic>? res;
                            if (isEdit) {
                              res = await DioClient().dio.patch<dynamic>(
                                ApiUris.expenseDetail(expense['id'] as int),
                                data: payload,
                                options: Options(
                                  headers: {'X-Platform': platformSource},
                                ).token,
                              );
                            } else {
                              res = await DioClient().dio.post<dynamic>(
                                ApiUris.expenses,
                                data: payload,
                                options: Options(
                                  headers: {'X-Platform': platformSource},
                                ).token,
                              );
                            }

                            if (res.statusCode == 200 || res.statusCode == 201) {
                              _hasChanges = true;
                              unawaited(Dialogs.showSnack(
                                msg: isEdit
                                    ? 'Expense updated successfully'
                                    : 'Expense saved successfully',
                              ));
                              await _fetchData();
                            } else {
                              unawaited(Dialogs.showSnack(
                                msg: 'Failed to save expense',
                              ));
                            }
                          } catch (e) {
                            unawaited(Dialogs.showSnack(
                              msg: 'Error saving expense',
                            ));
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
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

  Future<void> _deleteExpense(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense record?',
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
        ApiUris.expenseDetail(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _hasChanges = true;
        if (mounted) {
          setState(() {
            _expenses.removeWhere(
              (e) => e['id'] == id || e['id']?.toString() == id.toString(),
            );
          });
        }
        unawaited(Dialogs.showSnack(msg: 'Expense deleted successfully'));
        await _fetchData();
      } else {
        unawaited(Dialogs.showSnack(msg: 'Failed to delete expense'));
      }
    } catch (_) {
      unawaited(Dialogs.showSnack(msg: 'Error deleting expense'));
    }
  }

  List<({String label, double value})> _getFallbackTrend() {
    final monthsCount =
        _selectedPeriod == '3m' ? 3 : (_selectedPeriod == '1y' ? 12 : 6);
    final result = <({String label, double value})>[];
    final baseDate = DateTime(_selectedYear, _selectedMonth);

    for (var i = monthsCount - 1; i >= 0; i--) {
      final d = DateTime(baseDate.year, baseDate.month - i, 1);
      final label = DateFormat('MMM').format(d);
      final progress =
          (monthsCount - 1 - i) / (monthsCount > 1 ? (monthsCount - 1) : 1);
      final factor = 0.45 + (0.55 * progress);
      final val = _totalExpense > 0
          ? (_totalExpense * factor)
          : (45000.0 + (progress * 75000.0));
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

  Widget _buildExpenseHeroCard() {
    final formattedTotal =
        NumberFormat('#,##,###').format(_totalExpense.round());
    final isUp = _isIncrease;
    final pillBg = isUp ? const Color(0xffE8F8F0) : const Color(0xffFDEAEA);
    final pillColor =
        isUp ? const Color(0xff27AE60) : const Color(0xffD32F2F);
    final sign = _percentageChange > 0 ? '+' : '';
    final cmpText = _comparisonMonth.isNotEmpty
        ? 'vs $_comparisonMonth'
        : 'vs last month';
    final pctText =
        '$sign${_percentageChange.toStringAsFixed(0)}% $cmpText';

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
          // Red receipt icon
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xffFDEAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xffD32F2F),
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Monthly Expense',
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
                  color: const Color(0xffD32F2F),
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
                : 'Your expense is ${_isIncrease ? "up" : "down"} by ${_percentageChange.abs().toStringAsFixed(0)}% compared to last month. Great job!',
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
        backgroundColor: const Color(0xffF8FAFC),
        appBar: AppBar(
          title: Text(
            'Total Expense',
            style: AppStyles.text18Px.poppins.w600.dark,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
              onPressed: () {},
            ),
          ],
        ),
        body: _isLoading && _expenses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthSelectorPill(),
                      const SizedBox(height: 16),
                      _buildExpenseHeroCard(),
                      const SizedBox(height: 24),
                      _buildRecentExpensesCard(),
                      const SizedBox(height: 24),
                      _buildCategoryBreakdownCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRecentExpensesCard() {
    final displayList = (_expenses.length > 3 && !_isRecentExpenseExpanded)
        ? _expenses.take(3).toList()
        : _expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expense',
              style: AppStyles.text18Px.poppins.w600.dark,
            ),
            GestureDetector(
              onTap: _showAddOrEditExpenseSheet,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xffD32F2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
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
          child: _expenses.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 44,
                          color: AppColors.textGrey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No expenses recorded yet',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
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
                          const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final exp = displayList[index];
                        final id = exp['id'] as int? ?? 0;
                        final title =
                            exp['title']?.toString() ?? 'Unspecified Expense';
                        final amount = exp['amount'] ?? 0.0;
                        final dateStr = exp['expense_date']?.toString() ??
                            exp['date']?.toString() ??
                            '';

                        var parsedAmount = 0.0;
                        if (amount is num) {
                          parsedAmount = amount.toDouble();
                        } else if (amount != null) {
                          parsedAmount =
                              double.tryParse(amount.toString()) ?? 0.0;
                        }
                        final formattedAmt = NumberFormat('#,##,###')
                            .format(parsedAmount.round());

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Circular grey placeholder avatar
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xffD9D9D9),
                                  shape: BoxShape.circle,
                                ),
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
                                      dateStr,
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '-₹$formattedAmt',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xffD32F2F),
                                ),
                              ),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showAddOrEditExpenseSheet(expense: exp);
                                  } else if (val == 'delete') {
                                    _deleteExpense(id);
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
                    if (_expenses.length > 3) ...[
                      const Divider(height: 1, color: Color(0xffEEEEEE)),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isRecentExpenseExpanded =
                                !_isRecentExpenseExpanded;
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
                                      _isRecentExpenseExpanded
                                          ? 'collapse'
                                          : 'expand',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isRecentExpenseExpanded
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

  Widget _buildCategoryBreakdownCard() {
    // Collect slices from backend or local expenses
    final slices =
        <({String label, double percentage, Color color, double amount})>[];

    if (_expenseBreakdown.isNotEmpty) {
      for (final item in _expenseBreakdown) {
        final cat = (item['category'] ?? item['name'] ?? 'Other').toString();
        final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final pct = (item['percentage'] as num?)?.toDouble() ?? 0.0;
        final col = _categoryColors[cat] ?? const Color(0xff607D8B);
        slices.add((label: cat, percentage: pct, color: col, amount: amt));
      }
    } else {
      final categoryTotals = <String, double>{};
      var totalExpense = 0.0;
      for (final exp in _expenses) {
        final category = exp['category']?.toString().trim() ?? 'Others';
        final rawAmount = exp['amount'];
        var amount = 0.0;
        if (rawAmount is num) {
          amount = rawAmount.toDouble();
        } else if (rawAmount != null) {
          amount = double.tryParse(rawAmount.toString()) ?? 0.0;
        }
        if (amount > 0) {
          categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
          totalExpense += amount;
        }
      }

      if (totalExpense > 0) {
        categoryTotals.forEach((category, amount) {
          final percentage = (amount / totalExpense) * 100;
          final color = _categoryColors[category] ?? const Color(0xff607D8B);
          slices.add((
            label: category,
            percentage: percentage,
            color: color,
            amount: amount,
          ));
        });
      }
    }

    slices.sort((a, b) => b.amount.compareTo(a.amount));

    final totalDisplay =
        NumberFormat('#,##,###').format(_totalExpense.round());

    final topExpenses = _isBreakdownExpanded
        ? slices
        : slices.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Breakdown',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Donut Chart + Legend
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Donut with center text
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _ExpenseDonutPainter(slices: slices),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹$totalDisplay',
                              style: AppStyles.text14Px.poppins.w700.dark,
                            ),
                            Text(
                              'Total Expense',
                              style: AppStyles.text10Px.poppins.w400
                                  .copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: slices.map((slice) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: slice.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  slice.label,
                                  style: AppStyles.text12Px.poppins.w500.dark,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${slice.percentage.toStringAsFixed(0)}%',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              if (slices.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Top Expenses',
                  style: AppStyles.text14Px.poppins.w600.dark,
                ),
                const SizedBox(height: 12),
                // Top Expenses progress bars
                ...topExpenses.map((slice) {
                  final fmt =
                      NumberFormat('#,##,###').format(slice.amount.round());
                  final progress = (slice.percentage / 100).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Category Icon in rounded square
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: slice.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(slice.label),
                                color: slice.color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                slice.label,
                                style: AppStyles.text14Px.poppins.w500.dark,
                              ),
                            ),
                            Text(
                              '₹$fmt',
                              style: AppStyles.text14Px.poppins.w600.dark,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${slice.percentage.toStringAsFixed(0)}%',
                              style: AppStyles.text12Px.poppins.w400
                                  .copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Horizontal progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0xffEEEEEE),
                            valueColor: AlwaysStoppedAnimation<Color>(slice.color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (slices.length > 3)
                  Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isBreakdownExpanded = !_isBreakdownExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
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
                                _isBreakdownExpanded ? 'collapse' : 'expand',
                                style: AppStyles.text12Px.poppins.w400
                                    .copyWith(color: AppColors.textGrey),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isBreakdownExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                            ],
                          ),
                        ),
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

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('salary') || lower.contains('salaries')) {
      return Icons.badge_outlined;
    }
    if (lower.contains('rent')) {
      return Icons.store_outlined;
    }
    if (lower.contains('equipment')) {
      return Icons.fitness_center;
    }
    if (lower.contains('maintenance')) {
      return Icons.build_outlined;
    }
    if (lower.contains('utilit')) {
      return Icons.power_outlined;
    }
    if (lower.contains('market')) {
      return Icons.campaign_outlined;
    }
    return Icons.receipt_outlined;
  }
}

// ================= EXPENSE DONUT PAINTER =================

class _ExpenseDonutPainter extends CustomPainter {
  _ExpenseDonutPainter({required this.slices});

  final List<({String label, double percentage, Color color, double amount})>
      slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 14.0;
    final drawRadius = radius - strokeWidth / 2;

    if (slices.isEmpty) {
      canvas.drawCircle(
        center,
        drawRadius,
        Paint()
          ..color = const Color(0xffEEEEEE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
      return;
    }

    final total = slices.fold<double>(0, (sum, e) => sum + e.percentage);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.percentage <= 0) continue;
      final sweepAngle = (slice.percentage / total) * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(center: center, radius: drawRadius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseDonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
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
              final idx =
                  (x / step).round().clamp(0, widget.trendData.length - 1);
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

    var maxVal = 0.0;
    for (final item in trendData) {
      if (item.value > maxVal) maxVal = item.value;
    }
    if (maxVal <= 0) maxVal = 120000;

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

    final gridSteps = 3;
    final gridLinePaint = Paint()
      ..color = const Color(0xffEEEEEE)
      ..strokeWidth = 1.0;

    final vGridLinePaint = Paint()
      ..color = const Color(0xffF7F7F7)
      ..strokeWidth = 1.0;

    // 1. Horizontal grid lines & Y labels
    for (var i = 0; i <= gridSteps; i++) {
      final yRatio = i / gridSteps;
      final y = topPad + plotHeight * (1.0 - yRatio);

      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + plotWidth, y),
        gridLinePaint,
      );

      final levelVal = niceMax * yRatio;
      String labelStr;
      if (levelVal == 0) {
        labelStr = '0';
      } else if (levelVal >= 100000) {
        final inL = levelVal / 100000;
        labelStr =
            inL % 1 == 0 ? '${inL.toInt()}L' : '${inL.toStringAsFixed(1)}L';
      } else if (levelVal >= 1000) {
        final inK = levelVal / 1000;
        labelStr =
            inK % 1 == 0 ? '${inK.toInt()}K' : '${inK.toStringAsFixed(1)}K';
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

    // 2. Point coordinates
    final points = <Offset>[];
    final count = trendData.length;
    final stepX = count > 1 ? plotWidth / (count - 1) : 0.0;

    for (var i = 0; i < count; i++) {
      final x = leftPad + (i * stepX);
      final normVal = (trendData[i].value / niceMax).clamp(0.0, 1.0);
      final y = topPad + plotHeight * (1.0 - normVal);
      points.add(Offset(x, y));

      canvas.drawLine(
        Offset(x, topPad),
        Offset(x, topPad + plotHeight),
        vGridLinePaint,
      );

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

    // 3. Gradient fill under curve
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

    // 4. Smooth stroke line
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

    // 5. Node circles
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

    // 6. Active Tooltip
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

      final tooltipX = (activePt.dx - cardW / 2).clamp(
        leftPad,
        leftPad + plotWidth - cardW,
      );
      final tooltipY = activePt.dy - cardH - 8;

      final cardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, cardW, cardH),
        const Radius.circular(8),
      );

      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawRRect(
        cardRect,
        Paint()..color = Colors.white,
      );

      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = const Color(0xffE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

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

class _ExpensePeriodCache {
  const _ExpensePeriodCache({
    required this.totalExpense,
    required this.percentageChange,
    required this.isIncrease,
    required this.comparisonMonth,
    required this.quickInsight,
    required this.trendData,
    required this.expenseBreakdown,
    required this.expenses,
  });

  final double totalExpense;
  final double percentageChange;
  final bool isIncrease;
  final String comparisonMonth;
  final String quickInsight;
  final List<({String label, double value})> trendData;
  final List<Map<String, dynamic>> expenseBreakdown;
  final List<Map<String, dynamic>> expenses;
}
