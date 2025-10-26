// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BankDetailsModelImpl _$$BankDetailsModelImplFromJson(
  Map<String, dynamic> json,
) => _$BankDetailsModelImpl(
  id: (json['id'] as num).toInt(),
  organization: (json['organization'] as num).toInt(),
  organizationId: (json['organization_id'] as num).toInt(),
  accountHolderName: json['account_holder_name'] as String,
  accountNumber: json['account_number'] as String,
  ifscCode: json['ifsc_code'] as String,
  bankName: json['bank_name'] as String,
  branchName: json['branch_name'] as String,
);

Map<String, dynamic> _$$BankDetailsModelImplToJson(
  _$BankDetailsModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization': instance.organization,
  'organization_id': instance.organizationId,
  'account_holder_name': instance.accountHolderName,
  'account_number': instance.accountNumber,
  'ifsc_code': instance.ifscCode,
  'bank_name': instance.bankName,
  'branch_name': instance.branchName,
};
