import 'package:mentor_mobile_app/imports_bindings.dart';

part 'membership_state.dart';
part 'membership_cubit.freezed.dart';

class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit({required this.orgId}) : super(const MembershipState());

  final String orgId;

  Future<void> fetchMembershipPackages() async {
    emit(state.copyWith(membershipPackages: none()));
    final res = await MembershipRepository().list(queryParameters: {'organization_id': orgId});
    emit(state.copyWith(membershipPackages: some(res)));
  }

  Future<void> createMembershipPackage({
    required String packageType,
    required String name,
    required double description,
    required String actualPrice,
    required String offerPrice,
    required List<String> features,
    required bool isEmiAvailable,
  }) async {
    emit(state.copyWith(createOrUpdatePackage: none()));
    final body = {
      'organization_id': orgId,
      'package_type': packageType,
      'name': name,
      'description': description,
      'actual_price': actualPrice,
      'offer_price': offerPrice,
      'features': features,
      'is_emi_available': isEmiAvailable,
      'is_active': true,
    };
    final res = await MembershipRepository().create(body: body);
    emit(state.copyWith(createOrUpdatePackage: some(res)));
  }
}
