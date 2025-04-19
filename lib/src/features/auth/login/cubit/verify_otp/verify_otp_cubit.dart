import 'package:mentor_mobile_app/imports_bindings.dart';

part 'verify_otp_state.dart';
part 'verify_otp_cubit.freezed.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit() : super(const VerifyOtpState());

  Future<void> resentOtp({required String phone}) async {
    if ((state.verifyOtp?.isNone() ?? false) ||
        (state.resentOtp?.isNone() ?? false) ||
        (state.resentOtpReminigTime > 0)) {
      return;
    }
    emit(state.copyWith(resentOtp: none()));
    // await Future<void>.delayed(const Duration(seconds: 3));
    emit(state.copyWith(resentOtp: some(right(null))));
    // final result = await AuthService().login(email, password);
    // emit(state.copyWith(action: some(result)));
  }

  Future<void> verifyOtp({required String otp}) async {
    if (state.verifyOtp?.isNone() ?? false) {
      return;
    }
    if (otp.isEmpty) {
      emit(
        state.copyWith(
          verifyOtp: some(
            left(const ApiException.notFound(msg: 'Otp pin is required!')),
          ),
        ),
      );
      return;
    }
    if (otp.length != 4) {
      emit(
        state.copyWith(
          verifyOtp: some(
            left(const ApiException.notFound(msg: 'Otp pin is invalid!')),
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(verifyOtp: none()));
    await Future<void>.delayed(const Duration(seconds: 3));
    emit(state.copyWith(verifyOtp: some(right(null))));
    // final result = await AuthService().login(email, password);
    // emit(state.copyWith(action: some(result)));
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
        emit(
          state.copyWith(resentOtpReminigTime: state.resentOtpReminigTime - 1),
        );
      }
    });
  }
}
