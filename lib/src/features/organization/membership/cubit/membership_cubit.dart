import 'dart:developer' as dev;

import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/emi_options_model.dart';

part 'membership_cubit.freezed.dart';
part 'membership_state.dart';

class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit({required this.orgId}) : super(const MembershipState());

  final String orgId;

  Future<void> fetchMembershipPackages() async {
    emit(state.copyWith(membershipPackages: none()));
    final res = await MembershipRepository().list(
      queryParameters: {'organization_id': orgId},
    );
    emit(state.copyWith(membershipPackages: some(res)));
  }

  Future<void> createOrUpdateMembershipPackage({
    required int? membershipId,
    required String packageType,
    required String name,
    required String description,
    required String actualPrice,
    required String offerPrice,
    required List<String> features,
    required bool isEmiAvailable,
    List<EmiOptionsModel>? emiOptions,
  }) async {
    emit(state.copyWith(createOrUpdatePackage: none()));
    final body = {
      'organization': orgId,
      'package_type': packageType,
      'name': name,
      'description': description,
      'actual_price': actualPrice,
      'offer_price': offerPrice,
      'features': features,
      'is_emi_available': isEmiAvailable,
      'is_active': true,
      'emi_plans': emiOptions?.map((e) => e.toJson()).toList(),
    };

    final res =
        (membershipId != null
            ? await MembershipRepository().update(id: membershipId, body: body)
            : await MembershipRepository().create(body: body));
    emit(state.copyWith(createOrUpdatePackage: some(res)));
  }
}
