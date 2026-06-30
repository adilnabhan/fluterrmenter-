import 'package:mentor_mobile_app/imports_bindings.dart';

part 'organization_creation_state.dart';
part 'organization_creation_cubit.freezed.dart';

class OrganizationCreationCubit extends Cubit<OrganizationCreationState> {
  OrganizationCreationCubit() : super(const OrganizationCreationState());

  String? addBrandDetails({
    String? brandName,
    List<String>? brandCategory,
    String? brandDescription,
    String? brandLogo,
  }) {
    if (brandName?.isEmpty ?? false) {
      return 'Brand name is required';
    } else if (brandCategory?.isEmpty ?? false) {
      return 'Brand category is required';
    } else if (brandDescription?.isEmpty ?? false) {
      return 'Brand description is required';
    }
    //  else if (brandLogo?.isEmpty ?? false) {
    //   return 'Brand logo is required';
    // }
    if (isClosed) return null;
    emit(
      state.copyWith(
        brandDetails: (
          brandName: brandName!,
          brandCategory: brandCategory!,
          brandDescription: brandDescription!,
          brandLogo: brandLogo,
        ),
      ),
    );
    return null;
  }

  String? addGymLocationDetails({
    String? flatName,
    String? street,
    String? city,
    String? state,
    String? picode,
  }) {
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
    if (isClosed) return null;
    emit(
      this.state.copyWith(
        gymLocationDetails: (
          flatName: flatName ?? '',
          street: street ?? '',
          city: city ?? '',
          state: state ?? '',
          picode: picode ?? '',
        ),
      ),
    );
    return null;
  }

