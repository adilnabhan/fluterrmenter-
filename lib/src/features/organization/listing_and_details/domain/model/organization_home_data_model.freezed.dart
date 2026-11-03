// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_home_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrganizationHomeDataModel _$OrganizationHomeDataModelFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationHomeDataModel.fromJson(json);
}

/// @nodoc
mixin _$OrganizationHomeDataModel {
  @JsonKey(name: 'organization_id')
  int? get organizationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'trainer_count')
  int? get trainerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_customers_count')
  int? get activeCustomersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'upcoming_renewals_count')
  int? get upcomingRenewalsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_customers_count')
  int? get expiredCustomersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'upcoming_payment_count')
  int? get upcomingPaymentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'allPayment_count')
  int? get allPaymentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_customers_count')
  int? get totalCustomersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_customers')
  int? get totalCustomers => throw _privateConstructorUsedError;
  @JsonKey(name: 'freezed_customers_count')
  int? get freezedCustomersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_insights')
  Map<String, dynamic>? get memberInsights =>
      throw _privateConstructorUsedError;

  /// Serializes this OrganizationHomeDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationHomeDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationHomeDataModelCopyWith<OrganizationHomeDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationHomeDataModelCopyWith<$Res> {
  factory $OrganizationHomeDataModelCopyWith(
    OrganizationHomeDataModel value,
    $Res Function(OrganizationHomeDataModel) then,
  ) = _$OrganizationHomeDataModelCopyWithImpl<$Res, OrganizationHomeDataModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'organization_id') int? organizationId,
    @JsonKey(name: 'trainer_count') int? trainerCount,
    @JsonKey(name: 'active_customers_count') int? activeCustomersCount,
    @JsonKey(name: 'upcoming_renewals_count') int? upcomingRenewalsCount,
    @JsonKey(name: 'expired_customers_count') int? expiredCustomersCount,
    @JsonKey(name: 'upcoming_payment_count') int? upcomingPaymentCount,
    @JsonKey(name: 'allPayment_count') int? allPaymentCount,
    @JsonKey(name: 'total_customers_count') int? totalCustomersCount,
    @JsonKey(name: 'total_customers') int? totalCustomers,
    @JsonKey(name: 'freezed_customers_count') int? freezedCustomersCount,
    @JsonKey(name: 'member_insights') Map<String, dynamic>? memberInsights,
  });
}

/// @nodoc
class _$OrganizationHomeDataModelCopyWithImpl<
  $Res,
  $Val extends OrganizationHomeDataModel
>
    implements $OrganizationHomeDataModelCopyWith<$Res> {
  _$OrganizationHomeDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationHomeDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = freezed,
    Object? trainerCount = freezed,
    Object? activeCustomersCount = freezed,
    Object? upcomingRenewalsCount = freezed,
    Object? expiredCustomersCount = freezed,
    Object? upcomingPaymentCount = freezed,
    Object? allPaymentCount = freezed,
    Object? totalCustomersCount = freezed,
    Object? totalCustomers = freezed,
    Object? freezedCustomersCount = freezed,
    Object? memberInsights = freezed,
  }) {
    return _then(
      _value.copyWith(
            organizationId:
                freezed == organizationId
                    ? _value.organizationId
                    : organizationId // ignore: cast_nullable_to_non_nullable
                        as int?,
            trainerCount:
                freezed == trainerCount
                    ? _value.trainerCount
                    : trainerCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            activeCustomersCount:
                freezed == activeCustomersCount
                    ? _value.activeCustomersCount
                    : activeCustomersCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            upcomingRenewalsCount:
                freezed == upcomingRenewalsCount
                    ? _value.upcomingRenewalsCount
                    : upcomingRenewalsCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            expiredCustomersCount:
                freezed == expiredCustomersCount
                    ? _value.expiredCustomersCount
                    : expiredCustomersCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            upcomingPaymentCount:
                freezed == upcomingPaymentCount
                    ? _value.upcomingPaymentCount
                    : upcomingPaymentCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            allPaymentCount:
                freezed == allPaymentCount
                    ? _value.allPaymentCount
                    : allPaymentCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            totalCustomersCount:
                freezed == totalCustomersCount
                    ? _value.totalCustomersCount
                    : totalCustomersCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            totalCustomers:
                freezed == totalCustomers
                    ? _value.totalCustomers
                    : totalCustomers // ignore: cast_nullable_to_non_nullable
                        as int?,
            freezedCustomersCount:
                freezed == freezedCustomersCount
                    ? _value.freezedCustomersCount
                    : freezedCustomersCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            memberInsights:
                freezed == memberInsights
                    ? _value.memberInsights
                    : memberInsights // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationHomeDataModelImplCopyWith<$Res>
    implements $OrganizationHomeDataModelCopyWith<$Res> {
  factory _$$OrganizationHomeDataModelImplCopyWith(
    _$OrganizationHomeDataModelImpl value,
    $Res Function(_$OrganizationHomeDataModelImpl) then,
  ) = __$$OrganizationHomeDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'organization_id') int? organizationId,
    @JsonKey(name: 'trainer_count') int? trainerCount,
    @JsonKey(name: 'active_customers_count') int? activeCustomersCount,
    @JsonKey(name: 'upcoming_renewals_count') int? upcomingRenewalsCount,
    @JsonKey(name: 'expired_customers_count') int? expiredCustomersCount,
    @JsonKey(name: 'upcoming_payment_count') int? upcomingPaymentCount,
    @JsonKey(name: 'allPayment_count') int? allPaymentCount,
    @JsonKey(name: 'total_customers_count') int? totalCustomersCount,
    @JsonKey(name: 'total_customers') int? totalCustomers,
    @JsonKey(name: 'freezed_customers_count') int? freezedCustomersCount,
    @JsonKey(name: 'member_insights') Map<String, dynamic>? memberInsights,
  });
}

