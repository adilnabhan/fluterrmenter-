// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_membership_package_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ListMembershipPackagesModel _$ListMembershipPackagesModelFromJson(
  Map<String, dynamic> json,
) {
  return _ListMembershipPackagesModel.fromJson(json);
}

/// @nodoc
mixin _$ListMembershipPackagesModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  dynamic get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  dynamic get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  List<MembershipPackageModel>? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this ListMembershipPackagesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListMembershipPackagesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListMembershipPackagesModelCopyWith<ListMembershipPackagesModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListMembershipPackagesModelCopyWith<$Res> {
  factory $ListMembershipPackagesModelCopyWith(
    ListMembershipPackagesModel value,
    $Res Function(ListMembershipPackagesModel) then,
  ) =
      _$ListMembershipPackagesModelCopyWithImpl<
        $Res,
        ListMembershipPackagesModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') dynamic next,
    @JsonKey(name: 'previous') dynamic previous,
    @JsonKey(name: 'results') List<MembershipPackageModel>? results,
  });
}

/// @nodoc
class _$ListMembershipPackagesModelCopyWithImpl<
  $Res,
  $Val extends ListMembershipPackagesModel
>
    implements $ListMembershipPackagesModelCopyWith<$Res> {
  _$ListMembershipPackagesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListMembershipPackagesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _value.copyWith(
            count:
                freezed == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int?,
            next:
                freezed == next
                    ? _value.next
                    : next // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            previous:
                freezed == previous
                    ? _value.previous
                    : previous // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<MembershipPackageModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListMembershipPackagesModelImplCopyWith<$Res>
    implements $ListMembershipPackagesModelCopyWith<$Res> {
  factory _$$ListMembershipPackagesModelImplCopyWith(
    _$ListMembershipPackagesModelImpl value,
    $Res Function(_$ListMembershipPackagesModelImpl) then,
  ) = __$$ListMembershipPackagesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') dynamic next,
    @JsonKey(name: 'previous') dynamic previous,
    @JsonKey(name: 'results') List<MembershipPackageModel>? results,
  });
}

/// @nodoc
class __$$ListMembershipPackagesModelImplCopyWithImpl<$Res>
    extends
        _$ListMembershipPackagesModelCopyWithImpl<
          $Res,
          _$ListMembershipPackagesModelImpl
        >
    implements _$$ListMembershipPackagesModelImplCopyWith<$Res> {
  __$$ListMembershipPackagesModelImplCopyWithImpl(
    _$ListMembershipPackagesModelImpl _value,
    $Res Function(_$ListMembershipPackagesModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListMembershipPackagesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _$ListMembershipPackagesModelImpl(
        count:
            freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int?,
        next:
            freezed == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        previous:
            freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<MembershipPackageModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListMembershipPackagesModelImpl
    implements _ListMembershipPackagesModel {
  const _$ListMembershipPackagesModelImpl({
    @JsonKey(name: 'count') this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results') final List<MembershipPackageModel>? results,
  }) : _results = results;

  factory _$ListMembershipPackagesModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ListMembershipPackagesModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final dynamic next;
  @override
  @JsonKey(name: 'previous')
  final dynamic previous;
  final List<MembershipPackageModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<MembershipPackageModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ListMembershipPackagesModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListMembershipPackagesModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other.next, next) &&
            const DeepCollectionEquality().equals(other.previous, previous) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    const DeepCollectionEquality().hash(next),
    const DeepCollectionEquality().hash(previous),
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of ListMembershipPackagesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListMembershipPackagesModelImplCopyWith<_$ListMembershipPackagesModelImpl>
  get copyWith => __$$ListMembershipPackagesModelImplCopyWithImpl<
    _$ListMembershipPackagesModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListMembershipPackagesModelImplToJson(this);
  }
}

abstract class _ListMembershipPackagesModel
    implements ListMembershipPackagesModel {
  const factory _ListMembershipPackagesModel({
    @JsonKey(name: 'count') final int? count,
    @JsonKey(name: 'next') final dynamic next,
    @JsonKey(name: 'previous') final dynamic previous,
    @JsonKey(name: 'results') final List<MembershipPackageModel>? results,
  }) = _$ListMembershipPackagesModelImpl;

  factory _ListMembershipPackagesModel.fromJson(Map<String, dynamic> json) =
      _$ListMembershipPackagesModelImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int? get count;
  @override
  @JsonKey(name: 'next')
  dynamic get next;
  @override
  @JsonKey(name: 'previous')
  dynamic get previous;
  @override
  @JsonKey(name: 'results')
  List<MembershipPackageModel>? get results;

  /// Create a copy of ListMembershipPackagesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListMembershipPackagesModelImplCopyWith<_$ListMembershipPackagesModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MembershipPackageModel _$MembershipPackageModelFromJson(
  Map<String, dynamic> json,
) {
  return _MembershipPackageModel.fromJson(json);
}

/// @nodoc
mixin _$MembershipPackageModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization')
  int? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'package_type')
  String? get packageType => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_price')
  String? get actualPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'offer_price')
  String? get offerPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'features')
  List<String>? get features => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_plans')
  List<EmiPlansModel> get emiPlans => throw _privateConstructorUsedError;

  /// Serializes this MembershipPackageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembershipPackageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipPackageModelCopyWith<MembershipPackageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipPackageModelCopyWith<$Res> {
  factory $MembershipPackageModelCopyWith(
    MembershipPackageModel value,
    $Res Function(MembershipPackageModel) then,
  ) = _$MembershipPackageModelCopyWithImpl<$Res, MembershipPackageModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') int? organization,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'actual_price') String? actualPrice,
    @JsonKey(name: 'offer_price') String? offerPrice,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'features') List<String>? features,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') List<EmiPlansModel> emiPlans,
  });
}

