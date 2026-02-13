// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BankDetailsModel _$BankDetailsModelFromJson(Map<String, dynamic> json) {
  return _BankDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$BankDetailsModel {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "organization")
  int get organization => throw _privateConstructorUsedError;
  @JsonKey(name: "organization_id")
  int get organizationId => throw _privateConstructorUsedError;
  @JsonKey(name: "account_holder_name")
  String get accountHolderName => throw _privateConstructorUsedError;
  @JsonKey(name: "account_number")
  String get accountNumber => throw _privateConstructorUsedError;
  @JsonKey(name: "ifsc_code")
  String get ifscCode => throw _privateConstructorUsedError;
  @JsonKey(name: "bank_name")
  String get bankName => throw _privateConstructorUsedError;
  @JsonKey(name: "branch_name")
  String get branchName => throw _privateConstructorUsedError;
  @JsonKey(name: "pan_number")
  String? get panNumber => throw _privateConstructorUsedError;
  @JsonKey(name: "date_of_birth")
  String? get dateOBirth => throw _privateConstructorUsedError;

  /// Serializes this BankDetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BankDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BankDetailsModelCopyWith<BankDetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BankDetailsModelCopyWith<$Res> {
  factory $BankDetailsModelCopyWith(
    BankDetailsModel value,
    $Res Function(BankDetailsModel) then,
  ) = _$BankDetailsModelCopyWithImpl<$Res, BankDetailsModel>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "organization") int organization,
    @JsonKey(name: "organization_id") int organizationId,
    @JsonKey(name: "account_holder_name") String accountHolderName,
    @JsonKey(name: "account_number") String accountNumber,
    @JsonKey(name: "ifsc_code") String ifscCode,
    @JsonKey(name: "bank_name") String bankName,
    @JsonKey(name: "branch_name") String branchName,
    @JsonKey(name: "pan_number") String? panNumber,
    @JsonKey(name: "date_of_birth") String? dateOBirth,
  });
}

/// @nodoc
class _$BankDetailsModelCopyWithImpl<$Res, $Val extends BankDetailsModel>
    implements $BankDetailsModelCopyWith<$Res> {
  _$BankDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BankDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organization = null,
    Object? organizationId = null,
    Object? accountHolderName = null,
    Object? accountNumber = null,
    Object? ifscCode = null,
    Object? bankName = null,
    Object? branchName = null,
    Object? panNumber = freezed,
    Object? dateOBirth = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            organization:
                null == organization
                    ? _value.organization
                    : organization // ignore: cast_nullable_to_non_nullable
                        as int,
            organizationId:
                null == organizationId
                    ? _value.organizationId
                    : organizationId // ignore: cast_nullable_to_non_nullable
                        as int,
            accountHolderName:
                null == accountHolderName
                    ? _value.accountHolderName
                    : accountHolderName // ignore: cast_nullable_to_non_nullable
                        as String,
            accountNumber:
                null == accountNumber
                    ? _value.accountNumber
                    : accountNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            ifscCode:
                null == ifscCode
                    ? _value.ifscCode
                    : ifscCode // ignore: cast_nullable_to_non_nullable
                        as String,
            bankName:
                null == bankName
                    ? _value.bankName
                    : bankName // ignore: cast_nullable_to_non_nullable
                        as String,
            branchName:
                null == branchName
                    ? _value.branchName
                    : branchName // ignore: cast_nullable_to_non_nullable
                        as String,
            panNumber:
                freezed == panNumber
                    ? _value.panNumber
                    : panNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            dateOBirth:
                freezed == dateOBirth
                    ? _value.dateOBirth
                    : dateOBirth // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BankDetailsModelImplCopyWith<$Res>
    implements $BankDetailsModelCopyWith<$Res> {
  factory _$$BankDetailsModelImplCopyWith(
    _$BankDetailsModelImpl value,
    $Res Function(_$BankDetailsModelImpl) then,
  ) = __$$BankDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int id,
    @JsonKey(name: "organization") int organization,
    @JsonKey(name: "organization_id") int organizationId,
    @JsonKey(name: "account_holder_name") String accountHolderName,
    @JsonKey(name: "account_number") String accountNumber,
    @JsonKey(name: "ifsc_code") String ifscCode,
    @JsonKey(name: "bank_name") String bankName,
    @JsonKey(name: "branch_name") String branchName,
    @JsonKey(name: "pan_number") String? panNumber,
    @JsonKey(name: "date_of_birth") String? dateOBirth,
  });
}

