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
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "customer_details")
  CustomerDetails get customerDetails => throw _privateConstructorUsedError;
  @JsonKey(name: "plan_details")
  PlanDetails get planDetails => throw _privateConstructorUsedError;
  @JsonKey(name: "end_date")
  DateTime get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: "days_until_expire")
  int get daysUntilExpire => throw _privateConstructorUsedError;

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
    @JsonKey(name: "id") int id,
    @JsonKey(name: "customer_details") CustomerDetails customerDetails,
    @JsonKey(name: "plan_details") PlanDetails planDetails,
    @JsonKey(name: "end_date") DateTime endDate,
    @JsonKey(name: "days_until_expire") int daysUntilExpire,
  });

  $CustomerDetailsCopyWith<$Res> get customerDetails;
  $PlanDetailsCopyWith<$Res> get planDetails;
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
    Object? id = null,
    Object? customerDetails = null,
    Object? planDetails = null,
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
            planDetails:
                null == planDetails
                    ? _value.planDetails
                    : planDetails // ignore: cast_nullable_to_non_nullable
                        as PlanDetails,
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

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerDetailsCopyWith<$Res> get customerDetails {
    return $CustomerDetailsCopyWith<$Res>(_value.customerDetails, (value) {
      return _then(_value.copyWith(customerDetails: value) as $Val);
    });
  }

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlanDetailsCopyWith<$Res> get planDetails {
    return $PlanDetailsCopyWith<$Res>(_value.planDetails, (value) {
      return _then(_value.copyWith(planDetails: value) as $Val);
    });
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
    @JsonKey(name: "id") int id,
    @JsonKey(name: "customer_details") CustomerDetails customerDetails,
    @JsonKey(name: "plan_details") PlanDetails planDetails,
    @JsonKey(name: "end_date") DateTime endDate,
    @JsonKey(name: "days_until_expire") int daysUntilExpire,
  });

  @override
  $CustomerDetailsCopyWith<$Res> get customerDetails;
  @override
  $PlanDetailsCopyWith<$Res> get planDetails;
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
    Object? id = null,
    Object? customerDetails = null,
    Object? planDetails = null,
    Object? endDate = null,
    Object? daysUntilExpire = null,
  }) {
    return _then(
      _$UpComingPaymentsImpl(
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
        planDetails:
            null == planDetails
                ? _value.planDetails
                : planDetails // ignore: cast_nullable_to_non_nullable
                    as PlanDetails,
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
class _$UpComingPaymentsImpl implements _UpComingPayments {
  const _$UpComingPaymentsImpl({
    @JsonKey(name: "id") required this.id,
    @JsonKey(name: "customer_details") required this.customerDetails,
    @JsonKey(name: "plan_details") required this.planDetails,
    @JsonKey(name: "end_date") required this.endDate,
    @JsonKey(name: "days_until_expire") required this.daysUntilExpire,
  });

  factory _$UpComingPaymentsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpComingPaymentsImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "customer_details")
  final CustomerDetails customerDetails;
  @override
  @JsonKey(name: "plan_details")
  final PlanDetails planDetails;
  @override
  @JsonKey(name: "end_date")
  final DateTime endDate;
  @override
  @JsonKey(name: "days_until_expire")
  final int daysUntilExpire;

  @override
  String toString() {
    return 'UpComingPayments(id: $id, customerDetails: $customerDetails, planDetails: $planDetails, endDate: $endDate, daysUntilExpire: $daysUntilExpire)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpComingPaymentsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerDetails, customerDetails) ||
                other.customerDetails == customerDetails) &&
            (identical(other.planDetails, planDetails) ||
                other.planDetails == planDetails) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.daysUntilExpire, daysUntilExpire) ||
                other.daysUntilExpire == daysUntilExpire));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerDetails,
    planDetails,
    endDate,
    daysUntilExpire,
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
    @JsonKey(name: "id") required final int id,
    @JsonKey(name: "customer_details")
    required final CustomerDetails customerDetails,
    @JsonKey(name: "plan_details") required final PlanDetails planDetails,
    @JsonKey(name: "end_date") required final DateTime endDate,
    @JsonKey(name: "days_until_expire") required final int daysUntilExpire,
  }) = _$UpComingPaymentsImpl;

  factory _UpComingPayments.fromJson(Map<String, dynamic> json) =
      _$UpComingPaymentsImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "customer_details")
  CustomerDetails get customerDetails;
  @override
  @JsonKey(name: "plan_details")
  PlanDetails get planDetails;
  @override
  @JsonKey(name: "end_date")
  DateTime get endDate;
  @override
  @JsonKey(name: "days_until_expire")
  int get daysUntilExpire;

  /// Create a copy of UpComingPayments
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpComingPaymentsImplCopyWith<_$UpComingPaymentsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerDetails _$CustomerDetailsFromJson(Map<String, dynamic> json) {
  return _CustomerDetails.fromJson(json);
}

