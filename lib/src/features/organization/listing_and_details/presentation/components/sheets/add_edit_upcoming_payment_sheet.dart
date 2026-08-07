import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class AddEditUpcomingPaymentSheet extends StatefulWidget {
  const AddEditUpcomingPaymentSheet({
    required this.orgId,
    this.payment,
    super.key,
  });

  final int orgId;
  final Map<String, dynamic>? payment;

  @override
  State<AddEditUpcomingPaymentSheet> createState() =>
      _AddEditUpcomingPaymentSheetState();
}

class _AddEditUpcomingPaymentSheetState
    extends State<AddEditUpcomingPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _selectedCategory = 'Rent';
  String _selectedRepeat = 'monthly';
  bool _isLoading = false;

  final List<String> _categories = [
    'Rent',
    'Salary',
    'Utilities',
    'Maintenance',
    'Subscriptions',
    'Equipment',
    'Others',
  ];

  final Map<String, String> _repeatOptions = {
    'one_time': 'One-time',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'half_yearly': 'Half-Yearly',
    'yearly': 'Yearly',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.payment;
    _titleController = TextEditingController(text: p?['title']?.toString() ?? '');
    _amountController = TextEditingController(
      text: p?['amount'] != null
          ? double.tryParse(p!['amount'].toString())?.toStringAsFixed(0) ?? ''
          : '',
    );
    _notesController = TextEditingController(text: p?['notes']?.toString() ?? '');

    if (p?['due_date'] != null) {
      final parsed = DateTime.tryParse(p!['due_date'].toString());
      if (parsed != null) _dueDate = parsed;
    }

    if (p?['category'] != null && _categories.contains(p!['category'])) {
      _selectedCategory = p!['category'].toString();
    } else if (p?['category'] != null && p!['category'].toString().isNotEmpty) {
      final catStr = p!['category'].toString();
      if (!_categories.contains(catStr)) {
        _categories.add(catStr);
      }
      _selectedCategory = catStr;
    }

    if (p?['repeat'] != null && _repeatOptions.containsKey(p!['repeat'])) {
      _selectedRepeat = p!['repeat'].toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff27AE60),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        'organization_id': widget.orgId,
        'title': title,
        'amount': amount,
        'category': _selectedCategory,
        'due_date': DateFormat('yyyy-MM-dd').format(_dueDate),
        'repeat': _selectedRepeat,
        'notes': notes,
      };

      Response<dynamic> response;
      if (widget.payment != null && widget.payment!['id'] != null) {
        final id = widget.payment!['id'];
        response = await DioClient().dio.patch<dynamic>(
          ApiUris.upcomingPaymentDetail(int.parse(id.toString())),
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
      } else {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.upcomingPayments,
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(
          msg: widget.payment != null
              ? 'Upcoming payment updated!'
              : 'Upcoming payment created!',
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        Dialogs.showSnack(msg: 'Failed to save upcoming payment');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error saving upcoming payment');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.payment != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Handle & Title
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Upcoming Payment' : 'Add Upcoming Payment',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Payment Title *',
                  hintText: 'e.g. Gym Rent, Staff Salary',
                  filled: true,
                  fillColor: context.colors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff27AE60)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter payment title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (₹) *',
                  hintText: 'e.g. 45000',
                  prefixText: '₹ ',
                  filled: true,
                  fillColor: context.colors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff27AE60)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(val.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                'Category',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xff27AE60).withValues(alpha: 0.15),
                    backgroundColor: context.colors.fieldFill,
                    labelStyle: AppStyles.text12Px.poppins.w500.copyWith(
                      color: isSelected
                          ? const Color(0xff27AE60)
                          : context.colors.textPrimary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xff27AE60)
                          : context.colors.border,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Row for Due Date & Repeat
              Row(
                children: [
                  // Due Date Button
                  Expanded(
                    child: InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.fieldFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due Date',
                                  style: AppStyles.text10Px.poppins.w500
                                      .copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_dueDate),
                                  style: AppStyles.text13Px.poppins.w600
                                      .copyWith(
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: Color(0xff27AE60),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Repeat Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: context.colors.fieldFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRepeat,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xff27AE60),
                          ),
                          items: _repeatOptions.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: AppStyles.text13Px.poppins.w500.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRepeat = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add remarks, bill account details, etc.',
                  filled: true,
                  fillColor: context.colors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff27AE60)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff27AE60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Payment' : 'Save Payment',
                          style: AppStyles.text16Px.poppins.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
