import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/emi_options_model.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/package_group_model.dart';

part 'membership_cubit.freezed.dart';
part 'membership_state.dart';

class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit({required this.orgId}) : super(const MembershipState());

  final String orgId;

  int _currentPage = 1;
  String? _nextPageUrl;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchMembershipPackages({dynamic groupId}) async {
    if (isClosed) return;
    _currentPage = 1;
    _nextPageUrl = null;
    _hasMore = false;
    _isLoadingMore = false;
    emit(state.copyWith(membershipPackages: none()));
    final queryParams = <String, dynamic>{'organization_id': orgId, 'page': 1};
    if (groupId != null) {
      queryParams['group_id'] = groupId.toString();
    }
    final res = await MembershipRepository().list(
      queryParameters: queryParams,
    );
    if (isClosed) return;
    res.fold(
      (err) {
        _hasMore = false;
      },
      (data) {
        _nextPageUrl = data.next?.toString();
        _hasMore = _nextPageUrl != null && _nextPageUrl!.isNotEmpty;
      },
    );
    emit(state.copyWith(membershipPackages: some(res)));
  }

  Future<void> fetchMoreMembershipPackages({dynamic groupId}) async {
    if (isClosed || _isLoadingMore || !_hasMore) return;

    final currentOption = state.membershipPackages;
    final currentData = currentOption.fold(
      () => null,
      (either) => either.fold((l) => null, (r) => r),
    );
    if (currentData == null) return;

    _isLoadingMore = true;
    emit(state.copyWith(isLoading: true));

    final nextPage = _currentPage + 1;
    final Either<ApiException, ListMembershipPackagesModel> res;

    if (_nextPageUrl != null && _nextPageUrl!.isNotEmpty) {
      res = await MembershipRepository().listByUrl(url: _nextPageUrl!);
    } else {
      final queryParams = <String, dynamic>{
        'organization_id': orgId,
        'page': nextPage,
      };
      if (groupId != null) {
        queryParams['group_id'] = groupId.toString();
      }
      res = await MembershipRepository().list(queryParameters: queryParams);
    }

    if (isClosed) return;
    _isLoadingMore = false;

    res.fold(
      (err) {
        _hasMore = false;
        emit(state.copyWith(isLoading: false));
      },
      (newData) {
        _currentPage = nextPage;
        _nextPageUrl = newData.next?.toString();
        _hasMore = _nextPageUrl != null && _nextPageUrl!.isNotEmpty;

        final existingResults = currentData.results ?? [];
        final newResults = newData.results ?? [];
        final combinedResults = [...existingResults, ...newResults];

        final updatedModel = currentData.copyWith(
          results: combinedResults,
          next: newData.next,
          previous: newData.previous,
          count: newData.count ?? combinedResults.length,
        );

        emit(state.copyWith(
          membershipPackages: some(right(updatedModel)),
          isLoading: false,
        ));
      },
    );
  }

  Future<GroupedMembershipPackagesModel?> fetchGroupedPackages() async {
    final res =
        await MembershipRepository().getGroupedMembershipPackages(orgId: orgId);
    return res.fold(
      (error) => null,
      (data) => data,
    );
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
