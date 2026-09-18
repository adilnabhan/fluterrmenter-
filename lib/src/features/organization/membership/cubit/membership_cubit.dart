import 'dart:developer' as dev;

import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/emi_options_model.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/package_group_model.dart';

part 'membership_cubit.freezed.dart';
part 'membership_state.dart';

class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit({required this.orgId}) : super(const MembershipState());

  final String orgId;

  Future<void> fetchMembershipPackages({int? groupId}) async {
    if (isClosed) return;
    emit(state.copyWith(membershipPackages: none()));
    final queryParams = <String, dynamic>{'organization_id': orgId};
    if (groupId != null) {
      queryParams['group_id'] = groupId;
    }
    final res = await MembershipRepository().list(
      queryParameters: queryParams,
    );
    if (isClosed) return;
    emit(state.copyWith(membershipPackages: some(res)));
  }

  Future<List<MembershipPackageGroupModel>> fetchPackageGroups() async {
    final res = await MembershipRepository().listPackageGroups(orgId: orgId);
    return res.fold(
      (error) => [],
      (groups) => groups,
    );
  }

  Future<Either<ApiException, MembershipPackageGroupModel>> createPackageGroup({
    required String name,
    String? description,
    int order = 0,
  }) async {
    return await MembershipRepository().createPackageGroup(
      body: {
        'organization': orgId,
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'order': order,
        'is_active': true,
      },
    );
  }

  Future<Either<ApiException, void>> deletePackageGroup({
    required int groupId,
  }) async {
    return await MembershipRepository().deletePackageGroup(id: groupId);
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
    int? groupId,
    List<EmiOptionsModel>? emiOptions,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(createOrUpdatePackage: none()));
    final body = {
      'organization': orgId,
      'duration_days': packageType,
      if (groupId != null) 'group': groupId,
      if (name.isNotEmpty) 'name': name,
      if (description.isNotEmpty) 'description': description,
      'actual_price': actualPrice,
      'offer_price': offerPrice,
      'features': features, // always []
      'is_emi_available': isEmiAvailable,
      'is_active': true, // always included
      if (emiOptions != null && emiOptions.isNotEmpty)
        'emi_plans': emiOptions.map((e) => e.toJson()).toList(),
    };
    print('body is----$body');

    final res =
        (membershipId != null
            ? await MembershipRepository().update(id: membershipId, body: body)
            : await MembershipRepository().create(body: body));
    if (isClosed) return;
    emit(state.copyWith(createOrUpdatePackage: some(res)));
  }

  Future<void> deleteMembershipPackage({required int? id}) async {
    if (id == null) return;
    if (isClosed) return;
    emit(state.copyWith(isDeleting: true));
    final result = await MembershipRepository().delete(id: id);
    if (isClosed) return;
    emit(
      state.copyWith(isDeleting: false, createOrUpdatePackage: some(result)),
    );
  }

  Future<void> fetchBankAccountList() async {
    if (isClosed) return;
    emit(state.copyWith(bankDetails: none(), isLoading: true));
    final res = await MembershipRepository().fetchBankDetails(id: orgId);
    if (isClosed) return;
    emit(state.copyWith(bankDetails: some(res), isLoading: false));
  }

  Future<void> createOrUpdateBankDetails({
    String? holderName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String branchName,
    required String dateOBirth,
    required String panNumber,
    int? detailsId,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(createOrUpdateBank: none(), isLoading: true));
    final body = {
      'account_holder_name': holderName,
      'account_number': accountNumber,
      'ifsc_code': ifsc,
      'bank_name': bankName,
      'branch_name': branchName,
      'organization_id': orgId,
      'pan_number': panNumber,
      'date_of_birth': dateOBirth,
    };
    final res =
        (detailsId != null
            ? await MembershipRepository().updateBankDetails(
              body: body,
              detailsId: detailsId,
            )
            : await MembershipRepository().createBankDetails(body: body));
    if (isClosed) return;
    emit(state.copyWith(createOrUpdateBank: some(res), isLoading: false));
  }
}
