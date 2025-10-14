// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emi_options_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EmiOptionsModel _$EmiOptionsModelFromJson(Map<String, dynamic> json) {
  return _EmiOptionsModel.fromJson(json);
}

/// @nodoc
mixin _$EmiOptionsModel {
  @JsonKey(name: 'number_of_installments')
  int get month => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_amount_per_cycle')
  double get price => throw _privateConstructorUsedError;

  /// Serializes this EmiOptionsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmiOptionsModelCopyWith<EmiOptionsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmiOptionsModelCopyWith<$Res> {
  factory $EmiOptionsModelCopyWith(
          EmiOptionsModel value, $Res Function(EmiOptionsModel) then) =
      _$EmiOptionsModelCopyWithImpl<$Res, EmiOptionsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'number_of_installments') int month,
      @JsonKey(name: 'emi_amount_per_cycle') double price});
}

/// @nodoc
class _$EmiOptionsModelCopyWithImpl<$Res, $Val extends EmiOptionsModel>
    implements $EmiOptionsModelCopyWith<$Res> {
  _$EmiOptionsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmiOptionsModelImplCopyWith<$Res>
    implements $EmiOptionsModelCopyWith<$Res> {
  factory _$$EmiOptionsModelImplCopyWith(_$EmiOptionsModelImpl value,
          $Res Function(_$EmiOptionsModelImpl) then) =
      __$$EmiOptionsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'number_of_installments') int month,
      @JsonKey(name: 'emi_amount_per_cycle') double price});
}

/// @nodoc
class __$$EmiOptionsModelImplCopyWithImpl<$Res>
    extends _$EmiOptionsModelCopyWithImpl<$Res, _$EmiOptionsModelImpl>
    implements _$$EmiOptionsModelImplCopyWith<$Res> {
  __$$EmiOptionsModelImplCopyWithImpl(
      _$EmiOptionsModelImpl _value, $Res Function(_$EmiOptionsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? price = null,
  }) {
    return _then(_$EmiOptionsModelImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmiOptionsModelImpl implements _EmiOptionsModel {
  const _$EmiOptionsModelImpl(
      {@JsonKey(name: 'number_of_installments') required this.month,
      @JsonKey(name: 'emi_amount_per_cycle') required this.price});

  factory _$EmiOptionsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmiOptionsModelImplFromJson(json);

  @override
  @JsonKey(name: 'number_of_installments')
  final int month;
  @override
  @JsonKey(name: 'emi_amount_per_cycle')
  final double price;

  @override
  String toString() {
    return 'EmiOptionsModel(month: $month, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmiOptionsModelImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, price);

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmiOptionsModelImplCopyWith<_$EmiOptionsModelImpl> get copyWith =>
      __$$EmiOptionsModelImplCopyWithImpl<_$EmiOptionsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmiOptionsModelImplToJson(
      this,
    );
  }
}

abstract class _EmiOptionsModel implements EmiOptionsModel {
  const factory _EmiOptionsModel(
          {@JsonKey(name: 'number_of_installments') required final int month,
          @JsonKey(name: 'emi_amount_per_cycle') required final double price}) =
      _$EmiOptionsModelImpl;

  factory _EmiOptionsModel.fromJson(Map<String, dynamic> json) =
      _$EmiOptionsModelImpl.fromJson;

  @override
  @JsonKey(name: 'number_of_installments')
  int get month;
  @override
  @JsonKey(name: 'emi_amount_per_cycle')
  double get price;

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmiOptionsModelImplCopyWith<_$EmiOptionsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
