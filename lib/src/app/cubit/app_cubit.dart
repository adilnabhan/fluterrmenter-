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

  void addLoggedUser(LoginSuccessEntity user) {
    final loggedUsers = state.loggedUsers;
    if (loggedUsers.any((element) => element.id == user.id)) {
      return;
    }
    emit(state.copyWith(loggedUsers: [...loggedUsers, user]));
  }

  void removeLoggedUser(LoginSuccessEntity user) {
    final loggedUsers = state.loggedUsers;
    if (loggedUsers.isEmpty) {
      return;
    }
    emit(state.copyWith(loggedUsers: loggedUsers.where((element) => element.id != user.id).toList()));
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    final loggedUsers = (json['loggedUsers'] as List<dynamic>).map((e) => LoginSuccessEntity.fromJson(e as Map<String, dynamic>)).toList();
    final currentUser = json['currentUser'] != null ? LoginSuccessEntity.fromJson(json['currentUser'] as Map<String, dynamic>) : null;
    return AppState(
      themeMode: switch (json['theme_mode']) {
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      },
      locale: Locale(json['language_code'] as String),
      loggedUsers: loggedUsers,
      currentUser: currentUser,
    );
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    return {
      'theme_mode': state.themeMode.name,
      'language_code': state.locale.languageCode,
      'loggedUsers': state.loggedUsers.map((e) => e.toJson()).toList(),
      'currentUser': state.currentUser?.toJson(),
    };
  }
}
