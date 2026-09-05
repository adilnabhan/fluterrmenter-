import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/member_orboard_payment_successfull_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AddCustomerSearchScreen extends StatefulWidget {
  final int orgId;
  const AddCustomerSearchScreen({super.key, required this.orgId});

  @override
  State<AddCustomerSearchScreen> createState() =>
      _AddCustomerSearchScreenState();
}

class _AddCustomerSearchScreenState extends State<AddCustomerSearchScreen> {
  late MembersAndLeadsCubit _cubit;
  late MembershipCubit _membershipCubit;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _amountReceivedController = TextEditingController(
    text: '0',
  );

  Timer? _debounce;
  MembershipPackageModel? _selectedPlan;
  bool _isPlanDropdownOpen = false;
  String _paymentMethod = 'Cash';
  DateTime _startDate = DateTime.now();
  MemberDetailsModel? _manualMemberDetails;

  final List<String> _paymentMethods = [
    'Cash',
    'UPI',
    'Debit Card',
    'Credit Card',
    'Net Banking',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _membershipCubit = context.read<MembershipCubit>();
    _membershipCubit.fetchMembershipPackages();
    _cubit.clearSearchedCustomer();
    _discountController.addListener(_updateAmountToPay);
  }

  @override
  void dispose() {
    _discountController.removeListener(_updateAmountToPay);
    _searchController.dispose();
    _discountController.dispose();
    _amountReceivedController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _updateAmountToPay() {
    if (_selectedPlan == null) return;
    final rawPrice = double.tryParse(
          _selectedPlan?.offerPrice ?? _selectedPlan?.actualPrice ?? '0',
        ) ??
        0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final finalAmount = (rawPrice - discount).clamp(0.0, double.infinity);

    final formattedAmount =
        finalAmount == finalAmount.toInt()
            ? finalAmount.toInt().toString()
            : finalAmount.toStringAsFixed(2);

    if (_amountReceivedController.text != formattedAmount) {
      _amountReceivedController.text = formattedAmount;
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 10) {
        // Assume at least 10 digits for a valid number search
        _cubit.searchCustomerByNumber(value.trim());
      } else {
        _cubit.clearSearchedCustomer();
      }
    });
  }

  void _submit() {
    if (_cubit.state.createOrUpdateMember?.isNone() ?? false) {
      Dialogs.showSnack(msg: 'Please wait');
      return;
    }

    // Determine the customer to add
    MemberDetailsModel? customerToAdd;
    if (_manualMemberDetails != null) {
      customerToAdd = _manualMemberDetails;
    } else {
      final searchResult = _cubit.state.searchedCustomer;
      searchResult?.fold(
        () {},
        (either) => either.fold((l) {}, (r) => customerToAdd = r),
      );
    }

    if (customerToAdd == null) {
      Dialogs.showSnack(
        msg: 'Please search for a client or enter details manually.',
      );
      return;
    }

    if (_selectedPlan == null) {
      Dialogs.showSnack(msg: 'Please select a membership plan.');
      return;
    }

    double? discount = double.tryParse(_discountController.text);
    double? amountReceived = double.tryParse(_amountReceivedController.text);

    if (amountReceived == null) {
      Dialogs.showSnack(msg: 'Please enter a valid amount received.');
      return;
    }

    _cubit.cerateOrUpdateMemberDetails(
      memeberDetails: customerToAdd!,
      membershipPackageModel: _selectedPlan!,
      discountAmount: discount,
      amountReceived: amountReceived,
      paymentMethod: _paymentMethod,
      membershipStartDate: DateFormat('yyyy-MM-dd').format(_startDate),
      memberId: customerToAdd!.id, // Will be null if it's a new manual user
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Widget _buildProfileCard(MemberDetailsModel customer) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileImage(url: customer.profilePicture, radius: 30, isEdit: false),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (customer.fullName?.isNotEmpty ?? false)
                      ? customer.fullName!
                      : '${customer.firstName ?? ''} ${customer.lastName ?? ''}'
                          .trim()
                          .isEmpty
                      ? 'Unknown'
                      : '${customer.firstName ?? ''} ${customer.lastName ?? ''}'
                          .trim(),
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                Text(
                  customer.mobileNumber ?? '',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (customer.gender != null &&
                        customer.gender!.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          customer.gender!.trim()[0].toUpperCase() +
                              customer.gender!.trim().substring(1),
                          style: AppStyles.text12Px.poppins.w500.textGrey,
                        ),
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

  Widget _buildFieldCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _fieldInputDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: const Text('Add Client'),
      ),
      body: BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
        listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
        listener: (context, state) {
          state.createOrUpdateMember?.fold(() => null, (t) {
            return t.fold(
              (l) {
                Dialogs.showSnack(msg: l.msg);
              },
              (r) {
                Dialogs.showSnack(msg: 'Member added successfully');
                context.pushReplacement(
                  BlocProvider.value(
                    value: _cubit,
                    child: const MemberOnboardPaymentSuccessScreen(),
                  ),
                );
              },
            );
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fill details',
                style: AppStyles.text20Px.poppins.w600.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              if (_manualMemberDetails == null) ...[
                Text(
                  'Search Client by number',
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFieldCard(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    keyboardType: TextInputType.phone,
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                    decoration: _fieldInputDecoration(
                      hintText: 'Search Client',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Icon(
                          Icons.search,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Client doesn't have Discipl app? ",
                      style: AppStyles.text12Px.poppins.w400.textGrey,
                    ),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BlocProvider.value(
                                  value: _cubit,
                                  child: AddOrEditMemeberScreen(
                                    orgId: widget.orgId,
                                    isFromSearch: true,
                                  ),
                                ),
                          ),
                        );
                        if (result != null && result is MemberDetailsModel) {
                          setState(() {
                            _manualMemberDetails = result;
                          });
                        }
                      },
                      child: Text(
                        'Click here',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                  buildWhen: (p, c) => p.searchedCustomer != c.searchedCustomer,
                  builder: (context, state) {
                    return state.searchedCustomer?.fold(
                          () => const SizedBox.shrink(),
                          (either) => either.fold(
                            (l) => Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'This number is not registered in customer app',
                                      style: AppStyles.text12Px.poppins.w500
                                          .copyWith(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 32,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final number =
                                            _searchController.text.trim();
                                        final message = Uri.encodeComponent(
                                          "Hi! Please download the Discipl Customer app to proceed.",
                                        );
                                        launchUrl(
                                          Uri.parse(
                                            'https://wa.me/$number?text=$message',
                                          ),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/images/svg/icons/whatsapp.svg',
                                        height: 16,
                                        width: 16,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF25D366),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      label: Text(
                                        'Invite',
                                        style: AppStyles.text12Px.poppins.w600
                                            .copyWith(
                                              color: const Color(0xFF25D366),
                                            ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Color(0xFF25D366),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            (customer) => _buildProfileCard(customer),
                          ),
                        ) ??
                        const SizedBox.shrink();
                  },
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manual Entry Mode',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _manualMemberDetails = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                _buildProfileCard(_manualMemberDetails!),
              ],

              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Select Plan',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlocBuilder<MembershipCubit, MembershipState>(
                bloc: _membershipCubit,
                buildWhen:
                    (p, c) => p.membershipPackages != c.membershipPackages,
                builder: (context, state) {
                  return state.membershipPackages.fold(
                    () => const CircularProgressIndicator(),
                    (either) => either.fold(
                      (l) => const Text('Error loading plans'),
                      (data) {
                        final plans = data.results ?? [];
                        return _buildPlanSelector(plans);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discount',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFieldCard(
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: Colors.black87,
                            ),
                            decoration: _fieldInputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 6,
                                ),
                                child: Text(
                                  '₹',
                                  style: AppStyles.text14Px.poppins.w500.textGrey,
                                ),
                              ),
                            ),
                          ),
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
                          'Amount to Pay',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFieldCard(
                          child: TextField(
                            controller: _amountReceivedController,
                            keyboardType: TextInputType.number,
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: Colors.black87,
                            ),
                            decoration: _fieldInputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 6,
                                ),
                                child: Text(
                                  '₹',
                                  style: AppStyles.text14Px.poppins.w500.textGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Payment Method',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    _paymentMethods.map((method) {
                      return _buildPaymentMethodPill(method);
                    }).toList(),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Start Date',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffD0D5DD)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.black87,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen:
                    (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
                builder: (context, state) {
                  return Button.filled(
                    size: Size(double.maxFinite, 42.h),
                    title: 'Add Member',
                    isLoading: state.createOrUpdateMember?.isNone() ?? false,
                    buttonColor: AppColors.primary,
                    ontap: _submit,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelector(List<MembershipPackageModel> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isPlanDropdownOpen = !_isPlanDropdownOpen;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffD0D5DD)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedPlan?.name ?? 'Select Plan',
                    style: _selectedPlan != null
                        ? AppStyles.text14Px.poppins.w500.copyWith(
                            color: Colors.black87,
                          )
                        : AppStyles.text14Px.poppins.w400.textGrey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isPlanDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),
        if (_isPlanDropdownOpen) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffD0D5DD)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: plans.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Color(0xffEEEEEE),
                ),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = _selectedPlan?.id == plan.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan;
                        _isPlanDropdownOpen = false;
                        _updateAmountToPay();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name ?? '',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodPill(String method) {
    final isSelected = _paymentMethod == method;
    final style = _getPaymentMethodStyle(method, isSelected);

    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: style.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: style.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: style.iconColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              method,
              style: AppStyles.text13Px.poppins.w500.copyWith(
                color: style.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color bgColor, Color borderColor, Color iconColor, Color textColor})
  _getPaymentMethodStyle(String method, bool isSelected) {
    switch (method) {
      case 'Cash':
        return (
          bgColor: const Color(0xFFE8F8EE),
          borderColor:
              isSelected ? const Color(0xFF27AE60) : const Color(0xFFD5F5E3),
          iconColor:
              isSelected ? const Color(0xFF27AE60) : Colors.grey.shade600,
          textColor: const Color(0xFF1E8449),
        );
      case 'UPI':
        return (
          bgColor: const Color(0xFFEBF5FB),
          borderColor:
              isSelected ? const Color(0xFF2980B9) : const Color(0xFFD4EFDF),
          iconColor:
              isSelected ? const Color(0xFF2980B9) : Colors.grey.shade600,
          textColor: const Color(0xFF2471A3),
        );
      case 'Debit Card':
        return (
          bgColor: const Color(0xFFFEF9E7),
          borderColor:
              isSelected ? const Color(0xFFF39C12) : const Color(0xFFFCF3CF),
          iconColor:
              isSelected ? const Color(0xFFF39C12) : Colors.grey.shade600,
          textColor: const Color(0xFFB7950B),
        );
      case 'Credit Card':
        return (
          bgColor: const Color(0xFFF5EEF8),
          borderColor:
              isSelected ? const Color(0xFF8E44AD) : const Color(0xFFE8DAEF),
          iconColor:
              isSelected ? const Color(0xFF8E44AD) : Colors.grey.shade600,
          textColor: const Color(0xFF7D3C98),
        );
      case 'Net Banking':
        return (
          bgColor: const Color(0xFFE8F8F5),
          borderColor:
              isSelected ? const Color(0xFF16A085) : const Color(0xFFA3E4D7),
          iconColor:
              isSelected ? const Color(0xFF16A085) : Colors.grey.shade600,
          textColor: const Color(0xFF117A65),
        );
      default:
        return (
          bgColor: const Color(0xFFF5F5F5),
          borderColor:
              isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
          iconColor: isSelected ? AppColors.primary : Colors.grey.shade600,
          textColor: AppColors.dark,
        );
    }
  }
}
