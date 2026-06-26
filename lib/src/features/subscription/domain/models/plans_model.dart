// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:feggy_core/feggy_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plans_model.freezed.dart';
part 'plans_model.g.dart';

@freezed
class PlansModel with _$PlansModel {
  const factory PlansModel({@JsonKey(name: 'results') List<SubscriptionPlanModel>? results}) = _PlansModel;

  factory PlansModel.fromJson(Map<String, dynamic> json) => _$PlansModelFromJson(json);
}

@freezed
class SubscriptionPlanModel with _$SubscriptionPlanModel {
  const factory SubscriptionPlanModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'plan_type') String? planType,
    @JsonKey(name: 'regular_price') String? regularPrice,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'period') int? period,
  }) = _SubscriptionPlanModel;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanModelFromJson(json);
}

extension SubscriptionPlanModelX on SubscriptionPlanModel {
  num get totalPriceExcludeDiscount {
    return regularPrice?.toNum ?? 0;
  }

  num get totalPriceIncludeDiscount {
    return discountedPrice?.toNum ?? 0;
  }

  num get totalDiscount => totalPriceExcludeDiscount - totalPriceIncludeDiscount;

  num get perMonthPriceExcludeDiscount {
    final period = this.period ?? 0;
    if (period > 0 && totalPriceExcludeDiscount > 0) {
      return totalPriceExcludeDiscount / (period / 30);
    }
    return 0;
  }

  num get perMonthPriceIncludeDisount {
    final period = this.period ?? 0;
    if (period > 0 && totalPriceIncludeDiscount > 0) {
      return totalPriceIncludeDiscount / (period / 30);
    }
    return 0;
  }
}
