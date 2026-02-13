import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/domain/models/payment_history/payment_history_model.dart';

part 'members_and_leads_state.dart';
part 'members_and_leads_cubit.freezed.dart';

class MembersAndLeadsCubit extends Cubit<MembersAndLeadsState> {
  MembersAndLeadsCubit({required this.orgId})
    : super(const MembersAndLeadsState());

  final int orgId;

  ///============================= Members =============================\\\

  Future<void> fetchMembers({
    required MemberStatus? status,
    required ListingSort? sort,
    bool isPagination = false,
    String? searchQuery,
  }) async {
    final members = state.members.data.fold(
      () => null,
      (t) => t.fold((l) => null, (r) => r),
    );
    if (isPagination && (members?.next?.isEmpty ?? true)) {
      return;
    }
    emit(
      state.copyWith(
        members: (
          data: isPagination ? state.members.data : none(),
          isPagination: isPagination,
        ),
      ),
    );
    final res = await MembersRepository().membersListing(
      queryParameters: {
        if (status != null) 'status': status.name,
        if (sort != null) 'sort': sort.name,
        'organization_id': orgId,
        if (searchQuery?.trim().isNotEmpty ?? false) 'search': searchQuery,
      },
      nextUrl: isPagination ? members?.next : null,
    );
    if (isPagination) {
      await res.fold(
        (l) {
          emit(
            state.copyWith(
              members: (data: state.members.data, isPagination: false),
            ),
          );
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(
            results: [...?members?.results, ...?r.results],
          );
          emit(
            state.copyWith(
              members: (data: some(right(data)), isPagination: false),
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(members: (data: some(res), isPagination: isPagination)),
      );
    }
  }

  Future<void> fetchMemberDetails({required int memberId}) async {
    emit(state.copyWith(memberDetails: none()));
    final res = await MembersRepository().memberDetails(id: memberId);
    emit(state.copyWith(memberDetails: some(res)));
  }

  Future<void> cerateOrUpdateMemberDetails({
    required MemberDetailsModel memeberDetails,
    required MembershipPackageModel membershipPackageModel,
  }) async {
    print('id ---${membershipPackageModel.id}---$orgId');
    emit(
      state.copyWith(
        createOrUpdateMember: none(),
        memberOnboardedAnimationCompleted: null,
      ),
    );

    final map = {
      'first_name': memeberDetails.fullName,
      // 'last_name': '',
      'mobile_number': '+91${memeberDetails.mobileNumber}',
      'email': memeberDetails.email,
      'date_of_birth': memeberDetails.dateOfBirth?.format('yyyy-MM-dd'),
      'gender': memeberDetails.gender,
      'blood_group': memeberDetails.bloodGroup,
      'address': memeberDetails.address,
      'user_role': 45,
      'organization_id': orgId,
      'emergency_contact_number':
          memeberDetails.emergencyContactNumber!.isNotEmpty
              ? '+91${memeberDetails.emergencyContactNumber}'
              : null,
      'height': memeberDetails.height,
      'weight': memeberDetails.weight,
      'profession': memeberDetails.profession,
      'membership_plan_id': membershipPackageModel.id,
      'profile_picture':
          (memeberDetails.profilePicture?.isNotEmpty ?? false)
              ? await MultipartFile.fromFile(
                memeberDetails.profilePicture!,
                filename: 'profile.jpg',
              )
              : null,
    }..removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
    print(' ths map is--$map');
    final res = await MembersRepository().createOrUpdateMember(
      memberId: null,
      body: FormData.fromMap(map),
    );
    emit(state.copyWith(createOrUpdateMember: some(res)));
    res.fold((l) {}, (r) {
      Future.delayed(const Duration(seconds: 1), () {
        emit(state.copyWith(memberOnboardedAnimationCompleted: true));
      });
    });
  }

  ///============================= Leads =============================\\\

  Future<void> fetchLeads({
    required MemberStatus? status,
    required ListingSort? sort,
    bool isPagination = false,
    String? searchQuery,
  }) async {
    final leads = state.leads.data.fold(
      () => null,
      (t) => t.fold((l) => null, (r) => r),
    );
    if (isPagination && (leads?.next?.isEmpty ?? true)) {
      return;
    }
    emit(
      state.copyWith(
        leads: (
          data: isPagination ? state.leads.data : none(),
          isPagination: isPagination,
        ),
      ),
    );
    final res = await LeadsRepository().leadsListing(
      queryParameters: {
        if (status != null) 'status': status.name,
        if (sort != null) 'sort': sort.name,
        if (searchQuery?.trim().isNotEmpty ?? false) 'search': searchQuery,
        'organization_id': orgId,
      },
      nextUrl: isPagination ? leads?.next : null,
    );
    if (isPagination) {
      await res.fold(
        (l) {
          emit(
            state.copyWith(
              leads: (data: state.leads.data, isPagination: false),
            ),
          );
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(results: [...?leads?.results, ...?r.results]);
          emit(
            state.copyWith(
              leads: (data: some(right(data)), isPagination: false),
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(leads: (data: some(res), isPagination: isPagination)),
      );
    }
  }

  Future<void> fetchLeadDetails({required String leadId}) async {
    emit(state.copyWith(leadDetails: none()));
    final res = await LeadsRepository().leadDetails(id: leadId);
    emit(state.copyWith(leadDetails: some(res)));
  }

  Future<void> createOrUpdateLeadDetails({
    required int? leadId,
    required String? fullName,
    required String? mobileNumber,
    required String? email,
    required String? dateOfBirth,
    required String? gender,
    required String? bloodGroup,
    // required String? emergencyContact,
    required String? emergencyContactNumber,
    required int? experience,
    required String? addressProof,
    required List<String>? trainerCertificates,
    required String? profilePicture,
  }) async {
    emit(state.copyWith(createOrUpdateLead: none()));
    if (fullName?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Full name is required')),
          ),
        ),
      );
      return;
    } else if (mobileNumber?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Mobile number is required')),
          ),
        ),
      );
      return;
    } else if (email?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Email is required')),
          ),
        ),
      );
      return;
    } else if (dateOfBirth?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Date of birth is required')),
          ),
        ),
      );
      return;
    } else if (gender?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Gender is required')),
          ),
        ),
      );
      return;
    } else if (bloodGroup?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Blood group is required')),
          ),
        ),
      );
      return;
    } else if (emergencyContactNumber?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(
              const ApiException.notFound(
                msg: 'Emergency contact number is required',
              ),
            ),
          ),
        ),
      );
      return;
    } else if (experience == null) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Experience is required')),
          ),
        ),
      );
      return;
    } else if (addressProof?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Address proof is required')),
          ),
        ),
      );
      return;
    } else if (trainerCertificates?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(
              const ApiException.notFound(
                msg: 'Trainer certificates are required',
              ),
            ),
          ),
        ),
      );
      return;
    }
    // else if (profilePicture?.isEmpty ?? true) {
    //   emit(state.copyWith(createOrUpdateLead: some(left(const ApiException.notFound(msg: 'Profile picture is required')))));
    //   return;
    // }
    final formData = FormData.fromMap({
      'first_name': fullName,
      'last_name': '',
      'mobile_number': '+91$mobileNumber',
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender?.toLowerCase(),
      'blood_group': bloodGroup,
      'user_role': 35,
      'organization_id': orgId,
      // 'emergency_contact': emergencyContact,
      'emergency_contact_number': emergencyContactNumber,
      // 'height': height,
      // 'weight': weight,
      'designation': 'trainer',
      'experience': experience,
    });

    // Add address proof file if provided
    if (addressProof?.isNotEmpty ?? false) {
      formData.files.add(
        MapEntry('address_proof', await MultipartFile.fromFile(addressProof!)),
      );
    }

    // Add trainer certificates if provided
    if (trainerCertificates?.isNotEmpty ?? false) {
      for (var i = 0; i < trainerCertificates!.length; i++) {
        formData.files.add(
          MapEntry(
            'trainer_certificates[$i]',
            await MultipartFile.fromFile(trainerCertificates[i]),
          ),
        );
      }
    }

    // Add profile picture if provided
    if (profilePicture?.isNotEmpty ?? false) {
      formData.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(profilePicture!),
        ),
      );
    }

    // // Add categories if provided
    // if (categories.isNotEmpty) {
    //   for (final category in categories.asMap().entries) {
    //     formData.fields.add(MapEntry('categories[${category.key}]', category.value.toString()));
    //   }
    // }
    final res = await LeadsRepository().createOrupdateLead(
      leadId: leadId,
      body: formData,
    );
    emit(state.copyWith(createOrUpdateLead: some(res)));
  }

  Future<void> updateLeadBasicDetails({
    required int leadId,
    required String? fullName,
    required String? mobileNumber,
    required String? email,
    required String? gender,
    required String? profilePicture,
  }) async {
    emit(state.copyWith(createOrUpdateLead: none()));
    if (fullName?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Full name is required')),
          ),
        ),
      );
      return;
    } else if (mobileNumber?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Mobile number is required')),
          ),
        ),
      );
      return;
    } else if (email?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Email is required')),
          ),
        ),
      );
      return;
    } else if (gender?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Gender is required')),
          ),
        ),
      );
      return;
    }
    final formData = FormData.fromMap({
      'first_name': fullName,
      'last_name': '',
      'mobile_number': '+91$mobileNumber',
      'email': email,
      'gender': gender?.toLowerCase(),
      'user_role': 35,
      'organization_id': orgId,
      'designation': 'trainer',
    });
    // Add profile picture if provided
    if (profilePicture?.isNotEmpty ?? false) {
      formData.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(profilePicture!),
        ),
      );
    }
    final res = await LeadsRepository().createOrupdateLead(
      leadId: leadId,
      body: formData,
    );
    emit(state.copyWith(createOrUpdateLead: some(res)));
  }

  Future<void> updateMemberBasicDetails({
    required int memberId,
    required String? fullName,
    required String? mobileNumber,
    required String? email,
    required String? gender,
    required String? profilePicture,
  }) async {
    emit(state.copyWith(createOrUpdateMember: none()));
    // if (fullName?.isEmpty ?? true) {
    //   emit(
    //     state.copyWith(
    //       createOrUpdateMember: some(
    //         left(const ApiException.notFound(msg: 'Full name is required')),
    //       ),
    //     ),
    //   );
    //   return;
    // } else if (mobileNumber?.isEmpty ?? true) {
    //   emit(
    //     state.copyWith(
    //       createOrUpdateMember: some(
    //         left(const ApiException.notFound(msg: 'Mobile number is required')),
    //       ),
    //     ),
    //   );
    //   return;
    // } else if (email?.isEmpty ?? true) {
    //   emit(
    //     state.copyWith(
    //       createOrUpdateMember: some(
    //         left(const ApiException.notFound(msg: 'Email is required')),
    //       ),
    //     ),
    //   );
    //   return;
    // } else if (gender?.isEmpty ?? true) {
    //   emit(
    //     state.copyWith(
    //       createOrUpdateMember: some(
    //         left(const ApiException.notFound(msg: 'Gender is required')),
    //       ),
    //     ),
    //   );
    //   return;
    // }

    final Map<String, dynamic> data = {};

    void addIfNotNull(String key, dynamic value) {
      if (value != null && value.toString().isNotEmpty) {
        data[key] = value;
      }
    }

    addIfNotNull('first_name', fullName);
    addIfNotNull('last_name', '');
    addIfNotNull('mobile_number', '+91$mobileNumber');
    addIfNotNull('email', email);
    addIfNotNull('gender', gender?.toLowerCase());
    addIfNotNull('user_role', 35);
    addIfNotNull('organization_id', orgId);
    addIfNotNull('designation', 'trainer');

    final formData = FormData.fromMap(data);

    // ===== PROFILE PICTURE CHECK =====
    if (profilePicture?.isNotEmpty ?? false) {
      formData.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(profilePicture!),
        ),
      );
    }

    debugPrint("📦 ----- MEMBER UPDATE PAYLOAD -----");
    debugPrint("🧾 Fields:");
    for (var field in formData.fields) {
      debugPrint("   ${field.key}: ${field.value}");
    }

    debugPrint("🖼 Files:");
    for (var file in formData.files) {
      debugPrint("   ${file.key}: ${(file.value as MultipartFile).filename}");
    }
    debugPrint("📦 --------------------------------");

    // final formData = FormData.fromMap({
    //   'first_name': fullName,
    //   'last_name': '',
    //   'mobile_number': '+91$mobileNumber',
    //   'email': email,
    //   'gender': gender?.toLowerCase(),
    //   'user_role': 35,
    //   'organization_id': orgId,
    //   'designation': 'trainer',
    // });
    // // Add profile picture if provided
    // if (profilePicture?.isNotEmpty ?? false) {
    //   formData.files.add(
    //     MapEntry(
    //       'profile_picture',
    //       await MultipartFile.fromFile(profilePicture!),
    //     ),
    //   );
    // }
    final res = await MembersRepository().createOrUpdateMember(
      memberId: memberId,
      body: formData,
    );
    emit(state.copyWith(createOrUpdateMember: some(res)));
  }

  Future<void> updateMemberDob({
    required int memberId,
    required String? dob,
  }) async {
    emit(state.copyWith(createOrUpdateMember: none()));
    if (dob?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateMember: some(
            left(const ApiException.notFound(msg: 'Date of birth is required')),
          ),
        ),
      );
      return;
    }
    final res = await MembersRepository().createOrUpdateMember(
      memberId: memberId,
      body: {'date_of_birth': dob, 'organization_id': orgId},
    );
    emit(state.copyWith(createOrUpdateMember: some(res)));
  }

  Future<void> updateMemberHeight({
    required int memberId,
    required String? height,
  }) async {
    emit(state.copyWith(createOrUpdateMember: none()));
    if (height?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateMember: some(
            left(const ApiException.notFound(msg: 'Height is required')),
          ),
        ),
      );
      return;
    }
    final res = await MembersRepository().createOrUpdateMember(
      memberId: memberId,
      body: {'height': height, 'organization_id': orgId},
    );
    emit(state.copyWith(createOrUpdateMember: some(res)));
  }

  Future<void> updateMemberWeight({
    required int memberId,
    required String? weight,
  }) async {
    emit(state.copyWith(createOrUpdateMember: none()));
    if (weight?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateMember: some(
            left(const ApiException.notFound(msg: 'Weight is required')),
          ),
        ),
      );
      return;
    }
    final res = await MembersRepository().createOrUpdateMember(
      memberId: memberId,
      body: {'weight': weight, 'organization_id': orgId},
    );
    emit(state.copyWith(createOrUpdateMember: some(res)));
  }

  Future<void> updateLeadDob({
    required int leadId,
    required String? dob,
  }) async {
    emit(state.copyWith(createOrUpdateLead: none()));
    if (dob?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Date of birth is required')),
          ),
        ),
      );
      return;
    }
    final res = await LeadsRepository().createOrupdateLead(
      leadId: leadId,
      body: {'date_of_birth': dob, 'organization_id': orgId},
    );
    emit(state.copyWith(createOrUpdateLead: some(res)));
  }

  Future<void> updateLeadExperience({
    required int leadId,
    required String? experience,
  }) async {
    emit(state.copyWith(createOrUpdateLead: none()));
    if (experience?.isEmpty ?? true) {
      emit(
        state.copyWith(
          createOrUpdateLead: some(
            left(const ApiException.notFound(msg: 'Experience is required')),
          ),
        ),
      );
      return;
    }
    final res = await LeadsRepository().createOrupdateLead(
      leadId: leadId,
      body: {'experience': experience, 'organization_id': orgId},
    );
    emit(state.copyWith(createOrUpdateLead: some(res)));
  }

  // Future<void> fetchExpiringMemberShip() async {
  //   emit(state.copyWith(upComingPayments: none()));
  //   final res = await MembershipRepository().listExpiringMembership(
  //     queryParameters: {'organization_id': orgId},
  //   );
  //   emit(state.copyWith(upComingPayments: some(res)));
  // }

  Future<void> fetchExpiringMemberShip({bool isPagination = false}) async {
    // Extract existing data for pagination
    final expiring = state.upComingPayments.data.fold(
      () => null,
      (t) => t.fold((l) => null, (r) => r),
    );

    // Stop if pagination requested but no next page
    if (isPagination && (expiring?.next?.isEmpty ?? true)) {
      return;
    }

    // Emit loading state (preserve previous data if pagination)
    emit(
      state.copyWith(
        upComingPayments: (
          data: isPagination ? state.upComingPayments.data : none(),
          isPagination: isPagination,
        ),
      ),
    );

    // API Call
    final res = await MembershipRepository().listExpiringMembership(
      queryParameters: {'organization_id': orgId},
      nextUrl: isPagination ? expiring?.next : null,
    );

    // Handle Pagination Case
    if (isPagination) {
      await res.fold(
        (l) {
          emit(
            state.copyWith(
              upComingPayments: (
                data: state.upComingPayments.data,
                isPagination: false,
              ),
            ),
          );
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(
            results: [...?expiring?.results, ...?r.results],
          );

          emit(
            state.copyWith(
              upComingPayments: (data: some(right(data)), isPagination: false),
            ),
          );
        },
      );
    }
    // Handle First Load (no pagination)
    else {
      emit(
        state.copyWith(
          upComingPayments: (data: some(res), isPagination: false),
        ),
      );
    }
  }



  Future<void> fetchPaymentHistory({bool isPagination = false,
    required int orgId
  }) async {
    final paymentHistoryData = state.paymentHistory.data.fold(
          () => null,
          (t) => t.fold((l) => null, (r) => r),
    );

    final String? nextUrl = paymentHistoryData?.allPayments.next;

    if (isPagination && (nextUrl == null || nextUrl.isEmpty)) {
      return;
    }

    emit(
      state.copyWith(
        paymentHistory: (
        data: isPagination ? state.paymentHistory.data : none(),
        isPagination: isPagination,
        ),
      ),
    );

    final res = await MembershipRepository().listPaymentHistory(
      nextUrl: isPagination ? nextUrl : null,orgId: orgId

    );

    if (isPagination) {
      await res.fold(
            (l) {
          emit(
            state.copyWith(
              paymentHistory: (
              data: state.paymentHistory.data,
              isPagination: false,
              ),
            ),
          );
          Dialogs.showSnack(msg: l.msg);
        },
            (r) {
          final mergedData = r.copyWith(
            allPayments: r.allPayments.copyWith(
              results: [
                ...?paymentHistoryData?.allPayments.results,
                ...r.allPayments.results,
              ],
            ),
          );

          emit(
            state.copyWith(
              paymentHistory: (
              data: some(right(mergedData)),
              isPagination: false,
              ),
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          paymentHistory: (
          data: some(res),
          isPagination: false,
          ),
        ),
      );
    }
  }



}
