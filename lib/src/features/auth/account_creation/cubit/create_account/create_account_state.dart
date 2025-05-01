part of 'create_account_cubit.dart';

@freezed
class CreateAccountState with _$CreateAccountState {
  const factory CreateAccountState({required SentOtpEntity sentOtpEntity, Option<Either<ApiException, LoginSuccessEntity>>? onboardingUser}) = _CreateAccountState;
}
