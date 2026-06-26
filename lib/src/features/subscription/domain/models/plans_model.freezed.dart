// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plans_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlansModel _$PlansModelFromJson(Map<String, dynamic> json) {
  return _PlansModel.fromJson(json);
}

/// @nodoc
mixin _$PlansModel {
  @JsonKey(name: 'results')
  List<SubscriptionPlanModel>? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this PlansModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlansModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlansModelCopyWith<PlansModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlansModelCopyWith<$Res> {
  factory $PlansModelCopyWith(
    PlansModel value,
    $Res Function(PlansModel) then,
  ) = _$PlansModelCopyWithImpl<$Res, PlansModel>;
  @useResult
  $Res call({@JsonKey(name: 'results') List<SubscriptionPlanModel>? results});
}

/// @nodoc
class _$PlansModelCopyWithImpl<$Res, $Val extends PlansModel>
    implements $PlansModelCopyWith<$Res> {
  _$PlansModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlansModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? results = freezed}) {
    return _then(
      _value.copyWith(
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<SubscriptionPlanModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlansModelImplCopyWith<$Res>
    implements $PlansModelCopyWith<$Res> {
  factory _$$PlansModelImplCopyWith(
    _$PlansModelImpl value,
    $Res Function(_$PlansModelImpl) then,
  ) = __$$PlansModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'results') List<SubscriptionPlanModel>? results});
}

/// @nodoc
class __$$PlansModelImplCopyWithImpl<$Res>
    extends _$PlansModelCopyWithImpl<$Res, _$PlansModelImpl>
    implements _$$PlansModelImplCopyWith<$Res> {
  __$$PlansModelImplCopyWithImpl(
    _$PlansModelImpl _value,
    $Res Function(_$PlansModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlansModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? results = freezed}) {
    return _then(
      _$PlansModelImpl(
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<SubscriptionPlanModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlansModelImpl implements _PlansModel {
  const _$PlansModelImpl({
    @JsonKey(name: 'results') final List<SubscriptionPlanModel>? results,
  }) : _results = results;

  factory _$PlansModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlansModelImplFromJson(json);

  final List<SubscriptionPlanModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<SubscriptionPlanModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PlansModel(results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlansModelImpl &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  /// Create a copy of PlansModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlansModelImplCopyWith<_$PlansModelImpl> get copyWith =>
      __$$PlansModelImplCopyWithImpl<_$PlansModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlansModelImplToJson(this);
  }
}

abstract class _PlansModel implements PlansModel {
  const factory _PlansModel({
    @JsonKey(name: 'results') final List<SubscriptionPlanModel>? results,
  }) = _$PlansModelImpl;

  factory _PlansModel.fromJson(Map<String, dynamic> json) =
      _$PlansModelImpl.fromJson;

  @override
  @JsonKey(name: 'results')
  List<SubscriptionPlanModel>? get results;

  /// Create a copy of PlansModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlansModelImplCopyWith<_$PlansModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionPlanModel _$SubscriptionPlanModelFromJson(
  Map<String, dynamic> json,
) {
  return _SubscriptionPlanModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionPlanModel {
  @JsonKey(name: 'id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_type')
  String? get planType => throw _privateConstructorUsedError;
  @JsonKey(name: 'regular_price')
  String? get regularPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'discounted_price')
  String? get discountedPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'period')
  int? get period => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionPlanModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionPlanModelCopyWith<SubscriptionPlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionPlanModelCopyWith<$Res> {
  factory $SubscriptionPlanModelCopyWith(
    SubscriptionPlanModel value,
    $Res Function(SubscriptionPlanModel) then,
  ) = _$SubscriptionPlanModelCopyWithImpl<$Res, SubscriptionPlanModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'plan_type') String? planType,
    @JsonKey(name: 'regular_price') String? regularPrice,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'period') int? period,
  });
}

/// @nodoc
class _$SubscriptionPlanModelCopyWithImpl<
  $Res,
  $Val extends SubscriptionPlanModel
