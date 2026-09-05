import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_main_screen.dart';

class AccountSwitcherSheet extends StatefulWidget {
  const AccountSwitcherSheet({super.key});

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => this,
    );
  }

  @override
  State<AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<AccountSwitcherSheet> {
  final Map<String, String> _ownerOrgNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOwnerGymNames();
    });
  }

  /// Refreshes the access token for a specific account using its refresh token.
  /// Returns the new access token, or null if refresh failed.
  Future<String?> _refreshAccessToken(LoginSuccessModel account) async {
    final refreshToken = account.refresh;
    if (refreshToken == null || refreshToken.isEmpty) {
      print('❌ _refreshAccessToken: No refresh token for account id=${account.id}');
      return null;
    }

    try {
      print('🔄 _refreshAccessToken: Attempting token refresh for account id=${account.id}...');
      final dio = Dio();
      final res = await dio.post<dynamic>(
        ApiUris.tokenRefresh,
        data: {
          'refresh': refreshToken,
          'refresh_token': refreshToken,
        },
        options: Options(
          validateStatus: (_) => true,
          headers: {'X-Platform': platformSource},
        ),
      );
      print('🔄 _refreshAccessToken: Response code=${res.statusCode}, data=${res.data}');

      Map<String, dynamic>? dataMap;
      if (res.data is Map) {
        dataMap = Map<String, dynamic>.from(res.data as Map);
      } else if (res.data is String) {
        try {
          dataMap = jsonDecode(res.data as String) as Map<String, dynamic>;
        } catch (_) {}
      }

      if (dataMap != null) {
        final nestedData = dataMap['data'] is Map ? dataMap['data'] as Map : null;
        final newAccess = (dataMap['access'] ??
                dataMap['accessToken'] ??
                dataMap['access_token'] ??
                dataMap['token'] ??
                nestedData?['access'] ??
                nestedData?['access_token'])
            ?.toString();
        final newRefresh = (dataMap['refresh'] ??
                dataMap['refreshToken'] ??
                dataMap['refresh_token'] ??
                nestedData?['refresh'] ??
                nestedData?['refresh_token'])
            ?.toString();

        if (newAccess != null && newAccess.isNotEmpty) {
          print('✅ _refreshAccessToken: New access token received for account id=${account.id}');
          if (mounted) {
            final appCubit = context.read<AppCubit>();
            final updatedUser = account.copyWith(
              access: newAccess,
              refresh: newRefresh ?? refreshToken,
            );
            appCubit.updateAccount(updatedUser);
          }
          return newAccess;
        }
      }
    } catch (e) {
      print('❌ Failed to refresh token for account ${account.id}: $e');
    }
    return null;
  }

  Future<void> _refreshOwnerGymNames() async {
    if (!mounted) return;
    final appCubit = context.read<AppCubit>();
    final accounts = List<LoginSuccessModel>.from(appCubit.state.accounts);
    print('🏢 _refreshOwnerGymNames: Checking ${accounts.length} accounts...');

    bool hasChanges = false;
    for (final account in accounts) {
      print('🏢 Account: id=${account.id}, role=${account.userRole}, name="${account.firstName} ${account.lastName}", orgName="${account.organizationName}", mentorOrg="${account.mentor?.org?.name}"');
      final isOwner = account.userRole == 34 || account.userRole == 20 || account.userRole != 35;
      if (isOwner) {
        try {
          var token = account.access;
          if (token == null || token.isEmpty) {
            print('⚠️ Owner account has no access token, trying refresh token...');
            token = await _refreshAccessToken(account);
            if (token == null || token.isEmpty) {
              print('❌ Token refresh returned null for owner account ${account.id}');
              continue;
            }
          }

          final dio = Dio();

          // Try fetching org list with current token
          print('🏢 Fetching org list for owner ${account.id} with token: ${token.substring(0, min(15, token.length))}...');
          var res = await dio.get<dynamic>(
            ApiUris.listOrganizations,
            options: Options(
              validateStatus: (_) => true, // don't throw on 401
              headers: {
                'Authorization': 'JWT $token',
                'X-Platform': platformSource,
              },
            ),
          );
          print('🏢 Org list response status=${res.statusCode}, data=${res.data}');

          // If 401 (expired token), refresh and retry
          if (res.statusCode == 401) {
            print('🔄 Token expired (401) for owner account ${account.id}, refreshing...');
            final newToken = await _refreshAccessToken(account);
            if (newToken != null) {
              token = newToken;
              res = await dio.get<dynamic>(
                ApiUris.listOrganizations,
                options: Options(
                  validateStatus: (_) => true,
                  headers: {
                    'Authorization': 'JWT $token',
                    'X-Platform': platformSource,
                  },
                ),
              );
              print('🏢 Retry org list response status=${res.statusCode}, data=${res.data}');
            } else {
              print('❌ Token refresh failed for account ${account.id}');
              continue;
            }
          }

          if (res.statusCode == 200 && res.data != null) {
            var data = res.data;
            if (data is String) {
              try {
                data = jsonDecode(data);
              } catch (_) {}
            }

            final List result = (data is Map && data['result'] is List)
                ? (data['result'] as List)
                : (data is List
                    ? data
                    : (data is Map && data['data'] is List ? data['data'] as List : []));

            if (result.isNotEmpty) {
              // Find matching org or default to first
              Map? matchedOrg;
              for (final org in result) {
                if (org is Map) {
                  final oId = org['id'] as int?;
                  if (oId != null &&
                      (account.organizationId == oId ||
                          account.mentor?.org?.id == oId)) {
                    matchedOrg = org;
                    break;
                  }
                }
              }
              matchedOrg ??= result.first as Map;

              final orgId = matchedOrg['id'] as int?;
              final orgName = matchedOrg['name']?.toString() ?? matchedOrg['organization_name']?.toString();
              final orgLogo = matchedOrg['logo']?.toString() ?? matchedOrg['organization_logo']?.toString();

              print('🏢 Found organization: id=$orgId, name="$orgName", logo="$orgLogo"');

              if (orgName != null && orgName.isNotEmpty) {
                _ownerOrgNames['${account.mobileNumber}_${account.userRole}'] = orgName;
                _ownerOrgNames['${account.id}_${account.userRole}'] = orgName;
                _ownerOrgNames['${account.id}'] = orgName;
                if (account.mobileNumber != null) {
                  _ownerOrgNames[account.mobileNumber!] = orgName;
                }
                hasChanges = true;

                // Re-read the latest account state
                if (mounted) {
                  final latestAccounts = appCubit.state.accounts;
                  final latestAccount = latestAccounts.firstWhere(
                    (a) => a.id == account.id && a.userRole == account.userRole,
                    orElse: () => account,
                  );

                  final updatedUser = latestAccount.copyWith(
                    organizationId: orgId ?? latestAccount.organizationId,
                    organizationName: orgName,
                    profilePicture: (orgLogo != null && orgLogo.isNotEmpty)
                        ? orgLogo
                        : latestAccount.profilePicture,
                    mentor: latestAccount.mentor?.copyWith(
                      org: Org(
                        id: orgId ?? latestAccount.mentor?.org?.id,
                        name: orgName,
                      ),
                    ) ?? Mentor(
                      id: orgId,
                      name: orgName,
                      org: Org(id: orgId, name: orgName),
                    ),
                  );
                  appCubit.updateAccount(updatedUser);
                }
              }
            }
          }
        } catch (e) {
          print('❌ Failed to auto-fetch org details for account: $e');
        }
      }
    }

    if (hasChanges && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.watch<AppCubit>();
    final currentUser = appCubit.state.currentUser;
    final rawAccounts = appCubit.state.accounts;
    final accounts = rawAccounts.fold<List<LoginSuccessModel>>([], (prev, acc) {
      final isOwner = acc.userRole == 34 || acc.userRole == 20 || acc.userRole != 35;
      final orgKey = isOwner
          ? (acc.mentor?.org?.id?.toString() ?? acc.organizationId?.toString() ?? acc.mentor?.org?.name ?? '')
          : '';
      if (!prev.any((a) {
        final aIsOwner = a.userRole == 34 || a.userRole == 20 || a.userRole != 35;
        final aOrgKey = aIsOwner
            ? (a.mentor?.org?.id?.toString() ?? a.organizationId?.toString() ?? a.mentor?.org?.name ?? '')
            : '';
        return a.mobileNumber == acc.mobileNumber &&
            a.userRole == acc.userRole &&
            (!isOwner || aOrgKey == orgKey);
      })) {
        prev.add(acc);
      }
      return prev;
    });

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.colors.icon),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.fieldFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
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
                    final isOwner = account.userRole == 34 || account.userRole == 20 || account.userRole != 35;
                    final isActive = currentUser != null &&
                        account.id == currentUser.id &&
                        account.userRole == currentUser.userRole &&
                        (!isOwner ||
                            (account.mentor?.org?.id ?? account.organizationId) ==
                                (currentUser.mentor?.org?.id ?? currentUser.organizationId));

                    final key = '${account.mobileNumber}_${account.userRole}';
                    final idKey = '${account.id}_${account.userRole}';
                    final cachedOrgName = _ownerOrgNames[key] ??
                        _ownerOrgNames[idKey] ??
                        _ownerOrgNames['${account.id}'] ??
                        _ownerOrgNames[account.mobileNumber ?? ''];

                    final String name = isOwner
                        ? ((cachedOrgName != null && cachedOrgName.isNotEmpty)
                            ? cachedOrgName
                            : ((account.organizationName != null &&
                                    account.organizationName!.isNotEmpty &&
                                    account.organizationName != 'null')
                                ? account.organizationName!
                                : ((account.mentor?.org?.name != null &&
                                        account.mentor!.org!.name!.isNotEmpty &&
                                        account.mentor!.org!.name != 'null')
                                    ? account.mentor!.org!.name!
                                    : '${account.firstName ?? ""} ${account.lastName ?? ""}'.trim())))
                        : '${account.firstName ?? ""} ${account.lastName ?? ""}'.trim();
                    final displayName = name.isNotEmpty ? name : (account.mobileNumber ?? 'User');
                    final roleLabel = account.userRole == 35
                        ? 'Trainer'
                        : 'Fitness Center Owner';

                    final activeUserPic = (isActive && currentUser?.profilePicture != null)
                        ? currentUser!.profilePicture.toString()
                        : null;
                    final accountPic = account.profilePicture?.toString();

                    final String profilePicUrl = [
                      activeUserPic,
                      accountPic,
                    ].firstWhere(
                      (url) => url != null && url.trim().isNotEmpty && url.trim() != 'null',
                      orElse: () => '',
                    )!;

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
                                      url: profilePicUrl,
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
                                        style: AppStyles.text14Px.copyWith(
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        roleLabel,
                                        style: AppStyles.text12Px.poppins.w400.copyWith(
                                          color: context.colors.textSecondary,
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
                        Divider(
                          thickness: 1,
                          color: context.colors.divider,
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
                            style: AppStyles.text14Px.copyWith(
                              color: context.colors.textPrimary,
                            ),
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
