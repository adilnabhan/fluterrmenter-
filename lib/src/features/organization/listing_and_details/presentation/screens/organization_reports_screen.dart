import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/reports_customer_list_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/monthly_revenue_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/monthly_expense_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/client_workout_calendar_widget.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/organization_trainers_report_widget.dart';

double _safeDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  final s = val.toString().replaceAll('%', '').replaceAll(',', '').trim();
  return double.tryParse(s) ?? fallback;
}

int _safeInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final s = val.toString().replaceAll(RegExp(r'[^0-9\-]'), '').trim();
  return int.tryParse(s) ?? fallback;
}

num _safeNum(dynamic val, [num fallback = 0]) {
  if (val == null) return fallback;
  if (val is num) return val;
  final s = val.toString().replaceAll('%', '').replaceAll(',', '').trim();
  return num.tryParse(s) ?? fallback;
}

String _safeString(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  return val.toString();
}

class OrganizationReportsScreen extends StatefulWidget {
  final int orgId;
  final bool showBackButton;
  const OrganizationReportsScreen({super.key, required this.orgId, this.showBackButton = true});

  @override
  State<OrganizationReportsScreen> createState() =>
      _OrganizationReportsScreenState();
}

class _OrganizationReportsScreenState extends State<OrganizationReportsScreen> {
  static const List<String> _budgetCategories = [
    'Equipment',
    'Maintenance',
    'Utilities',
    'Marketing',
    'Salary',
    'Rent',
    'Others',
  ];

  bool _isLoading = true;
  String? _errorMessage;
  bool _isCategoryBreakdownExpanded = false;
  bool _isRevenueTargetBreakdownExpanded = false;
  Map<String, dynamic> _reportsData = {};
  Map<String, dynamic> _budgetData = {};
  Map<String, dynamic> _revenueTargetData = {};
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _revenues = [];
  List<Map<String, dynamic>> _revenueCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'All';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isRecentActivityExpanded = false;
  int _overviewHalf = DateTime.now().month > 6 ? 2 : 1;
  int _overviewYear = DateTime.now().year;

