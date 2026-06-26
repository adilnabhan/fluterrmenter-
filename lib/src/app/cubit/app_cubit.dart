import 'package:mentor_mobile_app/imports_bindings.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(const AppState());

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

  void addUser(LoginSuccessModel user) {
    LocalStorageService().saveUser(user);
    final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
    final existingIndex = currentAccounts.indexWhere(
      (a) => a.id == user.id && a.userRole == user.userRole,
    );
    if (existingIndex != -1) {
      currentAccounts[existingIndex] = user;
    } else {
      currentAccounts.add(user);
    }
    emit(state.copyWith(currentUser: user, accounts: currentAccounts));
  }

  void switchAccount(LoginSuccessModel user) {
    LocalStorageService().saveUser(user);
    emit(state.copyWith(currentUser: user));
  }

  void removeUser() {
    final currentAccounts = List<LoginSuccessModel>.from(state.accounts);
    final user = state.currentUser;
    if (user != null) {
      currentAccounts.removeWhere(
        (a) => a.id == user.id && a.userRole == user.userRole,
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

  @override
  AppState? fromJson(Map<String, dynamic> json) {
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

    // 🛡️ Fallback: Check Hive if HydratedBloc lost the user (e.g. cache cleared)
    if (currentUser == null) {
      final localUser = LocalStorageService().getUser();
      if (localUser != null) {
        print('✅ AppCubit: Restored user from Hive storage.');
        currentUser = localUser;
        if (!accounts.any((a) => a.id == localUser.id && a.userRole == localUser.userRole)) {
          accounts.add(localUser);
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
      final refreshToken = user?.refresh;

      // 🚪 No refresh token → logout
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ AppCubit: No refresh token found. Logging out.');
        if (state.currentUser != null) {
          emit(state.copyWith(currentUser: null));
        }
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

          final updatedUser = user!.copyWith(
            access: access,
            refresh: refresh ?? user.refresh,
          );

          // 💾 Save to Hive
          LocalStorageService().saveUser(updatedUser);

          emit(state.copyWith(currentUser: updatedUser));
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
