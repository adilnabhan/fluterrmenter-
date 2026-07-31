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
  bool _isLoading = true;
  Map<String, dynamic> _reportsData = {};
  List<Map<String, dynamic>> _expenses = [];
  DateTime? _startDate;
  DateTime? _endDate;

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

    String queryParams = 'organization_id=${widget.orgId}';
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
      // 2. Fetch expenses
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
                            value:
                                categories.contains(selectedCategory)
                                    ? selectedCategory
                                    : 'Other',
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
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

  void _showSetBudgetDialog(double currentBudget) {
    final controller = TextEditingController(
      text: currentBudget > 0 ? currentBudget.toStringAsFixed(2) : '',
    );
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text('Set Monthly Budget'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget Limit (₹)',
                hintText: 'e.g. 12500.00',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final valStr = controller.text.trim();
                  if (valStr.isEmpty) {
                    await Dialogs.showSnack(
                      msg: 'Please enter a budget amount',
                    );
                    return;
                  }
                  final newBudget = double.tryParse(valStr);
                  if (newBudget == null) {
                    await Dialogs.showSnack(msg: 'Invalid budget amount');
                    return;
                  }

                  Navigator.pop(context); // Close dialog
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                  }

                  try {
                    final payload = {'monthly_budget': newBudget};
                    final response = await DioClient().dio.post<dynamic>(
                      ApiUris.budget,
                      data: payload,
                      options:
                          Options(
                            headers: {'X-Platform': platformSource},
                          ).token,
                    );
                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      await Dialogs.showSnack(
                        msg: 'Organization budget updated successfully.',
                      );
                      await _fetchReports();
                    } else {
                      await Dialogs.showSnack(msg: 'Failed to update budget');
                    }
                  } catch (e) {
                    await Dialogs.showSnack(msg: 'Error updating budget');
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: const Text('Save'),
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

    final budgetSummary =
        _reportsData['budget_summary'] as Map<dynamic, dynamic>?;
    final budget = budgetSummary?['budget'] ?? 0.0;
    final budgetUsedAmount = budgetSummary?['budget_used_amount'] ?? 0.0;
    final budgetUsedPercentage =
        budgetSummary?['budget_used_percentage']?.toString() ?? "0%";
    final budgetRemaining = budgetSummary?['budget_remaining'] ?? 0.0;

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
                    ),
                    _buildTrainersTab(trainersPerformance),
                    _buildClientsTab(
                      totalClients: totalClients.toString(),
                      completedSessions: totalCompletedSessions.toString(),
                      retentionRate: financial?['retention_rate']?.toString() ?? "0%",
                      genderDistribution: genderDistribution,
                      ageDistribution: ageDistribution,
                      goalDistribution: goalDistribution,
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

  Widget _buildTrainersTab(List<dynamic> trainersPerformance) {
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
  }) {
    var budgetPctVal = 0.0;
    try {
      budgetPctVal =
          double.parse(budgetUsedPercentage.replaceAll('%', '')) / 100.0;
    } catch (_) {}
    if (budgetPctVal > 1.0) budgetPctVal = 1.0;
    if (budgetPctVal < 0.0) budgetPctVal = 0.0;

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
              height: 125,
              width: double.infinity,
              child: _buildReportCard(
                title: 'Net Profit / Loss',
                value: '₹${netProfit.toStringAsFixed(2)}',
                icon: netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                color:
                    netProfit >= 0
                        ? const Color(0xff2ECC71)
                        : const Color(0xffE74C3C),
              ),
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
                  color: const Color(0xffE67E22),
                ),
                _buildReportCard(
                  title: 'Total Expense',
                  value: '₹${totalExpense.toStringAsFixed(0)}',
                  icon: Icons.money_off,
                  color: const Color(0xffE74C3C),
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
                        style: AppStyles.text14Px.poppins.w600.dark,
                      ),
                      InkWell(
                        onTap: () => _showSetBudgetDialog(budget),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Budget: ',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: AppColors.textGrey,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₹${budget.toStringAsFixed(0)}',
                                    style: AppStyles.text14Px.poppins.w600.dark,
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
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _expenses.length,
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
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.text16Px.poppins.w600.dark),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppStyles.text16Px.poppins.w600.dark),
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
    ),);
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
  });

  final Map<dynamic, dynamic> genderDist;
  final int orgId;
  final DateTime? startDate;
  final DateTime? endDate;

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
                    onTap: () {
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