  String? addGymPhotos({required List<String> gymPhotos}) {
    if (gymPhotos.isEmpty) {
      return 'Gym photos are required';
    }
    if (isClosed) return null;
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
    if (isClosed) return;
    emit(state.copyWith(createOrg: none()));
    if (workingDays.isEmpty) {
      if (isClosed) return;
      emit(
        state.copyWith(
          createOrg: some(
            left(const ApiException.notFound(msg: 'Working days are required')),
          ),
        ),
      );
      return;
    } else if (morningStartingTime == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          createOrg: some(
            left(
              const ApiException.notFound(
                msg: 'Morning starting time is required',
              ),
            ),
          ),
        ),
      );
      return;
    } else if (morningEndingTime == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          createOrg: some(
            left(
              const ApiException.notFound(
                msg: 'Morning ending time is required',
              ),
            ),
          ),
        ),
      );
      return;
    } else if (eveningStartingTime == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          createOrg: some(
            left(
              const ApiException.notFound(
                msg: 'Evening starting time is required',
              ),
            ),
          ),
        ),
      );
      return;
    } else if (eveningEndingTime == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          createOrg: some(
            left(
              const ApiException.notFound(
                msg: 'Evening ending time is required',
              ),
            ),
          ),
        ),
      );
      return;
    } else if (amenities.isEmpty) {
      if (isClosed) return;
      emit(
        state.copyWith(
          createOrg: some(
            left(const ApiException.notFound(msg: 'Amenities are required')),
          ),
        ),
      );
      return;
    }
    final workingDaysInLowercase =
        workingDays.map((day) => day.toLowerCase()).toList();
    var appState = Feggy.read<AppCubit>()?.state;
    final formData = FormData.fromMap({
      //* Brand Details
      'name': state.brandDetails?.brandName,
      'description': state.brandDetails?.brandDescription,
      if (state.brandDetails?.brandLogo?.isNotEmpty ?? false)
        'logo': await MultipartFile.fromFile(state.brandDetails!.brandLogo!),
      if (appState?.currentUser?.email != null)
        'email': appState?.currentUser?.email,
      if (appState?.currentUser?.mobileNumber != null)
        'phone_number': appState?.currentUser?.mobileNumber,

      //* Gym Photos
      if (state.gymPhotos.isNotEmpty)
        'photos': await Future.wait(
          state.gymPhotos.map(MultipartFile.fromFile),
        ),

      //* Working Details
      'working_days':
          ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'].map((day) {
            return {
              'day': day,
              'is_open': workingDaysInLowercase.contains(day),
              'morning_opening_time':
                  '${morningStartingTime.hour.toString().padLeft(2, '0')}:${morningStartingTime.minute.toString().padLeft(2, '0')}',
              'morning_closing_time':
                  '${morningEndingTime.hour.toString().padLeft(2, '0')}:${morningEndingTime.minute.toString().padLeft(2, '0')}',
              'evening_opening_time':
                  '${eveningStartingTime.hour.toString().padLeft(2, '0')}:${eveningStartingTime.minute.toString().padLeft(2, '0')}',
              'evening_closing_time':
                  '${eveningEndingTime.hour.toString().padLeft(2, '0')}:${eveningEndingTime.minute.toString().padLeft(2, '0')}',
            };
          }).toList(),
      'social_media': [
        if (website?.isNotEmpty ?? false)
          {'platform': 'website', 'url': website},
        if (whatsapp?.isNotEmpty ?? false)
          {'platform': 'whatsapp', 'url': whatsapp},
        if (instagram?.isNotEmpty ?? false)
          {'platform': 'instagram', 'url': instagram},
        if (facebook?.isNotEmpty ?? false)
          {'platform': 'facebook', 'url': facebook},
        if (youtube?.isNotEmpty ?? false)
          {'platform': 'youtube', 'url': youtube},
      ],
    });
    //* Brand Details
    if (state.brandDetails?.brandCategory.isNotEmpty ?? false) {
      for (final category
          in state.brandDetails!.brandCategory.asMap().entries) {
        formData.fields.add(
          MapEntry('categories[${category.key}]', category.value),
        );
      }
    }
    if (serivicesOffering.isNotEmpty) {
      for (final category
          in state.brandDetails!.brandCategory.asMap().entries) {
        formData.fields.add(
          MapEntry('categories[${category.key}]', category.value),
        );
      }
    }
    if (amenities.isNotEmpty) {
      for (final amenitie in amenities.asMap().entries) {
        formData.fields.add(
          MapEntry('amenities[${amenitie.key}]', amenitie.value),
        );
      }
    }
    if (serivicesOffering.isNotEmpty) {
      for (final serivice in serivicesOffering.asMap().entries) {
        formData.fields.add(
          MapEntry('services[${serivice.key}]', serivice.value),
        );
      }
    }

    ///* Location Details
    if (state.gymLocationDetails?.flatName.isNotEmpty ?? false) {
      formData.fields.add(
        MapEntry(
          'location.building_name',
          state.gymLocationDetails?.flatName ?? '',
        ),
      );
    }
    if (state.gymLocationDetails?.street.isNotEmpty ?? false) {
      formData.fields.add(
        MapEntry('location.street', state.gymLocationDetails?.street ?? ''),
      );
    }
    if (state.gymLocationDetails?.city.isNotEmpty ?? false) {
      formData.fields.add(
        MapEntry('location.city', state.gymLocationDetails?.city ?? ""),
      );
    }
    if (state.gymLocationDetails?.state.isNotEmpty ?? false) {
      formData.fields.add(
        MapEntry('location.state', state.gymLocationDetails?.state ?? ''),
      );
    }
    if (state.gymLocationDetails?.picode.isNotEmpty ?? false) {
      formData.fields.add(
        MapEntry('location.pin_code', state.gymLocationDetails?.picode ?? ''),
      );
    }
    logFormData(formData);
    final appCubit = Feggy.read<AppCubit>();
    appState = appCubit?.state;
    final response = await OrganizationCreationRepository().create(
      body: formData,
    );
    response.fold((l) {}, (r) {
      print('the succes responce iss-----${r}');

      if (appState?.currentUser != null) {
        appCubit?.addUser(
          appState!.currentUser!.copyWith(
            mentor: Mentor(
              org: Org(
                id: r['id'] as int?, // <-- cast to int?
                name: r['name'] as String?, // <-- cast to String?
                profileCompleteness: 5,
              ),
            ),
          ),
        );
      }
    });
    if (isClosed) return;
    emit(state.copyWith(createOrg: some(response)));
  }

  void logFormData(FormData formData) {
    print("======= FORM DATA DEBUG START =======");

    for (final field in formData.fields) {
      print("Field => ${field.key} : ${field.value}");
    }

    for (final mapEntry in formData.files) {
      print(
        "File => ${mapEntry.key} : ${mapEntry.value.filename} "
        "(contentType: ${mapEntry.value.contentType})",
      );
    }

    print("======= FORM DATA DEBUG END =======");
  }
}
