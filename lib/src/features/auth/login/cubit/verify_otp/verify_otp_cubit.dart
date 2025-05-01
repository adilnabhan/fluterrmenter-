import 'package:mentor_mobile_app/imports_bindings.dart';

part 'verify_otp_state.dart';
part 'verify_otp_cubit.freezed.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit({required SentOtpEntity sentOtpEntity}) : super(VerifyOtpState(sentOtpEntity: sentOtpEntity));

  Future<void> resentOtp() async {
    if ((state.verifyOtp?.isNone() ?? false) || (state.resentOtp?.isNone() ?? false) || (state.resentOtpReminigTime > 0)) {
      return;
    }
    emit(state.copyWith(resentOtp: none()));
    final response = await AuthRepository().sentOtp(body: {'mobile_number': state.sentOtpEntity.mobileNumber, 'process': 'login', 'source': platformSource});
    emit(state.copyWith(resentOtp: some(response)));
  }

  Future<void> verifyOtp({required String otp}) async {
    if (state.verifyOtp?.isNone() ?? false) {
      return;
    }
    if (otp.isEmpty) {
      emit(state.copyWith(verifyOtp: some(left(const ApiException.notFound(msg: 'Otp pin is required!')))));
      return;
    }
    if (otp.length != 4) {
      emit(state.copyWith(verifyOtp: some(left(const ApiException.notFound(msg: 'Otp pin is invalid!')))));
      return;
    }
    emit(state.copyWith(verifyOtp: none()));
    final response = await AuthRepository().loginWithOtp(
      body: {'process': 'registration', 'source': platformSource, 'otp_id': state.sentOtpEntity.id, 'otp': otp, 'mobile_number': state.sentOtpEntity.mobileNumber},
    );
    emit(state.copyWith(verifyOtp: some(response)));
  }

  void startResentOtpTimer() {
    if (state.resentOtpReminigTime > 0) {
      return;
    }
    emit(state.copyWith(resentOtpReminigTime: 60));
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resentOtpReminigTime <= 0) {
        timer.cancel();
      } else {
        emit(state.copyWith(resentOtpReminigTime: state.resentOtpReminigTime - 1));
      }
    });
  }
}
