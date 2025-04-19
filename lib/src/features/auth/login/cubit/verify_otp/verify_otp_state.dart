part of 'verify_otp_cubit.dart';

@freezed
class VerifyOtpState with _$VerifyOtpState {
  const factory VerifyOtpState({
    Option<Either<ApiException, void>>? verifyOtp,
    Option<Either<ApiException, void>>? resentOtp,
    @Default(0) int resentOtpReminigTime,
  }) = _VerifyOtpState;
}
