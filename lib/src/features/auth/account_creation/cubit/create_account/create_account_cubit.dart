import 'package:mentor_mobile_app/imports_bindings.dart';

part 'create_account_state.dart';
part 'create_account_cubit.freezed.dart';

class CreateAccountCubit extends Cubit<CreateAccountState> {
  CreateAccountCubit({required SentOtpEntity sentOtp})
    : super(CreateAccountState(sentOtpEntity: sentOtp));

  Future<void> onboardUser({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    if (state.onboardingUser?.isNone() ?? false) {
      return;
    }
    emit(state.copyWith(onboardingUser: none()));
    if (firstName.isEmpty) {
      emit(
        state.copyWith(
          onboardingUser: some(
            left(const ApiException.notFound(msg: 'First name is required!')),
          ),
        ),
      );
      return;
    }
    if (lastName.isEmpty) {
      emit(
        state.copyWith(
          onboardingUser: some(
            left(const ApiException.notFound(msg: 'Last name is required!')),
          ),
        ),
      );
      return;
    }
    if (email.isEmpty) {
      emit(
        state.copyWith(
          onboardingUser: some(
            left(const ApiException.notFound(msg: 'Email is required!')),
          ),
        ),
      );
      return;
    }
    final result = await AuthRepository().onboarding(
      body: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'otp_id': state.sentOtpEntity.id,
        'mobile_number': state.sentOtpEntity.mobileNumber,
        'process': 'registration',
        'source': platformSource,
        'user_role': '20',
        'meta': <String, dynamic>{},
      },
    );
    emit(state.copyWith(onboardingUser: some(result)));
  }
}
