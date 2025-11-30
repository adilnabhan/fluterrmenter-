import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateOrganizationWorkingDetailsScreen extends StatefulWidget {
  const CreateOrganizationWorkingDetailsScreen({super.key});

  @override
  State<CreateOrganizationWorkingDetailsScreen> createState() =>
      _CreateOrganizationWorkingDetailsScreenState();
}

class _CreateOrganizationWorkingDetailsScreenState
    extends State<CreateOrganizationWorkingDetailsScreen> {
  late final OrganizationCreationCubit _gymCreationCubit;
  final _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final _selectedWeekDays = ValueNotifier(<String>[]);
  late final List<List<FieldData<dynamic>>> _gymWorkingDetailsFields;
  late final _socialUrlFields = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _gymCreationCubit = context.read<OrganizationCreationCubit>();
    _gymWorkingDetailsFields = [
      [
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          label: 'Morning',
          labelStyle: const TextStyle(color: AppColors.dark, fontSize: 13),
          requiredLabel: true,
          decoration: const InputDecoration(
            hintText: 'Starting time',
            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
        ),
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: const InputDecoration(
            hintText: 'Ending time',
            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
        ),
      ],
      [
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          label: 'Evening',
          labelStyle: const TextStyle(color: AppColors.dark, fontSize: 13),
          requiredLabel: true,
          decoration: const InputDecoration(
            hintText: 'Starting time',
            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
        ),
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: const InputDecoration(
            hintText: 'Ending time',
            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
        ),
      ],
      [
        FieldData(
          type: FieldType.multValues,
          textInputAction: TextInputAction.done,
          label: 'Service Offerings',
          requiredLabel: true,
          controller: TextEditingController(),
          selectedMultiValues: ValueNotifier([]),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Service Offerings is required';
            }
            return null;
          },
          onSubmitted: (value) {},
          decoration: InputDecoration(
            hintText: 'Enter the services you provide',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
      ],
      [
        FieldData<String>(
          type: FieldType.checkbox,
          items: [],
          textInputAction: TextInputAction.done,
          label: 'Amenities',
          requiredLabel: true,
          controller: TextEditingController(),
          selectedValues: ValueNotifier([]),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Amenities is required';
            }
            return null;
          },
          onSubmitted: (value) {},
          decoration: InputDecoration(
            hintText: 'Select Amenities',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          label: 'Social Media',
          textInputAction: TextInputAction.done,
          controller: _socialUrlFields[0],
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Add URL',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            prefixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/svg/icons/website.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            suffixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: _socialUrlFields[0],
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (!websiteRegX.hasMatch(value.text)) {
                      return SizedBox(
                        height: 24,
                        width: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: const ColoredBox(
                            color: AppColors.error,
                            child: Icon(
                              Icons.close,
                              color: AppColors.light,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return SvgPicture.asset(
                      'assets/images/svg/icons/green_success.svg',
                      height: 24,
                      width: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          controller: _socialUrlFields[1],
          focusNode: FocusNode(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Limit to 15 characters
          ],
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter WhatsApp number',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            prefixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/svg/icons/whatsapp.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            suffixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: _socialUrlFields[1],
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    // Validate phone number format
                    final phoneNumber = value.text.trim();
                    if (!RegExp(r'^\+?[0-9]{10,12}$').hasMatch(phoneNumber)) {
                      return SizedBox(
                        height: 24,
                        width: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: const ColoredBox(
                            color: AppColors.error,
                            child: Icon(
                              Icons.close,
                              color: AppColors.light,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return SvgPicture.asset(
                      'assets/images/svg/icons/green_success.svg',
                      height: 24,
                      width: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          controller: _socialUrlFields[2],
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Add URL',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            prefixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/svg/icons/instagram.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            suffixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: _socialUrlFields[2],
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (!websiteRegX.hasMatch(value.text)) {
                      return SizedBox(
                        height: 24,
                        width: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: const ColoredBox(
                            color: AppColors.error,
                            child: Icon(
                              Icons.close,
                              color: AppColors.light,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return SvgPicture.asset(
                      'assets/images/svg/icons/green_success.svg',
                      height: 24,
                      width: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          controller: _socialUrlFields[3],
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Add URL',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            prefixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/svg/icons/face_book.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            suffixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: _socialUrlFields[3],
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (!websiteRegX.hasMatch(value.text)) {
                      return SizedBox(
                        height: 24,
                        width: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: const ColoredBox(
                            color: AppColors.error,
                            child: Icon(
                              Icons.close,
                              color: AppColors.light,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return SvgPicture.asset(
                      'assets/images/svg/icons/green_success.svg',
                      height: 24,
                      width: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          controller: _socialUrlFields[4],
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Add URL',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            prefixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/svg/icons/youtube.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            suffixIcon: SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: _socialUrlFields[4],
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (!websiteRegX.hasMatch(value.text)) {
                      return SizedBox(
                        height: 24,
                        width: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: const ColoredBox(
                            color: AppColors.error,
                            child: Icon(
                              Icons.close,
                              color: AppColors.light,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return SvgPicture.asset(
                      'assets/images/svg/icons/green_success.svg',
                      height: 24,
                      width: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _selectedWeekDays.dispose();
    for (final field in _gymWorkingDetailsFields) {
      for (final fieldData in field) {
        fieldData.controller?.dispose();
        fieldData.focusNode?.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizationCreationCubit, OrganizationCreationState>(
      listenWhen:
          (previous, current) => previous.createOrg != current.createOrg,
      bloc: _gymCreationCubit,
      listener: (context, state) {
        state.createOrg?.fold(
          () {},
          (t) => t.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              context.pushAndRemoveUntil(
                const OrganizationCreationSuccessScreen(),
              );
            },
          ),
        );
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(automaticallyImplyLeading: false),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ============ OLD CODE - COMMENTED OUT ============
              // const SizedBox(height: 22),
              // const OrganizationCreationCompletionStatusCard(progress: 4),
              // const SizedBox(height: 28),
              // Text(
              //   'Profile Details',
              //   style: AppStyles.text16Px.poppins.w600.dark,
              // ),
              // ============ END OLD CODE ============

              // ============ NEW CODE - PROGRESS BAR ============
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (index) {
                  bool isActive = index <= 4; // Step 5 of 8
                  return Row(
                    children: [
                      Container(
                        width: 25,
                        height: 1,
                        color:
                            isActive ? AppColors.primary : AppColors.borderGrey,
                      ),
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          width: 8,
                          height: 8,
                          color:
                              isActive
                                  ? AppColors.primary
                                  : AppColors.borderGrey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'Tell Members\nWhat You\nOffer',
                style: AppStyles.text30Px.poppins.w600.dark,
              ),
              const SizedBox(height: 16),
              Text(
                'Your timings, amenities, and social links\nhelp users choose confidently.',
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ),

              // ============ END NEW CODE ============
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'Working Days',
                    style: AppStyles.text14Px.poppins.w500.dark,
                  ),
                  Text(
                    '*',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: _selectedWeekDays,
                builder: (context, selectedWeekDays, child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: responsiveSize(context, s: 3).toInt(),
                      crossAxisSpacing: 26,
                      mainAxisSpacing: 26,
                      mainAxisExtent: 52,
                    ),
                    itemCount: _weekDays.length,
                    itemBuilder: (BuildContext context, int index) {
                      final day = _weekDays[index];
                      final isSelected = selectedWeekDays.contains(day);
                      return InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () {
                          if (isSelected) {
                            _selectedWeekDays.value.remove(day);
                          } else {
                            _selectedWeekDays.value.add(day);
                          }
                          _selectedWeekDays.value = [...selectedWeekDays];
                        },
                        // ============ OLD CODE - COMMENTED OUT ============
                        // child: Container(
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xffF4F5FA),
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       Text(day, style: AppStyles.text14Px.w400.poppins),
                        //       SvgPicture.asset(
                        //         isSelected
                        //             ? 'assets/images/svg/icons/checkbox_filled.svg'
                        //             : 'assets/images/svg/icons/checkbox_blank.svg',
                        //         height: 18,
                        //         width: 18,
                        //         colorFilter: const ColorFilter.mode(
                        //           AppColors.dark,
                        //           BlendMode.srcIn,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // ============ END OLD CODE ============

                        // ============ NEW CODE - SELECTED WITH PINK BG & RED BORDER ============
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(
                                      0xFFFEE9E7,
                                    ) // Light pink background when selected
                                    : const Color(
                                      0xffF4F5FA,
                                    ), // Default gray background
                            borderRadius: BorderRadius.circular(8),
                            border:
                                isSelected
                                    ? Border.all(
                                      color:
                                          AppColors
                                              .primary, // Red border when selected
                                      width: 1.5,
                                    )
                                    : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(day, style: AppStyles.text14Px.w400.poppins),
                              SvgPicture.asset(
                                isSelected
                                    ? 'assets/images/svg/icons/checkbox_filled.svg'
                                    : 'assets/images/svg/icons/checkbox_blank.svg',
                                height: 18,
                                width: 18,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? AppColors
                                          .primary // Red checkbox when selected
                                      : AppColors
                                          .dark, // Dark checkbox when not selected
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ============ END NEW CODE ============
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    'Set your working hours',
                    style: AppStyles.text14Px.poppins.w500.dark,
                  ),
                  Text(
                    '*',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _gymWorkingDetailsFields.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 22);
                },
                itemBuilder: (BuildContext context, int index) {
                  final fields = _gymWorkingDetailsFields[index];
                  if (fields.length > 1) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: Field(data: fields[0])),
                        const SizedBox(width: 16),
                        Expanded(child: Field(data: fields[1])),
                      ],
                    );
                  }
                  if (fields.first.label == 'Amenities') {
                    return InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        AddAmenitiesSheet(
                          selectedValues: [
                            ...fields.first.selectedValues?.value.map(
                                  (e) => (label: e.label, value: '${e.value}'),
                                ) ??
                                [],
                          ],
                          onSubmit: (values) {
                            fields.first.selectedValues?.value =
                                values
                                    .map(
                                      (e) => (label: e.label, value: e.value),
                                    )
                                    .toList();
                          },
                        ).show(context);
                      },
                      child: AbsorbPointer(
                        child: Field<String>(
                          data: fields.first as FieldData<String>,
                        ),
                      ),
                    );
                  }
                  return Field(data: fields.first);
                },
              ),
              const SizedBox(height: 32),
              // ============ NEW CODE - FULL WIDTH NEXT BUTTON ============
              BlocBuilder<OrganizationCreationCubit, OrganizationCreationState>(
                bloc: _gymCreationCubit,
                buildWhen: (previous, current) {
                  return previous.createOrg != current.createOrg;
                },
                builder: (context, state) {
                  final isLoading = state.createOrg?.isNone() ?? false;
                  return Button.filled(
                    title: 'Next - Let\'s Add Your Plans',
                    ontap:
                        isLoading
                            ? () {}
                            : () {
                              print(
                                'selected days is--${_selectedWeekDays.value}',
                              );
                              _gymCreationCubit.createOrg(
                                workingDays: _selectedWeekDays.value,
                                morningStartingTime:
                                    _gymWorkingDetailsFields[0][0].selectedTime,
                                morningEndingTime:
                                    _gymWorkingDetailsFields[0][1].selectedTime,
                                eveningStartingTime:
                                    _gymWorkingDetailsFields[1][0].selectedTime,
                                eveningEndingTime:
                                    _gymWorkingDetailsFields[1][1].selectedTime,
                                serivicesOffering:
                                    _gymWorkingDetailsFields[2][0]
                                        .selectedMultiValues
                                        ?.value ??
                                    [],
                                amenities:
                                    _gymWorkingDetailsFields[3][0]
                                        .selectedValues
                                        ?.value
                                        .map((e) => '${e.value}')
                                        .toList() ??
                                    [],
                                website: _socialUrlFields[0].text,
                                whatsapp: _socialUrlFields[1].text,
                                instagram: _socialUrlFields[2].text,
                                facebook: _socialUrlFields[3].text,
                                youtube: _socialUrlFields[4].text,
                              );
                            },
                    buttonColor: AppColors.primary,
                  );
                },
              ),
              // ============ END NEW CODE ============
              const SizedBox(height: 20),
            ],
          ),
          // ============ OLD CODE - COMMENTED OUT ============
          // floatingActionButton: SizedBox(
          //   width: 84,
          //   child: BlocBuilder<
          //     OrganizationCreationCubit,
          //     OrganizationCreationState
          //   >(
          //     bloc: _gymCreationCubit,
          //     buildWhen: (previous, current) {
          //       return previous.createOrg != current.createOrg;
          //     },
          //     builder: (context, state) {
          //       return FloatingActionButton(
          //         onPressed:
          //             (state.createOrg?.isNone() ?? false)
          //                 ? null
          //                 : () {
          //                   print(
          //                     'sekfcet dayss  is--${_selectedWeekDays.value}',
          //                   );
          //                   _gymCreationCubit.createOrg(
          //                     workingDays: _selectedWeekDays.value,
          //                     morningStartingTime:
          //                         _gymWorkingDetailsFields[0][0].selectedTime,
          //                     morningEndingTime:
          //                         _gymWorkingDetailsFields[0][1].selectedTime,
          //                     eveningStartingTime:
          //                         _gymWorkingDetailsFields[1][0].selectedTime,
          //                     eveningEndingTime:
          //                         _gymWorkingDetailsFields[1][1].selectedTime,
          //                     serivicesOffering:
          //                         _gymWorkingDetailsFields[2][0]
          //                             .selectedMultiValues
          //                             ?.value ??
          //                         [],
          //                     amenities:
          //                         _gymWorkingDetailsFields[3][0]
          //                             .selectedValues
          //                             ?.value
          //                             .map((e) => '${e.value}')
          //                             .toList() ??
          //                         [],
          //                     website: _socialUrlFields[0].text,
          //                     whatsapp: _socialUrlFields[1].text,
          //                     instagram: _socialUrlFields[2].text,
          //                     facebook: _socialUrlFields[3].text,
          //                     youtube: _socialUrlFields[4].text,
          //                   );
          //                 },
          //         shape: const StadiumBorder(),
          //         backgroundColor: AppColors.primary,
          //         foregroundColor: AppColors.light,
          //         elevation: 0,
          //         child: const Icon(Icons.keyboard_arrow_right_outlined),
          //       );
          //     },
          //   ),
          // ),
          // ============ END OLD CODE ============
        ),
      ),
    );
  }
}
