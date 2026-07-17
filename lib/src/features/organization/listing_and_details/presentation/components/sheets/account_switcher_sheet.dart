import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_main_screen.dart';

class AccountSwitcherSheet extends StatelessWidget {
  const AccountSwitcherSheet({super.key});

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.watch<AppCubit>();
    final currentUser = appCubit.state.currentUser;
    final rawAccounts = appCubit.state.accounts;
    final accounts = rawAccounts.fold<List<LoginSuccessModel>>([], (prev, acc) {
      if (!prev.any((a) => 
          a.mobileNumber == acc.mobileNumber && 
          a.userRole == acc.userRole &&
          a.mentor?.org?.id == acc.mentor?.org?.id)) {
        prev.add(acc);
      }
      return prev;
    });

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accounts',
                style: AppStyles.text18Px.poppins.w600.dark,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.disabledButton),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  ...accounts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final account = entry.value;
                    final isActive = currentUser != null &&
                        account.id == currentUser.id &&
                        account.userRole == currentUser.userRole &&
                        account.mentor?.org?.id == currentUser.mentor?.org?.id;

                    final String name = account.userRole == 34 && account.mentor?.org?.name?.isNotEmpty == true
                        ? account.mentor!.org!.name!
                        : '${account.firstName ?? ""} ${account.lastName ?? ""}'.trim();
                    final displayName = name.isNotEmpty ? name : (account.mobileNumber ?? 'User');
                    final roleLabel = account.userRole == 35
                        ? 'Trainer'
                        : 'Fitness Center Owner';

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            if (!isActive) {
                              appCubit.switchAccount(account);
                              final target = account.userRole == 35
                                  ? const TrainerMainScreen()
                                  : const OrganizationListingScreen();
                              context.pushAndRemoveUntil(target);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                SizedBox.square(
                                  dimension: 48,
                                  child: IgnorePointer(
                                    child: ProfileImage(
                                      isEdit: false,
                                      radius: 48,
                                      url: account.profilePicture as String? ?? '',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: AppStyles.text14Px.dark,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        roleLabel,
                                        style: AppStyles.text12Px.poppins.w400.copyWith(
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isActive)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 24,
                                  )
                                else
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
                                                appCubit.removeSpecificAccount(account);
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
                  }),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const SentOtpScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
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
            ),
          ),
        ],
      ),
    );
  }
}