/// @nodoc
class _$MembershipPackageModelCopyWithImpl<
  $Res,
  $Val extends MembershipPackageModel
>
    implements $MembershipPackageModelCopyWith<$Res> {
  _$MembershipPackageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipPackageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? packageType = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? actualPrice = freezed,
    Object? offerPrice = freezed,
    Object? durationDays = freezed,
    Object? features = freezed,
    Object? isActive = freezed,
    Object? isEmiAvailable = freezed,
    Object? emiPlans = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            organization:
                freezed == organization
                    ? _value.organization
                    : organization // ignore: cast_nullable_to_non_nullable
                        as int?,
            packageType:
                freezed == packageType
                    ? _value.packageType
                    : packageType // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            actualPrice:
                freezed == actualPrice
                    ? _value.actualPrice
                    : actualPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            offerPrice:
                freezed == offerPrice
                    ? _value.offerPrice
                    : offerPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationDays:
                freezed == durationDays
                    ? _value.durationDays
                    : durationDays // ignore: cast_nullable_to_non_nullable
                        as int?,
            features:
                freezed == features
                    ? _value.features
                    : features // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isEmiAvailable:
                freezed == isEmiAvailable
                    ? _value.isEmiAvailable
                    : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                        as bool?,
            emiPlans:
                null == emiPlans
                    ? _value.emiPlans
                    : emiPlans // ignore: cast_nullable_to_non_nullable
                        as List<EmiPlansModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MembershipPackageModelImplCopyWith<$Res>
    implements $MembershipPackageModelCopyWith<$Res> {
  factory _$$MembershipPackageModelImplCopyWith(
    _$MembershipPackageModelImpl value,
    $Res Function(_$MembershipPackageModelImpl) then,
  ) = __$$MembershipPackageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') int? organization,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'actual_price') String? actualPrice,
    @JsonKey(name: 'offer_price') String? offerPrice,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'features') List<String>? features,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') List<EmiPlansModel> emiPlans,
  });
}

