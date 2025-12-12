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
    // final body = {
    //   'organization': orgId,
    //   // 'package_type': packageType,
    //   'duration_days': packageType,
    //   'name': name,
    //   'description': description,
    //   'actual_price': actualPrice,
    //   'offer_price': actualPrice,
    //   'features': features,
    //   'is_emi_available': isEmiAvailable,
    //   'is_active': true,
    //   'emi_plans': emiOptions?.map((e) => e.toJson()).toList(),
    // };
    final body = {
      'organization': orgId,
      'duration_days': packageType,
      if (name.isNotEmpty) 'name': name,
      if (description.isNotEmpty) 'description': description,
      'actual_price': actualPrice,
      'offer_price': offerPrice,
      'features': features, // always []
      'is_emi_available': isEmiAvailable,
      'is_active': true, // always included
      if (emiOptions!.isNotEmpty)
        'emi_plans': emiOptions.map((e) => e.toJson()).toList(),
    };
    print('body is----$body');

    final res =
        (membershipId != null
            ? await MembershipRepository().update(id: membershipId, body: body)
            : await MembershipRepository().create(body: body));
    emit(state.copyWith(createOrUpdatePackage: some(res)));
  }

  Future<void> deleteMembershipPackage({required int? id}) async {
    if (id == null) return;
    emit(state.copyWith(isDeleting: true));
    final result = await MembershipRepository().delete(id: id);
    emit(
      state.copyWith(isDeleting: false, createOrUpdatePackage: some(result)),
    );
  }

  Future<void> fetchBankAccountList() async {
    emit(state.copyWith(bankDetails: none(), isLoading: true));
    final res = await MembershipRepository().fetchBankDetails(id: orgId);
    emit(state.copyWith(bankDetails: some(res), isLoading: false));
  }

  Future<void> createOrUpdateBankDetails({
    String? holderName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String branchName,
    int? detailsId,
  }) async {
    emit(state.copyWith(createOrUpdateBank: none(), isLoading: true));
    final body = {
      'account_holder_name': holderName,
      'account_number': accountNumber,
      'ifsc_code': ifsc,
      'bank_name': bankName,
      'branch_name': branchName,
      'organization_id': orgId,
    };
    final res =
        (detailsId != null
            ? await MembershipRepository().updateBankDetails(
              body: body,
              detailsId: detailsId,
            )
            : await MembershipRepository().createBankDetails(body: body));
    emit(state.copyWith(createOrUpdateBank: some(res), isLoading: false));
  }
}
