import 'package:mentor_mobile_app/imports_bindings.dart';

part 'members_and_leads_state.dart';
part 'members_and_leads_cubit.freezed.dart';

class MembersAndLeadsCubit extends Cubit<MembersAndLeadsState> {
  MembersAndLeadsCubit({required this.orgId}) : super(const MembersAndLeadsState());

  final int orgId;

  ///============================= Members =============================\\\

  Future<void> fetchMembers({bool isPagination = false}) async {
    final members = state.members.data.fold(() => null, (t) => t.fold((l) => null, (r) => r));
    if (isPagination && (members?.next?.isEmpty ?? true)) {
      return;
    }
    emit(state.copyWith(members: (data: isPagination ? state.members.data : none(), isPagination: isPagination)));
    final res = await MembersRepository().membersListing(queryParameters: {'status': 'active', 'sort': 'recent', 'organization_id': orgId}, nextUrl: isPagination ? members?.next : null);
    if (isPagination) {
      await res.fold(
        (l) {
          emit(state.copyWith(members: (data: state.members.data, isPagination: false)));
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(results: [...?members?.results, ...?r.results]);
          emit(state.copyWith(members: (data: some(right(data)), isPagination: false)));
        },
      );
    } else {
      emit(state.copyWith(members: (data: some(res), isPagination: isPagination)));
    }
  }

  Future<void> fetchMemberDetails({required int memberId}) async {
    emit(state.copyWith(memberDetails: none()));
    final res = await MembersRepository().memberDetails(id: memberId);
    emit(state.copyWith(memberDetails: some(res)));
  }

  Future<void> cerateOrUpdateMemberDetails({
    required int? memberId,
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String bloodGroup,
    required int userRole,
    required int organizationId,
    required String emergencyContactName,
    required String emergencyContactNumber,
    required double height,
    required double weight,
    required String profession,
    required int membershipPlanId,
    required String profilePicture,
  }) async {
    emit(state.copyWith(memberDetails: none()));
    final res = await MembersRepository().createOrUpdateMember(
      memberId: memberId,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'mobile_number': mobileNumber,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'blood_group': bloodGroup,
        'user_role': userRole,
        'organization_id': organizationId,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_number': emergencyContactNumber,
        'height': height,
        'weight': weight,
        'profession': profession,
        'membership_plan_id': membershipPlanId,
        'profile_picture': profilePicture,
      },
    );
    emit(state.copyWith(memberDetails: some(res)));
  }

  ///============================= Leads =============================\\\

  Future<void> fetchLeads({bool isPagination = false}) async {
    final leads = state.leads.data.fold(() => null, (t) => t.fold((l) => null, (r) => r));
    if (isPagination && (leads?.next?.isEmpty ?? true)) {
      return;
    }
    emit(state.copyWith(leads: (data: isPagination ? state.leads.data : none(), isPagination: isPagination)));
    final res = await LeadsRepository().leadsListing(queryParameters: {'status': 'active', 'sort': 'recent', 'organization_id': 4}, nextUrl: isPagination ? leads?.next : null);
    if (isPagination) {
      await res.fold(
        (l) {
          emit(state.copyWith(leads: (data: state.leads.data, isPagination: false)));
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(results: [...?leads?.results, ...?r.results]);
          emit(state.copyWith(leads: (data: some(right(data)), isPagination: false)));
        },
      );
    } else {
      emit(state.copyWith(leads: (data: some(res), isPagination: isPagination)));
    }
  }

  Future<void> fetchLeadDetails({required int leadId}) async {
    emit(state.copyWith(leadDetails: none()));
    final res = await LeadsRepository().leadDetails(id: leadId);
    emit(state.copyWith(leadDetails: some(res)));
  }

  Future<void> createOrUpdateLeadDetails({
    required int? leadId,
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String bloodGroup,
    required int userRole,
    required int organizationId,
    required String emergencyContact,
    required String emergencyContactNumber,
    required double height,
    required double weight,
    required String designation,
    required int experience,
    required String addressProof,
    required List<String> trainerCertificates,
    required String profilePicture,
    required List<int> categories,
  }) async {
    emit(state.copyWith(createOrUpdateLead: none()));
    final formData = FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'mobile_number': mobileNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup,
      'user_role': userRole,
      'organization_id': organizationId,
      'emergency_contact': emergencyContact,
      'emergency_contact_number': emergencyContactNumber,
      'height': height,
      'weight': weight,
      'designation': designation,
      'experience': experience,
    });

    // Add address proof file if provided
    if (addressProof.isNotEmpty) {
      formData.files.add(MapEntry('address_proof', await MultipartFile.fromFile(addressProof)));
    }

    // Add trainer certificates if provided
    if (trainerCertificates.isNotEmpty) {
      for (var i = 0; i < trainerCertificates.length; i++) {
        formData.files.add(MapEntry('trainer_certificates[$i]', await MultipartFile.fromFile(trainerCertificates[i])));
      }
    }

    // Add profile picture if provided
    if (profilePicture.isNotEmpty) {
      formData.files.add(MapEntry('profile_picture', await MultipartFile.fromFile(profilePicture)));
    }

    // Add categories if provided
    if (categories.isNotEmpty) {
      for (final category in categories.asMap().entries) {
        formData.fields.add(MapEntry('categories[${category.key}]', category.value.toString()));
      }
    }
    final res = await LeadsRepository().createOrupdateLead(leadId: leadId, body: formData);
    emit(state.copyWith(createOrUpdateLead: some(res)));
  }
}
