// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_payments_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpComingPayments _$UpComingPaymentsFromJson(Map<String, dynamic> json) {
  return _UpComingPayments.fromJson(json);
}

/// @nodoc
mixin _$UpComingPayments {
  @JsonKey(name: "count")
  int get count => throw _privateConstructorUsedError;
  @JsonKey(name: "next")
  dynamic get next => throw _privateConstructorUsedError;
  @JsonKey(name: "previous")
  dynamic get previous => throw _privateConstructorUsedError;
  @JsonKey(name: "results")
  List<UpComingPaymentsList> get results => throw _privateConstructorUsedError;

  /// Serializes this UpComingPayments to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpComingPaymentsCopyWith<UpComingPayments> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpComingPaymentsCopyWith<$Res> {
  factory $UpComingPaymentsCopyWith(
    UpComingPayments value,
    $Res Function(UpComingPayments) then,
  ) = _$UpComingPaymentsCopyWithImpl<$Res, UpComingPayments>;
  @useResult
  $Res call({
    @JsonKey(name: "count") int count,
    @JsonKey(name: "next") dynamic next,
    @JsonKey(name: "previous") dynamic previous,
    @JsonKey(name: "results") List<UpComingPaymentsList> results,
  });
}

/// @nodoc
class _$UpComingPaymentsCopyWithImpl<$Res, $Val extends UpComingPayments>
    implements $UpComingPaymentsCopyWith<$Res> {
  _$UpComingPaymentsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = null,
  }) {
    return _then(
      _value.copyWith(
            count:
                null == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int,
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
                null == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<UpComingPaymentsList>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpComingPaymentsImplCopyWith<$Res>
    implements $UpComingPaymentsCopyWith<$Res> {
  factory _$$UpComingPaymentsImplCopyWith(
    _$UpComingPaymentsImpl value,
    $Res Function(_$UpComingPaymentsImpl) then,
  ) = __$$UpComingPaymentsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "count") int count,
    @JsonKey(name: "next") dynamic next,
    @JsonKey(name: "previous") dynamic previous,
    @JsonKey(name: "results") List<UpComingPaymentsList> results,
  });
}

/// @nodoc
class __$$UpComingPaymentsImplCopyWithImpl<$Res>
    extends _$UpComingPaymentsCopyWithImpl<$Res, _$UpComingPaymentsImpl>
    implements _$$UpComingPaymentsImplCopyWith<$Res> {
  __$$UpComingPaymentsImplCopyWithImpl(
    _$UpComingPaymentsImpl _value,
    $Res Function(_$UpComingPaymentsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = null,
  }) {
    return _then(
      _$UpComingPaymentsImpl(
        count:
            null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int,
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
            null == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<UpComingPaymentsList>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpComingPaymentsImpl implements _UpComingPayments {
  const _$UpComingPaymentsImpl({
    @JsonKey(name: "count") required this.count,
    @JsonKey(name: "next") this.next,
    @JsonKey(name: "previous") this.previous,
    @JsonKey(name: "results") required final List<UpComingPaymentsList> results,
  }) : _results = results;

  factory _$UpComingPaymentsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpComingPaymentsImplFromJson(json);

  @override
  @JsonKey(name: "count")
  final int count;
  @override
  @JsonKey(name: "next")
  final dynamic next;
  @override
  @JsonKey(name: "previous")
  final dynamic previous;
  final List<UpComingPaymentsList> _results;
  @override
  @JsonKey(name: "results")
  List<UpComingPaymentsList> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'UpComingPayments(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpComingPaymentsImpl &&
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

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpComingPaymentsImplCopyWith<_$UpComingPaymentsImpl> get copyWith =>
      __$$UpComingPaymentsImplCopyWithImpl<_$UpComingPaymentsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpComingPaymentsImplToJson(this);
  }
}

abstract class _UpComingPayments implements UpComingPayments {
  const factory _UpComingPayments({
    @JsonKey(name: "count") required final int count,
    @JsonKey(name: "next") final dynamic next,
    @JsonKey(name: "previous") final dynamic previous,
    @JsonKey(name: "results") required final List<UpComingPaymentsList> results,
  }) = _$UpComingPaymentsImpl;

  factory _UpComingPayments.fromJson(Map<String, dynamic> json) =
      _$UpComingPaymentsImpl.fromJson;

  @override
  @JsonKey(name: "count")
  int get count;
  @override
  @JsonKey(name: "next")
  dynamic get next;
  @override
  @JsonKey(name: "previous")
  dynamic get previous;
  @override
  @JsonKey(name: "results")
  List<UpComingPaymentsList> get results;

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpComingPaymentsImplCopyWith<_$UpComingPaymentsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpComingPaymentsList _$UpComingPaymentsListFromJson(Map<String, dynamic> json) {
  return _UpComingPaymentsList.fromJson(json);
}

/// @nodoc
mixin _$UpComingPaymentsList {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "customer_details")
  CustomerDetails get customerDetails => throw _privateConstructorUsedError;
  @JsonKey(name: "end_date")
  DateTime get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: "days_until_expire")
  int get daysUntilExpire => throw _privateConstructorUsedError;

  /// Serializes this UpComingPaymentsList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpComingPaymentsList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpComingPaymentsListCopyWith<UpComingPaymentsList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpComingPaymentsListCopyWith<$Res> {
  factory $UpComingPaymentsListCopyWith(
    UpComingPaymentsList value,
    $Res Function(UpComingPaymentsList) then,
  ) = _$UpComingPaymentsListCopyWithImpl<$Res, UpComingPaymentsList>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "customer_details") CustomerDetails customerDetails,
    @JsonKey(name: "end_date") DateTime endDate,
    @JsonKey(name: "days_until_expire") int daysUntilExpire,
  });

  $CustomerDetailsCopyWith<$Res> get customerDetails;
}

