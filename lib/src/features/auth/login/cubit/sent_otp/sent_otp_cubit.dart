import 'package:mentor_mobile_app/imports_bindings.dart';

part 'sent_otp_state.dart';
part 'sent_otp_cubit.freezed.dart';

class SentOtpCubit extends Cubit<SentOtpState> {
  SentOtpCubit() : super(const SentOtpState());

  Future<void> sentOtp({required String phone}) async {
    if ((state.sentOtp?.isNone() ?? false) ||
        (state.googleSignIn?.isNone() ?? false)) {
      return;
    }
    if (phone.isEmpty) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sentOtp: some(
            left(const ApiException.notFound(msg: 'Phone number is required!')),
          ),
        ),
      );
      return;
    }
    if (phone.length < 10) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sentOtp: some(
            left(const ApiException.notFound(msg: 'Phone number is invalid!')),
          ),
        ),
      );
      return;
    }
    if (isClosed) return;
    emit(state.copyWith(sentOtp: none()));
    final response = await AuthRepository().sentOtp(
      body: {
        'mobile_number': '+91$phone',
        'process': 'login',
        'source': platformSource,
      },
    );
    if (isClosed) return;
    emit(state.copyWith(sentOtp: some(response)));
  }

  Future<void> googleSignIn() async {
    if ((state.sentOtp?.isNone() ?? false) ||
        (state.googleSignIn?.isNone() ?? false)) {
      return;
    }
    if (isClosed) return;
    emit(state.copyWith(googleSignIn: none()));
    // await Future<void>.delayed(const Duration(seconds: 3));
    if (isClosed) return;
    emit(state.copyWith(googleSignIn: some(right(null))));
    // final result = await AuthService().login(email, password);
    if (isClosed) return;
    // emit(state.copyWith(action: some(result)));
  }
}