  Color get _cardBg => context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _cardBorder => context.isDarkMode ? context.colors.border : const Color(0xffEEEEEE);

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedYear = picked.start.year;
        _selectedMonth = picked.start.month;
      });
      _fetchReports();
    }
  }

  Future<void> _fetchReports({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final year = _selectedYear;
    final month = _selectedMonth;

    String queryParams = 'organization_id=${widget.orgId}&year=$year&month=$month';
    if (_startDate != null && _endDate != null) {
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate!);
      queryParams += '&start_date=$startStr&end_date=$endStr';
    }

    bool mainReportsFailed = false;
    String? failedReason;

    final dio = DioClient().dio;
    final tokenOptions = Options(headers: {'X-Platform': platformSource}).token;
    final baseOptions = Options(headers: {'X-Platform': platformSource});

    final results = await Future.wait([
      // 0: Reports
      dio.get<dynamic>('${ApiUris.reports}?$queryParams', options: baseOptions).catchError((e) {
        mainReportsFailed = true;
        if (e is DioException) {
          failedReason = e.response?.statusCode != null
              ? 'Server error (${e.response?.statusCode})'
              : 'Failed to connect to reports service';
        } else {
          failedReason = 'Failed to load reports';
        }
        return Response<dynamic>(requestOptions: RequestOptions(), statusCode: 500);
      }),
      // 1: Budget
      dio.get<dynamic>('${ApiUris.budget}?year=$year&month=$month', options: tokenOptions).catchError((_) => Response<dynamic>(requestOptions: RequestOptions())),
      // 2: Expenses
      dio.get<dynamic>('${ApiUris.expenses}?$queryParams', options: tokenOptions).catchError((_) => Response<dynamic>(requestOptions: RequestOptions())),
      // 3: Revenues
      dio.get<dynamic>('${ApiUris.revenues}?$queryParams', options: tokenOptions).catchError((_) => Response<dynamic>(requestOptions: RequestOptions())),
      // 4: Revenue Categories
      dio.get<dynamic>('${ApiUris.revenueCategories}?organization_id=${widget.orgId}', options: tokenOptions).catchError((_) => Response<dynamic>(requestOptions: RequestOptions())),
      // 5: Revenue Targets
      dio.get<dynamic>('${ApiUris.revenueTargets}?$queryParams', options: tokenOptions).catchError((_) => Response<dynamic>(requestOptions: RequestOptions())),
    ]);

    if (!mounted) return;

    final reportsRes = results[0];
    final budgetRes = results[1];
    final expensesRes = results[2];
    final revenuesRes = results[3];
    final catRes = results[4];
    final targetRes = results[5];

    Map<String, dynamic> newReportsData = _reportsData;
    Map<String, dynamic> newBudgetData = _budgetData;
    List<Map<String, dynamic>> newExpenses = _expenses;
    List<Map<String, dynamic>> newRevenues = _revenues;
    List<Map<String, dynamic>> newCategories = _revenueCategories;
    Map<String, dynamic> newTargetData = _revenueTargetData;

    if (reportsRes.statusCode == 200 && reportsRes.data is Map) {
      newReportsData = Map<String, dynamic>.from(reportsRes.data as Map);
    } else {
      mainReportsFailed = true;
    }

    if (budgetRes.statusCode == 200 && budgetRes.data is Map) {
      newBudgetData = Map<String, dynamic>.from(budgetRes.data as Map);
    }

    if (expensesRes.statusCode == 200) {
      final data = expensesRes.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['results'] is List) {
        list = data['results'] as List;
      } else if (data is Map && data['expenses'] is List) {
        list = data['expenses'] as List;
      }
      newExpenses = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    if (revenuesRes.statusCode == 200) {
      final data = revenuesRes.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['results'] is List) {
        list = data['results'] as List;
      } else if (data is Map && data['revenues'] is List) {
        list = data['revenues'] as List;
      }
      newRevenues = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    if (catRes.statusCode == 200) {
      final data = catRes.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['results'] is List) {
        list = data['results'] as List;
      }
      newCategories = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    if (targetRes.statusCode == 200 && targetRes.data is Map) {
      newTargetData = Map<String, dynamic>.from(targetRes.data as Map);
    }

    setState(() {
      _reportsData = newReportsData;
      _budgetData = newBudgetData;
      _expenses = newExpenses;
      _revenues = newRevenues;
      _revenueCategories = newCategories;
      _revenueTargetData = newTargetData;
      _isLoading = false;
      if (mainReportsFailed && _reportsData.isEmpty) {
        _errorMessage = failedReason ?? 'Server error occurred while loading reports.';
      }
    });
  }

  Widget _buildReportsShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Financial Overview" title shimmer
          const KShimmer(width: 160, height: 20, radius: 6),
          const SizedBox(height: 16),
          // Net Profit / Loss card with mini chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      KShimmer(width: 28, height: 28, radius: 14),
                      SizedBox(height: 12),
                      KShimmer(width: 120, height: 24, radius: 6),
                      SizedBox(height: 6),
                      KShimmer(width: 90, height: 12, radius: 4),
                    ],
                  ),
                ),
                const KShimmer(width: 120, height: 60, radius: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Monthly Revenue & Total Expense row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      KShimmer(width: 28, height: 28, radius: 14),
                      SizedBox(height: 10),
                      KShimmer(width: 80, height: 22, radius: 6),
                      SizedBox(height: 6),
                      KShimmer(width: 100, height: 12, radius: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      KShimmer(width: 28, height: 28, radius: 14),
                      SizedBox(height: 10),
                      KShimmer(width: 80, height: 22, radius: 6),
                      SizedBox(height: 6),
                      KShimmer(width: 100, height: 12, radius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // "Monthly Budget Progress" title shimmer
          const KShimmer(width: 200, height: 18, radius: 6),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    KShimmer(width: 80, height: 14, radius: 4),
                    KShimmer(width: 120, height: 14, radius: 4),
                  ],
                ),
                const SizedBox(height: 10),
                const KShimmer(width: double.infinity, height: 10, radius: 5),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        KShimmer(width: 80, height: 10, radius: 4),
                        SizedBox(height: 4),
                        KShimmer(width: 70, height: 20, radius: 6),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        KShimmer(width: 70, height: 10, radius: 4),
                        SizedBox(height: 4),
                        KShimmer(width: 60, height: 20, radius: 6),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: _cardBorder),
          const SizedBox(height: 10),
          // "Category Budget Breakdown" title shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              KShimmer(width: 180, height: 16, radius: 6),
              KShimmer(width: 80, height: 14, radius: 4),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: KShimmer(width: 200, height: 36, radius: 20),
          ),
          const SizedBox(height: 24),
          // "Monthly Revenue Target Progress" title shimmer
          const KShimmer(width: 240, height: 18, radius: 6),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    KShimmer(width: 80, height: 14, radius: 4),
                    KShimmer(width: 120, height: 14, radius: 4),
                  ],
                ),
                const SizedBox(height: 10),
                const KShimmer(width: double.infinity, height: 10, radius: 5),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        KShimmer(width: 80, height: 10, radius: 4),
                        SizedBox(height: 4),
                        KShimmer(width: 70, height: 20, radius: 6),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        KShimmer(width: 70, height: 10, radius: 4),
                        SizedBox(height: 4),
                        KShimmer(width: 60, height: 20, radius: 6),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('Delete Expense'),
            content: const Text(
              'Are you sure you want to delete this expense?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
        if (mounted) {
          setState(() {
            _expenses.removeWhere(
              (e) => e['id'] == id || e['id']?.toString() == id.toString(),
            );
          });
        }
        Dialogs.showSnack(msg: 'Expense deleted successfully');
        await _fetchReports(silent: true);
      } else {
        Dialogs.showSnack(msg: 'Failed to delete expense');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error deleting expense');
    }
  }

  void _showExpenseSheet({Map<String, dynamic>? expense}) {
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

    final budgetSummary =
        _reportsData['budget_summary'] as Map<dynamic, dynamic>?;
    final currentBudget = budgetSummary?['budget'] ?? 5000.0;

    var selectedCategory = (expense?['category'] as String?) ?? 'Maintenance';
    var selectedDate =
        expense?['expense_date'] != null
            ? DateTime.tryParse(expense!['expense_date'].toString()) ??
                DateTime.now()
            : DateTime.now();

    final categories = [
      'Maintenance',
      'Equipment',
      'Rent',
      'Salaries',
      'Utilities',
      'Marketing',
      'Other',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
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
                        hintText: 'e.g. Gym Equipment Maintenance',
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
                              hintText: 'e.g. 1200.50',
                              prefixText: '₹',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                                categories.contains(selectedCategory)
                                    ? selectedCategory
                                    : 'Other',
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                            ),
                            items:
                                categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() {
                                  selectedCategory = val;
                                });
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
                          setSheetState(() {
                            selectedDate = picked;
                          });
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
                        labelText: 'Notes / Description',
                        hintText: 'e.g. Repaired cable machine',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Button.filled(
                        title: isEdit ? 'Update Expense' : 'Save Expense',
                        buttonColor: AppColors.primary,
                        ontap: () async {
                          final title = titleController.text.trim();
                          final amountStr = amountController.text.trim();
                          final notes = notesController.text.trim();

                          if (title.isEmpty) {
                            await Dialogs.showSnack(msg: 'Title is required');
                            return;
                          }
                          final amount = double.tryParse(amountStr);
                          if (amount == null) {
                            await Dialogs.showSnack(msg: 'Invalid amount');
                            return;
                          }

                          final payload = {
                            'title': title,
                            'amount': amount,
                            'category': selectedCategory,
                            'expense_date': DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate),
                            'notes': notes,
                            'monthly_budget': currentBudget,
                          };

                          Navigator.pop(context); // Close sheet
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }

                          try {
                            dynamic response;
                            if (isEdit) {
                              response = await DioClient().dio.patch<dynamic>(
                                ApiUris.expenseDetail(expense['id'] as int),
                                data: payload,
                                options:
                                    Options(
                                      headers: {'X-Platform': platformSource},
                                    ).token,
                              );
                            } else {
                              response = await DioClient().dio.post<dynamic>(
                                ApiUris.expenses,
                                data: payload,
                                options:
                                    Options(
                                      headers: {'X-Platform': platformSource},
                                    ).token,
                              );
                            }

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              await Dialogs.showSnack(
                                msg:
                                    isEdit
                                        ? 'Expense updated successfully'
                                        : 'Expense saved successfully',
                              );
                              await _fetchReports();
                            } else {
                              await Dialogs.showSnack(
                                msg: 'Failed to save expense',
                              );
                            }
                          } catch (e) {
                            await Dialogs.showSnack(
                              msg: 'Error saving expense',
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
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

  void _showAllExpensesSheet() {
    String searchQuery = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = searchQuery.trim().toLowerCase();
            final filtered = _expenses.where((exp) {
              if (query.isEmpty) return true;
              final title = (exp['title'] ?? '').toString().toLowerCase();
              final category = (exp['category'] ?? '').toString().toLowerCase();
              return title.contains(query) || category.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xffCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Expenses (${_expenses.length})',
                          style: AppStyles.text18Px.poppins.w600.dark,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showExpenseSheet();
                              },
                              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 26),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      onChanged: (val) {
                        setSheetState(() => searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search expenses by name or category...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        filled: true,
                        fillColor: const Color(0xffF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No expenses found'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: Color(0xffEEEEEE)),
                            itemBuilder: (context, index) {
                              final exp = filtered[index];
                              final id = exp['id'] as int? ?? 0;
                              final title = exp['title']?.toString() ?? 'Unspecified Expense';
                              final category = exp['category']?.toString() ?? 'Other';
                              final amount = exp['amount'] ?? 0.0;
                              final dateStr = exp['expense_date']?.toString() ?? '';

                              var parsedAmount = 0.0;
                              if (amount is double) {
                                parsedAmount = amount;
                              } else if (amount != null) {
                                parsedAmount = double.tryParse(amount.toString()) ?? 0.0;
                              }

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
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
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                      surfaceTintColor: Colors.transparent,
                                      onSelected: (val) {
                                        Navigator.pop(context);
                                        if (val == 'edit') {
                                          _showExpenseSheet(expense: exp);
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAllRevenuesSheet() {
    String searchQuery = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = searchQuery.trim().toLowerCase();
            final filtered = _revenues.where((rev) {
              if (query.isEmpty) return true;
              final title = (rev['title'] ?? rev['name'] ?? '').toString().toLowerCase();
              final category = (rev['category'] ?? rev['category_name'] ?? '').toString().toLowerCase();
              return title.contains(query) || category.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xffCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Revenues (${_revenues.length})',
                          style: AppStyles.text18Px.poppins.w600.dark,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showRevenueSheet();
                              },
                              icon: const Icon(Icons.add_circle, color: Color(0xff27AE60), size: 26),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      onChanged: (val) {
                        setSheetState(() => searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search revenues by name or category...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        filled: true,
                        fillColor: const Color(0xffF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No revenues found'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: Color(0xffEEEEEE)),
                            itemBuilder: (context, index) {
                              final rev = filtered[index];
                              final id = rev['id'] as int? ?? 0;
                              final title = rev['title']?.toString() ?? rev['name']?.toString() ?? 'Unspecified Revenue';
                              final category = rev['category']?.toString() ?? rev['category_name']?.toString() ?? 'Membership Fee';
                              final amount = rev['amount'] ?? 0.0;
                              final dateStr = rev['revenue_date']?.toString() ?? rev['date']?.toString() ?? '';

                              var parsedAmount = 0.0;
                              if (amount is double) {
                                parsedAmount = amount;
                              } else if (amount != null) {
                                parsedAmount = double.tryParse(amount.toString()) ?? 0.0;
                              }

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
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
                                      '+ ₹${parsedAmount.toStringAsFixed(2)}',
                                      style: AppStyles.text14Px.poppins.w600.copyWith(
                                        color: const Color(0xff27AE60),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                      surfaceTintColor: Colors.transparent,
                                      onSelected: (val) {
                                        Navigator.pop(context);
                                        if (val == 'edit') {
                                          _showRevenueSheet(revenue: rev);
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
                  ),
                ],
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
      builder:
          (context) => AlertDialog(
            backgroundColor: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            surfaceTintColor: Colors.transparent,
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
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
        if (mounted) {
          setState(() {
            _revenues.removeWhere(
              (r) => r['id'] == id || r['id']?.toString() == id.toString(),
            );
          });
        }
        Dialogs.showSnack(msg: 'Revenue record deleted successfully');
        await _fetchReports(silent: true);
      } else {
        Dialogs.showSnack(msg: 'Failed to delete revenue record');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error deleting revenue record');
    }
  }

  void _showRevenueSheet({Map<String, dynamic>? revenue}) {
    final isEdit = revenue != null;
    final titleController = TextEditingController(
      text: (revenue?['title'] as String?) ?? (revenue?['name'] as String?) ?? '',
    );
    final amountController = TextEditingController(
      text: revenue?['amount']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: (revenue?['notes'] as String?) ?? (revenue?['description'] as String?) ?? '',
    );

    var selectedCategory = (revenue?['category'] as String?) ??
        (revenue?['category_name'] as String?) ??
        'Membership Fee';
    var selectedDate =
        revenue?['revenue_date'] != null || revenue?['date'] != null
            ? DateTime.tryParse((revenue?['revenue_date'] ?? revenue?['date']).toString()) ??
                DateTime.now()
            : DateTime.now();

    final List<String> defaultCategories = [
      'Membership Fee',
      'Admission Fee',
      'Product Sales',
      'Others',
    ];

    for (final cat in _revenueCategories) {
      final catName = cat['name']?.toString() ?? cat['title']?.toString();
      if (catName != null && catName.isNotEmpty && !defaultCategories.contains(catName)) {
        defaultCategories.add(catName);
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
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
                        labelText: 'Title *',
                        hintText: 'e.g. Personal Training Fee / Product Sale',
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
                            value:
                                defaultCategories.contains(selectedCategory)
                                    ? selectedCategory
                                    : 'Others',
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                            ),
                            items:
                                defaultCategories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() {
                                  selectedCategory = val;
                                });
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
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Revenue Date',
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
                        labelText: 'Notes / Description',
                        hintText: 'e.g. Payment for quarterly training package',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Button.filled(
                        title: isEdit ? 'Update Revenue' : 'Save Revenue',
                        buttonColor: const Color(0xff27AE60),
                        ontap: () async {
                          final title = titleController.text.trim();
                          final amountStr = amountController.text.trim();
                          final notes = notesController.text.trim();

                          if (title.isEmpty) {
                            await Dialogs.showSnack(msg: 'Title is required');
                            return;
                          }
                          final amount = double.tryParse(amountStr);
                          if (amount == null) {
                            await Dialogs.showSnack(msg: 'Invalid amount');
                            return;
                          }

                          final payload = {
                            'title': title,
                            'amount': amount,
                            'category': selectedCategory,
                            'revenue_date': DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate),
                            'notes': notes,
                            'organization_id': widget.orgId,
                          };

                          Navigator.pop(context);
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }

                          try {
                            dynamic response;
                            if (isEdit) {
                              response = await DioClient().dio.patch<dynamic>(
                                ApiUris.revenueDetail(revenue['id'] as int),
                                data: payload,
                                options:
                                    Options(
                                      headers: {'X-Platform': platformSource},
                                    ).token,
                              );
                            } else {
                              response = await DioClient().dio.post<dynamic>(
                                ApiUris.revenues,
                                data: payload,
                                options:
                                    Options(
                                      headers: {'X-Platform': platformSource},
                                    ).token,
                              );
                            }

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              await Dialogs.showSnack(
                                msg:
                                    isEdit
                                        ? 'Revenue updated successfully'
                                        : 'Revenue saved successfully',
                              );
                              await _fetchReports();
                            } else {
                              await Dialogs.showSnack(
                                msg: 'Failed to save revenue record',
                              );
                            }
                          } catch (e) {
                            await Dialogs.showSnack(
                              msg: 'Error saving revenue record',
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
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

  void _showSetCategoryBudgetsDialog([double? currentOverallBudget]) {
    final now = DateTime.now();
    final currentYear = _startDate?.year ?? now.year;
    final currentMonth = _startDate?.month ?? now.month;

    final List<dynamic> existingCategories =
        (_budgetData['categories'] as List<dynamic>?) ??
        ((_reportsData['budget_summary'] as Map?)?['categories'] as List<dynamic>?) ??
        [];

    final Map<String, TextEditingController> categoryControllers = {};
    for (final cat in _budgetCategories) {
      double existingAmount = 0.0;
      for (final item in existingCategories) {
        if (item is Map &&
            item['category']?.toString().toLowerCase() == cat.toLowerCase()) {
          existingAmount =
              double.tryParse((item['budget'] ?? item['amount'] ?? 0.0).toString()) ??
                  0.0;
          break;
        }
      }
      categoryControllers[cat] = TextEditingController(
        text: existingAmount > 0 ? existingAmount.toStringAsFixed(0) : '',
      );
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        surfaceTintColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Set Category Budgets',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set monthly budget limits per category for ${DateFormat('MMMM yyyy').format(DateTime(currentYear, currentMonth))}:',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._budgetCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: categoryControllers[cat],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: '$cat Budget (₹)',
                        labelStyle: TextStyle(
                          color: context.colors.textSecondary,
                        ),
                        hintText: 'e.g. 20000',
                        filled: true,
                        fillColor: context.colors.fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final List<Map<String, dynamic>> categoryPayload = [];
              categoryControllers.forEach((cat, ctrl) {
                final amountVal = double.tryParse(ctrl.text.trim()) ?? 0.0;
                if (amountVal > 0) {
                  categoryPayload.add({
                    'category': cat,
                    'amount': amountVal,
                  });
                }
              });

              if (categoryPayload.isEmpty) {
                Dialogs.showSnack(
                  msg: 'Please enter a budget amount for at least one category',
                );
                return;
              }

              Navigator.pop(ctx);
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }

              try {
                final payload = {
                  'year': currentYear,
                  'month': currentMonth,
                  'categories': categoryPayload,
                };

                final response = await DioClient().dio.post<dynamic>(
                  ApiUris.budget,
                  data: payload,
                  options:
                      Options(headers: {'X-Platform': platformSource}).token,
                );

                if (response.statusCode == 200 ||
                    response.statusCode == 201) {
                  Dialogs.showSnack(
                    msg: 'Category budgets updated successfully!',
                  );
                  await _fetchReports();
                } else {
                  Dialogs.showSnack(msg: 'Failed to set category budgets');
                }
              } catch (e) {
                Dialogs.showSnack(msg: 'Error setting category budgets');
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save Budgets'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getProcessedRevenueTargets(List<dynamic> rawCategories) {
    if (rawCategories.isEmpty) return [];

    final standardNames = {
      'membership fee',
      'admission fee',
      'product sales',
      'diet consultation',
      'others',
    };

    final customCatNames = <String>{};
    for (final cat in _revenueCategories) {
      if (cat is Map) {
        final isPlan = cat['is_membership_plan'] == true ||
            cat['membership_plan_id'] != null ||
            cat['is_plan'] == true;
        final name = (cat['name'] ?? cat['category'] ?? cat['title'])?.toString().trim();
        if (name != null && name.isNotEmpty && !isPlan) {
          customCatNames.add(name.toLowerCase());
        }
      }
    }

    final Map<String, double> targetMap = {};
    final Map<String, double> actualMap = {};
    final Map<String, String> displayNameMap = {};

    for (final item in rawCategories) {
      if (item is! Map) continue;

      final rawName = (item['category'] ?? item['name'] ?? 'Others').toString().trim();
      final lowerName = rawName.toLowerCase();
      final targetVal = double.tryParse((item['target'] ?? item['amount'] ?? 0.0).toString()) ?? 0.0;
      final actualVal = double.tryParse((item['actual'] ?? item['actual_revenue'] ?? 0.0).toString()) ?? 0.0;

      final isStandardOrCustom = standardNames.contains(lowerName) || customCatNames.contains(lowerName);

      if (isStandardOrCustom && lowerName != 'membership fee') {
        targetMap[lowerName] = (targetMap[lowerName] ?? 0.0) + targetVal;
        actualMap[lowerName] = (actualMap[lowerName] ?? 0.0) + actualVal;
        displayNameMap[lowerName] = rawName;
      } else {
        // Membership plan or 'Membership Fee' itself -> fold into 'Membership Fee'
        targetMap['membership fee'] = (targetMap['membership fee'] ?? 0.0) + targetVal;
        actualMap['membership fee'] = (actualMap['membership fee'] ?? 0.0) + actualVal;
        displayNameMap['membership fee'] = 'Membership Fee';
      }
    }

    final List<Map<String, dynamic>> processed = [];
    targetMap.forEach((key, targetVal) {
      final actualVal = actualMap[key] ?? 0.0;
      final remVal = targetVal > actualVal ? targetVal - actualVal : 0.0;
      final achPct = targetVal > 0 ? (actualVal / targetVal) * 100.0 : (actualVal > 0 ? 100.0 : 0.0);

      processed.add({
        'category': displayNameMap[key] ?? key,
        'target': targetVal,
        'actual': actualVal,
        'remaining': remVal,
        'achievement_percentage': achPct,
      });
    });

    return processed;
  }

  void _showSetCategoryRevenueTargetsDialog([double? currentOverallTarget]) {
    final now = DateTime.now();
    final currentYear = _startDate?.year ?? now.year;
    final currentMonth = _startDate?.month ?? now.month;

    final List<dynamic> existingTargetCategories =
        (_revenueTargetData['categories'] as List<dynamic>?) ??
        ((_reportsData['revenue_target_summary'] as Map?)?['categories'] as List<dynamic>?) ??
        [];

    final processedExisting = _getProcessedRevenueTargets(existingTargetCategories);

    final Set<String> allCategoryNames = {
      'Membership Fee',
      'Admission Fee',
      'Product Sales',
      'Diet Consultation',
      'Others',
    };

    for (final cat in _revenueCategories) {
      if (cat is Map) {
        final isPlan = cat['is_membership_plan'] == true ||
            cat['membership_plan_id'] != null ||
            cat['is_plan'] == true;
        final name = (cat['name'] ?? cat['category'] ?? cat['title'])?.toString().trim();
        if (name != null && name.isNotEmpty && !isPlan) {
          allCategoryNames.add(name);
        }
      }
    }

    final Map<String, TextEditingController> categoryControllers = {};
    for (final cat in allCategoryNames) {
      double existingAmount = 0.0;
      for (final item in processedExisting) {
        if (item['category']?.toString().toLowerCase() == cat.toLowerCase()) {
          existingAmount =
              double.tryParse((item['target'] ?? item['amount'] ?? 0.0).toString()) ??
                  0.0;
          break;
        }
      }
      categoryControllers[cat] = TextEditingController(
        text: existingAmount > 0 ? existingAmount.toStringAsFixed(0) : '',
      );
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        surfaceTintColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.track_changes, color: Color(0xff27AE60)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Set Revenue Targets',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set monthly revenue targets per category for ${DateFormat('MMMM yyyy').format(DateTime(currentYear, currentMonth))}:',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ...allCategoryNames.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: categoryControllers[cat],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: '$cat Target (₹)',
                        labelStyle: TextStyle(
                          color: context.colors.textSecondary,
                        ),
                        hintText: 'e.g. 50000',
                        filled: true,
                        fillColor: context.colors.fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xff27AE60)),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final List<Map<String, dynamic>> categoryPayload = [];
              categoryControllers.forEach((cat, ctrl) {
                final amountVal = double.tryParse(ctrl.text.trim()) ?? 0.0;
                if (amountVal > 0) {
                  categoryPayload.add({
                    'category': cat,
                    'target': amountVal,
                    'amount': amountVal,
                  });
                }
              });

              if (categoryPayload.isEmpty) {
                Dialogs.showSnack(
                  msg: 'Please enter a target amount for at least one category',
                );
                return;
              }

              Navigator.pop(ctx);
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }

              try {
                final payload = {
                  'organization_id': widget.orgId,
                  'year': currentYear,
                  'month': currentMonth,
                  'targets': categoryPayload,
                  'categories': categoryPayload,
                };

                final response = await DioClient().dio.post<dynamic>(
                  ApiUris.revenueTargets,
                  data: payload,
                  options:
                      Options(headers: {'X-Platform': platformSource}).token,
                );

                if (response.statusCode == 200 ||
                    response.statusCode == 201) {
                  Dialogs.showSnack(
                    msg: 'Revenue targets updated successfully!',
                  );
                  await _fetchReports();
                } else {
                  Dialogs.showSnack(msg: 'Failed to set revenue targets');
                }
              } catch (e) {
                Dialogs.showSnack(msg: 'Error setting revenue targets');
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff27AE60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save Targets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null && _reportsData.isEmpty) {
      return Scaffold(
        backgroundColor: context.isDarkMode ? context.colors.card : const Color(0xffF7F7F7),
        appBar: AppBar(
          backgroundColor: context.isDarkMode ? context.colors.card : Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          automaticallyImplyLeading: false,
          titleSpacing: widget.showBackButton ? null : 16,
          leading: widget.showBackButton ? const PopButton().center : null,
          title: Text(
            'Gym Analytics & Reports',
            style: AppStyles.text18Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xffFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 40,
                    color: Color(0xffDC2626),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Server Error',
                  style: AppStyles.text18Px.poppins.w600.dark,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppStyles.text14Px.poppins.textGrey,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _fetchReports();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                  label: const Text('Try Again', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      // Parsing variables
      final financial =
          _reportsData['financial_metrics'] as Map<dynamic, dynamic>?;
      final totalRevenue = financial?['total_revenue'] ?? 0.0;
      final totalExpense = financial?['total_expense'] ?? 0.0;
      final netProfit = financial?['net_profit'] ?? 0.0;
      final planRevenueBreakdown =
          financial?['plan_revenue_breakdown'] as List<dynamic>? ?? [];

      // Parse payment mode breakdown
      final paymentModeData = financial?['payment_mode_breakdown']
          ?? financial?['payment_modes']
          ?? _reportsData['payment_mode_breakdown']
          ?? _reportsData['payment_modes'];

      final List<dynamic> paymentModes = [];
      if (paymentModeData is Map) {
        paymentModeData.forEach((key, value) {
          final amt = double.tryParse(value.toString()) ?? 0.0;
          if (amt > 0) {
            paymentModes.add({
              'mode': key.toString(),
              'amount': amt,
            });
          }
        });
      } else if (paymentModeData is List) {
        for (final item in paymentModeData) {
          if (item is Map) {
            final mode = item['payment_mode'] ?? item['mode'] ?? 'Unknown';
            final amt = double.tryParse((item['amount'] ?? item['total'] ?? 0.0).toString()) ?? 0.0;
            if (amt > 0) {
              paymentModes.add({
                'mode': mode.toString(),
                'amount': amt,
              });
            }
          }
        }
      }
      paymentModes.sort((a, b) => _safeDouble(b['amount']).compareTo(_safeDouble(a['amount'])));

      final revGrowth = financial?['revenue_growth'] as Map<dynamic, dynamic>?;
      final expGrowth = financial?['expense_growth'] as Map<dynamic, dynamic>?;
      final profitGrowth = financial?['net_profit_growth'] as Map<dynamic, dynamic>?;
      final recentActivityRaw = financial?['recent_activity'] ?? _reportsData['recent_activity'];
      final halfYearOverviewRaw = financial?['half_year_overview'] ??
          _reportsData['half_year_overview'] ??
          (_reportsData['data'] is Map ? (_reportsData['data'] as Map)['half_year_overview'] : null);

      final demographics =
          _reportsData['client_demographics'] as Map<dynamic, dynamic>?;
      final totalClients = demographics?['total_clients'] ?? 0;
      final genderDistribution =
          demographics?['gender_distribution'] as Map<dynamic, dynamic>? ?? {};
      final ageDistribution =
          demographics?['age_distribution'] as Map<dynamic, dynamic>? ?? {};

      final professionDistribution = demographics?['profession_distribution']
          ?? _reportsData['profession_distribution']
          ?? [];
      final sleepHoursDistribution = demographics?['sleep_hours_distribution']
          ?? _reportsData['sleep_hours_distribution']
          ?? [];
      final workingHoursDistribution = demographics?['working_hours_distribution']
          ?? _reportsData['working_hours_distribution']
          ?? [];

      // Parse target goal distribution (nested under goals_insights)
      final goalInsightsRaw = _reportsData['goals_insights'];
      Map<dynamic, dynamic>? goalInsights;
      if (goalInsightsRaw is Map) {
        goalInsights = goalInsightsRaw;
      }
      final goalDistribution = goalInsights?['goal_distribution']
          ?? goalInsights?['target_goal_distribution']
          ?? demographics?['goal_distribution']
          ?? demographics?['target_goal_distribution']
          ?? [];

      final attendance =
          _reportsData['attendance_patterns'] as Map<dynamic, dynamic>?;
      final totalCompletedSessions = attendance?['total_completed_sessions'] ?? 0;
      final peakWorkoutHours =
          attendance?['peak_workout_hours'] as Map<dynamic, dynamic>? ?? {};

      final trainersPerformance =
          _reportsData['trainers_performance'] as List<dynamic>? ?? [];
      final trainerDemographics =
          _reportsData['trainer_demographics'] as Map<dynamic, dynamic>? ?? {};
      final trainerGenderDist =
          trainerDemographics['gender_distribution'] as Map<dynamic, dynamic>? ?? {};
      final trainerAgeDist =
          trainerDemographics['age_distribution'] as Map<dynamic, dynamic>? ?? {};
      final totalTrainers =
          trainerDemographics['total_trainers'] ?? trainersPerformance.length;

      final budgetSummary =
          _reportsData['budget_summary'] as Map<dynamic, dynamic>?;

      final double budget = double.tryParse((_budgetData['monthly_budget'] ??
              _budgetData['total_budget'] ??
              _budgetData['budget'] ??
              budgetSummary?['budget'] ??
              0.0)
          .toString()) ?? 0.0;

      final double budgetUsedAmount = double.tryParse((_budgetData['amount_used'] ??
              budgetSummary?['budget_used_amount'] ??
              0.0)
          .toString()) ?? 0.0;

      final double budgetRemaining = double.tryParse((_budgetData['remaining_budget'] ??
              budgetSummary?['budget_remaining'] ??
              0.0)
          .toString()) ?? 0.0;

      String budgetUsedPercentage = "0%";
      if (_budgetData['utilization_percentage'] != null) {
        budgetUsedPercentage = "${_budgetData['utilization_percentage']}%";
      } else if (budgetSummary?['budget_used_percentage'] != null) {
        budgetUsedPercentage = budgetSummary!['budget_used_percentage'].toString();
      }

      final List<dynamic> categoryBreakdown =
          (_budgetData['categories'] as List<dynamic>?) ??
          (budgetSummary?['categories'] as List<dynamic>?) ??
          [];

      final isDark = context.isDarkMode;

      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: isDark ? context.colors.card : const Color(0xffF7F7F7),
          appBar: AppBar(
            backgroundColor: isDark ? context.colors.card : Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            automaticallyImplyLeading: false,
            titleSpacing: widget.showBackButton ? null : 16,
            leading: widget.showBackButton ? const PopButton().center : null,
            title: Text(
              'Gym Analytics & Reports',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? context.colors.fieldFill : const Color(0xffE8ECEF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? context.colors.textSecondary : const Color(0xff2D3139),
                  labelStyle: AppStyles.text14Px.poppins.w600,
                  unselectedLabelStyle: AppStyles.text14Px.poppins.w500,
                  tabs: const [
                    Tab(height: 36, text: 'Finance'),
                    Tab(height: 36, text: 'Trainers'),
                    Tab(height: 36, text: 'Clients'),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              if (_startDate != null && _endDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    border: Border(
                      bottom: BorderSide(color: _cardBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filtered: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _selectedYear = DateTime.now().year;
                            _selectedMonth = DateTime.now().month;
                          });
                          _fetchReports();
                        },
                        child: Text(
                          'Clear',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? _buildReportsShimmer()
                    : TabBarView(
                        children: [
                      _ReportsKeepAliveTab(
                        child: _buildFinanceTab(
                        monthlyRevenue:
                            totalRevenue is double
                                ? totalRevenue
                                : double.tryParse(totalRevenue.toString()) ?? 0.0,
                        totalExpense:
                            totalExpense is double
                                ? totalExpense
                                : double.tryParse(totalExpense.toString()) ?? 0.0,
                        netProfit:
                            netProfit is double
                                ? netProfit
                                : double.tryParse(netProfit.toString()) ?? 0.0,
                        revenueGrowth: revGrowth,
                        expenseGrowth: expGrowth,
                        netProfitGrowth: profitGrowth,
                        recentActivity: recentActivityRaw,
                        halfYearOverview: halfYearOverviewRaw,
                        budget: budget,
                        budgetUsedAmount: budgetUsedAmount,
                        budgetUsedPercentage: budgetUsedPercentage,
                        budgetRemaining: budgetRemaining,
                        planRevenueBreakdown: planRevenueBreakdown,
                        paymentModes: paymentModes,
                        categoryBreakdown: categoryBreakdown,
                      ),
                      ),
                      _ReportsKeepAliveTab(
                        child: OrganizationTrainersReportWidget(
                          orgId: widget.orgId,
                        ),
                      ),
                      _ReportsKeepAliveTab(
                        child: _buildClientsTab(
                          totalClients: totalClients.toString(),
                        completedSessions: totalCompletedSessions.toString(),
                        retentionRate: financial?['retention_rate']?.toString() ?? "0%",
                        genderDistribution: genderDistribution,
                        ageDistribution: ageDistribution,
                        goalDistribution: goalDistribution,
                        professionDistribution: professionDistribution,
                        sleepHoursDistribution: sleepHoursDistribution,
                        workingHoursDistribution: workingHoursDistribution,
                        peakWorkoutHours: peakWorkoutHours,
                        ),
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error building OrganizationReportsScreen: $e\n$stack');
      return Scaffold(
        backgroundColor: context.isDarkMode ? context.colors.card : const Color(0xffF7F7F7),
        appBar: AppBar(
          backgroundColor: context.isDarkMode ? context.colors.card : Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          automaticallyImplyLeading: false,
          titleSpacing: widget.showBackButton ? null : 16,
          leading: widget.showBackButton ? const PopButton().center : null,
          title: Text(
            'Gym Analytics & Reports',
            style: AppStyles.text18Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Unable to display reports',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                const SizedBox(height: 8),
                Text(
                  'There was an unexpected error processing report data.',
                  textAlign: TextAlign.center,
                  style: AppStyles.text14Px.poppins.textGrey,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _fetchReports();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildClientsTab({
    required String totalClients,
    required String completedSessions,
    required String retentionRate,
    required Map<dynamic, dynamic> genderDistribution,
    required Map<dynamic, dynamic> ageDistribution,
    required dynamic goalDistribution,
    required dynamic professionDistribution,
    required dynamic sleepHoursDistribution,
    required dynamic workingHoursDistribution,
    required Map<dynamic, dynamic> peakWorkoutHours,
  }) {
    return RefreshIndicator(
      onRefresh: _fetchReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Client Overview'),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 750;
                final activeCard = _buildReportCard(
                  title: 'Active Clients',
                  value: totalClients,
                  icon: Icons.people_outline,
                  color: const Color(0xff486CC2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportsCustomerListScreen(
                          orgId: widget.orgId,
                          filterType: 'all',
                          filterValue: '',
                          filterLabel: 'All Active Clients',
                          startDate: _startDate,
                          endDate: _endDate,
                        ),
                      ),
                    );
                  },
                );

                final sessionsCard = _buildReportCard(
                  title: 'Completed Sessions',
                  value: completedSessions,
                  icon: Icons.check_circle_outline,
                  color: const Color(0xff527F50),
                );

                final retentionCard = _buildReportCard(
                  title: 'Retention Rate',
                  value: retentionRate,
                  icon: Icons.trending_up_outlined,
                  color: const Color(0xffE67E22),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: activeCard),
                      const SizedBox(width: 14),
                      Expanded(child: sessionsCard),
                      const SizedBox(width: 14),
                      Expanded(child: retentionCard),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: activeCard),
                        const SizedBox(width: 12),
                        Expanded(child: sessionsCard),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: retentionCard),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Client Demographics'),
            _buildDemographics(genderDistribution, ageDistribution, widget.orgId, _startDate, _endDate),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 850;

                Widget wrapSection(String title, Widget child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSectionTitle(title),
                      child,
                    ],
                  );
                }

                final hasProfession = professionDistribution is List && professionDistribution.isNotEmpty;
                final hasSleep = sleepHoursDistribution is List && sleepHoursDistribution.isNotEmpty;
                final hasWorkingHours = workingHoursDistribution is List && workingHoursDistribution.isNotEmpty;
                final hasPeakHours = peakWorkoutHours.isNotEmpty;

                Widget professionWidget = hasProfession
                    ? wrapSection(
                        'Profession Distribution',
                        _buildDistributionListCard(
                          items: professionDistribution,
                          titleKey: 'profession',
                          filterType: 'profession',
                          barColor: const Color(0xff3498DB),
                          icon: Icons.work_outline_rounded,
                        ),
                      )
                    : const SizedBox.shrink();

                Widget sleepWidget = hasSleep
                    ? wrapSection(
                        'Sleep Hours Distribution',
                        _buildDistributionListCard(
                          items: sleepHoursDistribution,
                          titleKey: 'range',
                          filterType: 'sleep_hours',
                          barColor: const Color(0xff9B59B6),
                          icon: Icons.bedtime_outlined,
                        ),
                      )
                    : const SizedBox.shrink();

                Widget workingHoursWidget = hasWorkingHours
                    ? wrapSection(
                        'Working Hours Distribution',
                        _buildDistributionListCard(
                          items: workingHoursDistribution,
                          titleKey: 'range',
                          filterType: 'working_hours',
                          barColor: const Color(0xffE67E22),
                          icon: Icons.access_time_rounded,
                        ),
                      )
                    : const SizedBox.shrink();

                Widget goalsWidget = wrapSection(
                  'Client Goals & Target Distribution',
                  _buildGoalDistribution(goalDistribution),
                );

                Widget calendarWidget = wrapSection(
                  'Client Workout Calendar',
                  ClientWorkoutCalendarWidget(orgId: widget.orgId),
                );

                Widget peakHoursWidget = hasPeakHours
                    ? wrapSection(
                        'Peak Workout Hours',
                        _buildPeakHours(peakWorkoutHours),
                      )
                    : const SizedBox.shrink();

                if (isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Profession & Sleep Hours
                      if (hasProfession || hasSleep) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasProfession) Expanded(child: professionWidget),
                            if (hasProfession && hasSleep) const SizedBox(width: 16),
                            if (hasSleep) Expanded(child: sleepWidget),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Row 2: Working Hours & Client Goals
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasWorkingHours) ...[
                            Expanded(child: workingHoursWidget),
                            const SizedBox(width: 16),
                          ],
                          Expanded(child: goalsWidget),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Row 3: Client Workout Calendar & Peak Workout Hours
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: calendarWidget),
                          if (hasPeakHours) ...[
                            const SizedBox(width: 16),
                            Expanded(child: peakHoursWidget),
                          ],
                        ],
                      ),
                    ],
                  );
                }

                // Mobile fallback (single column)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasProfession) ...[professionWidget, const SizedBox(height: 24)],
                    if (hasSleep) ...[sleepWidget, const SizedBox(height: 24)],
                    if (hasWorkingHours) ...[workingHoursWidget, const SizedBox(height: 24)],
                    calendarWidget,
                    const SizedBox(height: 24),
                    goalsWidget,
                    if (hasPeakHours) ...[const SizedBox(height: 24), peakHoursWidget],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainersTab({
    required List<dynamic> trainersPerformance,
    required Map<dynamic, dynamic> trainerGenderDist,
    required Map<dynamic, dynamic> trainerAgeDist,
    required String totalTrainers,
  }) {
    return RefreshIndicator(
      onRefresh: _fetchReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Trainer Overview'),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildReportCard(
                  title: 'Total Trainers',
                  value: totalTrainers,
                  icon: Icons.badge_outlined,
                  color: AppColors.primary,
                ),
              ],
            ),
            if (trainerGenderDist.isNotEmpty || trainerAgeDist.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Trainer Demographics'),
              _buildTrainerDemographics(trainerGenderDist, trainerAgeDist),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle('Trainer Performance'),
            if (trainersPerformance.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.textGrey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No trainer performance data available',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              _buildTrainerPerformance(trainersPerformance),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerDemographics(
    Map<dynamic, dynamic> genderDist,
    Map<dynamic, dynamic> ageDist,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender Distribution',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          _GenderPieChart(
            genderDist: genderDist,
            orgId: widget.orgId,
            startDate: _startDate,
            endDate: _endDate,
            isTrainer: true,
          ),

          const Divider(height: 32, color: Color(0xffEEEEEE)),

          Text('Age Distribution', style: AppStyles.text14Px.poppins.w600.dark),
          const SizedBox(height: 12),
          ...ageDist.entries.map((e) {
            final key = e.key.toString();
            final formattedKey = _formatAgeKey(key);
            final data = e.value as Map<dynamic, dynamic>?;
            if (data == null) return const SizedBox.shrink();
            final String pctStr = data['percentage']?.toString() ?? '0%';
            final count = data['count'] as int? ?? 0;

            double parsedPct = 0.0;
            try {
              parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
            } catch (_) {}

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      formattedKey,
                      style: AppStyles.text12Px.poppins.w500.dark,
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: parsedPct,
                      backgroundColor: const Color(0xffF0F0F0),
                      color: const Color(0xffF39C12),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$pctStr ($count)',
                      style: AppStyles.text12Px.poppins.w500.dark,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatAgeKey(String rawKey) {
    switch (rawKey.toLowerCase()) {
      case 'under_18':
      case 'under-18':
      case 'under18':
        return '< 18';
      case '18-25':
      case '18_25':
        return '18 - 25';
      case '26-35':
      case '26_35':
        return '26 - 35';
      case '36-45':
      case '36_45':
        return '36 - 45';
      case '46-55':
      case '46_55':
        return '46 - 55';
      case '56+':
      case '56_plus':
      case 'over_55':
        return '56+';
      case 'unspecified':
        return 'Unspecified';
      default:
        return rawKey;
    }
  }



  Widget _buildCategoryBreakdownSection(List<dynamic> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final displayedCategories = _isCategoryBreakdownExpanded
        ? categories
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category Budget Breakdown',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              '${categories.length} Categories',
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...displayedCategories.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final catName = map['category']?.toString() ?? 'Other';
          final catBudget = double.tryParse(
                  (map['budget'] ?? map['amount'] ?? 0.0).toString()) ??
              0.0;
          final catUsed =
              double.tryParse((map['amount_used'] ?? 0.0).toString()) ?? 0.0;
          final catRem = double.tryParse((map['remaining_budget'] ??
                  (catBudget - catUsed))
              .toString()) ??
              0.0;
          final catUtil = double.tryParse(
                  (map['utilization_percentage'] ?? 0.0).toString()) ??
              0.0;
          final pct = (catUtil / 100.0).clamp(0.0, 1.0);
          final int? expenseCount = map['expense_count'] as int?;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(catName),
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          catName,
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${catUsed.toStringAsFixed(0)} / ₹${catBudget.toStringAsFixed(0)} (${catUtil.toStringAsFixed(0)}%)',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: pct >= 0.9
                            ? Colors.red
                            : (pct >= 0.7
                                ? Colors.orange
                                : context.colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: context.colors.border,
                    color: pct >= 0.9
                        ? const Color(0xffE74C3C)
                        : (pct >= 0.7
                            ? const Color(0xffF39C12)
                            : const Color(0xff2ECC71)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining: ₹${catRem.toStringAsFixed(0)}',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    if (expenseCount != null)
                      Text(
                        '$expenseCount expense${expenseCount == 1 ? '' : 's'}',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: () {
            setState(() {
              _isCategoryBreakdownExpanded = !_isCategoryBreakdownExpanded;
            });
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              decoration: BoxDecoration(
                color: context.colors.fieldFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isCategoryBreakdownExpanded
                        ? 'Hide Categories'
                        : 'View Categories Breakdown (${categories.length})',
                    style: AppStyles.text13Px.poppins.w600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isCategoryBreakdownExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueTargetCategoryBreakdownSection(List<dynamic> rawCategories) {
    if (rawCategories.isEmpty) return const SizedBox.shrink();

    final categories = _getProcessedRevenueTargets(rawCategories);
    if (categories.isEmpty) return const SizedBox.shrink();

    final displayedCategories = _isRevenueTargetBreakdownExpanded
        ? categories
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category Target Breakdown',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              '${categories.length} Categories',
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...displayedCategories.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final catName = map['category']?.toString() ?? 'Other';
          final targetVal = double.tryParse(
                  (map['target'] ?? map['amount'] ?? 0.0).toString()) ??
              0.0;
          final actualVal = double.tryParse(
                  (map['actual'] ?? map['actual_revenue'] ?? 0.0).toString()) ??
              0.0;
          final remVal = double.tryParse(
                  (map['remaining'] ?? 0.0).toString()) ??
              (targetVal > actualVal ? targetVal - actualVal : 0.0);
          final achPct = double.tryParse(
                  (map['achievement_percentage'] ?? 0.0).toString()) ??
              (targetVal > 0 ? (actualVal / targetVal) * 100.0 : 0.0);
          final pct = (achPct / 100.0).clamp(0.0, 1.0);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(catName),
                          size: 16,
                          color: const Color(0xff27AE60),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          catName,
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${actualVal.toStringAsFixed(0)} / ₹${targetVal.toStringAsFixed(0)} (${achPct.toStringAsFixed(0)}%)',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: pct >= 1.0
                            ? const Color(0xff27AE60)
                            : (pct >= 0.7
                                ? const Color(0xff2ECC71)
                                : Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: context.colors.border,
                    color: pct >= 1.0
                        ? const Color(0xff27AE60)
                        : (pct >= 0.7
                            ? const Color(0xff2ECC71)
                            : const Color(0xffF39C12)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      remVal > 0
                          ? 'Remaining: ₹${remVal.toStringAsFixed(0)}'
                          : 'Target Met 🎉',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: remVal > 0
                            ? context.colors.textSecondary
                            : const Color(0xff27AE60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: () {
            setState(() {
              _isRevenueTargetBreakdownExpanded =
                  !_isRevenueTargetBreakdownExpanded;
            });
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              decoration: BoxDecoration(
                color: context.colors.fieldFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRevenueTargetBreakdownExpanded
                        ? 'Hide Categories'
                        : 'View Target Breakdown (${categories.length})',
                    style: AppStyles.text13Px.poppins.w600.copyWith(
                      color: const Color(0xff27AE60),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isRevenueTargetBreakdownExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xff27AE60),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'equipment':
        return Icons.fitness_center;
      case 'maintenance':
        return Icons.build;
      case 'utilities':
        return Icons.lightbulb_outline;
      case 'marketing':
        return Icons.campaign;
      case 'salary':
      case 'salaries':
        return Icons.payments;
      case 'rent':
        return Icons.store;
      default:
        return Icons.category;
    }
  }

  Widget _buildFinanceTab({
    required double monthlyRevenue,
    required double totalExpense,
    required double netProfit,
    Map<dynamic, dynamic>? revenueGrowth,
    Map<dynamic, dynamic>? expenseGrowth,
    Map<dynamic, dynamic>? netProfitGrowth,
    dynamic recentActivity,
    dynamic halfYearOverview,
    required double budget,
    required double budgetUsedAmount,
    required String budgetUsedPercentage,
    required double budgetRemaining,
    required List<dynamic> planRevenueBreakdown,
    required List<dynamic> paymentModes,
    required List<dynamic> categoryBreakdown,
  }) {
    var budgetPctVal = 0.0;
    try {
      budgetPctVal =
          double.parse(budgetUsedPercentage.replaceAll('%', '')) / 100.0;
    } catch (_) {}
    if (budgetPctVal > 1.0) budgetPctVal = 1.0;
    if (budgetPctVal < 0.0) budgetPctVal = 0.0;

    final double targetRevenue = double.tryParse((_revenueTargetData['total_target_revenue'] ??
            _revenueTargetData['target_revenue'] ??
            _revenueTargetData['target'] ??
            0.0).toString()) ?? 0.0;

    final double actualRevenue = double.tryParse((_revenueTargetData['total_actual_revenue'] ??
            _revenueTargetData['actual_revenue'] ??
            _revenueTargetData['actual'] ??
            monthlyRevenue).toString()) ?? 0.0;

    final double remainingTarget = double.tryParse((_revenueTargetData['remaining_to_target'] ??
            _revenueTargetData['remaining'] ??
            0.0).toString()) ?? (targetRevenue > actualRevenue ? targetRevenue - actualRevenue : 0.0);

    final String achievementPercentageStr = _revenueTargetData['achievement_percentage'] != null
        ? "${_revenueTargetData['achievement_percentage']}%"
        : (targetRevenue > 0 ? "${((actualRevenue / targetRevenue) * 100).toStringAsFixed(1)}%" : "0%");

    double targetPctVal = 0.0;
    try {
      targetPctVal = double.parse(achievementPercentageStr.replaceAll('%', '')) / 100.0;
    } catch (_) {}
    if (targetPctVal < 0.0) targetPctVal = 0.0;

    final List<dynamic> revenueCategoryTargets =
        (_revenueTargetData['categories'] as List<dynamic>?) ?? [];

    // Parse growth indicators
    final String profitComparisonText = netProfitGrowth?['comparison_text']?.toString() ??
        (netProfitGrowth?['percentage'] != null
            ? '${_safeNum(netProfitGrowth!['percentage']) >= 0 ? '+' : ''}${netProfitGrowth['percentage']}% vs last month'
            : '+18% vs Aug');
    final bool isProfitPositive = netProfitGrowth?['is_positive'] as bool? ?? (netProfit >= 0);

    List<double> sparklineValues = [];
    if (netProfitGrowth?['sparkline'] is List) {
      for (final e in netProfitGrowth!['sparkline'] as List) {
        if (e is num) {
          sparklineValues.add(e.toDouble());
        } else if (e is Map) {
          final val = e['value'] ?? e['amount'] ?? e['net_profit'] ?? e['profit'];
          if (val is num) {
            sparklineValues.add(val.toDouble());
          } else if (val != null) {
            sparklineValues.add(double.tryParse(val.toString()) ?? 0.0);
          }
        } else if (e != null) {
          final parsed = double.tryParse(e.toString());
          if (parsed != null) {
            sparklineValues.add(parsed);
          }
        }
      }
    }
    if (sparklineValues.length < 2) {
      sparklineValues = _get3MonthProfitData(netProfit).map((e) => e.value).toList();
      if (sparklineValues.length == 3) {
        final v1 = sparklineValues[0];
        final v2 = sparklineValues[1];
        final v3 = sparklineValues[2];
        sparklineValues = [
          v1 * 0.85,
          v1,
          (v1 + v2) / 2,
          v2,
          (v2 + v3) / 2,
          v3,
        ];
      }
    }

    final String revGrowthText = revenueGrowth?['comparison_text']?.toString() ??
        (revenueGrowth?['percentage'] != null
            ? '${_safeNum(revenueGrowth!['percentage']) >= 0 ? '+' : ''}${revenueGrowth['percentage']}% vs last month'
            : '+12% vs last month');
    final bool isRevPositive = revenueGrowth?['is_positive'] as bool? ?? true;

    final String expGrowthText = expenseGrowth?['comparison_text']?.toString() ??
        (expenseGrowth?['percentage'] != null
            ? '${_safeNum(expenseGrowth!['percentage']) >= 0 ? '+' : ''}${expenseGrowth['percentage']}% vs last month'
            : '-8% vs last month');
    final bool isExpPositive = expenseGrowth?['is_positive'] as bool? ?? false;

    // Parse or synthesize recent activities
    final List<Map<String, dynamic>> parsedRecentActivity = [];
    if (recentActivity is List && recentActivity.isNotEmpty) {
      for (final item in recentActivity) {
        if (item is Map) {
          parsedRecentActivity.add({
            'id': item['id']?.toString() ?? '',
            'type': (item['type'] ?? 'revenue').toString().toLowerCase(),
            'title': (item['title'] ?? item['name'] ?? 'Transaction').toString(),
            'subtitle': (item['subtitle'] ?? item['date'] ?? '').toString(),
            'amount': _safeDouble(item['amount']),
            'user_avatar': item['user_avatar']?.toString(),
            'date': item['date']?.toString() ?? '',
          });
        }
      }
    } else {
      for (final r in _revenues) {
        parsedRecentActivity.add({
          'id': r['id']?.toString() ?? '',
          'type': 'revenue',
          'title': (r['title'] ?? r['client_name'] ?? 'Revenue').toString(),
          'subtitle': (r['category'] ?? r['payment_mode'] ?? 'Income').toString(),
          'amount': _safeDouble(r['amount']),
          'user_avatar': r['client_avatar']?.toString(),
          'date': (r['revenue_date'] ?? r['created_at'] ?? '').toString(),
        });
      }
      for (final e in _expenses) {
        parsedRecentActivity.add({
          'id': e['id']?.toString() ?? '',
          'type': 'expense',
          'title': (e['title'] ?? e['category'] ?? 'Expense').toString(),
          'subtitle': (e['category'] ?? 'Expense').toString(),
          'amount': _safeDouble(e['amount']),
          'user_avatar': null,
          'date': (e['expense_date'] ?? e['created_at'] ?? '').toString(),
        });
      }
      parsedRecentActivity.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    }

    // Parse half-year overview data
    final List<({String month, double revenue, double expense})> overviewData = [];
    final monthsInHalf = _overviewHalf == 1
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
        : ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    bool hasBackendMonths = false;
    List<dynamic>? monthsList;
    if (halfYearOverview is List && halfYearOverview.isNotEmpty) {
      monthsList = halfYearOverview;
    } else if (halfYearOverview is Map) {
      final mList = halfYearOverview['months'];
      if (mList is List && mList.isNotEmpty) {
        monthsList = mList;
      }
    }

    if (monthsList != null && monthsList.isNotEmpty) {
      final Map<String, ({double revenue, double expense})> monthMap = {};
      for (final m in monthsList) {
        if (m is Map) {
          final rawMonth = (m['month'] ?? '').toString().trim();
          final rev = _safeDouble(m['revenue']);
          final exp = _safeDouble(m['expense']);
          if (rawMonth.isNotEmpty) {
            monthMap[rawMonth.toLowerCase()] = (revenue: rev, expense: exp);
          }
        }
      }

      for (final mName in monthsInHalf) {
        final match = monthMap[mName.toLowerCase()];
        if (match != null) {
          overviewData.add((month: mName, revenue: match.revenue, expense: match.expense));
          hasBackendMonths = true;
        } else {
          overviewData.add((month: mName, revenue: 0.0, expense: 0.0));
        }
      }

      // If month names in backend didn't match standard abbreviations, add backend items as-is
      if (!hasBackendMonths) {
        overviewData.clear();
        for (final m in monthsList) {
          if (m is Map) {
            overviewData.add((
              month: (m['month'] ?? '').toString(),
              revenue: _safeDouble(m['revenue']),
              expense: _safeDouble(m['expense']),
            ));
          }
        }
        if (overviewData.isNotEmpty) {
          hasBackendMonths = true;
        }
      }
    }

    if (!hasBackendMonths) {
      for (int i = 0; i < monthsInHalf.length; i++) {
        final mName = monthsInHalf[i];
        final monthNum = (_overviewHalf == 1 ? 1 : 7) + i;
        double rev = 0.0;
        double exp = 0.0;
        if (_selectedMonth == monthNum && _selectedYear == _overviewYear) {
          rev = monthlyRevenue;
          exp = totalExpense;
        } else {
          final history = _reportsData['monthly_history'] ??
              _reportsData['financial_history'];
          if (history is List) {
            for (final h in history) {
              if (h is Map && (h['month'] == mName || h['month_number'] == monthNum)) {
                rev = _safeDouble(h['revenue']);
                exp = _safeDouble(h['expense']);
              }
            }
          }
        }
        overviewData.add((month: mName, revenue: rev, expense: exp));
      }
    }

    return RefreshIndicator(
      onRefresh: _fetchReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Pill
            _buildMonthSelectorPill(),
            const SizedBox(height: 16),

            // Net Profit Hero Card
            _buildNetProfitHeroCard(
              netProfit: netProfit,
              comparisonText: profitComparisonText,
              isPositive: isProfitPositive,
              sparkline: sparklineValues,
            ),
            const SizedBox(height: 12),

            // Side-by-side Monthly Revenue & Monthly Expense Cards
            _buildSummaryCardsRow(
              monthlyRevenue: monthlyRevenue,
              revGrowthText: revGrowthText,
              isRevPositive: isRevPositive,
              totalExpense: totalExpense,
              expGrowthText: expGrowthText,
              isExpPositive: isExpPositive,
              planRevenueBreakdown: planRevenueBreakdown,
              paymentModes: paymentModes,
              budget: budget,
            ),
            const SizedBox(height: 24),

            // Recent Activity Section
            _buildRecentActivitySection(parsedRecentActivity),
            const SizedBox(height: 24),

            // Revenue & Expense Overview Section
            _buildRevenueExpenseOverviewSection(overviewData),
            const SizedBox(height: 24),

            _buildSectionTitle('Monthly Budget Progress'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Used: $budgetUsedPercentage',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showSetCategoryBudgetsDialog(budget),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Budget: ',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₹${budget.toStringAsFixed(0)}',
                                    style: AppStyles.text14Px.poppins.w600.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: budgetPctVal,
                      backgroundColor: const Color(0xffF0F0F0),
                      color:
                          budgetPctVal >= 0.9
                              ? const Color(0xffE74C3C)
                              : budgetPctVal >= 0.7
                              ? const Color(0xffF39C12)
                              : const Color(0xff2ECC71),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBudgetStat(
                        'Used Amount',
                        '₹${budgetUsedAmount.toStringAsFixed(0)}',
                      ),
                      _buildBudgetStat(
                        'Remaining',
                        '₹${budgetRemaining.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  _buildCategoryBreakdownSection(categoryBreakdown),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Monthly Revenue Target Progress'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Achieved: $achievementPercentageStr',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showSetCategoryRevenueTargetsDialog(targetRevenue),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Target: ',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₹${targetRevenue.toStringAsFixed(0)}',
                                    style: AppStyles.text14Px.poppins.w600.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: Color(0xff27AE60),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: targetPctVal > 1.0 ? 1.0 : targetPctVal,
                      backgroundColor: const Color(0xffF0F0F0),
                      color: targetPctVal >= 1.0
                          ? const Color(0xff2ECC71)
                          : targetPctVal >= 0.7
                          ? const Color(0xff27AE60)
                          : const Color(0xffF39C12),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBudgetStat(
                        'Actual Revenue',
                        '₹${actualRevenue.toStringAsFixed(0)}',
                      ),
                      _buildBudgetStat(
                        'Remaining Target',
                        '₹${remainingTarget.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  _buildRevenueTargetCategoryBreakdownSection(revenueCategoryTargets),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppStyles.text16Px.poppins.w600.dark),
    );
  }

  List<({String month, double value})> _get3MonthProfitData(
    double currentNetProfit,
  ) {
    final now = _startDate ?? DateTime.now();
    final List<({String month, double value})> result = [];

    final financial = _reportsData['financial_metrics'] as Map?;
    final history =
        _reportsData['monthly_history'] ??
        _reportsData['profit_history'] ??
        _reportsData['financial_history'] ??
        financial?['monthly_history'] ??
        financial?['history'] ??
        financial?['monthly_trend'];

    if (history is List && history.isNotEmpty) {
      final items = history.take(3).toList();
      for (final item in items) {
        if (item is Map) {
          final mName =
              (item['month'] ?? item['name'] ?? item['month_name'] ?? '').toString();
          final val =
              double.tryParse(
                (item['net_profit'] ??
                        item['profit'] ??
                        item['amount'] ??
                        item['value'] ??
                        0.0)
                    .toString(),
              ) ??
              0.0;
          result.add((
            month: mName.length > 3 ? mName.substring(0, 3) : mName,
            value: val,
          ));
        }
      }
    }

    if (result.length == 3) return result;

    final m3Date = now;
    final m2Date = DateTime(now.year, now.month - 1, 1);
    final m1Date = DateTime(now.year, now.month - 2, 1);

    final m1Name = DateFormat('MMM').format(m1Date);
    final m2Name = DateFormat('MMM').format(m2Date);
    final m3Name = DateFormat('MMM').format(m3Date);

    double m1Val = currentNetProfit != 0 ? currentNetProfit * 0.4 : 1000.0;
    double m2Val = currentNetProfit != 0 ? currentNetProfit * 0.85 : 2500.0;

    return [
      (month: m1Name, value: m1Val),
      (month: m2Name, value: m2Val),
      (month: m3Name, value: currentNetProfit),
    ];
  }

  Widget _buildNetProfitCard({
    required double netProfit,
  }) {
    final color = netProfit >= 0 ? const Color(0xff2ECC71) : const Color(0xffE74C3C);
    final icon = netProfit >= 0 ? Icons.trending_up : Icons.trending_down;
    final trendData = _get3MonthProfitData(netProfit);
    final values = trendData.map((e) => e.value).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Value & Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${netProfit.toStringAsFixed(2)}',
                        style: AppStyles.text20Px.poppins.w600.copyWith(color: color),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Net Profit / Loss',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right: 3-Month Mini Sparkline Graph Card
          Container(
            width: 145,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xffF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffEEEEEE)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    netProfit >= 0 ? Icons.show_chart : Icons.multiline_chart,
                    size: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                // Sparkline
                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _NetProfitSparklinePainter(
                      values: values,
                      lineColor: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Month Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: trendData.map((item) {
                    return Text(
                      item.month,
                      style: AppStyles.text10Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    try {
      final formatter = NumberFormat('#,##,###');
      return formatter.format(amount.round());
    } catch (_) {
      return amount.toStringAsFixed(0);
    }
  }

  void _showMonthYearPicker() {
    AppMonthPickerBottomSheet.show(
      context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      onSelected: (date) {
        setState(() {
          _selectedYear = date.year;
          _selectedMonth = date.month;
          _startDate = null;
          _endDate = null;
        });
        _fetchReports();
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
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthStr,
                style: AppStyles.text14Px.poppins.w600.dark,
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.unfold_more_rounded,
                size: 18,
                color: AppColors.textDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetProfitHeroCard({
    required double netProfit,
    required String comparisonText,
    required bool isPositive,
    required List<double> sparkline,
  }) {
    const purpleColor = Color(0xff7C3AED);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Profit / Loss',
                style: AppStyles.text13Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 12,
                      color: purpleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comparisonText,
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: purpleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${_formatAmount(netProfit)}',
            style: AppStyles.text24Px.poppins.w700.dark,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: _NetProfitHeroSparklinePainter(
                values: sparkline,
                lineColor: purpleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardsRow({
    required double monthlyRevenue,
    required String revGrowthText,
    required bool isRevPositive,
    required double totalExpense,
    required String expGrowthText,
    required bool isExpPositive,
    required List<dynamic> planRevenueBreakdown,
    required List<dynamic> paymentModes,
    required double budget,
  }) {
    return Row(
      children: [
        // Revenue Card
        Expanded(
          child: InkWell(
            onTap: () async {
              final didChange = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyRevenueDetailScreen(
                    orgId: widget.orgId,
                    startDate: _startDate,
                    endDate: _endDate,
                    month: _selectedMonth,
                    year: _selectedYear,
                    initialRevenues: _revenues,
                    initialPlanRevenueBreakdown: planRevenueBreakdown,
                    initialPaymentModes: paymentModes,
                    initialRevenueCategories: _revenueCategories,
                  ),
                ),
              );
              if (didChange == true) {
                _fetchReports(silent: true);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xffE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Color(0xff2E7D32),
                          size: 18,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xffBDBDBD),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Monthly Revenue',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '₹${_formatAmount(monthlyRevenue)}',
                      style: AppStyles.text18Px.poppins.w700.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 12,
                          color: Color(0xff2E7D32),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          revGrowthText,
                          style: AppStyles.text10Px.poppins.w600.copyWith(
                            color: const Color(0xff2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Expense Card
        Expanded(
          child: InkWell(
            onTap: () async {
              final didChange = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyExpenseDetailScreen(
                    orgId: widget.orgId,
                    startDate: _startDate,
                    endDate: _endDate,
                    month: _selectedMonth,
                    year: _selectedYear,
                    initialExpenses: _expenses,
                    currentBudget: budget,
                  ),
                ),
              );
              if (didChange == true) {
                _fetchReports(silent: true);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xffFFEBEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Color(0xffC62828),
                          size: 18,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xffBDBDBD),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Monthly Expense',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '₹${_formatAmount(totalExpense)}',
                      style: AppStyles.text18Px.poppins.w700.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFEBEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_down_rounded,
                          size: 12,
                          color: Color(0xffC62828),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          expGrowthText,
                          style: AppStyles.text10Px.poppins.w600.copyWith(
                            color: const Color(0xffC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(List<Map<String, dynamic>> activities) {
    final displayedItems = _isRecentActivityExpanded
        ? activities
        : activities.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            if (activities.length > 4)
              InkWell(
                onTap: () {
                  setState(() {
                    _isRecentActivityExpanded = !_isRecentActivityExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isRecentActivityExpanded ? 'Collapse' : 'Expand',
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        _isRecentActivityExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: AppColors.textGrey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No recent activities for this period',
                  style: AppStyles.text13Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(displayedItems.length, (index) {
                final item = displayedItems[index];
                final isRev = (item['type'] ?? 'revenue') == 'revenue';
                final amount = _safeDouble(item['amount']);
                final isLast = index == displayedItems.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isRev
                                  ? const Color(0xffE8F5E9)
                                  : const Color(0xffFFEBEE),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRev
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: isRev
                                  ? const Color(0xff2E7D32)
                                  : const Color(0xffC62828),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['title'] ?? '').toString(),
                                  style: AppStyles.text14Px.poppins.w600.dark,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (item['subtitle'] ?? '').toString(),
                                  style: AppStyles.text12Px.poppins.w400.copyWith(
                                    color: AppColors.textGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isRev ? '+' : '-'}₹${_formatAmount(amount)}',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: isRev
                                  ? const Color(0xff2E7D32)
                                  : const Color(0xffC62828),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        color: Color(0xffF0F0F0),
                      ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildRevenueExpenseOverviewSection(
    List<({String month, double revenue, double expense})> overviewData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue & Expense Overview',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: "2026 1/2 >" on left, "<  >  +" on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Red title: "2026 1/2 >"
                  InkWell(
                    onTap: () {
                      setState(() {
                        _overviewHalf = _overviewHalf == 1 ? 2 : 1;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_overviewYear ${_overviewHalf}/2',
                            style: const TextStyle(
                              color: Color(0xffD32F2F),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xffD32F2F),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions: <  >  +
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Left arrow button
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_overviewHalf == 2) {
                              _overviewHalf = 1;
                            } else {
                              _overviewHalf = 2;
                              _overviewYear -= 1;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.isDarkMode ? context.colors.fieldFill : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.isDarkMode ? context.colors.border : const Color(0xffE5E7EB),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 20,
                            color: context.isDarkMode ? context.colors.textPrimary : const Color(0xff374151),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right arrow button
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_overviewHalf == 1) {
                              _overviewHalf = 2;
                            } else {
                              _overviewHalf = 1;
                              _overviewYear += 1;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.isDarkMode ? context.colors.fieldFill : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.isDarkMode ? context.colors.border : const Color(0xffE5E7EB),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: context.isDarkMode ? context.colors.textPrimary : const Color(0xff374151),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Red Plus button
                      InkWell(
                        onTap: _showQuickAddOverviewModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xffD32F2F),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffD32F2F).withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grouped Bar Chart with Y-axis and grid lines
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomPaint(
                  painter: _GroupedBarChartPainter(
                    data: overviewData,
                    isDark: context.isDarkMode,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Legend: Centered Revenue (Green) and Expense (Red)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xff00E676),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Revenue',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.isDarkMode ? context.colors.textSecondary : const Color(0xff374151),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xffD32F2F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Expense',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: context.isDarkMode ? context.colors.textSecondary : const Color(0xff374151),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showQuickAddOverviewModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick Action',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xffE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xff2E7D32),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Add Revenue',
                    style: AppStyles.text14Px.poppins.w600.dark,
                  ),
                  subtitle: Text(
                    'Record a new payment or income',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyRevenueDetailScreen(
                          orgId: widget.orgId,
                          startDate: _startDate,
                          endDate: _endDate,
                          month: _selectedMonth,
                          year: _selectedYear,
                          initialRevenues: _revenues,
                          initialPlanRevenueBreakdown: const [],
                          initialPaymentModes: const [],
                          initialRevenueCategories: _revenueCategories,
                        ),
                      ),
                    ).then((val) {
                      if (val == true) _fetchReports(silent: true);
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xffFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xffC62828),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Add Expense',
                    style: AppStyles.text14Px.poppins.w600.dark,
                  ),
                  subtitle: Text(
                    'Record a new gym expense or bill',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyExpenseDetailScreen(
                          orgId: widget.orgId,
                          startDate: _startDate,
                          endDate: _endDate,
                          month: _selectedMonth,
                          year: _selectedYear,
                          initialExpenses: _expenses,
                          currentBudget: 0.0,
                        ),
                      ),
                    ).then((val) {
                      if (val == true) _fetchReports(silent: true);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExpenseCategoryPieChartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Wise Expenses',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_expenses.isNotEmpty)
                _ExpenseCategoryPieChart(expenses: _expenses)
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        size: 48,
                        color: AppColors.textGrey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No expense data available for pie chart breakdown.',
                        textAlign: TextAlign.center,
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRevenueCategoryPieChartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Wise Revenue',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_revenues.isNotEmpty)
                _RevenueCategoryPieChart(revenues: _revenues)
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        size: 48,
                        color: AppColors.textGrey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No revenue data available for pie chart breakdown.',
                        textAlign: TextAlign.center,
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: context.isDarkMode
                        ? context.colors.textSecondary
                        : const Color(0xFF9CA3AF),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppStyles.text22Px.poppins.w700.copyWith(
                    color: color,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppStyles.text13Px.poppins.w500.copyWith(
                    color: context.isDarkMode
                        ? context.colors.textSecondary
                        : AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRevenueBreakdown(List<dynamic> plans) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: _PlanRevenuePieChart(plans: plans),
    );
  }

  Widget _buildDemographics(
    Map<dynamic, dynamic> genderDist,
    Map<dynamic, dynamic> ageDist,
    int orgId,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    Widget buildGenderSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender Distribution',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          _GenderPieChart(
            genderDist: genderDist,
            orgId: orgId,
            startDate: startDate,
            endDate: endDate,
          ),
        ],
      );
    }

    Widget buildAgeSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Age Distribution', style: AppStyles.text14Px.poppins.w600.dark),
          const SizedBox(height: 12),
          ...ageDist.entries.map((e) {
            final key = e.key.toString();
            final data = e.value as Map<dynamic, dynamic>?;
            if (data == null) return const SizedBox.shrink();
            final String pctStr = data['percentage']?.toString() ?? '0%';
            final count = data['count'] as int? ?? 0;

            double parsedPct = 0.0;
            try {
              parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
            } catch (_) {}

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsCustomerListScreen(
                      orgId: orgId,
                      filterType: 'age_group',
                      filterValue: key,
                      filterLabel: 'Age Group: $key',
                      startDate: startDate,
                      endDate: endDate,
                      count: count,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        key,
                        style: AppStyles.text12Px.poppins.w500.dark,
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: parsedPct,
                        backgroundColor: context.isDarkMode
                            ? context.colors.fieldFill
                            : const Color(0xffF0F0F0),
                        color: const Color(0xffF39C12),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 50,
                      child: Text(
                        pctStr,
                        style: AppStyles.text12Px.poppins.w500.dark,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: buildGenderSection()),
                const SizedBox(width: 24),
                Container(
                  width: 1,
                  height: 200,
                  color: context.isDarkMode
                      ? context.colors.border
                      : const Color(0xffEEEEEE),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: buildAgeSection()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildGenderSection(),
                const Divider(height: 32, color: Color(0xffEEEEEE)),
                buildAgeSection(),
              ],
            ),
    );
  }

  Widget _buildGoalDistribution(dynamic goalDist) {
    final List<Map<String, dynamic>> normalizedGoals = [];

    if (goalDist is List) {
      for (final item in goalDist) {
        if (item is Map) {
          final goalName = item['goal']?.toString() ?? item['goal_name']?.toString() ?? 'Other';
          final pctStr = item['percentage']?.toString() ?? '0%';
          final countVal = int.tryParse(item['count']?.toString() ?? '') ?? 0;
          normalizedGoals.add({
            'goal': goalName,
            'percentage': pctStr,
            'count': countVal,
          });
        }
      }
    } else if (goalDist is Map) {
      goalDist.forEach((key, value) {
        String pctStr = '0%';
        int countVal = 0;
        if (value is Map) {
          pctStr = value['percentage']?.toString() ?? '0%';
          countVal = int.tryParse(value['count']?.toString() ?? '') ?? 0;
        } else if (value is String) {
          pctStr = value;
        } else if (value is num) {
          pctStr = '${value.toStringAsFixed(0)}%';
        }
        normalizedGoals.add({
          'goal': key.toString(),
          'percentage': pctStr,
          'count': countVal,
        });
      });
    }

    if (normalizedGoals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Center(
          child: Text(
            'No goal distribution data available',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
          ...normalizedGoals.map((e) {
            final key = _safeString(e['goal'], 'Unknown');
            final pctStr = _safeString(e['percentage'], '0%');
            final count = _safeInt(e['count']);

            double parsedPct = 0.0;
            try {
              parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
            } catch (_) {}

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsCustomerListScreen(
                      orgId: widget.orgId,
                      filterType: 'goal',
                      filterValue: key,
                      filterLabel: 'Goal: $key',
                      startDate: _startDate,
                      endDate: _endDate,
                      count: count,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        key,
                        style: AppStyles.text12Px.poppins.w500.dark,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: parsedPct,
                          backgroundColor: const Color(0xffF0F0F0),
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '$count',
                        style: AppStyles.text12Px.poppins.w500.dark,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDistributionListCard({
    required dynamic items,
    required String titleKey,
    required String filterType,
    required Color barColor,
    required IconData icon,
  }) {
    final List<Map<String, dynamic>> list = [];
    if (items is List) {
      for (final item in items) {
        if (item is Map) {
          final title = (item[titleKey] ?? item['label'] ?? item['profession'] ?? item['range'] ?? 'Other').toString();
          final label = (item['label'] ?? title).toString();
          final pctStr = (item['percentage'] ?? '0%').toString();
          final countVal = int.tryParse((item['count'] ?? 0).toString()) ?? 0;
          list.add({
            'title': title,
            'label': label,
            'percentage': pctStr,
            'count': countVal,
          });
        }
      }
    }

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Center(
          child: Text(
            'No distribution data available',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        final visibleItems = (list.length > 5 && !isExpanded)
            ? list.take(5).toList()
            : list;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...visibleItems.map((item) {
                  final String title = _safeString(item['title']);
                  final String label = _safeString(item['label']);
                  final String pctStr = _safeString(item['percentage'], '0%');
                  final int count = _safeInt(item['count']);

                  double parsedPct = 0.0;
                  try {
                    parsedPct = double.parse(pctStr.replaceAll('%', '')) / 100.0;
                  } catch (_) {}

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportsCustomerListScreen(
                            orgId: widget.orgId,
                            filterType: filterType,
                            filterValue: title,
                            filterLabel: '$label ($count)',
                            startDate: _startDate,
                            endDate: _endDate,
                            count: count,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: barColor),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: Text(
                              label,
                              style: AppStyles.text12Px.poppins.w500.dark,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: parsedPct,
                                backgroundColor: const Color(0xffF0F0F0),
                                color: barColor,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$count ($pctStr)',
                              style: AppStyles.text10Px.poppins.w600.dark,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (list.length > 5) ...[
                  const SizedBox(height: 4),
                  const Divider(height: 1, color: Color(0xffF0F0F0)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      setInnerState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded
                                ? 'Show Less'
                                : filterType == 'profession'
                                    ? 'More Professions (${list.length - 5})'
                                    : 'Show More (${list.length - 5})',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: barColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: barColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeakHours(Map<dynamic, dynamic> peakHours) {
    final sortedEntries =
        peakHours.entries.toList()..sort(
          (a, b) => _safeInt(b.value).compareTo(_safeInt(a.value)),
        );

    final topEntries = sortedEntries.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children:
            topEntries.map((e) {
              final time = e.key.toString();
              final count = e.value.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xff527F50),
                        ),
                        const SizedBox(width: 8),
                        Text(time, style: AppStyles.text14Px.poppins.w500.dark),
                      ],
                    ),
                    Text(
                      '$count Sessions',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTrainerPerformance(List<dynamic> trainers) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trainers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (trainers[index] is! Map) return const SizedBox.shrink();
        final trainer = trainers[index] as Map<dynamic, dynamic>;
        final name = trainer['name']?.toString() ?? 'Unknown Trainer';
        final exp = trainer['experience_years'] ?? 0;
        final clients = trainer['clients_trained_count'] ?? 0;
        final given = trainer['workout_plans_given_count'] ?? 0;
        final completed = trainer['workouts_completed_count'] ?? 0;
        final attendance = trainer['attendance_rate']?.toString() ?? '0%';
        final completion = trainer['completion_rate']?.toString() ?? '0%';
        final progress = trainer['active_progress']?.toString() ?? 'N/A';
        final waLink = trainer['whatsapp_link']?.toString() ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppStyles.text16Px.poppins.w500.dark),
                        const SizedBox(height: 4),
                        Text(
                          '$exp Years Experience • Progress: $progress',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (waLink.isNotEmpty)
                    InkWell(
                      onTap: () => launchUrl(Uri.parse(waLink)),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff25D366).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xff25D366),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTrainerStatBlock(
                      'Clients',
                      clients.toString(),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: const Color(0xffEEEEEE),
                  ),
                  Expanded(
                    child: _buildTrainerStatBlock('Given', given.toString()),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: const Color(0xffEEEEEE),
                  ),
                  Expanded(
                    child: _buildTrainerStatBlock(
                      'Completed',
                      completed.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF9F9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance: $attendance',
                      style: AppStyles.text12Px.poppins.w500.dark,
                    ),
                    Text(
                      'Completion: $completion',
                      style: AppStyles.text12Px.poppins.w500.dark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainerStatBlock(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppStyles.text16Px.poppins.w600.dark),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _GenderPieChart extends StatelessWidget {
  const _GenderPieChart({
    required this.genderDist,
    required this.orgId,
    this.startDate,
    this.endDate,
    this.isTrainer = false,
  });

  final Map<dynamic, dynamic> genderDist;
  final int orgId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isTrainer;

  @override
  Widget build(BuildContext context) {
    final allCategories =
        <String, ({String key, String label, double percentage, int count, Color color})>{
          'male': (
            key: 'male',
            label: 'Male',
            percentage: 0,
            count: 0,
            color: const Color(0xff486CC2),
          ),
          'female': (
            key: 'female',
            label: 'Female',
            percentage: 0,
            count: 0,
            color: const Color(0xffC2486C),
          ),
          'other': (
            key: 'other',
            label: 'Other',
            percentage: 0,
            count: 0,
            color: const Color(0xffF39C12),
          ),
          'unspecified': (
            key: 'unspecified',
            label: 'Unspecified',
            percentage: 0,
            count: 0,
            color: const Color(0xff95A5A6),
          ),
        };

    genderDist.forEach((key, val) {
      if (val is Map) {
        final labelName = key.toString().toLowerCase();
        final formattedLabel =
            labelName.isNotEmpty
                ? labelName[0].toUpperCase() + labelName.substring(1)
                : 'Other';
        final pctStr = val['percentage']?.toString() ?? '0%';
        final count = val['count'] as int? ?? 0;
        var pct = 0.0;
        try {
          pct = double.parse(pctStr.replaceAll('%', ''));
        } catch (_) {}

        var color = const Color(0xff95A5A6);
        if (labelName == 'male') {
          color = const Color(0xff486CC2);
        } else if (labelName == 'female') {
          color = const Color(0xffC2486C);
        } else if (labelName == 'other') {
          color = const Color(0xffF39C12);
        }

        allCategories[labelName] = (
          key: labelName,
          label: formattedLabel,
          percentage: pct,
          count: count,
          color: color,
        );
      }
    });

    final slices = allCategories.values.toList();

    return Row(
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: CustomPaint(painter: _PieChartPainter(slices: slices.map((s) => (label: s.label, percentage: s.percentage, count: s.count, color: s.color)).toList())),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                slices.map((slice) {
                  return InkWell(
                    onTap: isTrainer ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportsCustomerListScreen(
                            orgId: orgId,
                            filterType: 'gender',
                            filterValue: slice.key,
                            filterLabel: 'Gender: ${slice.label}',
                            startDate: startDate,
                            endDate: endDate,
                            count: slice.count,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                              style: AppStyles.text13Px.poppins.w500.dark,
                            ),
                          ),
                          Text(
                            '${slice.percentage.toStringAsFixed(0)}%',
                            style: AppStyles.text13Px.poppins.w600.dark,
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
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.slices});

  final List<({String label, double percentage, int count, Color color})>
  slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, item) => sum + item.percentage);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    if (total <= 0) {
      final bgPaint =
          Paint()
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
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = slice.color
            ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _PlanRevenuePieChart extends StatelessWidget {
  final List<dynamic> plans;
  const _PlanRevenuePieChart({required this.plans});

  static const List<Color> _colors = [
    Color(0xff486CC2),
    Color(0xffC2486C),
    Color(0xffF39C12),
    Color(0xff527F50),
    Color(0xff9C51BF),
    Color(0xffE74C3C),
    Color(0xff1ABC9C),
    Color(0xff34495E),
  ];

  @override
  Widget build(BuildContext context) {
    final List<({String label, double percentage, String subtext, Color color})> slices = [];

    for (int i = 0; i < plans.length; i++) {
      if (plans[i] is! Map) continue;
      final plan = plans[i] as Map<dynamic, dynamic>;
      final name = plan['plan_name']?.toString() ?? 'Unknown Plan';
      final type = plan['package_type']?.toString() ?? '';
      final subscribers = plan['subscribers_count'] ?? 0;
      final revenueVal = plan['revenue'] ?? 0.0;
      final revenue = revenueVal is num
          ? revenueVal.toDouble()
          : double.tryParse(revenueVal.toString()) ?? 0.0;
      final pctStr = plan['percentage']?.toString() ?? '0%';

      double pct = 0.0;
      try {
        pct = double.parse(pctStr.replaceAll('%', ''));
      } catch (_) {}

      slices.add((
        label: name,
        percentage: pct,
        subtext: '$type • $subscribers subscribers • ₹${revenue.toStringAsFixed(0)}',
        color: _colors[i % _colors.length],
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: _RevenuePieChartPainter(
                slices: slices.map((s) => (percentage: s.percentage, color: s.color)).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: slices.map((slice) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 10,
                        height: 10,
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
                            const SizedBox(height: 2),
                            Text(
                              slice.subtext,
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: AppColors.textGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slice.percentage.toStringAsFixed(1)}%',
                        style: AppStyles.text13Px.poppins.w600.dark,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenuePieChartPainter extends CustomPainter {
  final List<({double percentage, Color color})> slices;
  _RevenuePieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, item) => sum + item.percentage);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 22.0;
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
  bool shouldRepaint(covariant _RevenuePieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _ExpenseCategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  const _ExpenseCategoryPieChart({required this.expenses});

  static const Map<String, Color> _categoryColors = {
    'Equipment': Color(0xff486CC2),
    'Maintenance': Color(0xffF39C12),
    'Utilities': Color(0xff1ABC9C),
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
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    final Map<String, double> categoryTotals = {};
    double totalExpense = 0.0;

    for (final exp in expenses) {
      final category = exp['category']?.toString().trim() ?? 'Other';
      final rawAmount = exp['amount'];
      double amount = 0.0;
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

    if (totalExpense <= 0) return const SizedBox.shrink();

    final List<({String label, double percentage, int count, Color color, double amount})> slices = [];
    int fallbackIndex = 0;

    categoryTotals.forEach((category, amount) {
      final percentage = (amount / totalExpense) * 100;
      final color = _categoryColors[category] ??
          _fallbackColors[fallbackIndex % _fallbackColors.length];
      fallbackIndex++;

      slices.add((
        label: category,
        percentage: percentage,
        count: 0,
        color: color,
        amount: amount,
      ));
    });

    slices.sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode ? context.colors.border : const Color(0xffEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Breakdown by Category',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    slices: slices
                        .map((s) => (
                              label: s.label,
                              percentage: s.percentage,
                              count: s.count,
                              color: s.color,
                            ))
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
          ),
        ],
      ),
    );
  }
}

class _RevenueCategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> revenues;
  const _RevenueCategoryPieChart({required this.revenues});

  static const Map<String, Color> _categoryColors = {
    'Membership Fee': Color(0xff27AE60),
    'Admission Fee': Color(0xff2980B9),
    'Product Sales': Color(0xff8E44AD),
    'Others': Color(0xffF39C12),
  };

  static const List<Color> _fallbackColors = [
    Color(0xff1ABC9C),
    Color(0xffE67E22),
    Color(0xff34495E),
    Color(0xffC0392B),
    Color(0xff16A085),
  ];

  @override
  Widget build(BuildContext context) {
    if (revenues.isEmpty) return const SizedBox.shrink();

    final Map<String, double> categoryTotals = {};
    double totalRevenue = 0.0;

    for (final rev in revenues) {
      final category = rev['category']?.toString().trim() ??
          rev['category_name']?.toString().trim() ??
          'Others';
      final rawAmount = rev['amount'];
      double amount = 0.0;
      if (rawAmount is num) {
        amount = rawAmount.toDouble();
      } else if (rawAmount != null) {
        amount = double.tryParse(rawAmount.toString()) ?? 0.0;
      }

      if (amount > 0) {
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
        totalRevenue += amount;
      }
    }

    if (totalRevenue <= 0) return const SizedBox.shrink();

    final List<({String label, double percentage, int count, Color color, double amount})> slices = [];
    int fallbackIndex = 0;

    categoryTotals.forEach((category, amount) {
      final percentage = (amount / totalRevenue) * 100;
      final color = _categoryColors[category] ??
          _fallbackColors[fallbackIndex % _fallbackColors.length];
      fallbackIndex++;

      slices.add((
        label: category,
        percentage: percentage,
        count: 0,
        color: color,
        amount: amount,
      ));
    });

    slices.sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode ? context.colors.border : const Color(0xffEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Breakdown by Category',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    slices: slices
                        .map((s) => (
                              label: s.label,
                              percentage: s.percentage,
                              count: s.count,
                              color: s.color,
                            ))
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
          ),
        ],
      ),
    );
  }
}

class _NetProfitSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _NetProfitSparklinePainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = <Offset>[];
    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalized = (values[i] - minVal) / range;
      final y = size.height - 6 - (normalized * (size.height - 12));
      points.add(Offset(x, y));
    }

    // Fill path under graph
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlX = (p0.dx + p1.dx) / 2;
      fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Smooth curve stroke
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlX = (p0.dx + p1.dx) / 2;
      strokePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(strokePath, strokePaint);

    // Draw dots at data points
    final dotPaint = Paint()..color = lineColor;
    final whitePaint = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 3.5, dotPaint);
      canvas.drawCircle(points[i], 1.8, whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetProfitSparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

class _NetProfitHeroSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _NetProfitHeroSparklinePainter({
    required this.values,
    this.lineColor = const Color(0xff7C3AED),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = <Offset>[];
    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalized = (values[i] - minVal) / range;
      final y = size.height - 8 - (normalized * (size.height - 16));
      points.add(Offset(x, y));
    }

    // Fill path under graph
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlX = (p0.dx + p1.dx) / 2;
      fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Smooth curve stroke
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlX = (p0.dx + p1.dx) / 2;
      strokePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(strokePath, strokePaint);

    // Draw last glowing dot
    final lastPoint = points.last;
    canvas.drawCircle(
      lastPoint,
      6.0,
      Paint()..color = lineColor.withValues(alpha: 0.25),
    );
    canvas.drawCircle(lastPoint, 3.5, Paint()..color = lineColor);
    canvas.drawCircle(lastPoint, 1.8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _NetProfitHeroSparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

class _GroupedBarChartPainter extends CustomPainter {
  final List<({String month, double revenue, double expense})> data;
  final bool isDark;

  _GroupedBarChartPainter({
    required this.data,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    double maxVal = 0.0;
    for (final d in data) {
      if (d.revenue > maxVal) maxVal = d.revenue;
      if (d.expense > maxVal) maxVal = d.expense;
    }

    double yMax = 30000.0;
    double step = 10000.0;
    if (maxVal <= 0) {
      yMax = 30000.0;
      step = 10000.0;
    } else if (maxVal <= 30000.0) {
      yMax = 30000.0;
      step = 10000.0;
    } else {
      double roughStep = maxVal / 3;
      double magnitude = math.pow(10, (math.log(roughStep) / math.ln10).floor()).toDouble();
      double normalized = roughStep / magnitude;
      if (normalized <= 1) {
        step = 1 * magnitude;
      } else if (normalized <= 2) {
        step = 2 * magnitude;
      } else if (normalized <= 5) {
        step = 5 * magnitude;
      } else {
        step = 10 * magnitude;
      }
      yMax = step * 3;
      if (yMax < maxVal) yMax = step * 4;
    }

    final int tickCount = (yMax / step).round();
    final List<double> ticks = List.generate(tickCount + 1, (i) => (tickCount - i) * step);

    const double yAxisWidth = 46.0;
    const double topPadding = 8.0;
    const double bottomPadding = 26.0;
    final double chartHeight = size.height - bottomPadding - topPadding;
    final double chartWidth = size.width - yAxisWidth;

    // Draw horizontal grid lines and Y-axis labels
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xff2A2A2A) : const Color(0xffEEEEEE)
      ..strokeWidth = 1.0;

    for (int i = 0; i < ticks.length; i++) {
      final tick = ticks[i];
      final y = topPadding + (i / (ticks.length - 1)) * chartHeight;

      // Y-axis label text (e.g. ₹30k, ₹20k, ₹10k, ₹0)
      final textSpan = TextSpan(
        text: _formatYLabel(tick),
        style: const TextStyle(
          color: Color(0xff9E9E9E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(0, y - (textPainter.height / 2)),
      );

      // Horizontal grid line across from Y-axis label to right edge
      canvas.drawLine(
        Offset(yAxisWidth, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw bars for each month
    final groupCount = data.length;
    final groupWidth = chartWidth / groupCount;
    const barWidth = 12.0;
    const barSpacing = 3.0;
    final baselineY = topPadding + chartHeight;

    for (int i = 0; i < groupCount; i++) {
      final item = data[i];
      final centerX = yAxisWidth + (i * groupWidth) + (groupWidth / 2);

      // Revenue bar (Green gradient with rounded top)
      if (item.revenue > 0) {
        final revHeight = math.min((item.revenue / yMax) * chartHeight, chartHeight);
        final revRect = Rect.fromLTWH(
          centerX - barWidth - (barSpacing / 2),
          baselineY - revHeight,
          barWidth,
          revHeight,
        );
        final revRRect = RRect.fromRectAndCorners(
          revRect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        final revPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff2EEB7E), Color(0xff00C853)],
          ).createShader(revRect);
        canvas.drawRRect(revRRect, revPaint);
      }

      // Expense bar (Red gradient with rounded top)
      if (item.expense > 0) {
        final expHeight = math.min((item.expense / yMax) * chartHeight, chartHeight);
        final expRect = Rect.fromLTWH(
          centerX + (barSpacing / 2),
          baselineY - expHeight,
          barWidth,
          expHeight,
        );
        final expRRect = RRect.fromRectAndCorners(
          expRect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        final expPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFF5252), Color(0xffD32F2F)],
          ).createShader(expRect);
        canvas.drawRRect(expRRect, expPaint);
      }

      // Month label below baseline
      final monthSpan = TextSpan(
        text: item.month,
        style: const TextStyle(
          color: Color(0xff757575),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      );
      final monthPainter = TextPainter(
        text: monthSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      monthPainter.paint(
        canvas,
        Offset(centerX - (monthPainter.width / 2), baselineY + 8),
      );
    }
  }

  static String _formatYLabel(double val) {
    if (val == 0) return '₹0';
    if (val >= 10000000) {
      return '₹${(val / 10000000).toStringAsFixed(val % 10000000 == 0 ? 0 : 1)}Cr';
    }
    if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(val % 100000 == 0 ? 0 : 1)}L';
    }
    if (val >= 1000) {
      return '₹${(val / 1000).toStringAsFixed(val % 1000 == 0 ? 0 : 1)}k';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  bool shouldRepaint(covariant _GroupedBarChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

class _ReportsKeepAliveTab extends StatefulWidget {
  final Widget child;
  const _ReportsKeepAliveTab({required this.child});

  @override
  State<_ReportsKeepAliveTab> createState() => _ReportsKeepAliveTabState();
}

class _ReportsKeepAliveTabState extends State<_ReportsKeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
