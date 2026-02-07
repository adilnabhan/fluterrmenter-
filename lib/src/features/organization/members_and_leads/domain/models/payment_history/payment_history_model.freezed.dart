// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentHistory _$PaymentHistoryFromJson(Map<String, dynamic> json) {
  return _PaymentHistory.fromJson(json);
}

/// @nodoc
mixin _$PaymentHistory {
  @JsonKey(name: 'all_payments')
  PaymentHistorySection get allPayments => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_payments')
  PaymentHistorySection get pendingPayments =>
      throw _privateConstructorUsedError;

  /// Serializes this PaymentHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentHistoryCopyWith<PaymentHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentHistoryCopyWith<$Res> {
  factory $PaymentHistoryCopyWith(
    PaymentHistory value,
    $Res Function(PaymentHistory) then,
  ) = _$PaymentHistoryCopyWithImpl<$Res, PaymentHistory>;
  @useResult
  $Res call({
    @JsonKey(name: 'all_payments') PaymentHistorySection allPayments,
    @JsonKey(name: 'pending_payments') PaymentHistorySection pendingPayments,
  });

  $PaymentHistorySectionCopyWith<$Res> get allPayments;
  $PaymentHistorySectionCopyWith<$Res> get pendingPayments;
}

/// @nodoc
class _$PaymentHistoryCopyWithImpl<$Res, $Val extends PaymentHistory>
    implements $PaymentHistoryCopyWith<$Res> {
  _$PaymentHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allPayments = null, Object? pendingPayments = null}) {
    return _then(
      _value.copyWith(
            allPayments:
                null == allPayments
                    ? _value.allPayments
                    : allPayments // ignore: cast_nullable_to_non_nullable
                        as PaymentHistorySection,
            pendingPayments:
                null == pendingPayments
                    ? _value.pendingPayments
                    : pendingPayments // ignore: cast_nullable_to_non_nullable
                        as PaymentHistorySection,
          )
          as $Val,
    );
  }

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentHistorySectionCopyWith<$Res> get allPayments {
    return $PaymentHistorySectionCopyWith<$Res>(_value.allPayments, (value) {
      return _then(_value.copyWith(allPayments: value) as $Val);
    });
  }

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentHistorySectionCopyWith<$Res> get pendingPayments {
    return $PaymentHistorySectionCopyWith<$Res>(_value.pendingPayments, (
      value,
    ) {
      return _then(_value.copyWith(pendingPayments: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PaymentHistoryImplCopyWith<$Res>
    implements $PaymentHistoryCopyWith<$Res> {
  factory _$$PaymentHistoryImplCopyWith(
    _$PaymentHistoryImpl value,
    $Res Function(_$PaymentHistoryImpl) then,
  ) = __$$PaymentHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'all_payments') PaymentHistorySection allPayments,
    @JsonKey(name: 'pending_payments') PaymentHistorySection pendingPayments,
  });

  @override
  $PaymentHistorySectionCopyWith<$Res> get allPayments;
  @override
  $PaymentHistorySectionCopyWith<$Res> get pendingPayments;
}

/// @nodoc
class __$$PaymentHistoryImplCopyWithImpl<$Res>
    extends _$PaymentHistoryCopyWithImpl<$Res, _$PaymentHistoryImpl>
    implements _$$PaymentHistoryImplCopyWith<$Res> {
  __$$PaymentHistoryImplCopyWithImpl(
    _$PaymentHistoryImpl _value,
    $Res Function(_$PaymentHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? allPayments = null, Object? pendingPayments = null}) {
    return _then(
      _$PaymentHistoryImpl(
        allPayments:
            null == allPayments
                ? _value.allPayments
                : allPayments // ignore: cast_nullable_to_non_nullable
                    as PaymentHistorySection,
        pendingPayments:
            null == pendingPayments
                ? _value.pendingPayments
                : pendingPayments // ignore: cast_nullable_to_non_nullable
                    as PaymentHistorySection,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentHistoryImpl implements _PaymentHistory {
  const _$PaymentHistoryImpl({
    @JsonKey(name: 'all_payments') required this.allPayments,
    @JsonKey(name: 'pending_payments') required this.pendingPayments,
  });

  factory _$PaymentHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentHistoryImplFromJson(json);

  @override
  @JsonKey(name: 'all_payments')
  final PaymentHistorySection allPayments;
  @override
  @JsonKey(name: 'pending_payments')
  final PaymentHistorySection pendingPayments;

  @override
  String toString() {
    return 'PaymentHistory(allPayments: $allPayments, pendingPayments: $pendingPayments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentHistoryImpl &&
            (identical(other.allPayments, allPayments) ||
                other.allPayments == allPayments) &&
            (identical(other.pendingPayments, pendingPayments) ||
                other.pendingPayments == pendingPayments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, allPayments, pendingPayments);

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentHistoryImplCopyWith<_$PaymentHistoryImpl> get copyWith =>
      __$$PaymentHistoryImplCopyWithImpl<_$PaymentHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentHistoryImplToJson(this);
  }
}

abstract class _PaymentHistory implements PaymentHistory {
  const factory _PaymentHistory({
    @JsonKey(name: 'all_payments')
    required final PaymentHistorySection allPayments,
    @JsonKey(name: 'pending_payments')
    required final PaymentHistorySection pendingPayments,
  }) = _$PaymentHistoryImpl;

  factory _PaymentHistory.fromJson(Map<String, dynamic> json) =
      _$PaymentHistoryImpl.fromJson;

  @override
  @JsonKey(name: 'all_payments')
  PaymentHistorySection get allPayments;
  @override
  @JsonKey(name: 'pending_payments')
  PaymentHistorySection get pendingPayments;

  /// Create a copy of PaymentHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentHistoryImplCopyWith<_$PaymentHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentHistorySection _$PaymentHistorySectionFromJson(
  Map<String, dynamic> json,
) {
  return _PaymentHistorySection.fromJson(json);
}

/// @nodoc
mixin _$PaymentHistorySection {
  @JsonKey(name: 'count')
  int get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;

  /// Safe default when API sends null
  @JsonKey(name: 'results')
  List<PaymentHistoryItem> get results => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_paid_today')
  num get totalPaidToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pending_amount')
  num get totalPendingAmount => throw _privateConstructorUsedError;

  /// Serializes this PaymentHistorySection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentHistorySection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentHistorySectionCopyWith<PaymentHistorySection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentHistorySectionCopyWith<$Res> {
  factory $PaymentHistorySectionCopyWith(
    PaymentHistorySection value,
    $Res Function(PaymentHistorySection) then,
  ) = _$PaymentHistorySectionCopyWithImpl<$Res, PaymentHistorySection>;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<PaymentHistoryItem> results,
    @JsonKey(name: 'total_paid_today') num totalPaidToday,
    @JsonKey(name: 'total_pending_amount') num totalPendingAmount,
  });
}

/// @nodoc
class _$PaymentHistorySectionCopyWithImpl<
  $Res,
  $Val extends PaymentHistorySection
>
    implements $PaymentHistorySectionCopyWith<$Res> {
  _$PaymentHistorySectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentHistorySection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = null,
    Object? totalPaidToday = null,
    Object? totalPendingAmount = null,
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
                        as String?,
            previous:
                freezed == previous
                    ? _value.previous
                    : previous // ignore: cast_nullable_to_non_nullable
                        as String?,
            results:
                null == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<PaymentHistoryItem>,
            totalPaidToday:
                null == totalPaidToday
                    ? _value.totalPaidToday
                    : totalPaidToday // ignore: cast_nullable_to_non_nullable
                        as num,
            totalPendingAmount:
                null == totalPendingAmount
                    ? _value.totalPendingAmount
                    : totalPendingAmount // ignore: cast_nullable_to_non_nullable
                        as num,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentHistorySectionImplCopyWith<$Res>
    implements $PaymentHistorySectionCopyWith<$Res> {
  factory _$$PaymentHistorySectionImplCopyWith(
    _$PaymentHistorySectionImpl value,
    $Res Function(_$PaymentHistorySectionImpl) then,
  ) = __$$PaymentHistorySectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<PaymentHistoryItem> results,
    @JsonKey(name: 'total_paid_today') num totalPaidToday,
    @JsonKey(name: 'total_pending_amount') num totalPendingAmount,
  });
}

/// @nodoc
class __$$PaymentHistorySectionImplCopyWithImpl<$Res>
    extends
        _$PaymentHistorySectionCopyWithImpl<$Res, _$PaymentHistorySectionImpl>
    implements _$$PaymentHistorySectionImplCopyWith<$Res> {
  __$$PaymentHistorySectionImplCopyWithImpl(
    _$PaymentHistorySectionImpl _value,
    $Res Function(_$PaymentHistorySectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentHistorySection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = null,
    Object? totalPaidToday = null,
    Object? totalPendingAmount = null,
  }) {
    return _then(
      _$PaymentHistorySectionImpl(
        count:
            null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int,
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
            null == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<PaymentHistoryItem>,
        totalPaidToday:
            null == totalPaidToday
                ? _value.totalPaidToday
                : totalPaidToday // ignore: cast_nullable_to_non_nullable
                    as num,
        totalPendingAmount:
            null == totalPendingAmount
                ? _value.totalPendingAmount
                : totalPendingAmount // ignore: cast_nullable_to_non_nullable
                    as num,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentHistorySectionImpl implements _PaymentHistorySection {
  const _$PaymentHistorySectionImpl({
    @JsonKey(name: 'count') required this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results')
    final List<PaymentHistoryItem> results = const <PaymentHistoryItem>[],
    @JsonKey(name: 'total_paid_today') this.totalPaidToday = 0,
    @JsonKey(name: 'total_pending_amount') this.totalPendingAmount = 0,
  }) : _results = results;

  factory _$PaymentHistorySectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentHistorySectionImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;

  /// Safe default when API sends null
  final List<PaymentHistoryItem> _results;

  /// Safe default when API sends null
  @override
  @JsonKey(name: 'results')
  List<PaymentHistoryItem> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  @JsonKey(name: 'total_paid_today')
  final num totalPaidToday;
  @override
  @JsonKey(name: 'total_pending_amount')
  final num totalPendingAmount;

  @override
  String toString() {
    return 'PaymentHistorySection(count: $count, next: $next, previous: $previous, results: $results, totalPaidToday: $totalPaidToday, totalPendingAmount: $totalPendingAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentHistorySectionImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.totalPaidToday, totalPaidToday) ||
                other.totalPaidToday == totalPaidToday) &&
            (identical(other.totalPendingAmount, totalPendingAmount) ||
                other.totalPendingAmount == totalPendingAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    next,
    previous,
    const DeepCollectionEquality().hash(_results),
    totalPaidToday,
    totalPendingAmount,
  );

  /// Create a copy of PaymentHistorySection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentHistorySectionImplCopyWith<_$PaymentHistorySectionImpl>
  get copyWith =>
      __$$PaymentHistorySectionImplCopyWithImpl<_$PaymentHistorySectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentHistorySectionImplToJson(this);
  }
}

abstract class _PaymentHistorySection implements PaymentHistorySection {
  const factory _PaymentHistorySection({
    @JsonKey(name: 'count') required final int count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final String? previous,
    @JsonKey(name: 'results') final List<PaymentHistoryItem> results,
    @JsonKey(name: 'total_paid_today') final num totalPaidToday,
    @JsonKey(name: 'total_pending_amount') final num totalPendingAmount,
  }) = _$PaymentHistorySectionImpl;

  factory _PaymentHistorySection.fromJson(Map<String, dynamic> json) =
      _$PaymentHistorySectionImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  String? get previous;

  /// Safe default when API sends null
  @override
  @JsonKey(name: 'results')
  List<PaymentHistoryItem> get results;
  @override
  @JsonKey(name: 'total_paid_today')
  num get totalPaidToday;
  @override
  @JsonKey(name: 'total_pending_amount')
  num get totalPendingAmount;

  /// Create a copy of PaymentHistorySection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentHistorySectionImplCopyWith<_$PaymentHistorySectionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PaymentHistoryItem _$PaymentHistoryItemFromJson(Map<String, dynamic> json) {
  return _PaymentHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$PaymentHistoryItem {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_name')
  String get membershipName => throw _privateConstructorUsedError;

  /// API sends amount as string
  @JsonKey(name: 'amount')
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String? get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  DateTime get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_id')
  String? get paymentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError; // 🔹 NEW FIELDS (from API)
  @JsonKey(name: 'platform_fee')
  String? get platformFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform_fee_percentage')
  String? get platformFeePercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  String? get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'settlement_time')
  String? get settlementTime => throw _privateConstructorUsedError;

  /// Serializes this PaymentHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentHistoryItemCopyWith<PaymentHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentHistoryItemCopyWith<$Res> {
  factory $PaymentHistoryItemCopyWith(
    PaymentHistoryItem value,
    $Res Function(PaymentHistoryItem) then,
  ) = _$PaymentHistoryItemCopyWithImpl<$Res, PaymentHistoryItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int id,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'membership_name') String membershipName,
    @JsonKey(name: 'amount') String amount,
    @JsonKey(name: 'status') String status,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_date') DateTime paymentDate,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'platform_fee') String? platformFee,
    @JsonKey(name: 'platform_fee_percentage') String? platformFeePercentage,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'settlement_time') String? settlementTime,
  });
}

/// @nodoc
class _$PaymentHistoryItemCopyWithImpl<$Res, $Val extends PaymentHistoryItem>
    implements $PaymentHistoryItemCopyWith<$Res> {
  _$PaymentHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? membershipName = null,
    Object? amount = null,
    Object? status = null,
    Object? paymentMethod = freezed,
    Object? paymentDate = null,
    Object? orderId = freezed,
    Object? paymentId = freezed,
    Object? createdAt = null,
    Object? platformFee = freezed,
    Object? platformFeePercentage = freezed,
    Object? totalAmount = freezed,
    Object? settlementTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            customerName:
                null == customerName
                    ? _value.customerName
                    : customerName // ignore: cast_nullable_to_non_nullable
                        as String,
            membershipName:
                null == membershipName
                    ? _value.membershipName
                    : membershipName // ignore: cast_nullable_to_non_nullable
                        as String,
            amount:
                null == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            paymentMethod:
                freezed == paymentMethod
                    ? _value.paymentMethod
                    : paymentMethod // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentDate:
                null == paymentDate
                    ? _value.paymentDate
                    : paymentDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentId:
                freezed == paymentId
                    ? _value.paymentId
                    : paymentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            platformFee:
                freezed == platformFee
                    ? _value.platformFee
                    : platformFee // ignore: cast_nullable_to_non_nullable
                        as String?,
            platformFeePercentage:
                freezed == platformFeePercentage
                    ? _value.platformFeePercentage
                    : platformFeePercentage // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalAmount:
                freezed == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
            settlementTime:
                freezed == settlementTime
                    ? _value.settlementTime
                    : settlementTime // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentHistoryItemImplCopyWith<$Res>
    implements $PaymentHistoryItemCopyWith<$Res> {
  factory _$$PaymentHistoryItemImplCopyWith(
    _$PaymentHistoryItemImpl value,
    $Res Function(_$PaymentHistoryItemImpl) then,
  ) = __$$PaymentHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int id,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'membership_name') String membershipName,
    @JsonKey(name: 'amount') String amount,
    @JsonKey(name: 'status') String status,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_date') DateTime paymentDate,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'platform_fee') String? platformFee,
    @JsonKey(name: 'platform_fee_percentage') String? platformFeePercentage,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'settlement_time') String? settlementTime,
  });
}