/// @nodoc
class __$$MembershipPackageModelImplCopyWithImpl<$Res>
    extends
        _$MembershipPackageModelCopyWithImpl<$Res, _$MembershipPackageModelImpl>
    implements _$$MembershipPackageModelImplCopyWith<$Res> {
  __$$MembershipPackageModelImplCopyWithImpl(
    _$MembershipPackageModelImpl _value,
    $Res Function(_$MembershipPackageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembershipPackageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? packageType = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? actualPrice = freezed,
    Object? offerPrice = freezed,
    Object? durationDays = freezed,
    Object? features = freezed,
    Object? isActive = freezed,
    Object? isEmiAvailable = freezed,
    Object? emiPlans = null,
  }) {
    return _then(
      _$MembershipPackageModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        organization:
            freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                    as int?,
        packageType:
            freezed == packageType
                ? _value.packageType
                : packageType // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        actualPrice:
            freezed == actualPrice
                ? _value.actualPrice
                : actualPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        offerPrice:
            freezed == offerPrice
                ? _value.offerPrice
                : offerPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationDays:
            freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                    as int?,
        features:
            freezed == features
                ? _value._features
                : features // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isEmiAvailable:
            freezed == isEmiAvailable
                ? _value.isEmiAvailable
                : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                    as bool?,
        emiPlans:
            null == emiPlans
                ? _value._emiPlans
                : emiPlans // ignore: cast_nullable_to_non_nullable
                    as List<EmiPlansModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipPackageModelImpl implements _MembershipPackageModel {
  const _$MembershipPackageModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'organization') this.organization,
    @JsonKey(name: 'package_type') this.packageType,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'actual_price') this.actualPrice,
    @JsonKey(name: 'offer_price') this.offerPrice,
    @JsonKey(name: 'duration_days') this.durationDays,
    @JsonKey(name: 'features') final List<String>? features,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'is_emi_available') this.isEmiAvailable,
    @JsonKey(name: 'emi_plans') final List<EmiPlansModel> emiPlans = const [],
  }) : _features = features,
       _emiPlans = emiPlans;

  factory _$MembershipPackageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipPackageModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'organization')
  final int? organization;
  @override
  @JsonKey(name: 'package_type')
  final String? packageType;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'actual_price')
  final String? actualPrice;
  @override
  @JsonKey(name: 'offer_price')
  final String? offerPrice;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  final List<String>? _features;
  @override
  @JsonKey(name: 'features')
  List<String>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'is_emi_available')
  final bool? isEmiAvailable;
  final List<EmiPlansModel> _emiPlans;
  @override
  @JsonKey(name: 'emi_plans')
  List<EmiPlansModel> get emiPlans {
    if (_emiPlans is EqualUnmodifiableListView) return _emiPlans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_emiPlans);
  }

  @override
  String toString() {
    return 'MembershipPackageModel(id: $id, organization: $organization, packageType: $packageType, name: $name, description: $description, actualPrice: $actualPrice, offerPrice: $offerPrice, durationDays: $durationDays, features: $features, isActive: $isActive, isEmiAvailable: $isEmiAvailable, emiPlans: $emiPlans)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipPackageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actualPrice, actualPrice) ||
                other.actualPrice == actualPrice) &&
            (identical(other.offerPrice, offerPrice) ||
                other.offerPrice == offerPrice) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isEmiAvailable, isEmiAvailable) ||
                other.isEmiAvailable == isEmiAvailable) &&
            const DeepCollectionEquality().equals(other._emiPlans, _emiPlans));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organization,
    packageType,
    name,
    description,
    actualPrice,
    offerPrice,
    durationDays,
    const DeepCollectionEquality().hash(_features),
    isActive,
    isEmiAvailable,
    const DeepCollectionEquality().hash(_emiPlans),
  );

  /// Create a copy of MembershipPackageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipPackageModelImplCopyWith<_$MembershipPackageModelImpl>
  get copyWith =>
      __$$MembershipPackageModelImplCopyWithImpl<_$MembershipPackageModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipPackageModelImplToJson(this);
  }
}

abstract class _MembershipPackageModel implements MembershipPackageModel {
  const factory _MembershipPackageModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'organization') final int? organization,
    @JsonKey(name: 'package_type') final String? packageType,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'actual_price') final String? actualPrice,
    @JsonKey(name: 'offer_price') final String? offerPrice,
    @JsonKey(name: 'duration_days') final int? durationDays,
    @JsonKey(name: 'features') final List<String>? features,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'is_emi_available') final bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') final List<EmiPlansModel> emiPlans,
  }) = _$MembershipPackageModelImpl;

  factory _MembershipPackageModel.fromJson(Map<String, dynamic> json) =
      _$MembershipPackageModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'organization')
  int? get organization;
  @override
  @JsonKey(name: 'package_type')
  String? get packageType;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'actual_price')
  String? get actualPrice;
  @override
  @JsonKey(name: 'offer_price')
  String? get offerPrice;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'features')
  List<String>? get features;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable;
  @override
  @JsonKey(name: 'emi_plans')
  List<EmiPlansModel> get emiPlans;

  /// Create a copy of MembershipPackageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipPackageModelImplCopyWith<_$MembershipPackageModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