/// @nodoc
class __$$BankDetailsModelImplCopyWithImpl<$Res>
    extends _$BankDetailsModelCopyWithImpl<$Res, _$BankDetailsModelImpl>
    implements _$$BankDetailsModelImplCopyWith<$Res> {
  __$$BankDetailsModelImplCopyWithImpl(
    _$BankDetailsModelImpl _value,
    $Res Function(_$BankDetailsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BankDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organization = null,
    Object? organizationId = null,
    Object? accountHolderName = null,
    Object? accountNumber = null,
    Object? ifscCode = null,
    Object? bankName = null,
    Object? branchName = null,
    Object? panNumber = freezed,
    Object? dateOBirth = freezed,
  }) {
    return _then(
      _$BankDetailsModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        organization:
            null == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                    as int,
        organizationId:
            null == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                    as int,
        accountHolderName:
            null == accountHolderName
                ? _value.accountHolderName
                : accountHolderName // ignore: cast_nullable_to_non_nullable
                    as String,
        accountNumber:
            null == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        ifscCode:
            null == ifscCode
                ? _value.ifscCode
                : ifscCode // ignore: cast_nullable_to_non_nullable
                    as String,
        bankName:
            null == bankName
                ? _value.bankName
                : bankName // ignore: cast_nullable_to_non_nullable
                    as String,
        branchName:
            null == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                    as String,
        panNumber:
            freezed == panNumber
                ? _value.panNumber
                : panNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        dateOBirth:
            freezed == dateOBirth
                ? _value.dateOBirth
                : dateOBirth // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BankDetailsModelImpl implements _BankDetailsModel {
  const _$BankDetailsModelImpl({
    @JsonKey(name: "id") required this.id,
    @JsonKey(name: "organization") required this.organization,
    @JsonKey(name: "organization_id") required this.organizationId,
    @JsonKey(name: "account_holder_name") required this.accountHolderName,
    @JsonKey(name: "account_number") required this.accountNumber,
    @JsonKey(name: "ifsc_code") required this.ifscCode,
    @JsonKey(name: "bank_name") required this.bankName,
    @JsonKey(name: "branch_name") required this.branchName,
    @JsonKey(name: "pan_number") this.panNumber,
    @JsonKey(name: "date_of_birth") this.dateOBirth,
  });

  factory _$BankDetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BankDetailsModelImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "organization")
  final int organization;
  @override
  @JsonKey(name: "organization_id")
  final int organizationId;
  @override
  @JsonKey(name: "account_holder_name")
  final String accountHolderName;
  @override
  @JsonKey(name: "account_number")
  final String accountNumber;
  @override
  @JsonKey(name: "ifsc_code")
  final String ifscCode;
  @override
  @JsonKey(name: "bank_name")
  final String bankName;
  @override
  @JsonKey(name: "branch_name")
  final String branchName;
  @override
  @JsonKey(name: "pan_number")
  final String? panNumber;
  @override
  @JsonKey(name: "date_of_birth")
  final String? dateOBirth;

  @override
  String toString() {
    return 'BankDetailsModel(id: $id, organization: $organization, organizationId: $organizationId, accountHolderName: $accountHolderName, accountNumber: $accountNumber, ifscCode: $ifscCode, bankName: $bankName, branchName: $branchName, panNumber: $panNumber, dateOBirth: $dateOBirth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BankDetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.accountHolderName, accountHolderName) ||
                other.accountHolderName == accountHolderName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.ifscCode, ifscCode) ||
                other.ifscCode == ifscCode) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.panNumber, panNumber) ||
                other.panNumber == panNumber) &&
            (identical(other.dateOBirth, dateOBirth) ||
                other.dateOBirth == dateOBirth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organization,
    organizationId,
    accountHolderName,
    accountNumber,
    ifscCode,
    bankName,
    branchName,
    panNumber,
    dateOBirth,
  );

  /// Create a copy of BankDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BankDetailsModelImplCopyWith<_$BankDetailsModelImpl> get copyWith =>
      __$$BankDetailsModelImplCopyWithImpl<_$BankDetailsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BankDetailsModelImplToJson(this);
  }
}

abstract class _BankDetailsModel implements BankDetailsModel {
  const factory _BankDetailsModel({
    @JsonKey(name: "id") required final int id,
    @JsonKey(name: "organization") required final int organization,
    @JsonKey(name: "organization_id") required final int organizationId,
    @JsonKey(name: "account_holder_name")
    required final String accountHolderName,
    @JsonKey(name: "account_number") required final String accountNumber,
    @JsonKey(name: "ifsc_code") required final String ifscCode,
    @JsonKey(name: "bank_name") required final String bankName,
    @JsonKey(name: "branch_name") required final String branchName,
    @JsonKey(name: "pan_number") final String? panNumber,
    @JsonKey(name: "date_of_birth") final String? dateOBirth,
  }) = _$BankDetailsModelImpl;

  factory _BankDetailsModel.fromJson(Map<String, dynamic> json) =
      _$BankDetailsModelImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "organization")
  int get organization;
  @override
  @JsonKey(name: "organization_id")
  int get organizationId;
  @override
  @JsonKey(name: "account_holder_name")
  String get accountHolderName;
  @override
  @JsonKey(name: "account_number")
  String get accountNumber;
  @override
  @JsonKey(name: "ifsc_code")
  String get ifscCode;
  @override
  @JsonKey(name: "bank_name")
  String get bankName;
  @override
  @JsonKey(name: "branch_name")
  String get branchName;
  @override
  @JsonKey(name: "pan_number")
  String? get panNumber;
  @override
  @JsonKey(name: "date_of_birth")
  String? get dateOBirth;

  /// Create a copy of BankDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BankDetailsModelImplCopyWith<_$BankDetailsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
