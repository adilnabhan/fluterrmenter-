// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'members_listing_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MembersListingModel _$MembersListingModelFromJson(Map<String, dynamic> json) {
  return _MembersListingModel.fromJson(json);
}

/// @nodoc
mixin _$MembersListingModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  List<MemberDataModel>? get results => throw _privateConstructorUsedError;

  /// Serializes this MembersListingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembersListingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembersListingModelCopyWith<MembersListingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembersListingModelCopyWith<$Res> {
  factory $MembersListingModelCopyWith(
    MembersListingModel value,
    $Res Function(MembersListingModel) then,
  ) = _$MembersListingModelCopyWithImpl<$Res, MembersListingModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<MemberDataModel>? results,
  });
}

/// @nodoc
class _$MembersListingModelCopyWithImpl<$Res, $Val extends MembersListingModel>
    implements $MembersListingModelCopyWith<$Res> {
  _$MembersListingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembersListingModel
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
                        as String?,
            previous:
                freezed == previous
                    ? _value.previous
                    : previous // ignore: cast_nullable_to_non_nullable
                        as String?,
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<MemberDataModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MembersListingModelImplCopyWith<$Res>
    implements $MembersListingModelCopyWith<$Res> {
  factory _$$MembersListingModelImplCopyWith(
    _$MembersListingModelImpl value,
    $Res Function(_$MembersListingModelImpl) then,
  ) = __$$MembersListingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<MemberDataModel>? results,
  });
}

/// @nodoc
class __$$MembersListingModelImplCopyWithImpl<$Res>
    extends _$MembersListingModelCopyWithImpl<$Res, _$MembersListingModelImpl>
    implements _$$MembersListingModelImplCopyWith<$Res> {
  __$$MembersListingModelImplCopyWithImpl(
    _$MembersListingModelImpl _value,
    $Res Function(_$MembersListingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembersListingModel
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
      _$MembersListingModelImpl(
        count:
            freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int?,
        next:
            freezed == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                    as String?,
        previous:
            freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                    as String?,
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<MemberDataModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MembersListingModelImpl implements _MembersListingModel {
  const _$MembersListingModelImpl({
    @JsonKey(name: 'count') this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results') final List<MemberDataModel>? results,
  }) : _results = results;

  factory _$MembersListingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembersListingModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;
  final List<MemberDataModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<MemberDataModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MembersListingModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembersListingModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    next,
    previous,
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of MembersListingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembersListingModelImplCopyWith<_$MembersListingModelImpl> get copyWith =>
      __$$MembersListingModelImplCopyWithImpl<_$MembersListingModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MembersListingModelImplToJson(this);
  }
}

abstract class _MembersListingModel implements MembersListingModel {
  const factory _MembersListingModel({
    @JsonKey(name: 'count') final int? count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final String? previous,
    @JsonKey(name: 'results') final List<MemberDataModel>? results,
  }) = _$MembersListingModelImpl;

  factory _MembersListingModel.fromJson(Map<String, dynamic> json) =
      _$MembersListingModelImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int? get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  String? get previous;
  @override
  @JsonKey(name: 'results')
  List<MemberDataModel>? get results;

  /// Create a copy of MembersListingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembersListingModelImplCopyWith<_$MembersListingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberDataModel _$MemberDataModelFromJson(Map<String, dynamic> json) {
  return _MemberDataModel.fromJson(json);
}

/// @nodoc
mixin _$MemberDataModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_date')
  DateTime? get joinedDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_plan')
  ActivePlan? get activePlan => throw _privateConstructorUsedError;

  /// Serializes this MemberDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberDataModelCopyWith<MemberDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberDataModelCopyWith<$Res> {
  factory $MemberDataModelCopyWith(
    MemberDataModel value,
    $Res Function(MemberDataModel) then,
  ) = _$MemberDataModelCopyWithImpl<$Res, MemberDataModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'joined_date') DateTime? joinedDate,
    @JsonKey(name: 'active_plan') ActivePlan? activePlan,
  });

  $ActivePlanCopyWith<$Res>? get activePlan;
}

