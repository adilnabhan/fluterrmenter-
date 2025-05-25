part of 'membership_cubit.dart';

@freezed
class MembershipState with _$MembershipState {
  const factory MembershipState({
    @Default(None()) Option<Either<ApiException, ListMembershipPackagesModel>> membershipPackages,
    Option<Either<ApiException, MembershipPackageModel>>? createOrUpdatePackage,
  }) = _MembershipState;
}
