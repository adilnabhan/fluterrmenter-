// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_renewal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpcomingRenewalResponseModel _$UpcomingRenewalResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _UpcomingRenewalResponseModel.fromJson(json);
}

/// @nodoc
mixin _$UpcomingRenewalResponseModel {
  @JsonKey(name: "count")
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;
  @JsonKey(name: "results")
  List<UpcomingRenewalModel>? get results => throw _privateConstructorUsedError;

  /// Serializes this UpcomingRenewalResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingRenewalResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingRenewalResponseModelCopyWith<UpcomingRenewalResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingRenewalResponseModelCopyWith<$Res> {
  factory $UpcomingRenewalResponseModelCopyWith(
    UpcomingRenewalResponseModel value,
    $Res Function(UpcomingRenewalResponseModel) then,
  ) =
      _$UpcomingRenewalResponseModelCopyWithImpl<
        $Res,
        UpcomingRenewalResponseModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: "count") int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: "results") List<UpcomingRenewalModel>? results,
  });
}

/// @nodoc
class _$UpcomingRenewalResponseModelCopyWithImpl<
  $Res,
  $Val extends UpcomingRenewalResponseModel
>
    implements $UpcomingRenewalResponseModelCopyWith<$Res> {
  _$UpcomingRenewalResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingRenewalResponseModel
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
                        as List<UpcomingRenewalModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpcomingRenewalResponseModelImplCopyWith<$Res>
    implements $UpcomingRenewalResponseModelCopyWith<$Res> {
  factory _$$UpcomingRenewalResponseModelImplCopyWith(
    _$UpcomingRenewalResponseModelImpl value,
    $Res Function(_$UpcomingRenewalResponseModelImpl) then,
  ) = __$$UpcomingRenewalResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "count") int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: "results") List<UpcomingRenewalModel>? results,
  });
}

/// @nodoc
class __$$UpcomingRenewalResponseModelImplCopyWithImpl<$Res>
    extends
        _$UpcomingRenewalResponseModelCopyWithImpl<
          $Res,
          _$UpcomingRenewalResponseModelImpl
        >
    implements _$$UpcomingRenewalResponseModelImplCopyWith<$Res> {
  __$$UpcomingRenewalResponseModelImplCopyWithImpl(
    _$UpcomingRenewalResponseModelImpl _value,
    $Res Function(_$UpcomingRenewalResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpcomingRenewalResponseModel
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
      _$UpcomingRenewalResponseModelImpl(
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
                    as List<UpcomingRenewalModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingRenewalResponseModelImpl
    implements _UpcomingRenewalResponseModel {
  const _$UpcomingRenewalResponseModelImpl({
    @JsonKey(name: "count") this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: "results") final List<UpcomingRenewalModel>? results,
  }) : _results = results;

  factory _$UpcomingRenewalResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UpcomingRenewalResponseModelImplFromJson(json);

  @override
  @JsonKey(name: "count")
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;
  final List<UpcomingRenewalModel>? _results;
  @override
  @JsonKey(name: "results")
  List<UpcomingRenewalModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'UpcomingRenewalResponseModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingRenewalResponseModelImpl &&
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

  /// Create a copy of UpcomingRenewalResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingRenewalResponseModelImplCopyWith<
    _$UpcomingRenewalResponseModelImpl
  >
  get copyWith => __$$UpcomingRenewalResponseModelImplCopyWithImpl<
    _$UpcomingRenewalResponseModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingRenewalResponseModelImplToJson(this);
  }
}

abstract class _UpcomingRenewalResponseModel
    implements UpcomingRenewalResponseModel {
  const factory _UpcomingRenewalResponseModel({
    @JsonKey(name: "count") final int? count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final String? previous,
    @JsonKey(name: "results") final List<UpcomingRenewalModel>? results,
  }) = _$UpcomingRenewalResponseModelImpl;

  factory _UpcomingRenewalResponseModel.fromJson(Map<String, dynamic> json) =
      _$UpcomingRenewalResponseModelImpl.fromJson;

  @override
  @JsonKey(name: "count")
  int? get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  String? get previous;
  @override
  @JsonKey(name: "results")
  List<UpcomingRenewalModel>? get results;

  /// Create a copy of UpcomingRenewalResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingRenewalResponseModelImplCopyWith<
    _$UpcomingRenewalResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

UpcomingRenewalModel _$UpcomingRenewalModelFromJson(Map<String, dynamic> json) {
  return _UpcomingRenewalModel.fromJson(json);
}

/// @nodoc
mixin _$UpcomingRenewalModel {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "phone")
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: "whatsapp_link")
  String? get whatsappLink => throw _privateConstructorUsedError;
  @JsonKey(name: "profile_image")
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: "membership_name")
  String? get membershipName => throw _privateConstructorUsedError;
  @JsonKey(name: "renewal_date")
  String? get renewalDate => throw _privateConstructorUsedError;
  @JsonKey(name: "days_remaining")
  int? get daysRemaining => throw _privateConstructorUsedError;
  @JsonKey(name: "expiry_label")
  String? get expiryLabel => throw _privateConstructorUsedError;

  /// Serializes this UpcomingRenewalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingRenewalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingRenewalModelCopyWith<UpcomingRenewalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingRenewalModelCopyWith<$Res> {
  factory $UpcomingRenewalModelCopyWith(
    UpcomingRenewalModel value,
    $Res Function(UpcomingRenewalModel) then,
  ) = _$UpcomingRenewalModelCopyWithImpl<$Res, UpcomingRenewalModel>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "whatsapp_link") String? whatsappLink,
    @JsonKey(name: "profile_image") String? profileImage,
    @JsonKey(name: "membership_name") String? membershipName,
    @JsonKey(name: "renewal_date") String? renewalDate,
    @JsonKey(name: "days_remaining") int? daysRemaining,
    @JsonKey(name: "expiry_label") String? expiryLabel,
  });
}