/// @nodoc
mixin _$CustomerDetails {
  @JsonKey(name: "full_name")
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: "email")
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: "mobile_number")
  String get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  String? get image => throw _privateConstructorUsedError;

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
    @JsonKey(name: "full_name") String fullName,
    @JsonKey(name: "email") String email,
    @JsonKey(name: "mobile_number") String mobileNumber,
    @JsonKey(name: "image") String? image,
  });
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
    Object? fullName = null,
    Object? email = null,
    Object? mobileNumber = null,
    Object? image = freezed,
  }) {
    return _then(
      _value.copyWith(
            fullName:
                null == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            mobileNumber:
                null == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            image:
                freezed == image
                    ? _value.image
                    : image // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
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
    @JsonKey(name: "full_name") String fullName,
    @JsonKey(name: "email") String email,
    @JsonKey(name: "mobile_number") String mobileNumber,
    @JsonKey(name: "image") String? image,
  });
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
    Object? fullName = null,
    Object? email = null,
    Object? mobileNumber = null,
    Object? image = freezed,
  }) {
    return _then(
      _$CustomerDetailsImpl(
        fullName:
            null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        mobileNumber:
            null == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        image:
            freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerDetailsImpl implements _CustomerDetails {
  const _$CustomerDetailsImpl({
    @JsonKey(name: "full_name") required this.fullName,
    @JsonKey(name: "email") required this.email,
    @JsonKey(name: "mobile_number") required this.mobileNumber,
    @JsonKey(name: "image") this.image,
  });

  factory _$CustomerDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerDetailsImplFromJson(json);

  @override
  @JsonKey(name: "full_name")
  final String fullName;
  @override
  @JsonKey(name: "email")
  final String email;
  @override
  @JsonKey(name: "mobile_number")
  final String mobileNumber;
  @override
  @JsonKey(name: "image")
  final String? image;

  @override
  String toString() {
    return 'CustomerDetails(fullName: $fullName, email: $email, mobileNumber: $mobileNumber, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerDetailsImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fullName, email, mobileNumber, image);

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
    @JsonKey(name: "full_name") required final String fullName,
    @JsonKey(name: "email") required final String email,
    @JsonKey(name: "mobile_number") required final String mobileNumber,
    @JsonKey(name: "image") final String? image,
  }) = _$CustomerDetailsImpl;

  factory _CustomerDetails.fromJson(Map<String, dynamic> json) =
      _$CustomerDetailsImpl.fromJson;

  @override
  @JsonKey(name: "full_name")
  String get fullName;
  @override
  @JsonKey(name: "email")
  String get email;
  @override
  @JsonKey(name: "mobile_number")
  String get mobileNumber;
  @override
  @JsonKey(name: "image")
  String? get image;

  /// Create a copy of CustomerDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerDetailsImplCopyWith<_$CustomerDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanDetails _$PlanDetailsFromJson(Map<String, dynamic> json) {
  return _PlanDetails.fromJson(json);
}

/// @nodoc
mixin _$PlanDetails {
  @JsonKey(name: "name")
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: "package_type")
  String get packageType => throw _privateConstructorUsedError;

  /// Serializes this PlanDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanDetailsCopyWith<PlanDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanDetailsCopyWith<$Res> {
  factory $PlanDetailsCopyWith(
    PlanDetails value,
    $Res Function(PlanDetails) then,
  ) = _$PlanDetailsCopyWithImpl<$Res, PlanDetails>;
  @useResult
  $Res call({
    @JsonKey(name: "name") String name,
    @JsonKey(name: "package_type") String packageType,
  });
}

/// @nodoc
class _$PlanDetailsCopyWithImpl<$Res, $Val extends PlanDetails>
    implements $PlanDetailsCopyWith<$Res> {
  _$PlanDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? packageType = null}) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            packageType:
                null == packageType
                    ? _value.packageType
                    : packageType // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanDetailsImplCopyWith<$Res>
    implements $PlanDetailsCopyWith<$Res> {
  factory _$$PlanDetailsImplCopyWith(
    _$PlanDetailsImpl value,
    $Res Function(_$PlanDetailsImpl) then,
  ) = __$$PlanDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "name") String name,
    @JsonKey(name: "package_type") String packageType,
  });
}

/// @nodoc
class __$$PlanDetailsImplCopyWithImpl<$Res>
    extends _$PlanDetailsCopyWithImpl<$Res, _$PlanDetailsImpl>
    implements _$$PlanDetailsImplCopyWith<$Res> {
  __$$PlanDetailsImplCopyWithImpl(
    _$PlanDetailsImpl _value,
    $Res Function(_$PlanDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? packageType = null}) {
    return _then(
      _$PlanDetailsImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        packageType:
            null == packageType
                ? _value.packageType
                : packageType // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanDetailsImpl implements _PlanDetails {
  const _$PlanDetailsImpl({
    @JsonKey(name: "name") required this.name,
    @JsonKey(name: "package_type") required this.packageType,
  });

  factory _$PlanDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanDetailsImplFromJson(json);

  @override
  @JsonKey(name: "name")
  final String name;
  @override
  @JsonKey(name: "package_type")
  final String packageType;

  @override
  String toString() {
    return 'PlanDetails(name: $name, packageType: $packageType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanDetailsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, packageType);

  /// Create a copy of PlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanDetailsImplCopyWith<_$PlanDetailsImpl> get copyWith =>
      __$$PlanDetailsImplCopyWithImpl<_$PlanDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanDetailsImplToJson(this);
  }
}

abstract class _PlanDetails implements PlanDetails {
  const factory _PlanDetails({
    @JsonKey(name: "name") required final String name,
    @JsonKey(name: "package_type") required final String packageType,
  }) = _$PlanDetailsImpl;

  factory _PlanDetails.fromJson(Map<String, dynamic> json) =
      _$PlanDetailsImpl.fromJson;

  @override
  @JsonKey(name: "name")
  String get name;
  @override
  @JsonKey(name: "package_type")
  String get packageType;

  /// Create a copy of PlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanDetailsImplCopyWith<_$PlanDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
