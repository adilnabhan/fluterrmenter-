// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscriptionState {
  Option<Either<ApiException, PlansModel>> get plans =>
      throw _privateConstructorUsedError;
  SubscriptionPlanModel? get selectedSubscriptionModel =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, PaymentSuccessResponse>>? get payment =>
      throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionStateCopyWith<SubscriptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateCopyWith(
          SubscriptionState value, $Res Function(SubscriptionState) then) =
      _$SubscriptionStateCopyWithImpl<$Res, SubscriptionState>;
  @useResult
  $Res call(
      {Option<Either<ApiException, PlansModel>> plans,
      SubscriptionPlanModel? selectedSubscriptionModel,
      Option<Either<ApiException, PaymentSuccessResponse>>? payment});

  $SubscriptionPlanModelCopyWith<$Res>? get selectedSubscriptionModel;
}

/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res, $Val extends SubscriptionState>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plans = null,
    Object? selectedSubscriptionModel = freezed,
    Object? payment = freezed,
  }) {
    return _then(_value.copyWith(
      plans: null == plans
          ? _value.plans
          : plans // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, PlansModel>>,
      selectedSubscriptionModel: freezed == selectedSubscriptionModel
          ? _value.selectedSubscriptionModel
          : selectedSubscriptionModel // ignore: cast_nullable_to_non_nullable
              as SubscriptionPlanModel?,
      payment: freezed == payment
          ? _value.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, PaymentSuccessResponse>>?,
    ) as $Val);
  }

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionPlanModelCopyWith<$Res>? get selectedSubscriptionModel {
    if (_value.selectedSubscriptionModel == null) {
      return null;
    }

    return $SubscriptionPlanModelCopyWith<$Res>(
        _value.selectedSubscriptionModel!, (value) {
      return _then(_value.copyWith(selectedSubscriptionModel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubscriptionStateImplCopyWith<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  factory _$$SubscriptionStateImplCopyWith(_$SubscriptionStateImpl value,
          $Res Function(_$SubscriptionStateImpl) then) =
      __$$SubscriptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Option<Either<ApiException, PlansModel>> plans,
      SubscriptionPlanModel? selectedSubscriptionModel,
      Option<Either<ApiException, PaymentSuccessResponse>>? payment});

  @override
  $SubscriptionPlanModelCopyWith<$Res>? get selectedSubscriptionModel;
}

/// @nodoc
class __$$SubscriptionStateImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionStateImpl>
    implements _$$SubscriptionStateImplCopyWith<$Res> {
  __$$SubscriptionStateImplCopyWithImpl(_$SubscriptionStateImpl _value,
      $Res Function(_$SubscriptionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plans = null,
    Object? selectedSubscriptionModel = freezed,
    Object? payment = freezed,
  }) {
    return _then(_$SubscriptionStateImpl(
      plans: null == plans
          ? _value.plans
          : plans // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, PlansModel>>,
      selectedSubscriptionModel: freezed == selectedSubscriptionModel
          ? _value.selectedSubscriptionModel
          : selectedSubscriptionModel // ignore: cast_nullable_to_non_nullable
              as SubscriptionPlanModel?,
      payment: freezed == payment
          ? _value.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, PaymentSuccessResponse>>?,
    ));
  }
}

/// @nodoc

class _$SubscriptionStateImpl implements _SubscriptionState {
  const _$SubscriptionStateImpl(
      {this.plans = const None(),
      this.selectedSubscriptionModel,
      this.payment});

  @override
  @JsonKey()
  final Option<Either<ApiException, PlansModel>> plans;
  @override
  final SubscriptionPlanModel? selectedSubscriptionModel;
  @override
  final Option<Either<ApiException, PaymentSuccessResponse>>? payment;

  @override
  String toString() {
    return 'SubscriptionState(plans: $plans, selectedSubscriptionModel: $selectedSubscriptionModel, payment: $payment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStateImpl &&
            (identical(other.plans, plans) || other.plans == plans) &&
            (identical(other.selectedSubscriptionModel,
                    selectedSubscriptionModel) ||
                other.selectedSubscriptionModel == selectedSubscriptionModel) &&
            (identical(other.payment, payment) || other.payment == payment));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, plans, selectedSubscriptionModel, payment);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      __$$SubscriptionStateImplCopyWithImpl<_$SubscriptionStateImpl>(
          this, _$identity);
}

abstract class _SubscriptionState implements SubscriptionState {
  const factory _SubscriptionState(
      {final Option<Either<ApiException, PlansModel>> plans,
      final SubscriptionPlanModel? selectedSubscriptionModel,
      final Option<Either<ApiException, PaymentSuccessResponse>>?
          payment}) = _$SubscriptionStateImpl;

  @override
  Option<Either<ApiException, PlansModel>> get plans;
  @override
  SubscriptionPlanModel? get selectedSubscriptionModel;
  @override
  Option<Either<ApiException, PaymentSuccessResponse>>? get payment;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