/// @nodoc
class _$UpcomingRenewalModelCopyWithImpl<
  $Res,
  $Val extends UpcomingRenewalModel
>
    implements $UpcomingRenewalModelCopyWith<$Res> {
  _$UpcomingRenewalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingRenewalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? whatsappLink = freezed,
    Object? profileImage = freezed,
    Object? membershipName = freezed,
    Object? renewalDate = freezed,
    Object? daysRemaining = freezed,
    Object? expiryLabel = freezed,
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
            phone:
                freezed == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String?,
            whatsappLink:
                freezed == whatsappLink
                    ? _value.whatsappLink
                    : whatsappLink // ignore: cast_nullable_to_non_nullable
                        as String?,
            profileImage:
                freezed == profileImage
                    ? _value.profileImage
                    : profileImage // ignore: cast_nullable_to_non_nullable
                        as String?,
            membershipName:
                freezed == membershipName
                    ? _value.membershipName
                    : membershipName // ignore: cast_nullable_to_non_nullable
                        as String?,
            renewalDate:
                freezed == renewalDate
                    ? _value.renewalDate
                    : renewalDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            daysRemaining:
                freezed == daysRemaining
                    ? _value.daysRemaining
                    : daysRemaining // ignore: cast_nullable_to_non_nullable
                        as int?,
            expiryLabel:
                freezed == expiryLabel
                    ? _value.expiryLabel
                    : expiryLabel // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpcomingRenewalModelImplCopyWith<$Res>
    implements $UpcomingRenewalModelCopyWith<$Res> {
  factory _$$UpcomingRenewalModelImplCopyWith(
    _$UpcomingRenewalModelImpl value,
    $Res Function(_$UpcomingRenewalModelImpl) then,
  ) = __$$UpcomingRenewalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "whatsapp_link") String? whatsappLink,
    @JsonKey(name: "profile_image") String? profileImage,
    @JsonKey(name: "membership_name") String? membershipName,
    @JsonKey(name: "renewal_date") String? renewalDate,
    @JsonKey(name: "days_remaining") int? daysRemaining,
    @JsonKey(name: "expiry_label") String? expiryLabel,
  });
}