/// @nodoc
class __$$PaymentHistoryItemImplCopyWithImpl<$Res>
    extends _$PaymentHistoryItemCopyWithImpl<$Res, _$PaymentHistoryItemImpl>
    implements _$$PaymentHistoryItemImplCopyWith<$Res> {
  __$$PaymentHistoryItemImplCopyWithImpl(
    _$PaymentHistoryItemImpl _value,
    $Res Function(_$PaymentHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? membershipName = null,
    Object? amount = null,
    Object? status = null,
    Object? paymentMethod = freezed,
    Object? paymentDate = null,
    Object? orderId = freezed,
    Object? paymentId = freezed,
    Object? createdAt = null,
    Object? platformFee = freezed,
    Object? platformFeePercentage = freezed,
    Object? totalAmount = freezed,
    Object? settlementTime = freezed,
  }) {
    return _then(
      _$PaymentHistoryItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        customerName:
            null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                    as String,
        membershipName:
            null == membershipName
                ? _value.membershipName
                : membershipName // ignore: cast_nullable_to_non_nullable
                    as String,
        amount:
            null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        paymentMethod:
            freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentDate:
            null == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentId:
            freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        platformFee:
            freezed == platformFee
                ? _value.platformFee
                : platformFee // ignore: cast_nullable_to_non_nullable
                    as String?,
        platformFeePercentage:
            freezed == platformFeePercentage
                ? _value.platformFeePercentage
                : platformFeePercentage // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalAmount:
            freezed == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
        settlementTime:
            freezed == settlementTime
                ? _value.settlementTime
                : settlementTime // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentHistoryItemImpl implements _PaymentHistoryItem {
  const _$PaymentHistoryItemImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'customer_name') required this.customerName,
    @JsonKey(name: 'membership_name') required this.membershipName,
    @JsonKey(name: 'amount') required this.amount,
    @JsonKey(name: 'status') required this.status,
    @JsonKey(name: 'payment_method') this.paymentMethod,
    @JsonKey(name: 'payment_date') required this.paymentDate,
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'payment_id') this.paymentId,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'platform_fee') this.platformFee,
    @JsonKey(name: 'platform_fee_percentage') this.platformFeePercentage,
    @JsonKey(name: 'total_amount') this.totalAmount,
    @JsonKey(name: 'settlement_time') this.settlementTime,
  });

  factory _$PaymentHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentHistoryItemImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'membership_name')
  final String membershipName;

  /// API sends amount as string
  @override
  @JsonKey(name: 'amount')
  final String amount;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @override
  @JsonKey(name: 'payment_date')
  final DateTime paymentDate;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'payment_id')
  final String? paymentId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  // 🔹 NEW FIELDS (from API)
  @override
  @JsonKey(name: 'platform_fee')
  final String? platformFee;
  @override
  @JsonKey(name: 'platform_fee_percentage')
  final String? platformFeePercentage;
  @override
  @JsonKey(name: 'total_amount')
  final String? totalAmount;
  @override
  @JsonKey(name: 'settlement_time')
  final String? settlementTime;

  @override
  String toString() {
    return 'PaymentHistoryItem(id: $id, customerName: $customerName, membershipName: $membershipName, amount: $amount, status: $status, paymentMethod: $paymentMethod, paymentDate: $paymentDate, orderId: $orderId, paymentId: $paymentId, createdAt: $createdAt, platformFee: $platformFee, platformFeePercentage: $platformFeePercentage, totalAmount: $totalAmount, settlementTime: $settlementTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentHistoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.membershipName, membershipName) ||
                other.membershipName == membershipName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.platformFee, platformFee) ||
                other.platformFee == platformFee) &&
            (identical(other.platformFeePercentage, platformFeePercentage) ||
                other.platformFeePercentage == platformFeePercentage) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.settlementTime, settlementTime) ||
                other.settlementTime == settlementTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerName,
    membershipName,
    amount,
    status,
    paymentMethod,
    paymentDate,
    orderId,
    paymentId,
    createdAt,
    platformFee,
    platformFeePercentage,
    totalAmount,
    settlementTime,
  );

  /// Create a copy of PaymentHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentHistoryItemImplCopyWith<_$PaymentHistoryItemImpl> get copyWith =>
      __$$PaymentHistoryItemImplCopyWithImpl<_$PaymentHistoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentHistoryItemImplToJson(this);
  }
}

