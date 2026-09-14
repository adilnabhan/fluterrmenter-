import 'package:mentor_mobile_app/core/network/token_refresh_result.dart';
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
        if (kDebugMode) {
          print('✅ AppCubit constructor: Restored user from Hive fallback (id=${localUser.id}, access=${localUser.access != null ? 'YES' : 'NULL'}).');
        }
        final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
        if (!currentAccounts.any((a) => a.id == localUser.id && a.userRole == localUser.userRole)) {
          currentAccounts.add(localUser);
        }
        emit(state.copyWith(currentUser: localUser, accounts: currentAccounts));
      }
    }
  }


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
    NotificationServices.requestPermissionAndRegisterToken();
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
    NotificationServices.requestPermissionAndRegisterToken();
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
    if (kDebugMode) {
      print('🔍 AppCubit.fromJson called');
      print('🔍 json keys: ${json.keys.toList()}');
      print('🔍 currentUser in json: ${json['currentUser'] != null ? 'EXISTS' : 'NULL'}');
      print('🔍 accounts in json: ${json['accounts'] != null ? '${(json['accounts'] as List).length} accounts' : 'NULL'}');
      if (json['currentUser'] != null) {
        final u = json['currentUser'] as Map<String, dynamic>;
        print('🔍 stored access: ${u['access'] != null ? 'EXISTS' : 'NULL'}');
        print('🔍 stored refresh: ${u['refresh'] != null ? 'EXISTS' : 'NULL'}');
      }
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
      if (kDebugMode) {
        print('⚠️ AppCubit: currentUser is NULL from HydratedCubit. Trying Hive fallback...');
      }
      final localUser = LocalStorageService().getUser();
      if (kDebugMode) {
        print('⚠️ AppCubit: Hive user: ${localUser != null ? 'EXISTS (id=${localUser.id})' : 'NULL'}');
      }
      if (localUser != null) {
        if (kDebugMode) {
          print('✅ AppCubit: Restored user from Hive storage.');
        }
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
        if (kDebugMode) {
          print('✅ AppCubit: Recovered tokens from Hive for user ${currentUser.id}.');
        }
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

  /// The single in-flight refresh future.
  /// All concurrent callers (AuthInterceptor, app_view startup, etc.)
  /// await the same future so only one HTTP refresh call is made.
  Future<TokenRefreshResult>? _activeRefreshFuture;

  /// Refreshes the access token.
  ///
  /// Returns a [TokenRefreshResult] so the caller (especially
  /// `AuthInterceptor`) knows whether to retry, reject, or logout.
  ///
  /// Concurrent calls are coalesced: the first call creates the future,
  /// subsequent calls await the same future.
  Future<TokenRefreshResult> refreshToken() async {
    // If a refresh is already in flight, piggy-back on it.
    if (_activeRefreshFuture != null) {
      if (kDebugMode) {
        print('🔄 AppCubit: Refresh already in progress — waiting for existing operation.');
      }
      return _activeRefreshFuture!;
    }

    _activeRefreshFuture = _performRefresh();
    try {
      return await _activeRefreshFuture!;
    } finally {
      _activeRefreshFuture = null;
    }
  }

  /// Internal implementation — never call directly; use [refreshToken].
  Future<TokenRefreshResult> _performRefresh() async {
    if (kDebugMode) {
      print('🔄 AppCubit: Starting token refresh process...');
    }

    try {
      final user = state.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ AppCubit: No current user. Skipping refresh.');
        }
        return TokenRefreshResult.noUser;
      }

      final refreshTokenStr = user.refresh;
      if (refreshTokenStr == null || refreshTokenStr.isEmpty) {
        if (kDebugMode) {
          print('⚠️ AppCubit: No refresh token found for current user.');
        }
        return TokenRefreshResult.noRefreshToken;
      }

      if (kDebugMode) {
        print('🔄 AppCubit: Current user exists: true, Refresh token exists: true');
      }

      // outTokens map receives the new access/refresh from the repository.
      final outTokens = <String, dynamic>{};

      final result = await AuthRepository().refreshToken(
        refreshTokenStr,
        outTokens: outTokens,
      );

      switch (result) {
        case TokenRefreshResult.success:
          if (kDebugMode) {
            print('✅ AppCubit: Token refresh succeeded.');
            print('✅ AppCubit: Access token received: ${outTokens['access'] != null}');
            print('✅ AppCubit: Refresh token received: ${outTokens['refresh'] != null}');
          }

          final access = outTokens['access']?.toString();
          final refresh = outTokens['refresh']?.toString();

          if (access == null || access.isEmpty) {
            // Shouldn't happen (repo already validated), but safeguard.
            if (kDebugMode) {
              print('⚠️ AppCubit: Access token missing after success — treating as temporary failure.');
            }
            return TokenRefreshResult.temporaryFailure;
          }

          final updatedUser = user.copyWith(
            access: access,
            refresh: refresh ?? user.refresh,
          );

          // 💾 Persist to Hive — AWAIT so tokens are safely on disk
          // before any retried request reads them.
          await LocalStorageService().saveUser(updatedUser);

          // 🔄 Update the matching account in the accounts list
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

          if (kDebugMode) {
            print('✅ AppCubit: User state and storage updated with new tokens.');
          }
          return TokenRefreshResult.success;

        case TokenRefreshResult.invalidToken:
          if (kDebugMode) {
            print('🚫 AppCubit: Refresh token is invalid/expired. Logging out.');
          }
          if (state.currentUser != null) {
            emit(state.copyWith(currentUser: null));
            unawaited(Feggy.pushAndRemoveUntil(const SentOtpScreen()));
          }
          return TokenRefreshResult.invalidToken;

        case TokenRefreshResult.temporaryFailure:
          if (kDebugMode) {
            print('⚠️ AppCubit: Temporary failure during refresh. Keeping current session.');
          }
          // Session is preserved — user stays logged in.
          return TokenRefreshResult.temporaryFailure;

        case TokenRefreshResult.noRefreshToken:
        case TokenRefreshResult.noUser:
          // Already handled above, but enum must be exhaustive.
          return result;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AppCubit: Unexpected exception during token refresh: $e');
        print('⚠️ AppCubit: Keeping current session (not logging out).');
      }
      return TokenRefreshResult.temporaryFailure;
    }
  }
}
