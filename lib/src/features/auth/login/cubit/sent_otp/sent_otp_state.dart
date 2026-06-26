part of 'sent_otp_cubit.dart';

@freezed
class SentOtpState with _$SentOtpState {
  const factory SentOtpState({
    Option<Either<ApiException, SentOtpEntity>>? sentOtp,
    Option<Either<ApiException, void>>? googleSignIn,
  }) = _SentOtpState;
}
