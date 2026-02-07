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
    emit(state.copyWith(currentUser: user));
  }

  void removeUser() {
    emit(state.copyWith(currentUser: null));
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    final currentUser =
        json['currentUser'] != null
            ? LoginSuccessModel.fromJson(
              json['currentUser'] as Map<String, dynamic>,
            )
            : null;
    return AppState(
      themeMode: switch (json['theme_mode']) {
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      },
      locale: Locale(json['language_code'] as String),
      currentUser: currentUser,
    );
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    return {
      'theme_mode': state.themeMode.name,
      'language_code': state.locale.languageCode,
      'currentUser': state.currentUser?.toJson(),
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
          print(
            '❌ AppCubit: Token refresh API failed. Logging out. Error: $error',
          );
          // ❌ Refresh failed → logout
          if (state.currentUser != null) {
            emit(state.copyWith(currentUser: null));
            Feggy.pushAndRemoveUntil(const SentOtpScreen());
          }
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
          emit(
            state.copyWith(
              currentUser: user!.copyWith(
                access: access,
                refresh: refresh ?? user.refresh,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('❌ AppCubit: Exception during token refresh: $e');
      // ❌ Network / unexpected crash → logout safely
      if (state.currentUser != null) {
        emit(state.copyWith(currentUser: null));
      }
    } finally {
      _isRefreshing = false;
    }
  }
}
