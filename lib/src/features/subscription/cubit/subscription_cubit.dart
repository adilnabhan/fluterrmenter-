import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

part 'subscription_state.dart';
part 'subscription_cubit.freezed.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(const SubscriptionState());
}
