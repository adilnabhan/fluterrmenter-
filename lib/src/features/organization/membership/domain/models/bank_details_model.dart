import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_details_model.freezed.dart';
part 'bank_details_model.g.dart';

@freezed
class BankDetailsModel with _$BankDetailsModel {
  const factory BankDetailsModel({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "organization") required int organization,
    @JsonKey(name: "organization_id") required int organizationId,
    @JsonKey(name: "account_holder_name") required String accountHolderName,
    @JsonKey(name: "account_number") required String accountNumber,
    @JsonKey(name: "ifsc_code") required String ifscCode,
    @JsonKey(name: "bank_name") required String bankName,
    @JsonKey(name: "branch_name") required String branchName,
    @JsonKey(name: "pan_number")  String? panNumber,
    @JsonKey(name: "date_of_birth") String? dateOBirth,
  }) = _BankDetailsModel;

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$BankDetailsModelFromJson(json);
}
