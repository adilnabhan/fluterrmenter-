// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'initiate_razorpay_payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InitiateRazorpayPaymentModel _$InitiateRazorpayPaymentModelFromJson(
  Map<String, dynamic> json,
) {
  return _InitiateRazorpayPaymentModel.fromJson(json);
}

/// @nodoc
mixin _$InitiateRazorpayPaymentModel {
  @JsonKey(name: 'id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  User? get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization')
  String? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'discipl_plan')
  DisciplPlan? get disciplPlan => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;

  /// Serializes this InitiateRazorpayPaymentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InitiateRazorpayPaymentModelCopyWith<InitiateRazorpayPaymentModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitiateRazorpayPaymentModelCopyWith<$Res> {
  factory $InitiateRazorpayPaymentModelCopyWith(
    InitiateRazorpayPaymentModel value,
    $Res Function(InitiateRazorpayPaymentModel) then,
  ) =
      _$InitiateRazorpayPaymentModelCopyWithImpl<
        $Res,
        InitiateRazorpayPaymentModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'user') User? user,
    @JsonKey(name: 'organization') String? organization,
    @JsonKey(name: 'discipl_plan') DisciplPlan? disciplPlan,
    @JsonKey(name: 'amount') String? amount,
  });

  $UserCopyWith<$Res>? get user;
  $DisciplPlanCopyWith<$Res>? get disciplPlan;
}

/// @nodoc
class _$InitiateRazorpayPaymentModelCopyWithImpl<
  $Res,
  $Val extends InitiateRazorpayPaymentModel
>
    implements $InitiateRazorpayPaymentModelCopyWith<$Res> {
  _$InitiateRazorpayPaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? orderId = freezed,
    Object? user = freezed,
    Object? organization = freezed,
    Object? disciplPlan = freezed,
    Object? amount = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            user:
                freezed == user
                    ? _value.user
                    : user // ignore: cast_nullable_to_non_nullable
                        as User?,
            organization:
                freezed == organization
                    ? _value.organization
                    : organization // ignore: cast_nullable_to_non_nullable
                        as String?,
            disciplPlan:
                freezed == disciplPlan
                    ? _value.disciplPlan
                    : disciplPlan // ignore: cast_nullable_to_non_nullable
                        as DisciplPlan?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DisciplPlanCopyWith<$Res>? get disciplPlan {
    if (_value.disciplPlan == null) {
      return null;
    }

    return $DisciplPlanCopyWith<$Res>(_value.disciplPlan!, (value) {
      return _then(_value.copyWith(disciplPlan: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InitiateRazorpayPaymentModelImplCopyWith<$Res>
    implements $InitiateRazorpayPaymentModelCopyWith<$Res> {
  factory _$$InitiateRazorpayPaymentModelImplCopyWith(
    _$InitiateRazorpayPaymentModelImpl value,
    $Res Function(_$InitiateRazorpayPaymentModelImpl) then,
  ) = __$$InitiateRazorpayPaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'user') User? user,
    @JsonKey(name: 'organization') String? organization,
    @JsonKey(name: 'discipl_plan') DisciplPlan? disciplPlan,
    @JsonKey(name: 'amount') String? amount,
  });

  @override
  $UserCopyWith<$Res>? get user;
  @override
  $DisciplPlanCopyWith<$Res>? get disciplPlan;
}

/// @nodoc
class __$$InitiateRazorpayPaymentModelImplCopyWithImpl<$Res>
    extends
        _$InitiateRazorpayPaymentModelCopyWithImpl<
          $Res,
          _$InitiateRazorpayPaymentModelImpl
        >
    implements _$$InitiateRazorpayPaymentModelImplCopyWith<$Res> {
  __$$InitiateRazorpayPaymentModelImplCopyWithImpl(
    _$InitiateRazorpayPaymentModelImpl _value,
    $Res Function(_$InitiateRazorpayPaymentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? orderId = freezed,
    Object? user = freezed,
    Object? organization = freezed,
    Object? disciplPlan = freezed,
    Object? amount = freezed,
  }) {
    return _then(
      _$InitiateRazorpayPaymentModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        user:
            freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                    as User?,
        organization:
            freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                    as String?,
        disciplPlan:
            freezed == disciplPlan
                ? _value.disciplPlan
                : disciplPlan // ignore: cast_nullable_to_non_nullable
                    as DisciplPlan?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InitiateRazorpayPaymentModelImpl
    implements _InitiateRazorpayPaymentModel {
  const _$InitiateRazorpayPaymentModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'user') this.user,
    @JsonKey(name: 'organization') this.organization,
    @JsonKey(name: 'discipl_plan') this.disciplPlan,
    @JsonKey(name: 'amount') this.amount,
  });

  factory _$InitiateRazorpayPaymentModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$InitiateRazorpayPaymentModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String? id;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'user')
  final User? user;
  @override
  @JsonKey(name: 'organization')
  final String? organization;
  @override
  @JsonKey(name: 'discipl_plan')
  final DisciplPlan? disciplPlan;
  @override
  @JsonKey(name: 'amount')
  final String? amount;

  @override
  String toString() {
    return 'InitiateRazorpayPaymentModel(id: $id, orderId: $orderId, user: $user, organization: $organization, disciplPlan: $disciplPlan, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitiateRazorpayPaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.disciplPlan, disciplPlan) ||
                other.disciplPlan == disciplPlan) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    user,
    organization,
    disciplPlan,
    amount,
  );

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InitiateRazorpayPaymentModelImplCopyWith<
    _$InitiateRazorpayPaymentModelImpl
  >
  get copyWith => __$$InitiateRazorpayPaymentModelImplCopyWithImpl<
    _$InitiateRazorpayPaymentModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InitiateRazorpayPaymentModelImplToJson(this);
  }
}

