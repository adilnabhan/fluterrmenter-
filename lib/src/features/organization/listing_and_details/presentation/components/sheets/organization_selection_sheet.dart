import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/client_attendance_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_assigned_workouts_screen.dart';
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
                    final appCubit = context.read<AppCubit>();
                    final current = appCubit.state.currentUser;
                    final isOwner = current != null && (current.userRole == 34 || current.userRole == 20 || current.userRole != 35);
                    if (isOwner && orgsList.result != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        for (final org in orgsList.result!) {
                          final exists = appCubit.state.accounts.any((a) =>
                              (a.userRole == 34 || a.userRole == 20 || a.userRole != 35) &&
                              (a.mentor?.org?.id == org.id || a.organizationId == org.id));
                          if (!exists) {
                            final orgAccount = current.copyWith(
                              organizationId: org.id,
                              organizationName: org.name,
                              profilePicture: org.logo ?? current.profilePicture,
                              mentor: current.mentor?.copyWith(
                                org: current.mentor?.org?.copyWith(
                                  id: org.id,
                                  name: org.name,
                                ) ?? Org(id: org.id, name: org.name),
                              ) ?? Mentor(id: org.id, name: org.name, org: Org(id: org.id, name: org.name)),
                            );
                            appCubit.addUser(orgAccount);
                          }
                        }
                      });
                    }

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
                                    if (isOwner) {
                                      final updatedOrgUser = current.copyWith(
                                        organizationId: org.id,
                                        organizationName: org.name,
                                        profilePicture: org.logo ?? current.profilePicture,
                                        mentor: current.mentor?.copyWith(
                                          org: current.mentor?.org?.copyWith(
                                            id: org.id,
                                            name: org.name,
                                          ) ?? Org(id: org.id, name: org.name),
                                        ) ?? Mentor(id: org.id, name: org.name, org: Org(id: org.id, name: org.name)),
                                      );
                                      appCubit.addUser(updatedOrgUser);
                                    }
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
                              final isTrainer = acc.userRole == 35;
                              final orgId = acc.organizationId ?? acc.mentor?.org?.id;
                              final isAlreadyInCurrentOrgs = !isTrainer &&
                                  (orgsList.result?.any((org) => org.id == orgId) ?? false);

                              if (!isAlreadyInCurrentOrgs) {
                                final key = isTrainer
                                    ? '${acc.mobileNumber}_${acc.userRole}'
                                    : '${acc.mobileNumber}_${acc.userRole}_$orgId';
                                if (!prev.any((a) {
                                  final aOrgId = a.organizationId ?? a.mentor?.org?.id;
                                  final aKey = a.userRole == 35
                                      ? '${a.mobileNumber}_${a.userRole}'
                                      : '${a.mobileNumber}_${a.userRole}_$aOrgId';
                                  return aKey == key;
                                })) {
                                  prev.add(acc);
                                }
                              }
                              return prev;
                            });

                            return accounts.map((account) {
                              final isOwnerAccount = account.userRole == 34 ||
                                  account.userRole == 20 ||
                                  account.userRole != 35;
                              final roleLabel = account.userRole == 35
                                  ? 'Trainer'
                                  : 'Fitness Center Owner';

                              final String profilePic = (account.profilePicture != null &&
                                      account.profilePicture.toString().trim().isNotEmpty &&
                                      account.profilePicture.toString().trim() != 'null')
                                  ? account.profilePicture.toString().trim()
                                  : '';

                              final String displayName = isOwnerAccount
                                  ? ((account.organizationName != null &&
                                          account.organizationName!.isNotEmpty &&
                                          account.organizationName != 'null')
                                      ? account.organizationName!
                                      : ((account.mentor?.org?.name != null &&
                                              account.mentor!.org!.name!.isNotEmpty &&
                                              account.mentor!.org!.name != 'null')
                                          ? account.mentor!.org!.name!
                                          : ('${account.firstName ?? ""} ${account.lastName ?? ""}'.trim().isNotEmpty
                                              ? '${account.firstName ?? ""} ${account.lastName ?? ""}'.trim()
                                              : (account.mobileNumber ?? 'User'))))
                                  : ('${account.firstName ?? ""} ${account.lastName ?? ""}'.trim().isNotEmpty
                                      ? '${account.firstName ?? ""} ${account.lastName ?? ""}'.trim()
                                      : (account.mobileNumber ?? 'User'));

                              return Column(
                                children: [
                                  InkWell(
                                    overlayColor: const WidgetStatePropertyAll(
                                      Colors.transparent,
                                    ),
                                    onTap: () {
                                      ClientAttendanceScreen.clearCache();
                                      TrainerAssignedWorkoutsScreen.clearCache();
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
                                                url: profilePic,
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
                                                  displayName,
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
