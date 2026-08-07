import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/upcoming_payments_screen.dart';

class UpcomingPaymentsWidget extends StatefulWidget {
  const UpcomingPaymentsWidget({
    required this.orgId,
    this.margin,
    super.key,
  });

  final int orgId;
  final EdgeInsetsGeometry? margin;

  @override
  State<UpcomingPaymentsWidget> createState() => _UpcomingPaymentsWidgetState();
}

class _UpcomingPaymentsWidgetState extends State<UpcomingPaymentsWidget> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingPayments = [];
  Map<String, dynamic> _summary = {};
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchUpcomingPayments();
  }

  Future<void> _fetchUpcomingPayments() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.upcomingPayments}?organization_id=${widget.orgId}',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map) {
          final results = data['results'] ?? data['data'] ?? [];
          final summary = data['summary'] ?? data;
          if (mounted) {
            setState(() {
              _upcomingPayments = (results as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
              _summary = Map<String, dynamic>.from(summary as Map);
              _isLoading = false;
            });
          }
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markPaid(int id) async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.markUpcomingPaymentPaid(id),
        data: {'paid_date': DateFormat('yyyy-MM-dd').format(DateTime.now())},
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Payment marked as paid!');
        _fetchUpcomingPayments();
      }
    } catch (_) {
      Dialogs.showSnack(msg: 'Failed to mark payment paid');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: widget.margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final overdueCount = int.tryParse((_summary['overdue_count'] ?? 0).toString()) ?? 0;
    final overdueAmount = double.tryParse((_summary['total_overdue'] ?? 0).toString()) ?? 0.0;

    // Build day map for the focused month
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    final Map<int, List<Map<String, dynamic>>> dayPaymentsMap = {};
    for (final item in _upcomingPayments) {
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

    // Selected day items or default upcoming items
    List<Map<String, dynamic>> itemsForDisplay = [];
    if (_selectedDate != null &&
        _selectedDate!.year == _focusedMonth.year &&
        _selectedDate!.month == _focusedMonth.month) {
      itemsForDisplay = dayPaymentsMap[_selectedDate!.day] ?? [];
    } else {
      itemsForDisplay = _upcomingPayments
          .where((p) => p['status']?.toString().toLowerCase() != 'paid')
          .take(2)
          .toList();
    }

    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff27AE60).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xff27AE60),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upcoming Payments',
                        style: AppStyles.text15Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpcomingPaymentsScreen(orgId: widget.orgId),
                    ),
                  );
                  _fetchUpcomingPayments();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xff27AE60),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xff27AE60),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Overdue Alert Banner
          if (overdueCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffE74C3C).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xffE74C3C).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xffE74C3C),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$overdueCount Overdue Bill${overdueCount == 1 ? '' : 's'} (₹${overdueAmount.toStringAsFixed(0)})',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xffE74C3C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Calendar Month Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: AppStyles.text14Px.poppins.w600.copyWith(
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
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox.shrink();
              }
              final day = index - firstDayOfWeek + 1;
              final currentDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = _selectedDate != null && DateUtils.isSameDay(_selectedDate, currentDate);
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
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xffE74C3C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPending)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xffF39C12),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPaid && !hasOverdue && !hasPending)
                              Container(
                                width: 6,
                                height: 6,
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

          const SizedBox(height: 10),

          // Legend Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(const Color(0xffE74C3C), 'Overdue'),
              const SizedBox(width: 14),
              _buildLegendDot(const Color(0xffF39C12), 'Pending'),
              const SizedBox(width: 14),
              _buildLegendDot(const Color(0xff27AE60), 'Paid'),
            ],
          ),

          if (itemsForDisplay.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xffEEEEEE)),
            const SizedBox(height: 10),
            Text(
              _selectedDate != null
                  ? 'Bills on ${DateFormat('dd MMM yyyy').format(_selectedDate!)}'
                  : 'Upcoming Bills',
              style: AppStyles.text12Px.poppins.w600.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...itemsForDisplay.map((item) {
              final id = item['id'] != null ? int.tryParse(item['id'].toString()) : null;
              final title = item['title']?.toString() ?? 'Payment';
              final category = item['category']?.toString() ?? 'Others';
              final amount = double.tryParse((item['amount'] ?? 0).toString()) ?? 0.0;
              final status = item['status']?.toString().toLowerCase() ?? 'pending';
              final isPaid = status == 'paid';
              final isOverdue = status == 'overdue';

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.fieldFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOverdue
                        ? const Color(0xffE74C3C).withValues(alpha: 0.3)
                        : context.colors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 16,
                            color: const Color(0xff27AE60),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppStyles.text12Px.poppins.w600.copyWith(
                                    color: context.colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  category,
                                  style: AppStyles.text10Px.poppins.w500.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: AppStyles.text13Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
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
                                horizontal: 8,
                                vertical: 2,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Mark Paid',
                              style: AppStyles.text10Px.poppins.w600,
                            ),
                          ),
                        ] else if (isPaid) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff27AE60).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PAID',
                              style: AppStyles.text10Px.poppins.w600.copyWith(
                                color: const Color(0xff27AE60),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w500.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