/// @nodoc
class _$UpComingPaymentsListCopyWithImpl<
  $Res,
  $Val extends UpComingPaymentsList
>
    implements $UpComingPaymentsListCopyWith<$Res> {
  _$UpComingPaymentsListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpComingPaymentsList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerDetails = null,
    Object? endDate = null,
    Object? daysUntilExpire = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            customerDetails:
                null == customerDetails
                    ? _value.customerDetails
                    : customerDetails // ignore: cast_nullable_to_non_nullable
                        as CustomerDetails,
            endDate:
                null == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            daysUntilExpire:
                null == daysUntilExpire
                    ? _value.daysUntilExpire
                    : daysUntilExpire // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }

  /// Create a copy of UpComingPaymentsList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerDetailsCopyWith<$Res> get customerDetails {
    return $CustomerDetailsCopyWith<$Res>(_value.customerDetails, (value) {
      return _then(_value.copyWith(customerDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpComingPaymentsListImplCopyWith<$Res>
    implements $UpComingPaymentsListCopyWith<$Res> {
  factory _$$UpComingPaymentsListImplCopyWith(
    _$UpComingPaymentsListImpl value,
    $Res Function(_$UpComingPaymentsListImpl) then,
  ) = __$$UpComingPaymentsListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "customer_details") CustomerDetails customerDetails,
    @JsonKey(name: "end_date") DateTime endDate,
    @JsonKey(name: "days_until_expire") int daysUntilExpire,
  });

  @override
  $CustomerDetailsCopyWith<$Res> get customerDetails;
}

/// @nodoc
class __$$UpComingPaymentsListImplCopyWithImpl<$Res>
    extends _$UpComingPaymentsListCopyWithImpl<$Res, _$UpComingPaymentsListImpl>
    implements _$$UpComingPaymentsListImplCopyWith<$Res> {
  __$$UpComingPaymentsListImplCopyWithImpl(
    _$UpComingPaymentsListImpl _value,
    $Res Function(_$UpComingPaymentsListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpComingPaymentsList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerDetails = null,
    Object? endDate = null,
    Object? daysUntilExpire = null,
  }) {
    return _then(
      _$UpComingPaymentsListImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        customerDetails:
            null == customerDetails
                ? _value.customerDetails
                : customerDetails // ignore: cast_nullable_to_non_nullable
                    as CustomerDetails,
        endDate:
            null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        daysUntilExpire:
            null == daysUntilExpire
                ? _value.daysUntilExpire
                : daysUntilExpire // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpComingPaymentsListImpl implements _UpComingPaymentsList {
  const _$UpComingPaymentsListImpl({
    @JsonKey(name: "id") required this.id,
    @JsonKey(name: "customer_details") required this.customerDetails,
    @JsonKey(name: "end_date") required this.endDate,
    @JsonKey(name: "days_until_expire") required this.daysUntilExpire,
  });

  factory _$UpComingPaymentsListImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpComingPaymentsListImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "customer_details")
  final CustomerDetails customerDetails;
  @override
  @JsonKey(name: "end_date")
  final DateTime endDate;
  @override
  @JsonKey(name: "days_until_expire")
  final int daysUntilExpire;

  @override
  String toString() {
    return 'UpComingPaymentsList(id: $id, customerDetails: $customerDetails, endDate: $endDate, daysUntilExpire: $daysUntilExpire)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpComingPaymentsListImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerDetails, customerDetails) ||
                other.customerDetails == customerDetails) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.daysUntilExpire, daysUntilExpire) ||
                other.daysUntilExpire == daysUntilExpire));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerDetails, endDate, daysUntilExpire);

  /// Create a copy of UpComingPaymentsList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpComingPaymentsListImplCopyWith<_$UpComingPaymentsListImpl>
  get copyWith =>
      __$$UpComingPaymentsListImplCopyWithImpl<_$UpComingPaymentsListImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpComingPaymentsListImplToJson(this);
  }
}

