part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(ThemeMode.light) ThemeMode themeMode,
    @Default(Locale('en')) Locale locale,
    @Default([]) List<LoginSuccessEntity> loggedUsers,
    LoginSuccessEntity? currentUser
  }) = _AppState;
}
