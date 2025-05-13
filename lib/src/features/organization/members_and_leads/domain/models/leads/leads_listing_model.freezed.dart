// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leads_listing_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeadsListingModel _$LeadsListingModelFromJson(Map<String, dynamic> json) {
  return _LeadsListingModel.fromJson(json);
}

/// @nodoc
mixin _$LeadsListingModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  List<Result>? get results => throw _privateConstructorUsedError;

  /// Serializes this LeadsListingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadsListingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadsListingModelCopyWith<LeadsListingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadsListingModelCopyWith<$Res> {
  factory $LeadsListingModelCopyWith(
          LeadsListingModel value, $Res Function(LeadsListingModel) then) =
      _$LeadsListingModelCopyWithImpl<$Res, LeadsListingModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'count') int? count,
      @JsonKey(name: 'next') String? next,
      @JsonKey(name: 'previous') String? previous,
      @JsonKey(name: 'results') List<Result>? results});
}

/// @nodoc
class _$LeadsListingModelCopyWithImpl<$Res, $Val extends LeadsListingModel>
    implements $LeadsListingModelCopyWith<$Res> {
  _$LeadsListingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadsListingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(_value.copyWith(
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      next: freezed == next
          ? _value.next
          : next // ignore: cast_nullable_to_non_nullable
              as String?,
      previous: freezed == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as String?,
      results: freezed == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<Result>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeadsListingModelImplCopyWith<$Res>
    implements $LeadsListingModelCopyWith<$Res> {
  factory _$$LeadsListingModelImplCopyWith(_$LeadsListingModelImpl value,
          $Res Function(_$LeadsListingModelImpl) then) =
      __$$LeadsListingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'count') int? count,
      @JsonKey(name: 'next') String? next,
      @JsonKey(name: 'previous') String? previous,
      @JsonKey(name: 'results') List<Result>? results});
}

/// @nodoc
class __$$LeadsListingModelImplCopyWithImpl<$Res>
    extends _$LeadsListingModelCopyWithImpl<$Res, _$LeadsListingModelImpl>
    implements _$$LeadsListingModelImplCopyWith<$Res> {
  __$$LeadsListingModelImplCopyWithImpl(_$LeadsListingModelImpl _value,
      $Res Function(_$LeadsListingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeadsListingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(_$LeadsListingModelImpl(
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      next: freezed == next
          ? _value.next
          : next // ignore: cast_nullable_to_non_nullable
              as String?,
      previous: freezed == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as String?,
      results: freezed == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<Result>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadsListingModelImpl implements _LeadsListingModel {
  const _$LeadsListingModelImpl(
      {@JsonKey(name: 'count') this.count,
      @JsonKey(name: 'next') this.next,
      @JsonKey(name: 'previous') this.previous,
      @JsonKey(name: 'results') final List<Result>? results})
      : _results = results;

  factory _$LeadsListingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadsListingModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;
  final List<Result>? _results;
  @override
  @JsonKey(name: 'results')
  List<Result>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LeadsListingModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadsListingModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, count, next, previous,
      const DeepCollectionEquality().hash(_results));

  /// Create a copy of LeadsListingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadsListingModelImplCopyWith<_$LeadsListingModelImpl> get copyWith =>
      __$$LeadsListingModelImplCopyWithImpl<_$LeadsListingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadsListingModelImplToJson(
      this,
    );
  }
}

abstract class _LeadsListingModel implements LeadsListingModel {
  const factory _LeadsListingModel(
          {@JsonKey(name: 'count') final int? count,
          @JsonKey(name: 'next') final String? next,
          @JsonKey(name: 'previous') final String? previous,
          @JsonKey(name: 'results') final List<Result>? results}) =
      _$LeadsListingModelImpl;

  factory _LeadsListingModel.fromJson(Map<String, dynamic> json) =
      _$LeadsListingModelImpl.fromJson;

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
  List<Result>? get results;

  /// Create a copy of LeadsListingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadsListingModelImplCopyWith<_$LeadsListingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Result _$ResultFromJson(Map<String, dynamic> json) {
  return _Result.fromJson(json);
}

/// @nodoc
mixin _$Result {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'designation')
  String? get designation => throw _privateConstructorUsedError;
  @JsonKey(name: 'created')
  DateTime? get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories')
  List<String>? get categories => throw _privateConstructorUsedError;

  /// Serializes this Result to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultCopyWith<Result> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<$Res> {
  factory $ResultCopyWith(Result value, $Res Function(Result) then) =
      _$ResultCopyWithImpl<$Res, Result>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'name') String? name,
      @JsonKey(name: 'mobile_number') String? mobileNumber,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'designation') String? designation,
      @JsonKey(name: 'created') DateTime? created,
      @JsonKey(name: 'profile_picture') dynamic profilePicture,
      @JsonKey(name: 'categories') List<String>? categories});
}

