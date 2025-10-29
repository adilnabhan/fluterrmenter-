part of 'membership_cubit.dart';

@freezed
class MembershipState with _$MembershipState {
  const factory MembershipState({
    @Default(None())
    Option<Either<ApiException, ListMembershipPackagesModel>>
    membershipPackages,
    @Default(None())
    Option<Either<ApiException, BankDetailsModel>>
    bankDetails,
    Option<Either<ApiException, void>>? createOrUpdatePackage,
    Option<Either<ApiException, void>>? createOrUpdateBank,
    @Default(false) bool isDeleting,
    @Default(false) bool isLoading,
  }) = _MembershipState;
}

enum PackageType {
  monthly,
  quarterly,
  yearly;

  String get label {
    switch (this) {
      case PackageType.monthly:
        return 'Monthly Plan';
      case PackageType.quarterly:
        return 'Quarterly Plan';
      case PackageType.yearly:
        return 'Yearly Plan';
    }
  }

  static PackageType? fromLabel(String? label) {
    if (label == null) return null;
    try {
      return PackageType.values.firstWhere((e) => e.label == label);
    } catch (e) {
      return null;
    }
  }
}
