import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/member_orboard_payment_successfull_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AddCustomerSearchScreen extends StatefulWidget {
  final int orgId;
  const AddCustomerSearchScreen({super.key, required this.orgId});

  @override
  State<AddCustomerSearchScreen> createState() => _AddCustomerSearchScreenState();
}

class _AddCustomerSearchScreenState extends State<AddCustomerSearchScreen> {
  late MembersAndLeadsCubit _cubit;
  late MembershipCubit _membershipCubit;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _amountReceivedController = TextEditingController(text: '0');
  
  Timer? _debounce;
  MembershipPackageModel? _selectedPlan;
  String _paymentMethod = 'Cash';
  DateTime _startDate = DateTime.now();
  MemberDetailsModel? _manualMemberDetails;

  final List<String> _paymentMethods = ['Cash', 'UPI', 'Debit Card', 'Credit Card', 'Net Banking'];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _membershipCubit = context.read<MembershipCubit>();
    _membershipCubit.fetchMembershipPackages();
    _cubit.clearSearchedCustomer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _amountReceivedController.dispose();
    _debounce?.cancel();
    super.dispose();
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
        (either) => either.fold((l) {}, (r) => customerToAdd = r)
      );
    }

    if (customerToAdd == null) {
      Dialogs.showSnack(msg: 'Please search for a client or enter details manually.');
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
          ProfileImage(
            url: customer.profilePicture,
            radius: 30,
            isEdit: false,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (customer.fullName?.isNotEmpty ?? false) 
                    ? customer.fullName! 
                    : '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim().isEmpty 
                        ? 'Unknown' 
                        : '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim(),
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                Text(
                  customer.mobileNumber ?? '',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (customer.gender != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          customer.gender![0].toUpperCase() + customer.gender!.substring(1),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
        ],
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
              Text('Fill details', style: AppStyles.text20Px.poppins.w600.dark),
              const SizedBox(height: 24),
              
              if (_manualMemberDetails == null) ...[
                Text('Search Client by number', style: AppStyles.text14Px.poppins.w500.dark),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Search Client',
                    hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderGrey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("Client doesn't have Discipl app? ", style: AppStyles.text12Px.poppins.w400.textGrey),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
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
                      child: Text('Click here', style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.primary, decoration: TextDecoration.underline)),
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
                                child: Text('This number is not registered in customer app', style: AppStyles.text12Px.poppins.w500.copyWith(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 32,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final number = _searchController.text.trim();
                                    final message = Uri.encodeComponent("Hi! Please download the Discipl Customer app to proceed.");
                                    launchUrl(
                                      Uri.parse('https://wa.me/$number?text=$message'),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/images/svg/icons/whatsapp.svg',
                                    height: 16,
                                    width: 16,
                                    colorFilter: const ColorFilter.mode(Color(0xFF25D366), BlendMode.srcIn),
                                  ),
                                  label: Text('Invite', style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF25D366))),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        (customer) => _buildProfileCard(customer),
                      ),
                    ) ?? const SizedBox.shrink();
                  },
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Manual Entry Mode', style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.green)),
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
              RichText(
                text: TextSpan(
                  text: 'Select a Plan',
                  style: AppStyles.text14Px.poppins.w500.dark,
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<MembershipCubit, MembershipState>(
                bloc: _membershipCubit,
                buildWhen: (p, c) => p.membershipPackages != c.membershipPackages,
                builder: (context, state) {
                  return state.membershipPackages.fold(
                    () => const CircularProgressIndicator(),
                    (either) => either.fold(
                      (l) => const Text('Error loading plans'),
                      (data) {
                        final plans = data.results ?? [];
                        return DropdownButtonFormField<MembershipPackageModel>(
                          value: _selectedPlan,
                          hint: const Text('Select Plan'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderGrey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: plans.map((plan) {
                            return DropdownMenuItem(
                              value: plan,
                              child: Text(plan.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlan = value;
                              if (value != null) {
                                _amountReceivedController.text = value.offerPrice ?? value.actualPrice ?? '0';
                              }
                            });
                          },
                        );
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
                        Text('Discount Amount', style: AppStyles.text14Px.poppins.w500.dark),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderGrey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        RichText(
                          text: TextSpan(
                            text: 'Amount Received',
                            style: AppStyles.text14Px.poppins.w500.dark,
                            children: const [
                              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountReceivedController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderGrey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  text: 'Payment Method',
                  style: AppStyles.text14Px.poppins.w500.dark,
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _paymentMethods.map((method) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 55) / 2,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _paymentMethod = method;
                        });
                      },
                      child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _paymentMethod == method ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _paymentMethod == method ? AppColors.primary : AppColors.textGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPaymentMethodColor(method),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            method,
                            style: AppStyles.text12Px.poppins.w500.dark,
                          ),
                        ),
                      ],
                    ),
                  ));
                }).toList(),
              ),

              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  text: 'Membership Start Date',
                  style: AppStyles.text14Px.poppins.w500.dark,
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(_startDate), style: AppStyles.text14Px.poppins.w400.dark),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
                buildWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
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

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'Cash':
        return const Color(0xffB5FFC0);
      case 'UPI':
        return const Color(0xffC6D2FF);
      case 'Debit Card':
        return const Color(0xffFFE6B5);
      case 'Credit Card':
        return const Color(0xffE6C6FF);
      case 'Net Banking':
        return const Color(0xffB5F0FF);
      default:
        return const Color(0xffF5F5F5);
    }
  }
}