>
    implements $SubscriptionPlanModelCopyWith<$Res> {
  _$SubscriptionPlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? planType = freezed,
    Object? regularPrice = freezed,
    Object? discountedPrice = freezed,
    Object? period = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            planType:
                freezed == planType
                    ? _value.planType
                    : planType // ignore: cast_nullable_to_non_nullable
                        as String?,
            regularPrice:
                freezed == regularPrice
                    ? _value.regularPrice
                    : regularPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            discountedPrice:
                freezed == discountedPrice
                    ? _value.discountedPrice
                    : discountedPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            period:
                freezed == period
                    ? _value.period
                    : period // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionPlanModelImplCopyWith<$Res>
    implements $SubscriptionPlanModelCopyWith<$Res> {
  factory _$$SubscriptionPlanModelImplCopyWith(
    _$SubscriptionPlanModelImpl value,
    $Res Function(_$SubscriptionPlanModelImpl) then,
  ) = __$$SubscriptionPlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'plan_type') String? planType,
    @JsonKey(name: 'regular_price') String? regularPrice,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'period') int? period,
  });
}

/// @nodoc
class __$$SubscriptionPlanModelImplCopyWithImpl<$Res>
    extends
        _$SubscriptionPlanModelCopyWithImpl<$Res, _$SubscriptionPlanModelImpl>
    implements _$$SubscriptionPlanModelImplCopyWith<$Res> {
  __$$SubscriptionPlanModelImplCopyWithImpl(
    _$SubscriptionPlanModelImpl _value,
    $Res Function(_$SubscriptionPlanModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? planType = freezed,
    Object? regularPrice = freezed,
    Object? discountedPrice = freezed,
    Object? period = freezed,
  }) {
    return _then(
      _$SubscriptionPlanModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        planType:
            freezed == planType
                ? _value.planType
                : planType // ignore: cast_nullable_to_non_nullable
                    as String?,
        regularPrice:
            freezed == regularPrice
                ? _value.regularPrice
                : regularPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        discountedPrice:
            freezed == discountedPrice
                ? _value.discountedPrice
                : discountedPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        period:
            freezed == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionPlanModelImpl implements _SubscriptionPlanModel {
  const _$SubscriptionPlanModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'plan_type') this.planType,
    @JsonKey(name: 'regular_price') this.regularPrice,
    @JsonKey(name: 'discounted_price') this.discountedPrice,
    @JsonKey(name: 'period') this.period,
  });

  factory _$SubscriptionPlanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionPlanModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'plan_type')
  final String? planType;
  @override
  @JsonKey(name: 'regular_price')
  final String? regularPrice;
  @override
  @JsonKey(name: 'discounted_price')
  final String? discountedPrice;
  @override
  @JsonKey(name: 'period')
  final int? period;

  @override
  String toString() {
    return 'SubscriptionPlanModel(id: $id, name: $name, planType: $planType, regularPrice: $regularPrice, discountedPrice: $discountedPrice, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionPlanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.regularPrice, regularPrice) ||
                other.regularPrice == regularPrice) &&
            (identical(other.discountedPrice, discountedPrice) ||
                other.discountedPrice == discountedPrice) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    planType,
    regularPrice,
    discountedPrice,
    period,
  );

  /// Create a copy of SubscriptionPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionPlanModelImplCopyWith<_$SubscriptionPlanModelImpl>
  get copyWith =>
      __$$SubscriptionPlanModelImplCopyWithImpl<_$SubscriptionPlanModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionPlanModelImplToJson(this);
  }
}

abstract class _SubscriptionPlanModel implements SubscriptionPlanModel {
  const factory _SubscriptionPlanModel({
    @JsonKey(name: 'id') final String? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'plan_type') final String? planType,
    @JsonKey(name: 'regular_price') final String? regularPrice,
    @JsonKey(name: 'discounted_price') final String? discountedPrice,
    @JsonKey(name: 'period') final int? period,
  }) = _$SubscriptionPlanModelImpl;

  factory _SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =
      _$SubscriptionPlanModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'plan_type')
  String? get planType;
  @override
  @JsonKey(name: 'regular_price')
  String? get regularPrice;
  @override
  @JsonKey(name: 'discounted_price')
  String? get discountedPrice;
  @override
  @JsonKey(name: 'period')
  int? get period;

  /// Create a copy of SubscriptionPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionPlanModelImplCopyWith<_$SubscriptionPlanModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
