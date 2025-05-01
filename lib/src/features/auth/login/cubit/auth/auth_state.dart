part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({@Default([]) List<LoginSuccessEntity> loggedUsers, LoginSuccessEntity? currentUser}) = _AuthState;
}
