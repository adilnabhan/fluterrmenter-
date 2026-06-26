import 'package:feggy_core/imports_bindings.dart';

part 'emi_options_model.freezed.dart';
part 'emi_options_model.g.dart';

@freezed
class EmiOptionsModel with _$EmiOptionsModel {
  const factory EmiOptionsModel({
    @JsonKey(name: 'number_of_installments') required int month,
    @JsonKey(name: 'emi_amount_per_cycle') required double price,
  }) = _EmiOptionsModel;

  factory EmiOptionsModel.fromJson(Map<String, dynamic> json) =>
      _$EmiOptionsModelFromJson(json);
}