abstract class _InitiateRazorpayPaymentModel
    implements InitiateRazorpayPaymentModel {
  const factory _InitiateRazorpayPaymentModel({
    @JsonKey(name: 'id') final String? id,
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'user') final User? user,
    @JsonKey(name: 'organization') final String? organization,
    @JsonKey(name: 'discipl_plan') final DisciplPlan? disciplPlan,
    @JsonKey(name: 'amount') final String? amount,
  }) = _$InitiateRazorpayPaymentModelImpl;

  factory _InitiateRazorpayPaymentModel.fromJson(Map<String, dynamic> json) =
      _$InitiateRazorpayPaymentModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String? get id;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'user')
  User? get user;
  @override
  @JsonKey(name: 'organization')
  String? get organization;
  @override
  @JsonKey(name: 'discipl_plan')
  DisciplPlan? get disciplPlan;
  @override
  @JsonKey(name: 'amount')
  String? get amount;

  /// Create a copy of InitiateRazorpayPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InitiateRazorpayPaymentModelImplCopyWith<
    _$InitiateRazorpayPaymentModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

DisciplPlan _$DisciplPlanFromJson(Map<String, dynamic> json) {
  return _DisciplPlan.fromJson(json);
}

/// @nodoc
mixin _$DisciplPlan {
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

  /// Serializes this DisciplPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DisciplPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisciplPlanCopyWith<DisciplPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisciplPlanCopyWith<$Res> {
  factory $DisciplPlanCopyWith(
    DisciplPlan value,
    $Res Function(DisciplPlan) then,
  ) = _$DisciplPlanCopyWithImpl<$Res, DisciplPlan>;
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
class _$DisciplPlanCopyWithImpl<$Res, $Val extends DisciplPlan>
    implements $DisciplPlanCopyWith<$Res> {
  _$DisciplPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisciplPlan
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
abstract class _$$DisciplPlanImplCopyWith<$Res>
    implements $DisciplPlanCopyWith<$Res> {
  factory _$$DisciplPlanImplCopyWith(
    _$DisciplPlanImpl value,
    $Res Function(_$DisciplPlanImpl) then,
  ) = __$$DisciplPlanImplCopyWithImpl<$Res>;
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
class __$$DisciplPlanImplCopyWithImpl<$Res>
    extends _$DisciplPlanCopyWithImpl<$Res, _$DisciplPlanImpl>
    implements _$$DisciplPlanImplCopyWith<$Res> {
  __$$DisciplPlanImplCopyWithImpl(
    _$DisciplPlanImpl _value,
    $Res Function(_$DisciplPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisciplPlan
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
      _$DisciplPlanImpl(
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
class _$DisciplPlanImpl implements _DisciplPlan {
  const _$DisciplPlanImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'plan_type') this.planType,
    @JsonKey(name: 'regular_price') this.regularPrice,
    @JsonKey(name: 'discounted_price') this.discountedPrice,
    @JsonKey(name: 'period') this.period,
  });

  factory _$DisciplPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisciplPlanImplFromJson(json);

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
    return 'DisciplPlan(id: $id, name: $name, planType: $planType, regularPrice: $regularPrice, discountedPrice: $discountedPrice, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisciplPlanImpl &&
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

  /// Create a copy of DisciplPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisciplPlanImplCopyWith<_$DisciplPlanImpl> get copyWith =>
      __$$DisciplPlanImplCopyWithImpl<_$DisciplPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisciplPlanImplToJson(this);
  }
}

abstract class _DisciplPlan implements DisciplPlan {
  const factory _DisciplPlan({
    @JsonKey(name: 'id') final String? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'plan_type') final String? planType,
    @JsonKey(name: 'regular_price') final String? regularPrice,
    @JsonKey(name: 'discounted_price') final String? discountedPrice,
    @JsonKey(name: 'period') final int? period,
  }) = _$DisciplPlanImpl;

  factory _DisciplPlan.fromJson(Map<String, dynamic> json) =
      _$DisciplPlanImpl.fromJson;

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

  /// Create a copy of DisciplPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisciplPlanImplCopyWith<_$DisciplPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            firstName:
                freezed == firstName
                    ? _value.firstName
                    : firstName // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastName:
                freezed == lastName
                    ? _value.lastName
                    : lastName // ignore: cast_nullable_to_non_nullable
                        as String?,
            mobileNumber:
                freezed == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
  }) {
    return _then(
      _$UserImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        firstName:
            freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastName:
            freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                    as String?,
        mobileNumber:
            freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'mobile_number') this.mobileNumber,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;

  @override
  String toString() {
    return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, firstName, lastName, mobileNumber);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'mobile_number') final String? mobileNumber,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
