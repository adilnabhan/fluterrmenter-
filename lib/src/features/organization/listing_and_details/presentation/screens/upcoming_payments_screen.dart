import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/add_edit_upcoming_payment_sheet.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_content_constraint.dart';

class UpcomingPaymentsScreen extends StatefulWidget {
  const UpcomingPaymentsScreen({
    required this.orgId,
    super.key,
  });

  final int orgId;

  @override
  State<UpcomingPaymentsScreen> createState() => _UpcomingPaymentsScreenState();
}

class _UpcomingPaymentsScreenState extends State<UpcomingPaymentsScreen> {
  bool _isLoading = true;
  bool _isCalendarView = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  String _selectedStatusFilter = 'all'; // all, pending, overdue, paid
  String _selectedCategoryFilter = 'All';

  Map<String, dynamic> _summaryMetrics = {};
  List<Map<String, dynamic>> _paymentsList = [];

  final List<String> _categories = [
    'All',
    'Rent',
    'Salary',
    'Utilities',
    'Maintenance',
    'Subscriptions',
    'Equipment',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUpcomingPayments();
  }

  Future<void> _fetchUpcomingPayments({bool showLoading = true}) async {
    if (showLoading && mounted && _paymentsList.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final queryParams = <String, String>{
        'organization_id': widget.orgId.toString(),
      };

      final uri = Uri.parse(ApiUris.upcomingPayments)
          .replace(queryParameters: queryParams)
          .toString();

      final response = await DioClient().dio.get<dynamic>(
        uri,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map) {
          final results = data['results'] ?? data['data'] ?? <dynamic>[];
          final summary = data['summary'] ?? data;

          if (mounted) {
            setState(() {
              _paymentsList = (results as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
              _summaryMetrics = Map<String, dynamic>.from(summary as Map);
            });
          }
        }
      }
    } catch (e) {
      // Quiet fail / show snackbar
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markPaid(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Mark as Paid?',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        content: Text(
          'This will record an expense in financial reports and automatically generate the next recurring due payment if applicable.',
          style: AppStyles.text13Px.poppins.w400.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff27AE60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Mark Paid'),
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
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.markUpcomingPaymentPaid(id),
        data: {'paid_date': DateFormat('yyyy-MM-dd').format(DateTime.now())},
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Payment marked as paid & expense recorded!');
        await _fetchUpcomingPayments();
      } else {
        Dialogs.showSnack(msg: 'Failed to mark payment as paid');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error marking payment as paid');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePayment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Upcoming Payment?',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this payment reminder?',
          style: AppStyles.text13Px.poppins.w400.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
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
        ApiUris.upcomingPaymentDetail(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Dialogs.showSnack(msg: 'Upcoming payment deleted');
        await _fetchUpcomingPayments();
      } else {
        Dialogs.showSnack(msg: 'Failed to delete payment');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error deleting payment');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddEditSheet([Map<String, dynamic>? payment]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditUpcomingPaymentSheet(
        orgId: widget.orgId,
        payment: payment,
      ),
    );

    if (result == true) {
      _fetchUpcomingPayments();
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.house_rounded;
      case 'salary':
        return Icons.badge_outlined;
      case 'utilities':
        return Icons.bolt_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      case 'subscriptions':
        return Icons.subscriptions_rounded;
      case 'equipment':
        return Icons.fitness_center_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xff27AE60);
      case 'overdue':
        return const Color(0xffE74C3C);
      case 'pending':
      default:
        return const Color(0xffF39C12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? context.colors.background : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          'Upcoming Payments & Bills',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? context.colors.card : Colors.white,
        surfaceTintColor: isDark ? context.colors.card : Colors.white,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        actions: [
          // View Switcher Toggle
          IconButton(
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            icon: Icon(
              _isCalendarView
                  ? Icons.format_list_bulleted_rounded
                  : Icons.calendar_month_rounded,
              color: const Color(0xff27AE60),
            ),
            tooltip: _isCalendarView
                ? 'Switch to List View'
                : 'Switch to Calendar View',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(),
        backgroundColor: const Color(0xff27AE60),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Payment',
          style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
        ),
      ),
      body: _isLoading && _paymentsList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchUpcomingPayments(showLoading: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: DesktopContentConstraint(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Header Metrics
                      _buildSummaryMetricsHeader(),
                      const SizedBox(height: 16),

                      if (_isCalendarView) ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 850;
                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 360,
                                    child: _buildCalendarWidget(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader(
                                          'Payments for ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildFilteredPaymentsList(
                                          dateFilter: _selectedDate,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 380),
                                    child: _buildCalendarWidget(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSectionHeader(
                                  'Payments for ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                                ),
                                const SizedBox(height: 8),
                                _buildFilteredPaymentsList(
                                  dateFilter: _selectedDate,
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        // List View: Status Filter Tabs & Category Chips
                        _buildStatusFilterTabs(),
                        const SizedBox(height: 12),
                        _buildCategoryFilterChips(),
                        const SizedBox(height: 16),
                        _buildFilteredPaymentsList(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryMetricsHeader() {
    int overdueCount = int.tryParse((_summaryMetrics['overdue_count'] ?? 0).toString()) ?? 0;
    double overdueAmount = double.tryParse((_summaryMetrics['total_overdue'] ?? 0).toString()) ?? 0.0;
    int upcomingCount = int.tryParse((_summaryMetrics['upcoming_count'] ?? 0).toString()) ?? 0;
    double upcomingAmount = double.tryParse((_summaryMetrics['total_upcoming'] ?? 0).toString()) ?? 0.0;
    int paidCount = int.tryParse((_summaryMetrics['paid_count'] ?? 0).toString()) ?? 0;
    double paidAmount = double.tryParse((_summaryMetrics['total_paid'] ?? 0).toString()) ?? 0.0;

    // Fallback: calculate directly from list if summary map is not pre-populated by backend
    if (overdueCount == 0 && upcomingCount == 0 && paidCount == 0 && _paymentsList.isNotEmpty) {
      overdueCount = _paymentsList.where((p) => p['status']?.toString().toLowerCase() == 'overdue').length;
      overdueAmount = _paymentsList
          .where((p) => p['status']?.toString().toLowerCase() == 'overdue')
          .fold(0.0, (sum, p) => sum + (double.tryParse(p['amount']?.toString() ?? '0') ?? 0.0));

      upcomingCount = _paymentsList.where((p) => p['status']?.toString().toLowerCase() == 'pending').length;
      upcomingAmount = _paymentsList
          .where((p) => p['status']?.toString().toLowerCase() == 'pending')
          .fold(0.0, (sum, p) => sum + (double.tryParse(p['amount']?.toString() ?? '0') ?? 0.0));

      paidCount = _paymentsList.where((p) => p['status']?.toString().toLowerCase() == 'paid').length;
      paidAmount = _paymentsList
          .where((p) => p['status']?.toString().toLowerCase() == 'paid')
          .fold(0.0, (sum, p) => sum + (double.tryParse(p['amount']?.toString() ?? '0') ?? 0.0));
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Overdue',
            count: '$overdueCount',
            amount: '₹${overdueAmount.toStringAsFixed(0)}',
            color: const Color(0xffE74C3C),
            icon: Icons.error_outline_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            title: 'Upcoming',
            count: '$upcomingCount',
            amount: '₹${upcomingAmount.toStringAsFixed(0)}',
            color: const Color(0xffF39C12),
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            title: 'Paid',
            count: '$paidCount',
            amount: '₹${paidAmount.toStringAsFixed(0)}',
            color: const Color(0xff27AE60),
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? context.colors.card : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? context.colors.border : const Color(0xffEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
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
              Icon(icon, size: 18, color: color),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: AppStyles.text10Px.poppins.w600.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppStyles.text10Px.poppins.w500.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterTabs() {
    final isDark = context.isDarkMode;
    final tabs = [
      {'key': 'all', 'label': 'All Bills'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'overdue', 'label': 'Overdue'},
      {'key': 'paid', 'label': 'Paid'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? context.colors.card : context.colors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: tabs.map((t) {
          final isSelected = t['key'] == _selectedStatusFilter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatusFilter = t['key']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? context.colors.fieldFill : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    t['label']!,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: isSelected
                          ? const Color(0xff27AE60)
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = cat == _selectedCategoryFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: const Color(0xff27AE60).withValues(alpha: 0.15),
              backgroundColor: isDark ? context.colors.card : Colors.white,
              labelStyle: AppStyles.text12Px.poppins.w500.copyWith(
                color: isSelected
                    ? const Color(0xff27AE60)
                    : context.colors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xff27AE60)
                    : (isDark ? context.colors.border : const Color(0xffEEEEEE)),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryFilter = cat;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarWidget() {
    final isDark = context.isDarkMode;
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    final Map<int, List<Map<String, dynamic>>> dayPaymentsMap = {};
    for (final item in _paymentsList) {
      final dueDateStr = item['due_date']?.toString();
      if (dueDateStr != null) {
        final parsed = DateTime.tryParse(dueDateStr);
        if (parsed != null &&
            parsed.year == _focusedMonth.year &&
            parsed.month == _focusedMonth.month) {
          dayPaymentsMap.putIfAbsent(parsed.day, () => []).add(item);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? context.colors.card : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? context.colors.border : const Color(0xffEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: AppStyles.text15Px.poppins.w600.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: AppStyles.text10Px.poppins.w600.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDayOfWeek,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox.shrink();
              }
              final day = index - firstDayOfWeek + 1;
              final currentDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = DateUtils.isSameDay(_selectedDate, currentDate);
              final isToday = DateUtils.isSameDay(DateTime.now(), currentDate);

              final dayPayments = dayPaymentsMap[day] ?? [];
              final hasOverdue = dayPayments.any((p) => p['status']?.toString().toLowerCase() == 'overdue');
              final hasPending = dayPayments.any((p) => p['status']?.toString().toLowerCase() == 'pending');
              final hasPaid = dayPayments.any((p) => p['status']?.toString().toLowerCase() == 'paid');

              Color? cellBg;
              Color textColor = context.colors.textPrimary;
              Border? cellBorder;

              if (isSelected) {
                cellBg = const Color(0xff27AE60);
                textColor = Colors.white;
              } else if (hasOverdue) {
                cellBg = const Color(0xffE74C3C).withValues(alpha: 0.18);
                textColor = const Color(0xffC0392B);
                cellBorder = Border.all(color: const Color(0xffE74C3C), width: 1.5);
              } else if (hasPending) {
                cellBg = const Color(0xffF39C12).withValues(alpha: 0.2);
                textColor = const Color(0xffD35400);
                cellBorder = Border.all(color: const Color(0xffF39C12), width: 1.5);
              } else if (hasPaid) {
                cellBg = const Color(0xff27AE60).withValues(alpha: 0.15);
                textColor = const Color(0xff1E8449);
              } else if (isToday) {
                cellBg = const Color(0xff27AE60).withValues(alpha: 0.08);
                cellBorder = Border.all(color: const Color(0xff27AE60), width: 1.5);
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = currentDate;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: cellBg ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: cellBorder,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppStyles.text12Px.poppins.w700.copyWith(
                          color: textColor,
                        ),
                      ),
                      if (dayPayments.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasOverdue)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xffE74C3C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPending && !hasOverdue)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xffF39C12),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPaid && !hasOverdue && !hasPending)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xff27AE60),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppStyles.text14Px.poppins.w600.copyWith(
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildFilteredPaymentsList({DateTime? dateFilter}) {
    final isDark = context.isDarkMode;
    var filtered = _paymentsList;
    if (dateFilter != null) {
      filtered = filtered.where((item) {
        final dueDateStr = item['due_date']?.toString();
        if (dueDateStr == null) return false;
        final parsed = DateTime.tryParse(dueDateStr);
        return parsed != null && DateUtils.isSameDay(parsed, dateFilter);
      }).toList();
    } else {
      if (_selectedStatusFilter != 'all') {
        filtered = filtered.where((item) {
          final status = item['status']?.toString().toLowerCase();
          return status == _selectedStatusFilter.toLowerCase();
        }).toList();
      }
      if (_selectedCategoryFilter != 'All') {
        filtered = filtered.where((item) {
          final cat = item['category']?.toString().toLowerCase();
          return cat == _selectedCategoryFilter.toLowerCase();
        }).toList();
      }
    }

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? context.colors.card : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? context.colors.border : const Color(0xffEEEEEE),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming payments found',
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final id = item['id'] != null ? int.tryParse(item['id'].toString()) : null;
        final title = item['title']?.toString() ?? item['name']?.toString() ?? 'Payment';
        final category = item['category']?.toString() ?? 'Others';
        final amount = double.tryParse((item['amount'] ?? 0.0).toString()) ?? 0.0;
        final status = item['status']?.toString().toLowerCase() ?? 'pending';
        final repeat = item['repeat']?.toString() ?? 'one_time';
        final dueDateStr = item['due_date']?.toString();
        DateTime? dueDate;
        if (dueDateStr != null) {
          dueDate = DateTime.tryParse(dueDateStr);
        }

        final isPaid = status == 'paid';
        final isOverdue = status == 'overdue';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? context.colors.card : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? const Color(0xffE74C3C).withValues(alpha: 0.3)
                  : (isDark ? context.colors.border : const Color(0xffEEEEEE)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xff27AE60).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: const Color(0xff27AE60),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                category,
                                style: AppStyles.text12Px.poppins.w400.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              if (repeat != 'one_time') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.fieldFill,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    repeat.replaceAll('_', ' '),
                                    style: AppStyles.text10Px.poppins.w500.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Popup menu for Edit/Delete
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: context.colors.textSecondary,
                      size: 20,
                    ),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _openAddEditSheet(item);
                      } else if (val == 'delete' && id != null) {
                        _deletePayment(id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: AppStyles.text10Px.poppins.w500.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dueDate != null
                            ? 'Due: ${DateFormat('dd MMM yyyy').format(dueDate)}'
                            : 'No due date',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: isOverdue
                              ? const Color(0xffE74C3C)
                              : context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: AppStyles.text10Px.poppins.w600.copyWith(
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                          if (!isPaid && id != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _markPaid(id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff27AE60),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Mark Paid',
                                style: AppStyles.text10Px.poppins.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
