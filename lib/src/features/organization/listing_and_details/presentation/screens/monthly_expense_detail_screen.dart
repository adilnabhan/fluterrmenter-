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
  bool _hasChanges = false;

  List<Map<String, dynamic>> _expenses = [];

  static const List<String> _defaultCategories = [
    'Maintenance',
    'Equipment',
    'Rent',
    'Salaries',
    'Utilities',
    'Marketing',
    'Other',
  ];

  static const Map<String, Color> _categoryColors = {
    'Maintenance': Color(0xffF39C12),
    'Equipment': Color(0xff2980B9),
    'Utilities': Color(0xff27AE60),
    'Rent': Color(0xff9C51BF),
    'Salaries': Color(0xff527F50),
    'Marketing': Color(0xffC2486C),
    'Other': Color(0xffE74C3C),
  };

  static const List<Color> _fallbackColors = [
    Color(0xff34495E),
    Color(0xffE67E22),
    Color(0xff2ECC71),
    Color(0xff3498DB),
    Color(0xff9B59B6),
  ];

  @override
  void initState() {
    super.initState();
    _expenses = widget.initialExpenses != null
        ? List<Map<String, dynamic>>.from(widget.initialExpenses!)
        : [];

    if (_expenses.isEmpty) {
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
        if (mounted) {
          setState(() {
            _expenses =
                list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        }
      }
    } catch (_) {}

    if (mounted) {
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
            'Monthly Expenses',
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
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchData,
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
              'Recent Expenses',
              style: AppStyles.text18Px.poppins.w600.dark,
            ),
            GestureDetector(
              onTap: _showAddOrEditExpenseSheet,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xff27AE60),
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
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffE74C3C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _showAddOrEditExpenseSheet,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add First Expense'),
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
                        final category = exp['category']?.toString() ?? 'Other';
                        final amount = exp['amount'] ?? 0.0;
                        final dateStr = exp['expense_date']?.toString() ?? '';

                        var parsedAmount = 0.0;
                        if (amount is num) {
                          parsedAmount = amount.toDouble();
                        } else if (amount != null) {
                          parsedAmount =
                              double.tryParse(amount.toString()) ?? 0.0;
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            title,
                            style: AppStyles.text14Px.poppins.w600.dark,
                          ),
                          subtitle: Text(
                            '$category • $dateStr',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${parsedAmount.toStringAsFixed(2)}',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xffE74C3C),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Breakdown by Category',
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
          child: _expenses.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No expense data available for breakdown.',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                )
              : _buildPieChartContent(),
        ),
      ],
    );
  }

  Widget _buildPieChartContent() {
    final categoryTotals = <String, double>{};
    var totalExpense = 0.0;

    for (final exp in _expenses) {
      final category = exp['category']?.toString().trim() ?? 'Other';
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

    if (totalExpense <= 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No expense amounts recorded yet',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    final slices =
        <({String label, double percentage, Color color, double amount})>[];
    var fallbackIndex = 0;

    categoryTotals.forEach((category, amount) {
      final percentage = (amount / totalExpense) * 100;
      final color = _categoryColors[category] ??
          _fallbackColors[fallbackIndex % _fallbackColors.length];
      fallbackIndex++;

      slices.add((
        label: category,
        percentage: percentage,
        color: color,
        amount: amount,
      ));
    });

    slices.sort((a, b) => b.amount.compareTo(a.amount));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: _ExpensePieChartPainter(slices: slices),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices.map((slice) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: slice.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        slice.label,
                        style: AppStyles.text12Px.poppins.w500.dark,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${slice.percentage.toStringAsFixed(1)}% (₹${slice.amount.toStringAsFixed(0)})',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
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
}

class _ExpensePieChartPainter extends CustomPainter {
  _ExpensePieChartPainter({required this.slices});

  final List<({String label, double percentage, Color color, double amount})>
      slices;

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    const holeRadiusRatio = 0.65;
    final innerRadius = outerRadius * holeRadiusRatio;

    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweepAngle = (slice.percentage / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: outerRadius);
      final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
      final path = Path()
        ..arcTo(rect, startAngle, sweepAngle, false)
        ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
        ..close();

      canvas.drawPath(path, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ExpensePieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