abstract class _UpComingPaymentsList implements UpComingPaymentsList {
  const factory _UpComingPaymentsList({
    @JsonKey(name: "id") required final int id,
    @JsonKey(name: "customer_details")
    required final CustomerDetails customerDetails,
    @JsonKey(name: "end_date") required final DateTime endDate,
    @JsonKey(name: "days_until_expire") required final int daysUntilExpire,
  }) = _$UpComingPaymentsListImpl;

  factory _UpComingPaymentsList.fromJson(Map<String, dynamic> json) =
      _$UpComingPaymentsListImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "customer_details")
  CustomerDetails get customerDetails;
  @override
  @JsonKey(name: "end_date")
  DateTime get endDate;
  @override
  @JsonKey(name: "days_until_expire")
  int get daysUntilExpire;

  /// Create a copy of UpComingPaymentsList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpComingPaymentsListImplCopyWith<_$UpComingPaymentsListImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CustomerDetails _$CustomerDetailsFromJson(Map<String, dynamic> json) {
  return _CustomerDetails.fromJson(json);
}

/// @nodoc
mixin _$CustomerDetails {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: "mobile_number")
  String get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: "profile_picture")
  String? get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: "joined_date")
  String get joinedDate => throw _privateConstructorUsedError;
  @JsonKey(name: "active_plan")
  ActivePlans get activePlans => throw _privateConstructorUsedError;

  /// Serializes this CustomerDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerDetailsCopyWith<CustomerDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerDetailsCopyWith<$Res> {
  factory $CustomerDetailsCopyWith(
    CustomerDetails value,
    $Res Function(CustomerDetails) then,
  ) = _$CustomerDetailsCopyWithImpl<$Res, CustomerDetails>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "name") String name,
    @JsonKey(name: "mobile_number") String mobileNumber,
    @JsonKey(name: "profile_picture") String? profilePicture,
    @JsonKey(name: "joined_date") String joinedDate,
    @JsonKey(name: "active_plan") ActivePlans activePlans,
  });

  $ActivePlansCopyWith<$Res> get activePlans;
}

