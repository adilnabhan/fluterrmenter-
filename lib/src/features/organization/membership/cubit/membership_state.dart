part of 'membership_cubit.dart';

@freezed
class MembershipState with _$MembershipState {
  const factory MembershipState({
    @Default(None())
    Option<Either<ApiException, ListMembershipPackagesModel>>
    membershipPackages,
    Option<Either<ApiException, void>>? createOrUpdatePackage,
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
