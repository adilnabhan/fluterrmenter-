import 'package:mentor_mobile_app/imports_bindings.dart';

class BankListingViewScreen extends StatelessWidget {
  const BankListingViewScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembershipCubit(orgId: '${orgDetails.id!}'),
      child: _BankListingViewScreen(orgDetails: orgDetails),
    );
  }
}

class _BankListingViewScreen extends StatefulWidget {
  const _BankListingViewScreen({required this.orgDetails});

  final OrganizationDetailsModel orgDetails;

  @override
  State<_BankListingViewScreen> createState() => __BankListingViewScreenState();
}

class __BankListingViewScreenState extends State<_BankListingViewScreen> {
  late final MembershipCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchBankAccountList();
  }

  Future<void> _onDeleteBank({int? id}) async {
    if (id == null) return;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<MembershipCubit, MembershipState>(
          bloc: _cubit,
          builder: (context, state) {
            final isLoading = state.isDeleting;
            return PopScope(
              canPop: !isLoading,
              child: AlertDialog(
                title: const Text('Delete Bank'),
                content: const Text(
                  'Are you sure you want to delete this bank account?',
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              await _cubit.deleteMembershipPackage(id: id);
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              _fetch();
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembershipCubit, MembershipState>(
      bloc: _cubit,
      listenWhen: (p, c) => p.createOrUpdateBank != c.createOrUpdateBank,
      listener: (context, state) {
        state.createOrUpdateBank?.fold(
          () {},
          (either) => either.fold((l) {}, (r) => _fetch()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text('Bank Accounts', style: AppStyles.text16Px.poppins.w500),
        ),
        body: Column(
          children: [
            BlocBuilder<MembershipCubit, MembershipState>(
              builder: (context, state) {
                bool hasBankData = state.bankDetails.fold(
                  () => false, // None → no data
                  (either) => either.fold(
                    (error) => false, // Error → treat as no data
                    (data) => true, // Success → data exists
                  ),
                );

                if (hasBankData) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    Text(
                      'Add Bank Accounts',
                      style: AppStyles.text16Px.poppins.w500.dark,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        if (widget.orgDetails.id == null) {
                          Dialogs.showSnack(msg: 'Organization not found');
                          return;
                        }
                        context.push(
                          BlocProvider.value(
                            value: _cubit,
                            child: const AddEditBankAccountScreenView(),
                          ),
                        );
                      },
                      label: const Text('Add'),
                      icon: const Icon(Icons.add),
                      style: const ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          AppColors.primary,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xffFFEAEA),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MembershipCubit, MembershipState>(
                buildWhen: (p, c) => p.bankDetails != c.bankDetails,
                builder: (context, state) {
                  return state.bankDetails.fold(
                    () => const Center(child: CircularProgressIndicator()),
                    (either) => either.fold(
                      (error) => error.maybeWhen(
                        network: (e) => ErrorUi.network(onTap: _fetch),
                        notFound: (e) => ErrorUi.empty().center,
                        orElse: () => ErrorUi.server(onTap: _fetch),
                      ),
                      (data) {
                        // BankDetailsModel bankData=data;
                        // if (bankData.accountNumber) {
                        //   return ErrorUi.empty().center;
                        // }
                        return RefreshIndicator(
                          onRefresh: _fetch,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.light,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data.bankName,
                                        style:
                                            AppStyles
                                                .text14Px
                                                .poppins
                                                .w600
                                                .dark,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        context.push(
                                          BlocProvider.value(
                                            value: _cubit,
                                            child: AddEditBankAccountScreenView(
                                              bankDetails: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // IconButton(
                                    //   icon: const Icon(Icons.delete),
                                    //   onPressed: () {},
                                    //   // () => _onDeleteBank(id: bank?.id),
                                    // ),
                                  ],
                                ),
                                const Divider(color: Color(0xffDDDDDD)),
                                const SizedBox(height: 8),
                                _buildRow(
                                  'Account Holder',
                                  data.accountHolderName,
                                ),
                                _buildRow('Account Number', data.accountNumber),
                                _buildRow('IFSC Code', data.ifscCode),
                                _buildRow('Branch', data.branchName),
                                _buildRow('PAN Number', data.panNumber),
                                _buildRow('DOB', data.panNumber),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ).pad(16),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.text13Px.poppins.w400.dark),
        Text(value ?? '-', style: AppStyles.text14Px.poppins.w500.dark),
      ],
    ).pOnly(bottom: 8);
  }
}
