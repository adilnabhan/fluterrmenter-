import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_main_screen.dart';

class OrganizationSelectionSheet extends StatefulWidget {
  const OrganizationSelectionSheet({super.key});

  Future<void> show(
    BuildContext context,
    OrganizationListingAndDetailsCubit cubit,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => BlocProvider.value(value: cubit, child: this),
    );
  }

  @override
  State<OrganizationSelectionSheet> createState() =>
      _OrganizationSelectionSheetState();
}

class _OrganizationSelectionSheetState extends State<OrganizationSelectionSheet>
    with SingleTickerProviderStateMixin {
  late final OrganizationListingAndDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Accounts', style: AppStyles.text18Px.poppins.w600.dark),
            IconButton(
              onPressed: context.pop,
              icon: const Icon(Icons.close, color: AppColors.textGrey),
            ),
          ],
        ),
        Flexible(
          child: BlocBuilder<
            OrganizationListingAndDetailsCubit,
            OrganizationListingAndDetailsState
          >(
            buildWhen: (previous, current) => previous.list != current.list,
            bloc: _cubit,
            builder:
                (context, state) => state.list.fold(
                  () => const Center(child: CircularProgressIndicator()),
                  (
                    either,
                  ) => either.fold((error) => const Center(child: Text('Error')), (
                    orgsList,
                  ) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.disabledButton),
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          ...?orgsList.result?.map((org) {
                            return Column(
                              children: [
                                InkWell(
                                  overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  onTap: () {
                                    _cubit.selectOrganization(org);
                                    context.pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox.square(
                                          dimension: 48,
                                          child: AbsorbPointer(
                                            child: ProfileImage(
                                              isEdit: false,
                                              radius: 48,
                                              url: org.logo ?? '',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          org.name ?? '',
                                          style: AppStyles.text14Px.dark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  thickness: 1,
                                  color: Color(0xffDDDDDD),
                                ),
                              ],
                            );
                          }),

                          ...(() {
                            final appState = context.watch<AppCubit>().state;
                            final rawAccounts = appState.accounts;
                            
                            final accounts = rawAccounts.fold<List<LoginSuccessModel>>([], (prev, acc) {
                              if (acc.userRole == 35 && !prev.any((a) => a.mobileNumber == acc.mobileNumber && a.userRole == acc.userRole)) {
                                prev.add(acc);
                              }
                              return prev;
                            });

                            return accounts.map((account) {
                              final roleLabel =
                                  account.userRole == 35
                                      ? 'Trainer'
                                      : 'Fitness Center Owner';
                              return Column(
                                children: [
                                  InkWell(
                                    overlayColor: const WidgetStatePropertyAll(
                                      Colors.transparent,
                                    ),
                                    onTap: () {
                                      context.read<AppCubit>().switchAccount(
                                        account,
                                      );
                                      final target =
                                          account.userRole == 35
                                              ? const TrainerMainScreen()
                                              : const OrganizationListingScreen();
                                      context.pushAndRemoveUntil(target);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox.square(
                                            dimension: 48,
                                            child: AbsorbPointer(
                                              child: ProfileImage(
                                                isEdit: false,
                                                radius: 48,
                                                url:
                                                    account.profilePicture
                                                        as String? ??
                                                    '',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${account.firstName ?? ""} ${account.lastName ?? ""}'
                                                          .trim()
                                                          .isNotEmpty
                                                      ? '${account.firstName ?? ""} ${account.lastName ?? ""}'
                                                          .trim()
                                                      : (account.mobileNumber ??
                                                          'User'),
                                                  style: AppStyles.text14Px.dark,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  roleLabel,
                                                  style: AppStyles
                                                      .text12Px
                                                      .poppins
                                                      .w400
                                                      .copyWith(
                                                        color: AppColors.textGrey,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.logout, color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Logout Account'),
                                                  content: const Text('Are you sure you want to logout from this account?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(ctx),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                        context.read<AppCubit>().removeSpecificAccount(account);
                                                      },
                                                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0xffDDDDDD),
                                  ),
                                ],
                              );
                            });
                          }()),

                          ///* Add button
                          InkWell(
                            onTap: () {
                              context
                                ..pop()
                                ..push(const SentOtpScreen());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Add Account',
                                    style: AppStyles.text14Px.dark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
          ),
        ),
      ],
    ).pad(16).pOnly(bottom: 32);
  }
}
