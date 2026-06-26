part of 'members_and_leads_cubit.dart';

@freezed
class MembersAndLeadsState with _$MembersAndLeadsState {
  const factory MembersAndLeadsState({
    //* Members
    @Default((data: None(), isPagination: false))
    ({
      Option<Either<ApiException, MembersListingModel>> data,
      bool isPagination,
    })
    members,
    @Default(None())
    Option<Either<ApiException, MemberDetailsModel>> memberDetails,
    Option<Either<ApiException, MemberDetailsModel>>? createOrUpdateMember,
    bool? memberOnboardedAnimationCompleted,

    //* Leads
    @Default((data: None(), isPagination: false))
    ({Option<Either<ApiException, LeadsListingModel>> data, bool isPagination})
    leads,
    @Default(None()) Option<Either<ApiException, LeadDetailsModel>> leadDetails,
    Option<Either<ApiException, CreateOrUpdateLeadModel>>? createOrUpdateLead,
    @Default((data: None(), isPagination: false))
    ({Option<Either<ApiException, UpComingPayments>> data, bool isPagination})
    upComingPayments,
    // paymentHistory
    @Default((data: None(), isPagination: false))
    ({Option<Either<ApiException, PaymentHistory>> data, bool isPagination})
    paymentHistory,
  }) = _MembersAndLeadsState;
}

enum MemberStatus { active, expired }

enum ListingSort { recent, oldest }