/// @nodoc
class _$CustomerDetailsCopyWithImpl<$Res, $Val extends CustomerDetails>
    implements $CustomerDetailsCopyWith<$Res> {
  _$CustomerDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? mobileNumber = null,
    Object? profilePicture = freezed,
    Object? joinedDate = null,
    Object? activePlans = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            mobileNumber:
                null == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as String?,
            joinedDate:
                null == joinedDate
                    ? _value.joinedDate
                    : joinedDate // ignore: cast_nullable_to_non_nullable
                        as String,
            activePlans:
                null == activePlans
                    ? _value.activePlans
                    : activePlans // ignore: cast_nullable_to_non_nullable
                        as ActivePlans,
          )
          as $Val,
    );
  }

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActivePlansCopyWith<$Res> get activePlans {
    return $ActivePlansCopyWith<$Res>(_value.activePlans, (value) {
      return _then(_value.copyWith(activePlans: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerDetailsImplCopyWith<$Res>
    implements $CustomerDetailsCopyWith<$Res> {
  factory _$$CustomerDetailsImplCopyWith(
    _$CustomerDetailsImpl value,
    $Res Function(_$CustomerDetailsImpl) then,
  ) = __$$CustomerDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "name") String name,
    @JsonKey(name: "mobile_number") String mobileNumber,
    @JsonKey(name: "profile_picture") String? profilePicture,
    @JsonKey(name: "joined_date") String joinedDate,
    @JsonKey(name: "active_plan") ActivePlans activePlans,
  });

  @override
  $ActivePlansCopyWith<$Res> get activePlans;
}

/// @nodoc
class __$$CustomerDetailsImplCopyWithImpl<$Res>
    extends _$CustomerDetailsCopyWithImpl<$Res, _$CustomerDetailsImpl>
    implements _$$CustomerDetailsImplCopyWith<$Res> {
  __$$CustomerDetailsImplCopyWithImpl(
    _$CustomerDetailsImpl _value,
    $Res Function(_$CustomerDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? mobileNumber = null,
    Object? profilePicture = freezed,
    Object? joinedDate = null,
    Object? activePlans = null,
  }) {
    return _then(
      _$CustomerDetailsImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        mobileNumber:
            null == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as String?,
        joinedDate:
            null == joinedDate
                ? _value.joinedDate
                : joinedDate // ignore: cast_nullable_to_non_nullable
                    as String,
        activePlans:
            null == activePlans
                ? _value.activePlans
                : activePlans // ignore: cast_nullable_to_non_nullable
                    as ActivePlans,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerDetailsImpl implements _CustomerDetails {
  const _$CustomerDetailsImpl({
    @JsonKey(name: "id") required this.id,
    @JsonKey(name: "name") required this.name,
    @JsonKey(name: "mobile_number") required this.mobileNumber,
    @JsonKey(name: "profile_picture") this.profilePicture,
    @JsonKey(name: "joined_date") required this.joinedDate,
    @JsonKey(name: "active_plan") required this.activePlans,
  });

  factory _$CustomerDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerDetailsImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "name")
  final String name;
  @override
  @JsonKey(name: "mobile_number")
  final String mobileNumber;
  @override
  @JsonKey(name: "profile_picture")
  final String? profilePicture;
  @override
  @JsonKey(name: "joined_date")
  final String joinedDate;
  @override
  @JsonKey(name: "active_plan")
  final ActivePlans activePlans;

  @override
  String toString() {
    return 'CustomerDetails(id: $id, name: $name, mobileNumber: $mobileNumber, profilePicture: $profilePicture, joinedDate: $joinedDate, activePlans: $activePlans)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.joinedDate, joinedDate) ||
                other.joinedDate == joinedDate) &&
            (identical(other.activePlans, activePlans) ||
                other.activePlans == activePlans));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    mobileNumber,
    profilePicture,
    joinedDate,
    activePlans,
  );

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerDetailsImplCopyWith<_$CustomerDetailsImpl> get copyWith =>
      __$$CustomerDetailsImplCopyWithImpl<_$CustomerDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerDetailsImplToJson(this);
  }
}

abstract class _CustomerDetails implements CustomerDetails {
  const factory _CustomerDetails({
    @JsonKey(name: "id") required final int id,
    @JsonKey(name: "name") required final String name,
    @JsonKey(name: "mobile_number") required final String mobileNumber,
    @JsonKey(name: "profile_picture") final String? profilePicture,
    @JsonKey(name: "joined_date") required final String joinedDate,
    @JsonKey(name: "active_plan") required final ActivePlans activePlans,
  }) = _$CustomerDetailsImpl;

  factory _CustomerDetails.fromJson(Map<String, dynamic> json) =
      _$CustomerDetailsImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "name")
  String get name;
  @override
  @JsonKey(name: "mobile_number")
  String get mobileNumber;
  @override
  @JsonKey(name: "profile_picture")
  String? get profilePicture;
  @override
  @JsonKey(name: "joined_date")
  String get joinedDate;
  @override
  @JsonKey(name: "active_plan")
  ActivePlans get activePlans;

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerDetailsImplCopyWith<_$CustomerDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivePlans _$ActivePlansFromJson(Map<String, dynamic> json) {
  return _ActivePlans.fromJson(json);
}

/// @nodoc
mixin _$ActivePlans {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "plan_name")
  String get planName => throw _privateConstructorUsedError;
  @JsonKey(name: "start_date")
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: "end_date")
  DateTime get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ActivePlans to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivePlans
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivePlansCopyWith<ActivePlans> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivePlansCopyWith<$Res> {
  factory $ActivePlansCopyWith(
    ActivePlans value,
    $Res Function(ActivePlans) then,
  ) = _$ActivePlansCopyWithImpl<$Res, ActivePlans>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "plan_name") String planName,
    @JsonKey(name: "start_date") DateTime startDate,
    @JsonKey(name: "end_date") DateTime endDate,
    @JsonKey(name: "status") String status,
  });
}

