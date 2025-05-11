// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'members_and_leads_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MembersAndLeadsState {
//* Members
  ({Option<Either<ApiException, MembersListingModel>> data, bool isPagination})
      get members => throw _privateConstructorUsedError;
  Option<Either<ApiException, MemberDetailsModel>> get memberDetails =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, MemberDetailsModel>>? get createOrUpdateMember =>
      throw _privateConstructorUsedError; //* Leads
  ({Option<Either<ApiException, LeadsListingModel>> data, bool isPagination})
      get leads => throw _privateConstructorUsedError;
  Option<Either<ApiException, LeadDetailsModel>> get leadDetails =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, CreateOrUpdateLeadModel>>?
      get createOrUpdateLead => throw _privateConstructorUsedError;

  /// Create a copy of MembersAndLeadsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembersAndLeadsStateCopyWith<MembersAndLeadsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembersAndLeadsStateCopyWith<$Res> {
  factory $MembersAndLeadsStateCopyWith(MembersAndLeadsState value,
          $Res Function(MembersAndLeadsState) then) =
      _$MembersAndLeadsStateCopyWithImpl<$Res, MembersAndLeadsState>;
  @useResult
  $Res call(
      {({
        Option<Either<ApiException, MembersListingModel>> data,
        bool isPagination
      }) members,
      Option<Either<ApiException, MemberDetailsModel>> memberDetails,
      Option<Either<ApiException, MemberDetailsModel>>? createOrUpdateMember,
      ({
        Option<Either<ApiException, LeadsListingModel>> data,
        bool isPagination
      }) leads,
      Option<Either<ApiException, LeadDetailsModel>> leadDetails,
      Option<Either<ApiException, CreateOrUpdateLeadModel>>?
          createOrUpdateLead});
}

