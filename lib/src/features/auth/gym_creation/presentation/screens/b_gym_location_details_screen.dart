import 'package:flutter/cupertino.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class GymLocationDetailsScreen extends StatelessWidget {
  const GymLocationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => GymLocationDetailsCubit(), child: const _GymLocationDetailsScreen());
  }
}

class _GymLocationDetailsScreen extends StatefulWidget {
  const _GymLocationDetailsScreen();

  @override
  State<_GymLocationDetailsScreen> createState() => __GymLocationDetailsScreenState();
}

class __GymLocationDetailsScreenState extends State<_GymLocationDetailsScreen> {
  late final GymLocationDetailsCubit _cubit;
  late final List<List<FieldData<dynamic>>> _locationDetails;
  late final FocusNode _searchFocusNode;
  late final TextEditingController _searchField;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _cubit = context.read<GymLocationDetailsCubit>();
    _searchFocusNode = FocusNode();
    _searchField = TextEditingController();
    _locationDetails = [
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.next,
          label: 'Building/Flat Name & Number ',
          requiredLabel: true,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Building/Flat Name & Number is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _locationDetails[1][0].focusNode?.requestFocus();
          },
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Building/Flat Name & Number',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.next,
          label: 'Street / Road Name ',
          requiredLabel: true,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Street / Road Name is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _locationDetails[2][0].focusNode?.requestFocus();
          },
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Street / Road Name',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'City',
          requiredLabel: true,

          controller: TextEditingController(),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'City is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _locationDetails[3][0].focusNode?.requestFocus();
          },
          decoration: InputDecoration(
            hintText: 'City',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'State',
          requiredLabel: true,

          controller: TextEditingController(),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'State is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _locationDetails[3][1].focusNode?.requestFocus();
          },
          decoration: InputDecoration(
            hintText: 'State',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
          ),
        ),
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'PIN / ZIP Code',
          requiredLabel: true,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'PIN / ZIP Code is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _locationDetails[4][0].focusNode?.requestFocus();
          },
          decoration: InputDecoration(
            hintText: 'PIN / ZIP Code',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
          ),
        ),
      ],
    ];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode.dispose();
    _searchField.dispose();
    for (final element in _locationDetails) {
      for (final field in element) {
        field.controller?.dispose();
        field.focusNode?.dispose();
      }
    }
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(const _GymLocationDetailsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GymLocationDetailsCubit, GymLocationDetailsState>(
      listenWhen: (p, c) => p.selectedPlaceDetails != c.selectedPlaceDetails || p.currentPlaceDetails != c.currentPlaceDetails,
      listener: (context, state) {
        state.currentPlaceDetails?.fold(() {}, (t) {
          t.fold((l) {}, (r) {});
        });
        state.selectedPlaceDetails?.data.fold(() {}, (t) {
          t.fold((l) {}, (r) {
            _cubit.searchPlaces(q: '');
            _searchField.value = TextEditingValue(text: r.placeName ?? r.placeName ?? '');
            _searchFocusNode.unfocus();
            _locationDetails[0][0].controller?.value = TextEditingValue(text: r.placeName ?? '');
            // _locationDetails[1][0].controller?.value = TextEditingValue(
            //   text: r.adrAddress ?? '',
            // );
            _locationDetails[2][0].controller?.value = TextEditingValue(text: r.district ?? '');
            _locationDetails[3][0].controller?.value = TextEditingValue(text: r.state ?? '');
            _locationDetails[3][1].controller?.value = TextEditingValue(text: r.pincode ?? '');
          });
        });
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 22),
              const GymProfileCompletionStatusCard(progress: 2),
              const SizedBox(height: 28),
              Row(
                children: [
                  const CircleAvatar(backgroundColor: AppColors.primary, radius: 3).pOnly(right: 6),
                  Flexible(
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchField,
                      onChanged: (value) {
                        EasyDebounce.debounce('search_query', const Duration(milliseconds: 100), () {
                          _cubit.searchPlaces(q: value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for your location',
                        filled: false,
                        prefixIcon: SizedBox.square(dimension: 32, child: SvgPicture.asset('assets/images/svg/icons/search.svg', height: 32, width: 32).center),
                        suffixIcon: ValueListenableBuilder(
                          valueListenable: _searchField,
                          builder: (BuildContext context, value, Widget? child) {
                            if (value.text.trim().isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return InkWell(
                              onTap: () {
                                _searchField.clear();
                                _cubit.searchPlaces(q: '');
                                _searchFocusNode.unfocus();
                              },
                              child: SizedBox.square(dimension: 32, child: SvgPicture.asset('assets/images/svg/icons/close.svg', height: 32, width: 32).center),
                            );
                          },
                        ),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  _cubit.getPlaceDetailsFromCurrentLocation();
                },
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/svg/icons/map.svg', height: 32, width: 32),
                    const SizedBox(width: 8),
                    Flexible(child: Text('Use your current location', style: AppStyles.text14Px.poppins.w600.dark)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              BlocBuilder<GymLocationDetailsCubit, GymLocationDetailsState>(
                buildWhen: (p, c) => c.placeAutoCompletes?.fold(() => false, (t) => t.fold((l) => false, (r) => true)) ?? true,
                builder: (context, state) {
                  final placeAutoCompletes = state.placeAutoCompletes?.fold(() => null, (t) => t.fold((l) => null, (r) => r));
                  if (placeAutoCompletes?.predictions?.isEmpty ?? false) {
                    return Column(
                      children: [
                        const SizedBox(height: 40),
                        SvgPicture.asset('assets/images/svg/icons/location_not_found.svg', height: 80).center,
                        const SizedBox(height: 26),
                        Text('Location not found', style: AppStyles.text16Px.poppins.w800.dark),
                        const SizedBox(height: 8),
                        Text('Please search for a valid location', style: AppStyles.text12Px.poppins.w400.textGrey),
                      ],
                    );
                  }
                  if (placeAutoCompletes?.predictions?.isNotEmpty ?? false) {
                    return ListView.separated(
                      itemCount: placeAutoCompletes?.predictions?.length ?? 0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 22);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final mainText = placeAutoCompletes?.predictions?[index].structuredFormatting?.mainText ?? '';
                        final secondaryText = placeAutoCompletes?.predictions?[index].description ?? '';
                        return BlocBuilder<GymLocationDetailsCubit, GymLocationDetailsState>(
                          buildWhen: (previous, current) => previous.selectedPlaceDetails != current.selectedPlaceDetails,
                          builder: (context, state) {
                            final isLoading = (state.selectedPlaceDetails?.data.isNone() ?? false) && state.selectedPlaceDetails?.placeID == placeAutoCompletes?.predictions?[index].placeId;
                            return InkWell(
                              onTap: () {
                                if (isLoading) {
                                  return;
                                }
                                final placeId = placeAutoCompletes?.predictions?[index].placeId;
                                if (placeId == null) {
                                  return;
                                }
                                _cubit.getPlaceDetails(placeId: placeId);
                              },
                              child: Row(
                                children: [
                                  if (isLoading)
                                    const SizedBox.square(dimension: 26, child: CupertinoActivityIndicator(color: AppColors.dark))
                                  else
                                    SvgPicture.asset('assets/images/svg/icons/location.svg', fit: BoxFit.scaleDown, height: 26, width: 26),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (mainText.isNotEmpty) Text(mainText, style: AppStyles.text14Px.poppins.w600.dark),
                                        if (secondaryText.isNotEmpty && secondaryText.isNotEmpty) const SizedBox(height: 4),
                                        if (secondaryText.isNotEmpty) Text(secondaryText, style: AppStyles.text12Px.poppins.w400.textGrey),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return ListView.separated(
                    itemCount: _locationDetails.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 22);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final fields = _locationDetails[index];
                      if (fields.length > 1) {
                        // return Row(
                        //   children: [
                        //     Expanded(child: Field(data: fields[0])),
                        //     const SizedBox(width: 16),
                        //     Expanded(child: Field(data: fields[1])),
                        //   ],
                        // );
                        return Column(children: [Field(data: fields[0]), const SizedBox(height: 16), Field(data: fields[1])]);
                      }
                      return Field(data: _locationDetails[index][0]);
                    },
                  );
                },
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
        floatingActionButton: SizedBox(
          width: 84,
          child: FloatingActionButton(
            onPressed: _onContinue,
            shape: const StadiumBorder(),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.light,
            elevation: 0,
            child: const Icon(Icons.keyboard_arrow_right_outlined),
          ),
        ),
      ),
    );
  }
}