/// @nodoc
class _$ActivePlansCopyWithImpl<$Res, $Val extends ActivePlans>
    implements $ActivePlansCopyWith<$Res> {
  _$ActivePlansCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivePlans
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planName = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            planName:
                null == planName
                    ? _value.planName
                    : planName // ignore: cast_nullable_to_non_nullable
                        as String,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDate:
                null == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivePlansImplCopyWith<$Res>
    implements $ActivePlansCopyWith<$Res> {
  factory _$$ActivePlansImplCopyWith(
    _$ActivePlansImpl value,
    $Res Function(_$ActivePlansImpl) then,
  ) = __$$ActivePlansImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "plan_name") String planName,
    @JsonKey(name: "start_date") DateTime startDate,
    @JsonKey(name: "end_date") DateTime endDate,
    @JsonKey(name: "status") String status,
  });
}

/// @nodoc
class __$$ActivePlansImplCopyWithImpl<$Res>
    extends _$ActivePlansCopyWithImpl<$Res, _$ActivePlansImpl>
    implements _$$ActivePlansImplCopyWith<$Res> {
  __$$ActivePlansImplCopyWithImpl(
    _$ActivePlansImpl _value,
    $Res Function(_$ActivePlansImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivePlans
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planName = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(
      _$ActivePlansImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        planName:
            null == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                    as String,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDate:
            null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivePlansImpl implements _ActivePlans {
  const _$ActivePlansImpl({
    @JsonKey(name: "id") required this.id,
    @JsonKey(name: "plan_name") required this.planName,
    @JsonKey(name: "start_date") required this.startDate,
    @JsonKey(name: "end_date") required this.endDate,
    @JsonKey(name: "status") required this.status,
  });

  factory _$ActivePlansImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivePlansImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "plan_name")
  final String planName;
  @override
  @JsonKey(name: "start_date")
  final DateTime startDate;
  @override
  @JsonKey(name: "end_date")
  final DateTime endDate;
  @override
  @JsonKey(name: "status")
  final String status;

  @override
  String toString() {
    return 'ActivePlans(id: $id, planName: $planName, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivePlansImpl &&
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

  /// Create a copy of ActivePlans
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivePlansImplCopyWith<_$ActivePlansImpl> get copyWith =>
      __$$ActivePlansImplCopyWithImpl<_$ActivePlansImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivePlansImplToJson(this);
  }
}

abstract class _ActivePlans implements ActivePlans {
  const factory _ActivePlans({
    @JsonKey(name: "id") required final int id,
    @JsonKey(name: "plan_name") required final String planName,
    @JsonKey(name: "start_date") required final DateTime startDate,
    @JsonKey(name: "end_date") required final DateTime endDate,
    @JsonKey(name: "status") required final String status,
  }) = _$ActivePlansImpl;

  factory _ActivePlans.fromJson(Map<String, dynamic> json) =
      _$ActivePlansImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "plan_name")
  String get planName;
  @override
  @JsonKey(name: "start_date")
  DateTime get startDate;
  @override
  @JsonKey(name: "end_date")
  DateTime get endDate;
  @override
  @JsonKey(name: "status")
  String get status;

  /// Create a copy of ActivePlans
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivePlansImplCopyWith<_$ActivePlansImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