/// @nodoc
class __$$UpcomingRenewalModelImplCopyWithImpl<$Res>
    extends _$UpcomingRenewalModelCopyWithImpl<$Res, _$UpcomingRenewalModelImpl>
    implements _$$UpcomingRenewalModelImplCopyWith<$Res> {
  __$$UpcomingRenewalModelImplCopyWithImpl(
    _$UpcomingRenewalModelImpl _value,
    $Res Function(_$UpcomingRenewalModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpcomingRenewalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? whatsappLink = freezed,
    Object? profileImage = freezed,
    Object? membershipName = freezed,
    Object? renewalDate = freezed,
    Object? daysRemaining = freezed,
    Object? expiryLabel = freezed,
  }) {
    return _then(
      _$UpcomingRenewalModelImpl(
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
        phone:
            freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String?,
        whatsappLink:
            freezed == whatsappLink
                ? _value.whatsappLink
                : whatsappLink // ignore: cast_nullable_to_non_nullable
                    as String?,
        profileImage:
            freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                    as String?,
        membershipName:
            freezed == membershipName
                ? _value.membershipName
                : membershipName // ignore: cast_nullable_to_non_nullable
                    as String?,
        renewalDate:
            freezed == renewalDate
                ? _value.renewalDate
                : renewalDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        daysRemaining:
            freezed == daysRemaining
                ? _value.daysRemaining
                : daysRemaining // ignore: cast_nullable_to_non_nullable
                    as int?,
        expiryLabel:
            freezed == expiryLabel
                ? _value.expiryLabel
                : expiryLabel // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingRenewalModelImpl implements _UpcomingRenewalModel {
  const _$UpcomingRenewalModelImpl({
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "phone") this.phone,
    @JsonKey(name: "whatsapp_link") this.whatsappLink,
    @JsonKey(name: "profile_image") this.profileImage,
    @JsonKey(name: "membership_name") this.membershipName,
    @JsonKey(name: "renewal_date") this.renewalDate,
    @JsonKey(name: "days_remaining") this.daysRemaining,
    @JsonKey(name: "expiry_label") this.expiryLabel,
  });

  factory _$UpcomingRenewalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpcomingRenewalModelImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "phone")
  final String? phone;
  @override
  @JsonKey(name: "whatsapp_link")
  final String? whatsappLink;
  @override
  @JsonKey(name: "profile_image")
  final String? profileImage;
  @override
  @JsonKey(name: "membership_name")
  final String? membershipName;
  @override
  @JsonKey(name: "renewal_date")
  final String? renewalDate;
  @override
  @JsonKey(name: "days_remaining")
  final int? daysRemaining;
  @override
  @JsonKey(name: "expiry_label")
  final String? expiryLabel;

  @override
  String toString() {
    return 'UpcomingRenewalModel(id: $id, name: $name, phone: $phone, whatsappLink: $whatsappLink, profileImage: $profileImage, membershipName: $membershipName, renewalDate: $renewalDate, daysRemaining: $daysRemaining, expiryLabel: $expiryLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingRenewalModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.whatsappLink, whatsappLink) ||
                other.whatsappLink == whatsappLink) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.membershipName, membershipName) ||
                other.membershipName == membershipName) &&
            (identical(other.renewalDate, renewalDate) ||
                other.renewalDate == renewalDate) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining) &&
            (identical(other.expiryLabel, expiryLabel) ||
                other.expiryLabel == expiryLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    phone,
    whatsappLink,
    profileImage,
    membershipName,
    renewalDate,
    daysRemaining,
    expiryLabel,
  );

  /// Create a copy of UpcomingRenewalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingRenewalModelImplCopyWith<_$UpcomingRenewalModelImpl>
  get copyWith =>
      __$$UpcomingRenewalModelImplCopyWithImpl<_$UpcomingRenewalModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingRenewalModelImplToJson(this);
  }
}

abstract class _UpcomingRenewalModel implements UpcomingRenewalModel {
  const factory _UpcomingRenewalModel({
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "phone") final String? phone,
    @JsonKey(name: "whatsapp_link") final String? whatsappLink,
    @JsonKey(name: "profile_image") final String? profileImage,
    @JsonKey(name: "membership_name") final String? membershipName,
    @JsonKey(name: "renewal_date") final String? renewalDate,
    @JsonKey(name: "days_remaining") final int? daysRemaining,
    @JsonKey(name: "expiry_label") final String? expiryLabel,
  }) = _$UpcomingRenewalModelImpl;

  factory _UpcomingRenewalModel.fromJson(Map<String, dynamic> json) =
      _$UpcomingRenewalModelImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "phone")
  String? get phone;
  @override
  @JsonKey(name: "whatsapp_link")
  String? get whatsappLink;
  @override
  @JsonKey(name: "profile_image")
  String? get profileImage;
  @override
  @JsonKey(name: "membership_name")
  String? get membershipName;
  @override
  @JsonKey(name: "renewal_date")
  String? get renewalDate;
  @override
  @JsonKey(name: "days_remaining")
  int? get daysRemaining;
  @override
  @JsonKey(name: "expiry_label")
  String? get expiryLabel;

  /// Create a copy of UpcomingRenewalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingRenewalModelImplCopyWith<_$UpcomingRenewalModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
