import 'dart:math' as math;
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/reports_customer_list_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/client_workout_calendar_widget.dart';

class OrganizationReportsScreen extends StatefulWidget {
  final int orgId;
  const OrganizationReportsScreen({super.key, required this.orgId});

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
      });
      _fetchReports();
    }
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final year = _startDate?.year ?? now.year;
    final month = _startDate?.month ?? now.month;

    String queryParams = 'organization_id=${widget.orgId}&year=$year&month=$month';
    if (_startDate != null && _endDate != null) {
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate!);
      queryParams += '&start_date=$startStr&end_date=$endStr';
    }

    try {
      // 1. Fetch reports
      final reportsResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.reports}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (reportsResponse.statusCode == 200 && reportsResponse.data is Map) {
        if (mounted) {
          setState(() {
            _reportsData = Map<String, dynamic>.from(
              reportsResponse.data as Map,
            );
          });
        }
      }
    } catch (e) {
      // ignore/handle reports error quietly
    }

    try {
      // 2. Fetch budget category breakdown
      String budgetUri = '${ApiUris.budget}?year=$year&month=$month';
      final budgetResponse = await DioClient().dio.get<dynamic>(
        budgetUri,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (budgetResponse.statusCode == 200 && budgetResponse.data is Map) {
        if (mounted) {
          setState(() {
            _budgetData = Map<String, dynamic>.from(
              budgetResponse.data as Map,
            );
          });
        }
      }
    } catch (e) {
      // ignore/handle budget error quietly
    }

    try {
      // 3. Fetch expenses
      final expensesResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.expenses}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (expensesResponse.statusCode == 200) {
        final data = expensesResponse.data;
        List<dynamic> list = [];
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
    } catch (e) {
      // ignore/handle expenses error quietly
    }

    try {
      // 4. Fetch revenues
      final revenuesResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenues}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (revenuesResponse.statusCode == 200) {
        final data = revenuesResponse.data;
        List<dynamic> list = [];
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
    } catch (e) {
      // ignore/handle revenues error quietly
    }

    try {
      // 5. Fetch revenue categories
      final catResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenueCategories}?organization_id=${widget.orgId}',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (catResponse.statusCode == 200) {
        final data = catResponse.data;
        List<dynamic> list = [];
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
    } catch (e) {
      // ignore/handle revenue categories error quietly
    }

    try {
      // 6. Fetch revenue targets
      final revenueTargetResponse = await DioClient().dio.get<dynamic>(
        '${ApiUris.revenueTargets}?$queryParams',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (revenueTargetResponse.statusCode == 200 &&
          revenueTargetResponse.data is Map) {
        if (mounted) {
          setState(() {
            _revenueTargetData = Map<String, dynamic>.from(
              revenueTargetResponse.data as Map,
            );
          });
        }
      }
    } catch (e) {
      // ignore/handle revenue target error quietly
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExpense(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
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

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.expenseDetail(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        await Dialogs.showSnack(msg: 'Expense deleted successfully');
        await _fetchReports();
      } else {
        await Dialogs.showSnack(msg: 'Failed to delete expense');
      }
    } catch (e) {
      await Dialogs.showSnack(msg: 'Error deleting expense');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                                      color: Colors.white,
                                      surfaceTintColor: Colors.white,
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                                      color: Colors.white,
                                      surfaceTintColor: Colors.white,
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
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.revenueDetail(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        await Dialogs.showSnack(msg: 'Revenue record deleted successfully');
        await _fetchReports();
      } else {
        await Dialogs.showSnack(msg: 'Failed to delete revenue record');
      }
    } catch (e) {
      await Dialogs.showSnack(msg: 'Error deleting revenue record');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    paymentModes.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const PopButton().center,
          title: Text(
            'Gym Analytics & Reports',
            style: AppStyles.text18Px.poppins.w600.dark,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _startDate != null && _endDate != null
                    ? Icons.calendar_month
                    : Icons.calendar_today,
                color: AppColors.primary,
              ),
              tooltip: 'Filter by date range',
              onPressed: _selectDateRange,
            ),
            if (_startDate != null || _endDate != null)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                tooltip: 'Clear filter',
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  _fetchReports();
                },
              ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            labelStyle: AppStyles.text14Px.poppins.w600,
            unselectedLabelStyle: AppStyles.text14Px.poppins.w400,
            tabs: const [
              Tab(text: 'Finance'),
              Tab(text: 'Trainers'),
              Tab(text: 'Clients'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_startDate != null && _endDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xffEEEEEE)),
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
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                    _buildFinanceTab(
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
                      budget:
                          budget is double
                              ? budget
                              : double.tryParse(budget.toString()) ?? 0.0,
                      budgetUsedAmount:
                          budgetUsedAmount is double
                              ? budgetUsedAmount
                              : double.tryParse(budgetUsedAmount.toString()) ??
                                  0.0,
                      budgetUsedPercentage: budgetUsedPercentage,
                      budgetRemaining:
                          budgetRemaining is double
                              ? budgetRemaining
                              : double.tryParse(budgetRemaining.toString()) ??
                                  0.0,
                      planRevenueBreakdown: planRevenueBreakdown,
                      paymentModes: paymentModes,
                      categoryBreakdown: categoryBreakdown,
                    ),
                    _buildTrainersTab(
                      trainersPerformance: trainersPerformance,
                      trainerGenderDist: trainerGenderDist,
                      trainerAgeDist: trainerAgeDist,
                      totalTrainers: totalTrainers.toString(),
                    ),
                    _buildClientsTab(
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
                  ],
                ),
            ),
          ],
        ),
      ),
    );
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
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildReportCard(
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
                ),
                _buildReportCard(
                  title: 'Completed Sessions',
                  value: completedSessions,
                  icon: Icons.check_circle_outline,
                  color: const Color(0xff527F50),
                ),
                _buildReportCard(
                  title: 'Retention Rate',
                  value: retentionRate,
                  icon: Icons.trending_up_outlined,
                  color: const Color(0xffE67E22),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Client Demographics'),
            _buildDemographics(genderDistribution, ageDistribution, widget.orgId, _startDate, _endDate),
            const SizedBox(height: 24),
            if (professionDistribution is List && professionDistribution.isNotEmpty) ...[
              _buildSectionTitle('Profession Distribution'),
              _buildDistributionListCard(
                items: professionDistribution,
                titleKey: 'profession',
                filterType: 'profession',
                barColor: const Color(0xff3498DB),
                icon: Icons.work_outline_rounded,
              ),
              const SizedBox(height: 24),
            ],
            if (sleepHoursDistribution is List && sleepHoursDistribution.isNotEmpty) ...[
              _buildSectionTitle('Sleep Hours Distribution'),
              _buildDistributionListCard(
                items: sleepHoursDistribution,
                titleKey: 'range',
                filterType: 'sleep_hours',
                barColor: const Color(0xff9B59B6),
                icon: Icons.bedtime_outlined,
              ),
              const SizedBox(height: 24),
            ],
            if (workingHoursDistribution is List && workingHoursDistribution.isNotEmpty) ...[
              _buildSectionTitle('Working Hours Distribution'),
              _buildDistributionListCard(
                items: workingHoursDistribution,
                titleKey: 'range',
                filterType: 'working_hours',
                barColor: const Color(0xffE67E22),
                icon: Icons.access_time_rounded,
              ),
              const SizedBox(height: 24),
            ],
            ClientWorkoutCalendarWidget(orgId: widget.orgId),
            const SizedBox(height: 24),
            _buildSectionTitle('Client Goals & Target Distribution'),
            _buildGoalDistribution(goalDistribution),
            const SizedBox(height: 24),
            if (peakWorkoutHours.isNotEmpty) ...[
              _buildSectionTitle('Peak Workout Hours'),
              _buildPeakHours(peakWorkoutHours),
              const SizedBox(height: 24),
            ],
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
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
            _buildSectionTitle('Financial Overview'),

            SizedBox(
              height: 130,
              width: double.infinity,
              child: _buildNetProfitCard(netProfit: netProfit),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildReportCard(
                  title: 'Monthly Revenue',
                  value: '₹${monthlyRevenue.toStringAsFixed(0)}',
                  icon: Icons.currency_rupee,
                  color: const Color(0xff27AE60),
                  onTap: _showRevenueCategoryPieChartSheet,
                ),
                _buildReportCard(
                  title: 'Total Expense',
                  value: '₹${totalExpense.toStringAsFixed(0)}',
                  icon: Icons.money_off,
                  color: const Color(0xffE74C3C),
                  onTap: _showExpenseCategoryPieChartSheet,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Monthly Budget Progress'),
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

            _buildSectionTitle('Amount Received by Payment Mode'),
            if (paymentModes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
                ),
                child: Center(
                  child: Text(
                    'No payment mode data available',
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              )
            else
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
                  children: paymentModes.map((item) {
                    final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
                    final String mode = itemMap['mode']?.toString() ?? '';
                    final double amount = double.tryParse(itemMap['amount']?.toString() ?? '') ?? 0.0;
                    final double totalReceived = paymentModes.fold(0.0, (sum, e) {
                      final map = Map<String, dynamic>.from(e as Map);
                      return sum + (double.tryParse(map['amount']?.toString() ?? '') ?? 0.0);
                    });
                    final double pct = totalReceived > 0 ? (amount / totalReceived) : 0.0;

                    IconData modeIcon = Icons.payment_outlined;
                    Color modeColor = const Color(0xff3498db);

                    final modeLower = mode.toLowerCase();
                    if (modeLower.contains('cash')) {
                      modeIcon = Icons.money_outlined;
                      modeColor = const Color(0xff2ecc71);
                    } else if (modeLower.contains('upi') || modeLower.contains('gpay') || modeLower.contains('phonepe') || modeLower.contains('paytm')) {
                      modeIcon = Icons.qr_code_scanner_outlined;
                      modeColor = const Color(0xff9b59b6);
                    } else if (modeLower.contains('card') || modeLower.contains('credit') || modeLower.contains('debit')) {
                      modeIcon = Icons.credit_card_outlined;
                      modeColor = const Color(0xffe74c3c);
                    } else if (modeLower.contains('net') || modeLower.contains('bank') || modeLower.contains('transfer')) {
                      modeIcon = Icons.account_balance_outlined;
                      modeColor = const Color(0xfff1c40f);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: modeColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(modeIcon, size: 16, color: modeColor),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mode,
                                style: AppStyles.text14Px.poppins.w600.dark,
                              ),
                              const Spacer(),
                              Text(
                                '₹${amount.toStringAsFixed(0)}',
                                style: AppStyles.text14Px.poppins.w600.dark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${(pct * 100).toStringAsFixed(0)}%)',
                                style: AppStyles.text12Px.poppins.w400.copyWith(
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: const Color(0xffF0F0F0),
                              color: modeColor,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Recent Expenses'),
                Row(
                  children: [
                    if (_expenses.length > 5)
                      GestureDetector(
                        onTap: () => _showAllExpensesSheet(),
                        child: Text(
                          'View All (${_expenses.length})',
                          style: AppStyles.text13Px.poppins.w600.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => _showExpenseSheet(),
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_expenses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
                ),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showExpenseSheet(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add First Expense'),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _expenses.length > 5 ? 5 : _expenses.length,
                      separatorBuilder:
                          (context, index) =>
                              const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final exp = _expenses[index];
                        final id = exp['id'] as int? ?? 0;
                        final title =
                            exp['title']?.toString() ?? 'Unspecified Expense';
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
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showExpenseSheet(expense: exp);
                                  } else if (val == 'delete') {
                                    _deleteExpense(id);
                                  }
                                },
                                itemBuilder:
                                    (context) => [
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
                    if (_expenses.length > 5) ...[
                      const Divider(height: 1, color: Color(0xffEEEEEE)),
                      InkWell(
                        onTap: () => _showAllExpensesSheet(),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'View All ${_expenses.length} Expenses',
                            style: AppStyles.text13Px.poppins.w600.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Recent Revenues'),
                Row(
                  children: [
                    if (_revenues.length > 5)
                      GestureDetector(
                        onTap: () => _showAllRevenuesSheet(),
                        child: Text(
                          'View All (${_revenues.length})',
                          style: AppStyles.text13Px.poppins.w600.copyWith(
                            color: const Color(0xff27AE60),
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => _showRevenueSheet(),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xff27AE60),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_revenues.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 44,
                      color: AppColors.textGrey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No revenue records yet',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff27AE60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showRevenueSheet(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add First Revenue'),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _revenues.length > 5 ? 5 : _revenues.length,
                      separatorBuilder:
                          (context, index) =>
                              const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final rev = _revenues[index];
                        final id = rev['id'] as int? ?? 0;
                        final title =
                            rev['title']?.toString() ?? rev['name']?.toString() ?? 'Unspecified Revenue';
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
                                '+ ₹${parsedAmount.toStringAsFixed(2)}',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xff27AE60),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showRevenueSheet(revenue: rev);
                                  } else if (val == 'delete') {
                                    _deleteRevenue(id);
                                  }
                                },
                                itemBuilder:
                                    (context) => [
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
                    if (_revenues.length > 5) ...[
                      const Divider(height: 1, color: Color(0xffEEEEEE)),
                      InkWell(
                        onTap: () => _showAllRevenuesSheet(),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'View All ${_revenues.length} Revenues',
                            style: AppStyles.text13Px.poppins.w600.copyWith(
                              color: const Color(0xff27AE60),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),

            _buildSectionTitle('Plan Revenue Breakdown'),
            if (planRevenueBreakdown.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffEEEEEE)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 48,
                      color: AppColors.textGrey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No plan revenue breakdown data available',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              _buildPlanRevenueBreakdown(planRevenueBreakdown),
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

  void _showExpenseCategoryPieChartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                    style: AppStyles.text18Px.poppins.w600.dark,
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
      backgroundColor: Colors.white,
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
                    style: AppStyles.text18Px.poppins.w600.dark,
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
        padding: const EdgeInsets.all(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppStyles.text20Px.poppins.w600.copyWith(color: color),
              ),
              Text(
                title,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: AppColors.textGrey,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
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
            orgId: orgId,
            startDate: startDate,
            endDate: endDate,
          ),

          const Divider(height: 32, color: Color(0xffEEEEEE)),

          Text('Age Distribution', style: AppStyles.text14Px.poppins.w300.dark),
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
                        backgroundColor: const Color(0xffF0F0F0),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEEEEE)),
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
          ...normalizedGoals.map((e) {
            final key = e['goal'] as String;
            final pctStr = e['percentage'] as String;
            final count = e['count'] as int;

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEEEEE)),
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

    return Container(
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
        children: list.map((item) {
          final String title = item['title'] as String;
          final String label = item['label'] as String;
          final String pctStr = item['percentage'] as String;
          final int count = item['count'] as int;

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
        }).toList(),
      ),
    );
  }

  Widget _buildPeakHours(Map<dynamic, dynamic> peakHours) {
    final sortedEntries =
        peakHours.entries.toList()..sort(
          (a, b) => ((b.value as int?) ?? 0).compareTo((a.value as int?) ?? 0),
        );

    final topEntries = sortedEntries.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffEEEEEE)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
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