/// @nodoc
class _$ResultCopyWithImpl<$Res, $Val extends Result>
    implements $ResultCopyWith<$Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? name = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? designation = freezed,
    Object? created = freezed,
    Object? profilePicture = freezed,
    Object? categories = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _value.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      designation: freezed == designation
          ? _value.designation
          : designation // ignore: cast_nullable_to_non_nullable
              as String?,
      created: freezed == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as dynamic,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResultImplCopyWith<$Res> implements $ResultCopyWith<$Res> {
  factory _$$ResultImplCopyWith(
          _$ResultImpl value, $Res Function(_$ResultImpl) then) =
      __$$ResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'name') String? name,
      @JsonKey(name: 'mobile_number') String? mobileNumber,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'designation') String? designation,
      @JsonKey(name: 'created') DateTime? created,
      @JsonKey(name: 'profile_picture') dynamic profilePicture,
      @JsonKey(name: 'categories') List<String>? categories});
}

/// @nodoc
class __$$ResultImplCopyWithImpl<$Res>
    extends _$ResultCopyWithImpl<$Res, _$ResultImpl>
    implements _$$ResultImplCopyWith<$Res> {
  __$$ResultImplCopyWithImpl(
      _$ResultImpl _value, $Res Function(_$ResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? name = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? designation = freezed,
    Object? created = freezed,
    Object? profilePicture = freezed,
    Object? categories = freezed,
  }) {
    return _then(_$ResultImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _value.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      designation: freezed == designation
          ? _value.designation
          : designation // ignore: cast_nullable_to_non_nullable
              as String?,
      created: freezed == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as dynamic,
      categories: freezed == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultImpl implements _Result {
  const _$ResultImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'name') this.name,
      @JsonKey(name: 'mobile_number') this.mobileNumber,
      @JsonKey(name: 'email') this.email,
      @JsonKey(name: 'designation') this.designation,
      @JsonKey(name: 'created') this.created,
      @JsonKey(name: 'profile_picture') this.profilePicture,
      @JsonKey(name: 'categories') final List<String>? categories})
      : _categories = categories;

  factory _$ResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'designation')
  final String? designation;
  @override
  @JsonKey(name: 'created')
  final DateTime? created;
  @override
  @JsonKey(name: 'profile_picture')
  final dynamic profilePicture;
  final List<String>? _categories;
  @override
  @JsonKey(name: 'categories')
  List<String>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Result(id: $id, userId: $userId, name: $name, mobileNumber: $mobileNumber, email: $email, designation: $designation, created: $created, profilePicture: $profilePicture, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.created, created) || other.created == created) &&
            const DeepCollectionEquality()
                .equals(other.profilePicture, profilePicture) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      mobileNumber,
      email,
      designation,
      created,
      const DeepCollectionEquality().hash(profilePicture),
      const DeepCollectionEquality().hash(_categories));

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultImplCopyWith<_$ResultImpl> get copyWith =>
      __$$ResultImplCopyWithImpl<_$ResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultImplToJson(
      this,
    );
  }
}

abstract class _Result implements Result {
  const factory _Result(
          {@JsonKey(name: 'id') final int? id,
          @JsonKey(name: 'user_id') final String? userId,
          @JsonKey(name: 'name') final String? name,
          @JsonKey(name: 'mobile_number') final String? mobileNumber,
          @JsonKey(name: 'email') final String? email,
          @JsonKey(name: 'designation') final String? designation,
          @JsonKey(name: 'created') final DateTime? created,
          @JsonKey(name: 'profile_picture') final dynamic profilePicture,
          @JsonKey(name: 'categories') final List<String>? categories}) =
      _$ResultImpl;

  factory _Result.fromJson(Map<String, dynamic> json) = _$ResultImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'designation')
  String? get designation;
  @override
  @JsonKey(name: 'created')
  DateTime? get created;
  @override
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture;
  @override
  @JsonKey(name: 'categories')
  List<String>? get categories;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultImplCopyWith<_$ResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
