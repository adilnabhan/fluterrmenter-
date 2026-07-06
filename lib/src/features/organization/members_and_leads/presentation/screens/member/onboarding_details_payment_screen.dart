import 'dart:io';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';

class OnboardingDetailsPaymentScreen extends StatefulWidget {
  const OnboardingDetailsPaymentScreen({
    required this.orgId,
    required this.memberDetails,
    required this.selectedPackage,
    required this.packages,
    super.key,
  });

  final int orgId;
  final MemberDetailsModel memberDetails;
  final MembershipPackageModel selectedPackage;
  final List<MembershipPackageModel> packages;

  @override
  State<OnboardingDetailsPaymentScreen> createState() => _OnboardingDetailsPaymentScreenState();
}

class _OnboardingDetailsPaymentScreenState extends State<OnboardingDetailsPaymentScreen> {
  late final MembersAndLeadsCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  late MembershipPackageModel _selectedPlan;
  Map<String, dynamic>? _selectedTrainer;
  List<Map<String, dynamic>> _trainers = [];
  bool _loadingTrainers = false;

  final _discountController = TextEditingController(text: '0');
  final _amountReceivedController = TextEditingController();
  
  String _paymentMethod = 'cash';
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _selectedPlan = widget.selectedPackage;
    _updateAmountReceived();
    _fetchTrainers();
  }

  @override
  void dispose() {
    _discountController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }

  void _updateAmountReceived() {
    final priceStr = _selectedPlan.offerPrice?.isNotEmpty == true
        ? _selectedPlan.offerPrice
        : _selectedPlan.actualPrice;
    final price = double.tryParse(priceStr ?? '0') ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final finalAmount = (price - discount).clamp(0.0, double.infinity);
    _amountReceivedController.text = finalAmount.toStringAsFixed(0);
  }

  Future<void> _fetchTrainers() async {
    setState(() {
      _loadingTrainers = true;
    });
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.leadsListing,
        queryParameters: {
          'organization_id': widget.orgId,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (List<dynamic>.from((response.data as Map)['results'] as List? ?? []))
            : (response.data as List<dynamic>);
        setState(() {
          _trainers = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loadingTrainers = false;
        });
      } else {
        setState(() {
          _loadingTrainers = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingTrainers = false;
      });
    }
  }

  void _showTrainerSearchBottomSheet() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _TrainerSearchBottomSheet(
          trainers: _trainers,
          loading: _loadingTrainers,
          onSelected: (trainer) {
            setState(() {
              _selectedTrainer = trainer;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submit() {
    if (_cubit.state.createOrUpdateMember?.isNone() ?? false) {
      Dialogs.showSnack(msg: 'Please wait');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      final amountReceived = double.tryParse(_amountReceivedController.text) ?? 0.0;
      
      _cubit.cerateOrUpdateMemberDetails(
        memeberDetails: widget.memberDetails,
        membershipPackageModel: _selectedPlan,
        discountAmount: discount,
        amountReceived: amountReceived,
        paymentMethod: _paymentMethod,
        membershipStartDate: _startDate,
        trainerId: _selectedTrainer?['id'] as int?,
      );
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.memberOnboardedAnimationCompleted != c.memberOnboardedAnimationCompleted,
      listener: (context, state) {
        if (state.memberOnboardedAnimationCompleted ?? false) {
          context.pop();
        }
      },
      child: BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
        listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
        bloc: _cubit,
        listener: (context, state) {
          state.createOrUpdateMember?.fold(() => null, (t) {
            return t.fold(
              (l) {
                Dialogs.showSnack(msg: l.msg);
              },
              (r) {
                Dialogs.showSnack(msg: 'Member added successfully');
                context.push(
                  BlocProvider.value(
                    value: _cubit,
                    child: const MemberOnboardPaymentSuccessScreen(),
                  ),
                );
              },
            );
          });
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const PopButton().center,
            titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
            title: const Text('Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Customer Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xffFFCECE),
                        backgroundImage: widget.memberDetails.profilePicture != null
                            ? FileImage(File(widget.memberDetails.profilePicture!))
                            : null,
                        child: widget.memberDetails.profilePicture == null
                            ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.memberDetails.fullName ?? '',
                              style: AppStyles.text16Px.poppins.w600.dark,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.memberDetails.mobileNumber != null
                                  ? '+91 ${widget.memberDetails.mobileNumber}'
                                  : '',
                              style: AppStyles.text14Px.poppins.w400.textGrey,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (widget.memberDetails.gender != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF2F2F7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _capitalize(widget.memberDetails.gender ?? ''),
                                      style: AppStyles.text12Px.poppins.w500.copyWith(color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFFF2E6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircleAvatar(radius: 3, backgroundColor: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        'No Plan',
                                        style: AppStyles.text12Px.poppins.w500.copyWith(color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Fill details',
                  style: AppStyles.text18Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),

                // Select a Plan
                Text(
                  'Select a Plan*',
                  style: AppStyles.text14Px.poppins.w500.dark,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MembershipPackageModel>(
                  value: _selectedPlan,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderGrey),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  items: widget.packages.map((plan) {
                    return DropdownMenuItem<MembershipPackageModel>(
                      value: plan,
                      child: Text(plan.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPlan = val;
                        _updateAmountReceived();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Trainer Selection
                Text(
                  'Trainer Selection',
                  style: AppStyles.text14Px.poppins.w500.dark,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showTrainerSearchBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTrainer != null
                              ? (_selectedTrainer!['trainer_name'] ?? '')
                              : 'Select Trainer',
                          style: AppStyles.text14Px.poppins.w400.copyWith(
                            color: _selectedTrainer != null ? Colors.black : Colors.black38,
                          ),
                        ),
                        const Icon(Icons.search, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Discount and Amount Received side by side
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discount Amount',
                            style: AppStyles.text14Px.poppins.w500.dark,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.borderGrey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.borderGrey),
                              ),
                            ),
                            onChanged: (_) => _updateAmountReceived(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Received*',
                            style: AppStyles.text14Px.poppins.w500.dark,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountReceivedController,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Enter Amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.borderGrey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.borderGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Payment Method Radio Options
                Text(
                  'Payment Method*',
                  style: AppStyles.text14Px.poppins.w500.dark,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPaymentMethodOption('cash', 'Cash', const Color(0xffE2F5EC), Colors.green),
                    _buildPaymentMethodOption('upi', 'UPI', const Color(0xffE6F0FA), Colors.blue),
                    _buildPaymentMethodOption('debit_card', 'Debit Card', const Color(0xffFFF2E6), Colors.orange),
                    _buildPaymentMethodOption('credit_card', 'Credit Card', const Color(0xffF2E6FF), Colors.purple),
                    _buildPaymentMethodOption('net_banking', 'Net Banking', const Color(0xffE6F9F9), Colors.teal),
                  ],
                ),
                const SizedBox(height: 20),

                // Membership Start Date
                Text(
                  'Membership Start Date*',
                  style: AppStyles.text14Px.poppins.w500.dark,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate.format('dd MMM yyyy'),
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Add Member Submit Button
                BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                  buildWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
                  builder: (context, state) {
                    final isLoading = state.createOrUpdateMember?.isNone() ?? false;
                    return FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Member',
                              style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String key, String label, Color bgColor, Color textColor) {
    final isSelected = _paymentMethod == key;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = key;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 20,
            color: isSelected ? AppColors.primary : Colors.black38,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? textColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: AppStyles.text12Px.poppins.w500.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerSearchBottomSheet extends StatefulWidget {
  const _TrainerSearchBottomSheet({
    required this.trainers,
    required this.loading,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> trainers;
  final bool loading;
  final ValueChanged<Map<String, dynamic>> onSelected;

  @override
  State<_TrainerSearchBottomSheet> createState() => _TrainerSearchBottomSheetState();
}

class _TrainerSearchBottomSheetState extends State<_TrainerSearchBottomSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.trainers.where((t) {
      final name = (t['trainer_name'] ?? '').toString().toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Trainer',
            style: AppStyles.text16Px.poppins.w600.dark,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search trainer by name...',
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _query = val;
              });
            },
          ),
          const SizedBox(height: 16),
          if (widget.loading)
            const Center(child: CircularProgressIndicator()).pad(20)
          else if (filtered.isEmpty)
            Center(
              child: Text(
                'No trainers found',
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ),
            ).pad(20)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final trainer = filtered[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xffFFEAEA),
                      child: Text(
                        (trainer['trainer_name'] ?? 'T').toString().substring(0, 1).toUpperCase(),
                        style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      trainer['trainer_name'] ?? '',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                    onTap: () => widget.onSelected(trainer),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
