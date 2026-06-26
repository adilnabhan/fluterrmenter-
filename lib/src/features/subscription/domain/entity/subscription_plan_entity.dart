// ignore_for_file: public_member_api_docs, sort_constructors_first
class SubscriptionPlanEntity {
  final String title;
  final num perMonthPrice;
  final num? perMonthOriginalPrice;
  final num totalPrice;
  final num? totalDiscount;

  SubscriptionPlanEntity({
    required this.title,
    required this.perMonthPrice,
    required this.totalPrice,
    this.perMonthOriginalPrice,
    this.totalDiscount,
  });
}
