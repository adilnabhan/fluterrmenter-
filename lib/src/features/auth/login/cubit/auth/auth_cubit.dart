import 'package:mentor_mobile_app/imports_bindings.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(const AuthState());

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
  AuthState? fromJson(Map<String, dynamic> json) {
    final loggedUsers = (json['loggedUsers'] as List<dynamic>).map((e) => LoginSuccessEntity.fromJson(e as Map<String, dynamic>)).toList();
    final currentUser = json['currentUser'] != null ? LoginSuccessEntity.fromJson(json['currentUser'] as Map<String, dynamic>) : null;
    return AuthState(loggedUsers: loggedUsers, currentUser: currentUser);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return {'loggedUsers': state.loggedUsers.map((e) => e.toJson()).toList(), 'currentUser': state.currentUser?.toJson()};
  }
}