/// @nodoc
class __$$OrganizationHomeDataModelImplCopyWithImpl<$Res>
    extends
        _$OrganizationHomeDataModelCopyWithImpl<
          $Res,
          _$OrganizationHomeDataModelImpl
        >
    implements _$$OrganizationHomeDataModelImplCopyWith<$Res> {
  __$$OrganizationHomeDataModelImplCopyWithImpl(
    _$OrganizationHomeDataModelImpl _value,
    $Res Function(_$OrganizationHomeDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationHomeDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = freezed,
    Object? trainerCount = freezed,
    Object? activeCustomersCount = freezed,
    Object? upcomingRenewalsCount = freezed,
    Object? expiredCustomersCount = freezed,
    Object? upcomingPaymentCount = freezed,
    Object? allPaymentCount = freezed,
    Object? totalCustomersCount = freezed,
    Object? totalCustomers = freezed,
    Object? freezedCustomersCount = freezed,
    Object? memberInsights = freezed,
  }) {
    return _then(
      _$OrganizationHomeDataModelImpl(
        organizationId:
            freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                    as int?,
        trainerCount:
            freezed == trainerCount
                ? _value.trainerCount
                : trainerCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        activeCustomersCount:
            freezed == activeCustomersCount
                ? _value.activeCustomersCount
                : activeCustomersCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        upcomingRenewalsCount:
            freezed == upcomingRenewalsCount
                ? _value.upcomingRenewalsCount
                : upcomingRenewalsCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        expiredCustomersCount:
            freezed == expiredCustomersCount
                ? _value.expiredCustomersCount
                : expiredCustomersCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        upcomingPaymentCount:
            freezed == upcomingPaymentCount
                ? _value.upcomingPaymentCount
                : upcomingPaymentCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        allPaymentCount:
            freezed == allPaymentCount
                ? _value.allPaymentCount
                : allPaymentCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        totalCustomersCount:
            freezed == totalCustomersCount
                ? _value.totalCustomersCount
                : totalCustomersCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        totalCustomers:
            freezed == totalCustomers
                ? _value.totalCustomers
                : totalCustomers // ignore: cast_nullable_to_non_nullable
                    as int?,
        freezedCustomersCount:
            freezed == freezedCustomersCount
                ? _value.freezedCustomersCount
                : freezedCustomersCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        memberInsights:
            freezed == memberInsights
                ? _value.memberInsights
                : memberInsights // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationHomeDataModelImpl implements _OrganizationHomeDataModel {
  const _$OrganizationHomeDataModelImpl({
    @JsonKey(name: 'organization_id') this.organizationId,
    @JsonKey(name: 'trainer_count') this.trainerCount,
    @JsonKey(name: 'active_customers_count') this.activeCustomersCount,
    @JsonKey(name: 'upcoming_renewals_count') this.upcomingRenewalsCount,
    @JsonKey(name: 'expired_customers_count') this.expiredCustomersCount,
    @JsonKey(name: 'upcoming_payment_count') this.upcomingPaymentCount,
    @JsonKey(name: 'allPayment_count') this.allPaymentCount,
    @JsonKey(name: 'total_customers_count') this.totalCustomersCount,
    @JsonKey(name: 'total_customers') this.totalCustomers,
    @JsonKey(name: 'freezed_customers_count') this.freezedCustomersCount,
    @JsonKey(name: 'member_insights') this.memberInsights,
  });

  factory _$OrganizationHomeDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationHomeDataModelImplFromJson(json);

  @override
  @JsonKey(name: 'organization_id')
  final int? organizationId;
  @override
  @JsonKey(name: 'trainer_count')
  final int? trainerCount;
  @override
  @JsonKey(name: 'active_customers_count')
  final int? activeCustomersCount;
  @override
  @JsonKey(name: 'upcoming_renewals_count')
  final int? upcomingRenewalsCount;
  @override
  @JsonKey(name: 'expired_customers_count')
  final int? expiredCustomersCount;
  @override
  @JsonKey(name: 'upcoming_payment_count')
  final int? upcomingPaymentCount;
  @override
  @JsonKey(name: 'allPayment_count')
  final int? allPaymentCount;
  @override
  @JsonKey(name: 'total_customers_count')
  final int? totalCustomersCount;
  @override
  @JsonKey(name: 'total_customers')
  final int? totalCustomers;
  @override
  @JsonKey(name: 'freezed_customers_count')
  final int? freezedCustomersCount;
  @override
  @JsonKey(name: 'member_insights')
  final Map<String, dynamic>? memberInsights;

  @override
  String toString() {
    return 'OrganizationHomeDataModel(organizationId: $organizationId, trainerCount: $trainerCount, activeCustomersCount: $activeCustomersCount, upcomingRenewalsCount: $upcomingRenewalsCount, expiredCustomersCount: $expiredCustomersCount, upcomingPaymentCount: $upcomingPaymentCount, allPaymentCount: $allPaymentCount, totalCustomersCount: $totalCustomersCount, totalCustomers: $totalCustomers, freezedCustomersCount: $freezedCustomersCount, memberInsights: $memberInsights)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationHomeDataModelImpl &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.trainerCount, trainerCount) ||
                other.trainerCount == trainerCount) &&
            (identical(other.activeCustomersCount, activeCustomersCount) ||
                other.activeCustomersCount == activeCustomersCount) &&
            (identical(other.upcomingRenewalsCount, upcomingRenewalsCount) ||
                other.upcomingRenewalsCount == upcomingRenewalsCount) &&
            (identical(other.expiredCustomersCount, expiredCustomersCount) ||
                other.expiredCustomersCount == expiredCustomersCount) &&
            (identical(other.upcomingPaymentCount, upcomingPaymentCount) ||
                other.upcomingPaymentCount == upcomingPaymentCount) &&
            (identical(other.allPaymentCount, allPaymentCount) ||
                other.allPaymentCount == allPaymentCount) &&
            (identical(other.totalCustomersCount, totalCustomersCount) ||
                other.totalCustomersCount == totalCustomersCount) &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.freezedCustomersCount, freezedCustomersCount) ||
                other.freezedCustomersCount == freezedCustomersCount) &&
            (identical(other.memberInsights, memberInsights) ||
                other.memberInsights == memberInsights));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    organizationId,
    trainerCount,
    activeCustomersCount,
    upcomingRenewalsCount,
    expiredCustomersCount,
    upcomingPaymentCount,
    allPaymentCount,
    totalCustomersCount,
    totalCustomers,
    freezedCustomersCount,
    memberInsights,
  );

  /// Create a copy of OrganizationHomeDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationHomeDataModelImplCopyWith<_$OrganizationHomeDataModelImpl>
  get copyWith => __$$OrganizationHomeDataModelImplCopyWithImpl<
    _$OrganizationHomeDataModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationHomeDataModelImplToJson(this);
  }
}