abstract class _PaymentHistoryItem implements PaymentHistoryItem {
  const factory _PaymentHistoryItem({
    @JsonKey(name: 'id') required final int id,
    @JsonKey(name: 'customer_name') required final String customerName,
    @JsonKey(name: 'membership_name') required final String membershipName,
    @JsonKey(name: 'amount') required final String amount,
    @JsonKey(name: 'status') required final String status,
    @JsonKey(name: 'payment_method') final String? paymentMethod,
    @JsonKey(name: 'payment_date') required final DateTime paymentDate,
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'payment_id') final String? paymentId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'platform_fee') final String? platformFee,
    @JsonKey(name: 'platform_fee_percentage')
    final String? platformFeePercentage,
    @JsonKey(name: 'total_amount') final String? totalAmount,
    @JsonKey(name: 'settlement_time') final String? settlementTime,
  }) = _$PaymentHistoryItemImpl;

  factory _PaymentHistoryItem.fromJson(Map<String, dynamic> json) =
      _$PaymentHistoryItemImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'membership_name')
  String get membershipName;

  /// API sends amount as string
  @override
  @JsonKey(name: 'amount')
  String get amount;
  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(name: 'payment_method')
  String? get paymentMethod;
  @override
  @JsonKey(name: 'payment_date')
  DateTime get paymentDate;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'payment_id')
  String? get paymentId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // 🔹 NEW FIELDS (from API)
  @override
  @JsonKey(name: 'platform_fee')
  String? get platformFee;
  @override
  @JsonKey(name: 'platform_fee_percentage')
  String? get platformFeePercentage;
  @override
  @JsonKey(name: 'total_amount')
  String? get totalAmount;
  @override
  @JsonKey(name: 'settlement_time')
  String? get settlementTime;

  /// Create a copy of PaymentHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentHistoryItemImplCopyWith<_$PaymentHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
