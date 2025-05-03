import 'package:mentor_mobile_app/imports_bindings.dart';

part 'gym_creation_state.dart';
part 'gym_creation_cubit.freezed.dart';

class GymCreationCubit extends Cubit<GymCreationState> {
  GymCreationCubit() : super(const GymCreationState());

  String? addBrandDetails({String? brandName, String? brandCategory, String? brandDescription, String? brandLogo}) {
    if (brandName?.isEmpty ?? false) {
      return 'Brand name is required';
    } else if (brandCategory?.isEmpty ?? false) {
      return 'Brand category is required';
    } else if (brandDescription?.isEmpty ?? false) {
      return 'Brand description is required';
    } else if (brandLogo?.isEmpty ?? false) {
      return 'Brand logo is required';
    }
    emit(state.copyWith(brandDetails: (brandName: brandName!, brandCategory: brandCategory!, brandDescription: brandDescription!, brandLogo: brandLogo!)));
    return null;
  }

  String? addGymLocationDetails({String? flatName, String? street, String? city, String? state, String? picode}) {
    if (flatName?.isEmpty ?? false) {
      return 'Flat name is required';
    } else if (street?.isEmpty ?? false) {
      return 'Street is required';
    } else if (city?.isEmpty ?? false) {
      return 'City is required';
    } else if (state?.isEmpty ?? false) {
      return 'State is required';
    } else if (picode?.isEmpty ?? false) {
      return 'Pincode is required';
    }
    emit(this.state.copyWith(gymLocationDetails: (flatName: flatName!, street: street!, city: city!, state: state!, picode: picode!)));
    return null;
  }

  String? addGymPhotos({required List<String> gymPhotos}) {
    if (gymPhotos.isEmpty) {
      return 'Gym photos are required';
    }
    emit(state.copyWith(gymPhotos: gymPhotos));
    return null;
  }

  Future<void> createOrg({
    required List<String> workingDays,
    required TimeOfDay? morningStartingTime,
    required TimeOfDay? morningEndingTime,
    required TimeOfDay? eveningStartingTime,
    required TimeOfDay? eveningEndingTime,
    required List<String> serivicesOffering,
    required List<String> amenities,
    String? website,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? youtube,
  }) async {
    if (state.createOrg?.isNone() ?? false) {
      return;
    }
    if (workingDays.isEmpty) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Working days are required')))));
      return;
    } else if (morningStartingTime == null) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Morning starting time is required')))));
      return;
    } else if (morningEndingTime == null) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Morning ending time is required')))));
      return;
    } else if (eveningStartingTime == null) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Evening starting time is required')))));
      return;
    } else if (eveningEndingTime == null) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Evening ending time is required')))));
      return;
    } else if (serivicesOffering.isEmpty) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Services offering are required')))));
      return;
    } else if (amenities.isEmpty) {
      emit(state.copyWith(createOrg: some(left(const ApiException.notFound(msg: 'Amenities are required')))));
      return;
    }
    final workingDaysInLowercase = workingDays.map((day) => day.toLowerCase()).toList();
    final response = await GymCreationRepository().create(
      body: {
        //* Brand Details
        'name': state.brandDetails?.brandName,
        'categories': [state.brandDetails?.brandCategory],
        'description': state.brandDetails?.brandDescription,
        'logo': state.brandDetails?.brandLogo,
        // 'email': state.brandDetails?.brandName,
        // 'phone_number': state.brandDetails?.brandName,
        //* Location Details
        'location': {
          'building_name': state.gymLocationDetails?.flatName,
          'street': state.gymLocationDetails?.street,
          'city': state.gymLocationDetails?.city,
          'state': state.gymLocationDetails?.state,
          'pin_code': state.gymLocationDetails?.picode,
          'latitude': '',
          'longitude': '',
        },
        //* Gym Photos
        'photos': state.gymPhotos,

        ///* Working Details
        ///{day: tue is_open: true morning_opening_time: 06:00 morning_closing_time: 12:00 evening_opening_time: 17:00 evening_closing_time: 21:00}
        'working_days':
            ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'].map((day) {
              return {
                'day': day,
                'is_open': workingDaysInLowercase.contains(day),
                'morning_opening_time': morningStartingTime,
                'morning_closing_time': morningEndingTime,
                'evening_opening_time': eveningStartingTime,
                'evening_closing_time': eveningEndingTime,
              };
            }).toList(),
        'services': serivicesOffering,
        'amenities': amenities,
        'social_media': [
          if (website != null) {'platform': 'website', 'url': website},
          if (whatsapp != null) {'platform': 'whatsapp', 'url': whatsapp},
          if (instagram != null) {'platform': 'instagram', 'url': instagram},
          if (facebook != null) {'platform': 'facebook', 'url': facebook},
          if (youtube != null) {'platform': 'youtube', 'url': youtube},
        ],
      },
    );
    emit(state.copyWith(createOrg: some(response)));
  }
}