abstract class _OrganizationHomeDataModel implements OrganizationHomeDataModel {
  const factory _OrganizationHomeDataModel({
    @JsonKey(name: 'organization_id') final int? organizationId,
    @JsonKey(name: 'trainer_count') final int? trainerCount,
    @JsonKey(name: 'active_customers_count') final int? activeCustomersCount,
    @JsonKey(name: 'upcoming_renewals_count') final int? upcomingRenewalsCount,
    @JsonKey(name: 'expired_customers_count') final int? expiredCustomersCount,
    @JsonKey(name: 'upcoming_payment_count') final int? upcomingPaymentCount,
    @JsonKey(name: 'allPayment_count') final int? allPaymentCount,
    @JsonKey(name: 'total_customers_count') final int? totalCustomersCount,
    @JsonKey(name: 'total_customers') final int? totalCustomers,
    @JsonKey(name: 'freezed_customers_count') final int? freezedCustomersCount,
    @JsonKey(name: 'member_insights')
    final Map<String, dynamic>? memberInsights,
  }) = _$OrganizationHomeDataModelImpl;

  factory _OrganizationHomeDataModel.fromJson(Map<String, dynamic> json) =
      _$OrganizationHomeDataModelImpl.fromJson;

  @override
  @JsonKey(name: 'organization_id')
  int? get organizationId;
  @override
  @JsonKey(name: 'trainer_count')
  int? get trainerCount;
  @override
  @JsonKey(name: 'active_customers_count')
  int? get activeCustomersCount;
  @override
  @JsonKey(name: 'upcoming_renewals_count')
  int? get upcomingRenewalsCount;
  @override
  @JsonKey(name: 'expired_customers_count')
  int? get expiredCustomersCount;
  @override
  @JsonKey(name: 'upcoming_payment_count')
  int? get upcomingPaymentCount;
  @override
  @JsonKey(name: 'allPayment_count')
  int? get allPaymentCount;
  @override
  @JsonKey(name: 'total_customers_count')
  int? get totalCustomersCount;
  @override
  @JsonKey(name: 'total_customers')
  int? get totalCustomers;
  @override
  @JsonKey(name: 'freezed_customers_count')
  int? get freezedCustomersCount;
  @override
  @JsonKey(name: 'member_insights')
  Map<String, dynamic>? get memberInsights;

  /// Create a copy of OrganizationHomeDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationHomeDataModelImplCopyWith<_$OrganizationHomeDataModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
