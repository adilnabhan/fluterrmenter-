part of 'verify_otp_cubit.dart';

@freezed
class VerifyOtpState with _$VerifyOtpState {
  const factory VerifyOtpState({
    required SentOtpEntity sentOtpEntity,
    Option<Either<ApiException, LoginSuccessEntity>>? verifyOtp,
    Option<Either<ApiException, SentOtpEntity>>? resentOtp,
    @Default(0) int resentOtpReminigTime,
  }) = _VerifyOtpState;
}