EmiPlansModel _$EmiPlansModelFromJson(Map<String, dynamic> json) {
  return _EmiPlansModel.fromJson(json);
}

/// @nodoc
mixin _$EmiPlansModel {
  @JsonKey(name: 'number_of_installments')
  int get month => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'emi_amount_per_cycle',
    fromJson: StringToDoubleConverter.fromJsonStatic,
    toJson: StringToDoubleConverter.toJsonStatic,
  )
  double get price => throw _privateConstructorUsedError;

  /// Serializes this EmiPlansModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmiPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmiPlansModelCopyWith<EmiPlansModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmiPlansModelCopyWith<$Res> {
  factory $EmiPlansModelCopyWith(
    EmiPlansModel value,
    $Res Function(EmiPlansModel) then,
  ) = _$EmiPlansModelCopyWithImpl<$Res, EmiPlansModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'number_of_installments') int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    double price,
  });
}

/// @nodoc
class _$EmiPlansModelCopyWithImpl<$Res, $Val extends EmiPlansModel>
    implements $EmiPlansModelCopyWith<$Res> {
  _$EmiPlansModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmiPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? month = null, Object? price = null}) {
    return _then(
      _value.copyWith(
            month:
                null == month
                    ? _value.month
                    : month // ignore: cast_nullable_to_non_nullable
                        as int,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmiPlansModelImplCopyWith<$Res>
    implements $EmiPlansModelCopyWith<$Res> {
  factory _$$EmiPlansModelImplCopyWith(
    _$EmiPlansModelImpl value,
    $Res Function(_$EmiPlansModelImpl) then,
  ) = __$$EmiPlansModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'number_of_installments') int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    double price,
  });
}

/// @nodoc
class __$$EmiPlansModelImplCopyWithImpl<$Res>
    extends _$EmiPlansModelCopyWithImpl<$Res, _$EmiPlansModelImpl>
    implements _$$EmiPlansModelImplCopyWith<$Res> {
  __$$EmiPlansModelImplCopyWithImpl(
    _$EmiPlansModelImpl _value,
    $Res Function(_$EmiPlansModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmiPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? month = null, Object? price = null}) {
    return _then(
      _$EmiPlansModelImpl(
        month:
            null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                    as int,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmiPlansModelImpl implements _EmiPlansModel {
  const _$EmiPlansModelImpl({
    @JsonKey(name: 'number_of_installments') required this.month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    required this.price,
  });

  factory _$EmiPlansModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmiPlansModelImplFromJson(json);

  @override
  @JsonKey(name: 'number_of_installments')
  final int month;
  @override
  @JsonKey(
    name: 'emi_amount_per_cycle',
    fromJson: StringToDoubleConverter.fromJsonStatic,
    toJson: StringToDoubleConverter.toJsonStatic,
  )
  final double price;

  @override
  String toString() {
    return 'EmiPlansModel(month: $month, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmiPlansModelImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, price);

  /// Create a copy of EmiPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmiPlansModelImplCopyWith<_$EmiPlansModelImpl> get copyWith =>
      __$$EmiPlansModelImplCopyWithImpl<_$EmiPlansModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmiPlansModelImplToJson(this);
  }
}

abstract class _EmiPlansModel implements EmiPlansModel {
  const factory _EmiPlansModel({
    @JsonKey(name: 'number_of_installments') required final int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    required final double price,
  }) = _$EmiPlansModelImpl;

  factory _EmiPlansModel.fromJson(Map<String, dynamic> json) =
      _$EmiPlansModelImpl.fromJson;

  @override
  @JsonKey(name: 'number_of_installments')
  int get month;
  @override
  @JsonKey(
    name: 'emi_amount_per_cycle',
    fromJson: StringToDoubleConverter.fromJsonStatic,
    toJson: StringToDoubleConverter.toJsonStatic,
  )
  double get price;

  /// Create a copy of EmiPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmiPlansModelImplCopyWith<_$EmiPlansModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
