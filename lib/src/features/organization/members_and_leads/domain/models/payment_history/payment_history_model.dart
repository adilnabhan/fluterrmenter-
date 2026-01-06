import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_model.freezed.dart';
part 'payment_history_model.g.dart';

@freezed
class PaymentHistory with _$PaymentHistory {
  const factory PaymentHistory({
    @JsonKey(name: 'all_payments')
    required PaymentHistorySection allPayments,

    @JsonKey(name: 'pending_payments')
    required PaymentHistorySection pendingPayments,
  }) = _PaymentHistory;

  factory PaymentHistory.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryFromJson(json);
}

@freezed
class PaymentHistorySection with _$PaymentHistorySection {
  const factory PaymentHistorySection({
    @JsonKey(name: 'count')
    required int count,

    /// Pagination URLs
    @JsonKey(name: 'next')
    String? next,

    @JsonKey(name: 'previous')
    String? previous,

    @JsonKey(name: 'results')
    required List<PaymentHistoryItem> results,

    @JsonKey(name: 'total_paid_today')
    required num totalPaidToday,

    @JsonKey(name: 'total_pending_amount')
    required num totalPendingAmount,
  }) = _PaymentHistorySection;

  factory PaymentHistorySection.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistorySectionFromJson(json);
}

@freezed
class PaymentHistoryItem with _$PaymentHistoryItem {
  const factory PaymentHistoryItem({
    @JsonKey(name: 'id')
    required int id,

    @JsonKey(name: 'customer_name')
    required String customerName,

    @JsonKey(name: 'membership_name')
    required String membershipName,

    /// API sends this as string ("1700.00")
    @JsonKey(name: 'amount')
    required String amount,

    @JsonKey(name: 'status')
    required String status,

    @JsonKey(name: 'payment_method')
    String? paymentMethod,

    @JsonKey(name: 'payment_date')
    required DateTime paymentDate,

    @JsonKey(name: 'order_id')
    String? orderId,

    @JsonKey(name: 'payment_id')
    String? paymentId,

    @JsonKey(name: 'created_at')
    required DateTime createdAt,
  }) = _PaymentHistoryItem;

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryItemFromJson(json);
}