/// @nodoc
class _$MembersAndLeadsStateCopyWithImpl<$Res,
        $Val extends MembersAndLeadsState>
    implements $MembersAndLeadsStateCopyWith<$Res> {
  _$MembersAndLeadsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembersAndLeadsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? members = null,
    Object? memberDetails = null,
    Object? createOrUpdateMember = freezed,
    Object? leads = null,
    Object? leadDetails = null,
    Object? createOrUpdateLead = freezed,
  }) {
    return _then(_value.copyWith(
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as ({
              Option<Either<ApiException, MembersListingModel>> data,
              bool isPagination
            }),
      memberDetails: null == memberDetails
          ? _value.memberDetails
          : memberDetails // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, MemberDetailsModel>>,
      createOrUpdateMember: freezed == createOrUpdateMember
          ? _value.createOrUpdateMember
          : createOrUpdateMember // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, MemberDetailsModel>>?,
      leads: null == leads
          ? _value.leads
          : leads // ignore: cast_nullable_to_non_nullable
              as ({
              Option<Either<ApiException, LeadsListingModel>> data,
              bool isPagination
            }),
      leadDetails: null == leadDetails
          ? _value.leadDetails
          : leadDetails // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, LeadDetailsModel>>,
      createOrUpdateLead: freezed == createOrUpdateLead
          ? _value.createOrUpdateLead
          : createOrUpdateLead // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, CreateOrUpdateLeadModel>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembersAndLeadsStateImplCopyWith<$Res>
    implements $MembersAndLeadsStateCopyWith<$Res> {
  factory _$$MembersAndLeadsStateImplCopyWith(_$MembersAndLeadsStateImpl value,
          $Res Function(_$MembersAndLeadsStateImpl) then) =
      __$$MembersAndLeadsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {({
        Option<Either<ApiException, MembersListingModel>> data,
        bool isPagination
      }) members,
      Option<Either<ApiException, MemberDetailsModel>> memberDetails,
      Option<Either<ApiException, MemberDetailsModel>>? createOrUpdateMember,
      ({
        Option<Either<ApiException, LeadsListingModel>> data,
        bool isPagination
      }) leads,
      Option<Either<ApiException, LeadDetailsModel>> leadDetails,
      Option<Either<ApiException, CreateOrUpdateLeadModel>>?
          createOrUpdateLead});
}

/// @nodoc
class __$$MembersAndLeadsStateImplCopyWithImpl<$Res>
    extends _$MembersAndLeadsStateCopyWithImpl<$Res, _$MembersAndLeadsStateImpl>
    implements _$$MembersAndLeadsStateImplCopyWith<$Res> {
  __$$MembersAndLeadsStateImplCopyWithImpl(_$MembersAndLeadsStateImpl _value,
      $Res Function(_$MembersAndLeadsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MembersAndLeadsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? members = null,
    Object? memberDetails = null,
    Object? createOrUpdateMember = freezed,
    Object? leads = null,
    Object? leadDetails = null,
    Object? createOrUpdateLead = freezed,
  }) {
    return _then(_$MembersAndLeadsStateImpl(
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as ({
              Option<Either<ApiException, MembersListingModel>> data,
              bool isPagination
            }),
      memberDetails: null == memberDetails
          ? _value.memberDetails
          : memberDetails // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, MemberDetailsModel>>,
      createOrUpdateMember: freezed == createOrUpdateMember
          ? _value.createOrUpdateMember
          : createOrUpdateMember // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, MemberDetailsModel>>?,
      leads: null == leads
          ? _value.leads
          : leads // ignore: cast_nullable_to_non_nullable
              as ({
              Option<Either<ApiException, LeadsListingModel>> data,
              bool isPagination
            }),
      leadDetails: null == leadDetails
          ? _value.leadDetails
          : leadDetails // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, LeadDetailsModel>>,
      createOrUpdateLead: freezed == createOrUpdateLead
          ? _value.createOrUpdateLead
          : createOrUpdateLead // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, CreateOrUpdateLeadModel>>?,
    ));
  }
}

/// @nodoc

class _$MembersAndLeadsStateImpl implements _MembersAndLeadsState {
  const _$MembersAndLeadsStateImpl(
      {this.members = const (data: None(), isPagination: false),
      this.memberDetails = const None(),
      this.createOrUpdateMember,
      this.leads = const (data: None(), isPagination: false),
      this.leadDetails = const None(),
      this.createOrUpdateLead});

//* Members
  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, MembersListingModel>> data,
    bool isPagination
  }) members;
  @override
  @JsonKey()
  final Option<Either<ApiException, MemberDetailsModel>> memberDetails;
  @override
  final Option<Either<ApiException, MemberDetailsModel>>? createOrUpdateMember;
//* Leads
  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, LeadsListingModel>> data,
    bool isPagination
  }) leads;
  @override
  @JsonKey()
  final Option<Either<ApiException, LeadDetailsModel>> leadDetails;
  @override
  final Option<Either<ApiException, CreateOrUpdateLeadModel>>?
      createOrUpdateLead;

  @override
  String toString() {
    return 'MembersAndLeadsState(members: $members, memberDetails: $memberDetails, createOrUpdateMember: $createOrUpdateMember, leads: $leads, leadDetails: $leadDetails, createOrUpdateLead: $createOrUpdateLead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembersAndLeadsStateImpl &&
            (identical(other.members, members) || other.members == members) &&
            (identical(other.memberDetails, memberDetails) ||
                other.memberDetails == memberDetails) &&
            (identical(other.createOrUpdateMember, createOrUpdateMember) ||
                other.createOrUpdateMember == createOrUpdateMember) &&
            (identical(other.leads, leads) || other.leads == leads) &&
            (identical(other.leadDetails, leadDetails) ||
                other.leadDetails == leadDetails) &&
            (identical(other.createOrUpdateLead, createOrUpdateLead) ||
                other.createOrUpdateLead == createOrUpdateLead));
  }

  @override
  int get hashCode => Object.hash(runtimeType, members, memberDetails,
      createOrUpdateMember, leads, leadDetails, createOrUpdateLead);

  /// Create a copy of MembersAndLeadsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembersAndLeadsStateImplCopyWith<_$MembersAndLeadsStateImpl>
      get copyWith =>
          __$$MembersAndLeadsStateImplCopyWithImpl<_$MembersAndLeadsStateImpl>(
              this, _$identity);
}

abstract class _MembersAndLeadsState implements MembersAndLeadsState {
  const factory _MembersAndLeadsState(
      {final ({
        Option<Either<ApiException, MembersListingModel>> data,
        bool isPagination
      }) members,
      final Option<Either<ApiException, MemberDetailsModel>> memberDetails,
      final Option<Either<ApiException, MemberDetailsModel>>?
          createOrUpdateMember,
      final ({
        Option<Either<ApiException, LeadsListingModel>> data,
        bool isPagination
      }) leads,
      final Option<Either<ApiException, LeadDetailsModel>> leadDetails,
      final Option<Either<ApiException, CreateOrUpdateLeadModel>>?
          createOrUpdateLead}) = _$MembersAndLeadsStateImpl;

//* Members
  @override
  ({Option<Either<ApiException, MembersListingModel>> data, bool isPagination})
      get members;
  @override
  Option<Either<ApiException, MemberDetailsModel>> get memberDetails;
  @override
  Option<Either<ApiException, MemberDetailsModel>>?
      get createOrUpdateMember; //* Leads
  @override
  ({Option<Either<ApiException, LeadsListingModel>> data, bool isPagination})
      get leads;
  @override
  Option<Either<ApiException, LeadDetailsModel>> get leadDetails;
  @override
  Option<Either<ApiException, CreateOrUpdateLeadModel>>? get createOrUpdateLead;

  /// Create a copy of MembersAndLeadsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembersAndLeadsStateImplCopyWith<_$MembersAndLeadsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
