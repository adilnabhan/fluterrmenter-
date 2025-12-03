import 'package:mentor_mobile_app/imports_bindings.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(const AppState());

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
}