/// @nodoc
class _$MemberDataModelCopyWithImpl<$Res, $Val extends MemberDataModel>
    implements $MemberDataModelCopyWith<$Res> {
  _$MemberDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? mobileNumber = freezed,
    Object? profilePicture = freezed,
    Object? joinedDate = freezed,
    Object? activePlan = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            mobileNumber:
                freezed == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            joinedDate:
                freezed == joinedDate
                    ? _value.joinedDate
                    : joinedDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            activePlan:
                freezed == activePlan
                    ? _value.activePlan
                    : activePlan // ignore: cast_nullable_to_non_nullable
                        as ActivePlan?,
          )
          as $Val,
    );
  }

  /// Create a copy of MemberDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActivePlanCopyWith<$Res>? get activePlan {
    if (_value.activePlan == null) {
      return null;
    }

    return $ActivePlanCopyWith<$Res>(_value.activePlan!, (value) {
      return _then(_value.copyWith(activePlan: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MemberDataModelImplCopyWith<$Res>
    implements $MemberDataModelCopyWith<$Res> {
  factory _$$MemberDataModelImplCopyWith(
    _$MemberDataModelImpl value,
    $Res Function(_$MemberDataModelImpl) then,
  ) = __$$MemberDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'joined_date') DateTime? joinedDate,
    @JsonKey(name: 'active_plan') ActivePlan? activePlan,
  });

  @override
  $ActivePlanCopyWith<$Res>? get activePlan;
}

/// @nodoc
class __$$MemberDataModelImplCopyWithImpl<$Res>
    extends _$MemberDataModelCopyWithImpl<$Res, _$MemberDataModelImpl>
    implements _$$MemberDataModelImplCopyWith<$Res> {
  __$$MemberDataModelImplCopyWithImpl(
    _$MemberDataModelImpl _value,
    $Res Function(_$MemberDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? mobileNumber = freezed,
    Object? profilePicture = freezed,
    Object? joinedDate = freezed,
    Object? activePlan = freezed,
  }) {
    return _then(
      _$MemberDataModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        mobileNumber:
            freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        joinedDate:
            freezed == joinedDate
                ? _value.joinedDate
                : joinedDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        activePlan:
            freezed == activePlan
                ? _value.activePlan
                : activePlan // ignore: cast_nullable_to_non_nullable
                    as ActivePlan?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberDataModelImpl implements _MemberDataModel {
  const _$MemberDataModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'mobile_number') this.mobileNumber,
    @JsonKey(name: 'profile_picture') this.profilePicture,
    @JsonKey(name: 'joined_date') this.joinedDate,
    @JsonKey(name: 'active_plan') this.activePlan,
  });

  factory _$MemberDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberDataModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;
  @override
  @JsonKey(name: 'profile_picture')
  final dynamic profilePicture;
  @override
  @JsonKey(name: 'joined_date')
  final DateTime? joinedDate;
  @override
  @JsonKey(name: 'active_plan')
  final ActivePlan? activePlan;

  @override
  String toString() {
    return 'MemberDataModel(id: $id, name: $name, mobileNumber: $mobileNumber, profilePicture: $profilePicture, joinedDate: $joinedDate, activePlan: $activePlan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            const DeepCollectionEquality().equals(
              other.profilePicture,
              profilePicture,
            ) &&
            (identical(other.joinedDate, joinedDate) ||
                other.joinedDate == joinedDate) &&
            (identical(other.activePlan, activePlan) ||
                other.activePlan == activePlan));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    mobileNumber,
    const DeepCollectionEquality().hash(profilePicture),
    joinedDate,
    activePlan,
  );

  /// Create a copy of MemberDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberDataModelImplCopyWith<_$MemberDataModelImpl> get copyWith =>
      __$$MemberDataModelImplCopyWithImpl<_$MemberDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberDataModelImplToJson(this);
  }
}

abstract class _MemberDataModel implements MemberDataModel {
  const factory _MemberDataModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'mobile_number') final String? mobileNumber,
    @JsonKey(name: 'profile_picture') final dynamic profilePicture,
    @JsonKey(name: 'joined_date') final DateTime? joinedDate,
    @JsonKey(name: 'active_plan') final ActivePlan? activePlan,
  }) = _$MemberDataModelImpl;

  factory _MemberDataModel.fromJson(Map<String, dynamic> json) =
      _$MemberDataModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;
  @override
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture;
  @override
  @JsonKey(name: 'joined_date')
  DateTime? get joinedDate;
  @override
  @JsonKey(name: 'active_plan')
  ActivePlan? get activePlan;

  /// Create a copy of MemberDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberDataModelImplCopyWith<_$MemberDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivePlan _$ActivePlanFromJson(Map<String, dynamic> json) {
  return _ActivePlan.fromJson(json);
}

/// @nodoc
mixin _$ActivePlan {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_name')
  String? get planName => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this ActivePlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivePlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivePlanCopyWith<ActivePlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivePlanCopyWith<$Res> {
  factory $ActivePlanCopyWith(
    ActivePlan value,
    $Res Function(ActivePlan) then,
  ) = _$ActivePlanCopyWithImpl<$Res, ActivePlan>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
  });
}

/// @nodoc
class _$ActivePlanCopyWithImpl<$Res, $Val extends ActivePlan>
    implements $ActivePlanCopyWith<$Res> {
  _$ActivePlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivePlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planName = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            planName:
                freezed == planName
                    ? _value.planName
                    : planName // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                freezed == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivePlanImplCopyWith<$Res>
    implements $ActivePlanCopyWith<$Res> {
  factory _$$ActivePlanImplCopyWith(
    _$ActivePlanImpl value,
    $Res Function(_$ActivePlanImpl) then,
  ) = __$$ActivePlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
  });
}

/// @nodoc
class __$$ActivePlanImplCopyWithImpl<$Res>
    extends _$ActivePlanCopyWithImpl<$Res, _$ActivePlanImpl>
    implements _$$ActivePlanImplCopyWith<$Res> {
  __$$ActivePlanImplCopyWithImpl(
    _$ActivePlanImpl _value,
    $Res Function(_$ActivePlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivePlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? planName = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$ActivePlanImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        planName:
            freezed == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivePlanImpl implements _ActivePlan {
  const _$ActivePlanImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'plan_name') this.planName,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'status') this.status,
  });

  factory _$ActivePlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivePlanImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'plan_name')
  final String? planName;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'status')
  final String? status;

  @override
  String toString() {
    return 'ActivePlan(id: $id, planName: $planName, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivePlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, planName, startDate, endDate, status);

  /// Create a copy of ActivePlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivePlanImplCopyWith<_$ActivePlanImpl> get copyWith =>
      __$$ActivePlanImplCopyWithImpl<_$ActivePlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivePlanImplToJson(this);
  }
}

abstract class _ActivePlan implements ActivePlan {
  const factory _ActivePlan({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'plan_name') final String? planName,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
    @JsonKey(name: 'status') final String? status,
  }) = _$ActivePlanImpl;

  factory _ActivePlan.fromJson(Map<String, dynamic> json) =
      _$ActivePlanImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'plan_name')
  String? get planName;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'status')
  String? get status;

  /// Create a copy of ActivePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivePlanImplCopyWith<_$ActivePlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
