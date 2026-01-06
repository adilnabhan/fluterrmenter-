// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentHistoryImpl _$$PaymentHistoryImplFromJson(Map<String, dynamic> json) =>
    _$PaymentHistoryImpl(
      allPayments: PaymentHistorySection.fromJson(
        json['all_payments'] as Map<String, dynamic>,
      ),
      pendingPayments: PaymentHistorySection.fromJson(
        json['pending_payments'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$PaymentHistoryImplToJson(
  _$PaymentHistoryImpl instance,
) => <String, dynamic>{
  'all_payments': instance.allPayments,
  'pending_payments': instance.pendingPayments,
};

_$PaymentHistorySectionImpl _$$PaymentHistorySectionImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentHistorySectionImpl(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>)
          .map((e) => PaymentHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalPaidToday: json['total_paid_today'] as num,
  totalPendingAmount: json['total_pending_amount'] as num,
);

Map<String, dynamic> _$$PaymentHistorySectionImplToJson(
  _$PaymentHistorySectionImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
  'total_paid_today': instance.totalPaidToday,
  'total_pending_amount': instance.totalPendingAmount,
};

_$PaymentHistoryItemImpl _$$PaymentHistoryItemImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentHistoryItemImpl(
  id: (json['id'] as num).toInt(),
  customerName: json['customer_name'] as String,
  membershipName: json['membership_name'] as String,
  amount: json['amount'] as String,
  status: json['status'] as String,
  paymentMethod: json['payment_method'] as String?,
  paymentDate: DateTime.parse(json['payment_date'] as String),
  orderId: json['order_id'] as String?,
  paymentId: json['payment_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$PaymentHistoryItemImplToJson(
  _$PaymentHistoryItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customer_name': instance.customerName,
  'membership_name': instance.membershipName,
  'amount': instance.amount,
  'status': instance.status,
  'payment_method': instance.paymentMethod,
  'payment_date': instance.paymentDate.toIso8601String(),
  'order_id': instance.orderId,
  'payment_id': instance.paymentId,
  'created_at': instance.createdAt.toIso8601String(),
};
