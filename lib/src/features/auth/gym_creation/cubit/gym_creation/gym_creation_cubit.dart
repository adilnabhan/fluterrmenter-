import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

part 'gym_creation_state.dart';
part 'gym_creation_cubit.freezed.dart';

class GymCreationCubit extends Cubit<GymCreationState> {
  GymCreationCubit() : super(const GymCreationState());
}
