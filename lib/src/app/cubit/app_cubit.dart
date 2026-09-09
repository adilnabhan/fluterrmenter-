import 'package:mentor_mobile_app/imports_bindings.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(const AppState()) {
    _initFallback();
  }

  void _initFallback() {
    if (state.currentUser == null) {
      final localUser = LocalStorageService().getUser();
      if (localUser != null) {
        print('✅ AppCubit constructor: Restored user from Hive fallback (id=${localUser.id}, access=${localUser.access != null ? 'YES' : 'NULL'}).');
        final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
        if (!currentAccounts.any((a) => a.id == localUser.id && a.userRole == localUser.userRole)) {
          currentAccounts.add(localUser);
        }
        emit(state.copyWith(currentUser: localUser, accounts: currentAccounts));
      }
    }
  }

  bool _isRefreshing = false;

  //*
  Future<void> changeThemeMode(ThemeMode theme) async {
    //  await SessionService().storeTheme(theme);
    emit(state.copyWith(themeMode: theme));
    // await NotificationServices.createNotification(
    //   title: 'Theme Changed',
    //   body: 'Current theme mode is ${theme.name}',
    // );
  }

  //
  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  bool _isSameAccount(LoginSuccessModel a, LoginSuccessModel b) {
    if (a.userRole != b.userRole) return false;
    
    // For fitness center owners (role 20 or 34), distinguish by organization
    final aIsOwner = a.userRole == 34 || a.userRole == 20 || a.userRole != 35;
    final bIsOwner = b.userRole == 34 || b.userRole == 20 || b.userRole != 35;
    if (aIsOwner || bIsOwner) {
      final aOrgId = a.mentor?.org?.id ?? a.organizationId;
      final bOrgId = b.mentor?.org?.id ?? b.organizationId;
      if (aOrgId != null && bOrgId != null) {
        return aOrgId == bOrgId && a.mobileNumber == b.mobileNumber;
      }
      final aOrgName = a.mentor?.org?.name ?? a.organizationName;
      final bOrgName = b.mentor?.org?.name ?? b.organizationName;
      if (aOrgName != null && bOrgName != null && aOrgName.isNotEmpty && bOrgName.isNotEmpty) {
        return aOrgName.toLowerCase() == bOrgName.toLowerCase() && a.mobileNumber == b.mobileNumber;
      }
    }
    
    // For trainers (role 35) or general users
    return (a.id == b.id || a.mobileNumber == b.mobileNumber);
  }

  void addUser(LoginSuccessModel user) {
    LocalStorageService().saveUser(user);
    final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
    final existingIndex = currentAccounts.indexWhere(
      (a) => _isSameAccount(a, user),
    );
    if (existingIndex != -1) {
      currentAccounts[existingIndex] = user;
    } else {
      currentAccounts.add(user);
    }
    emit(state.copyWith(currentUser: user, accounts: currentAccounts));
    NotificationServices.registerDeviceToken();
  }

  void updateAccount(LoginSuccessModel user) {
    final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
    final existingIndex = currentAccounts.indexWhere(
      (a) => _isSameAccount(a, user),
    );
    if (existingIndex != -1) {
      currentAccounts[existingIndex] = user;
    } else {
      currentAccounts.add(user);
    }

    final isCurrentActive =
        state.currentUser != null && _isSameAccount(state.currentUser!, user);
    if (isCurrentActive) {
      LocalStorageService().saveUser(user);
      emit(state.copyWith(currentUser: user, accounts: currentAccounts));
    } else {
      emit(state.copyWith(accounts: currentAccounts));
    }
  }

  void switchAccount(LoginSuccessModel user) {
    LocalStorageService().saveUser(user);
    emit(state.copyWith(currentUser: user));
    NotificationServices.registerDeviceToken();
  }

  void removeUser() {
    final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
    final user = state.currentUser;
    if (user != null) {
      currentAccounts.removeWhere(
        (a) => _isSameAccount(a, user),
      );
    }

    if (currentAccounts.isNotEmpty) {
      final nextUser = currentAccounts.first;
      LocalStorageService().saveUser(nextUser);
      emit(state.copyWith(currentUser: nextUser, accounts: currentAccounts));
    } else {
      LocalStorageService().clearUser();
      emit(state.copyWith(currentUser: null, accounts: []));
    }
  }

  void removeSpecificAccount(LoginSuccessModel account) {
    final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
    currentAccounts.removeWhere(
      (a) => _isSameAccount(a, account),
    );
    emit(state.copyWith(accounts: currentAccounts));
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    print('🔍 AppCubit.fromJson called');
    print('🔍 json keys: ${json.keys.toList()}');
    print('🔍 currentUser in json: ${json['currentUser'] != null ? 'EXISTS' : 'NULL'}');
    print('🔍 accounts in json: ${json['accounts'] != null ? '${(json['accounts'] as List).length} accounts' : 'NULL'}');
    if (json['currentUser'] != null) {
      final u = json['currentUser'] as Map<String, dynamic>;
      print('🔍 stored access: ${u['access'] != null ? 'EXISTS (${u['access'].toString().substring(0, 10)}...)' : 'NULL'}');
      print('🔍 stored refresh: ${u['refresh'] != null ? 'EXISTS' : 'NULL'}');
    }

    var currentUser =
        json['currentUser'] != null
            ? LoginSuccessModel.fromJson(
              json['currentUser'] as Map<String, dynamic>,
            )
            : null;

    var accounts = json['accounts'] != null
        ? (json['accounts'] as List)
            .map((e) => LoginSuccessModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <LoginSuccessModel>[];

    if (accounts.isEmpty && currentUser != null) {
      accounts = [currentUser];
    }

    // 🛡️ Deduplicate accounts to fix duplicate entries while preserving distinct fitness centers
    final uniqueAccounts = <LoginSuccessModel>[];
    final seen = <String>{};
    for (final acc in accounts.reversed) {
      // Reverse to keep the latest added/updated account
      final isOwner = acc.userRole == 34 || acc.userRole == 20 || acc.userRole != 35;
      final orgKey = isOwner
          ? (acc.mentor?.org?.id?.toString() ?? acc.organizationId?.toString() ?? acc.mentor?.org?.name ?? '')
          : '';
      final key = '${acc.mobileNumber}_${acc.userRole}_$orgKey';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueAccounts.add(acc);
      }
    }
    accounts = uniqueAccounts.reversed.toList();

    // 🛡️ Fallback: Check Hive if HydratedBloc lost the user (e.g. cache cleared)
    if (currentUser == null) {
      print('⚠️ AppCubit: currentUser is NULL from HydratedCubit. Trying Hive fallback...');
      final localUser = LocalStorageService().getUser();
      print('⚠️ AppCubit: Hive user: ${localUser != null ? 'EXISTS (id=${localUser.id}, access=${localUser.access != null ? 'YES' : 'NULL'})' : 'NULL'}');
      if (localUser != null) {
        print('✅ AppCubit: Restored user from Hive storage.');
        currentUser = localUser;
        if (!accounts.any((a) => a.id == localUser.id && a.userRole == localUser.userRole)) {
          accounts.add(localUser);
        }
      }
    }

    // 🛡️ Fallback: If user exists but tokens are null, try recovering from Hive
    if (currentUser != null && (currentUser.access == null || currentUser.access!.isEmpty)) {
      final localUser = LocalStorageService().getUser();
      if (localUser != null && localUser.access != null && localUser.access!.isNotEmpty) {
        print('✅ AppCubit: Recovered tokens from Hive for user ${currentUser.id}.');
        currentUser = currentUser.copyWith(
          access: localUser.access,
          refresh: localUser.refresh ?? currentUser.refresh,
        );
        // Also update the account in the list
        final idx = accounts.indexWhere(
          (a) => a.id == currentUser!.id && a.userRole == currentUser!.userRole,
        );
        if (idx != -1) {
          accounts[idx] = currentUser!;
        }
      }
    }

    return AppState(
      themeMode: switch (json['theme_mode']) {
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      },
      locale: Locale(json['language_code'] as String? ?? 'en'),
      currentUser: currentUser,
      accounts: accounts,
    );
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    return {
      'theme_mode': state.themeMode.name,
      'language_code': state.locale.languageCode,
      'currentUser': state.currentUser?.toJson(),
      'accounts': state.accounts.map((e) => e.toJson()).toList(),
    };
  }

  Future<void> onboardingUpdate({
    required Map<String, dynamic> body,
    required int? id,
  }) async {
    try {
      final result = await AuthRepository().onboardingUpdate(
        body: body,
        id: id,
      );

      // Handle both success and failure properly
      result.fold(
        (failure) {
          // Emit error and stop loader
        },
        (r) {
          // Emit success and stop loader
          // addUser(r);
          // emit(
          //   state.copyWith(
          //     currentUser: r,
          //     // onboardingUser: some(right(r)),
          //   ),
          // );
        },
      );
    } catch (e) {
      // Catch unhandled exceptions and stop loader
    }
  }

  // ---------------- REFRESH TOKEN ----------------

  // Future<void> refreshToken() async {
  //   if (_isRefreshing) return;
  //   _isRefreshing = true;
  //   print('refresh token calling ---');
  //   final refreshToken = state.currentUser?.refresh;
  //
  //   if (refreshToken == null || refreshToken.isEmpty) {
  //     emit(state.copyWith(currentUser: null));
  //     _isRefreshing = false;
  //     return;
  //   }
  //
  //   final result = await AuthRepository().refreshToken(refreshToken);
  //
  //   result.fold(
  //         (error) {
  //       /// ❌ refresh failed → logout
  //       emit(state.copyWith(currentUser: null));
  //     },
  //         (data) {
  //       print('newly generated token is---${data['access']}');
  //       print('newly generated refresh is---${data['refresh']}');
  //
  //       final access = data['access']?.toString();
  //       final refresh = data['refresh']?.toString();
  //
  //       if (access != null && refresh != null) {
  //         emit(
  //           state.copyWith(
  //             currentUser: state.currentUser?.copyWith(
  //               access: access,
  //               refresh: refresh,
  //             ),
  //           ),
  //         );
  //       } else {
  //         emit(state.copyWith(currentUser: null));
  //       }
  //     },
  //   );
  //
  //   _isRefreshing = false;
  // }

  /*
  Future<void> refreshToken() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final user = state.currentUser;
      final refreshToken = user?.refresh;

      // 🚪 No refresh token → logout
      if (refreshToken == null || refreshToken.isEmpty) {
        if (state.currentUser != null) {
          emit(state.copyWith(currentUser: null));
        }
        return;
      }

      final result = await AuthRepository().refreshToken(refreshToken);

      result.fold(
        (error) {
          // ❌ Refresh failed → logout
          if (state.currentUser != null) {
            emit(state.copyWith(currentUser: null));
            Feggy.pushAndRemoveUntil(const SentOtpScreen());
          }
        },
        (data) {
          print('newly generated token is---${data['access']}');
          print('newly generated refresh is---${data['refresh']}');

          final access = data['access']?.toString();
          final refresh = data['refresh']?.toString();

          // ❌ Invalid response → logout
          if (access == null || refresh == null) {
            emit(state.copyWith(currentUser: null));
            return;
          }

          // ✅ Update tokens
          emit(
            state.copyWith(
              currentUser: user!.copyWith(access: access, refresh: refresh),
            ),
          );
        },
      );
    } catch (e) {
      // ❌ Network / unexpected crash → logout safely
      if (state.currentUser != null) {
        emit(state.copyWith(currentUser: null));
      }
    } finally {
      _isRefreshing = false;
    }
  }
  */

  Future<void> refreshToken() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    print('🔄 AppCubit: Starting token refresh process...');

    try {
      final user = state.currentUser;
      if (user == null) {
        return;
      }
      final refreshToken = user.refresh;

      // 🚪 No refresh token → don't aggressively log out unless authentication failure occurs
      if (refreshToken == null || refreshToken.isEmpty) {
        print('⚠️ AppCubit: No refresh token found for current user.');
        return;
      }

      final result = await AuthRepository().refreshToken(refreshToken);

      result.fold(
        (error) {
          print('❌ AppCubit: Token refresh API failed. Error: $error');

          error.maybeWhen(
            network: (msg) {
              print(
                '🌐 AppCubit: Network issue detected ($msg). Keeping current session for offline access.',
              );
              // 🚪 Do NOT logout if it's just a network issue.
              // This allows the user to see cached data while offline.
            },
            orElse: () {
              print(
                '🚫 AppCubit: Token refresh failed (Invalid token). Logging out.',
              );
              if (state.currentUser != null) {
                emit(state.copyWith(currentUser: null));
                Feggy.pushAndRemoveUntil(const SentOtpScreen());
              }
            },
          );
        },
        (data) {
          print('✅ AppCubit: Token refresh API success.');
          print('🔑 New Access Token: ${data['access']}');
          print('🔄 New Refresh Token: ${data['refresh']}');

          final access = data['access']?.toString();
          final refresh = data['refresh']?.toString();

          // ❌ Invalid response → logout
          if (access == null) {
            print('❌ AppCubit: New access token is null. Logging out.');
            emit(state.copyWith(currentUser: null));
            return;
          }

          // ✅ Update tokens
          print('✅ AppCubit: Updating user with new tokens.');

          final updatedUser = user.copyWith(
            access: access,
            refresh: refresh ?? user.refresh,
          );

          // 💾 Save to Hive
          LocalStorageService().saveUser(updatedUser);

          // 🔄 Update accounts list to keep switcher tokens in sync
          final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
          final existingIndex = currentAccounts.indexWhere(
            (a) => _isSameAccount(a, updatedUser),
          );
          if (existingIndex != -1) {
            currentAccounts[existingIndex] = updatedUser;
          }

          emit(
            state.copyWith(
              currentUser: updatedUser,
              accounts: currentAccounts,
            ),
          );
        },
      );
    } catch (e) {
      print('❌ AppCubit: Exception during token refresh: $e');
      // 🚪 On unexpected error, we keep the session to avoid aggressive logouts
      // especially during transient network issues or offline startup.
      print(
        '⚠️ AppCubit: Failed to pre-emptively refresh token. Keeping current session.',
      );
    } finally {
      _isRefreshing = false;
    }
  }
}
