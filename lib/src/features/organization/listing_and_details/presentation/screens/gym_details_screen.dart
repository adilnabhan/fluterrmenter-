import 'package:mentor_mobile_app/imports_bindings.dart';

class GymDetailsScreen extends StatefulWidget {
  const GymDetailsScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;
  late final List<({String label, String value, void Function() onTap})> _basicDetails;
  late final List<List<FieldData<dynamic>>> _socialMediaFields;
  late final _socialUrlFields = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()];
  ({String label, String value, void Function() onTap}) copyBasicDetails(String? newValue, int fieldIndex) {
    return (label: _basicDetails[fieldIndex].label, value: newValue ?? _basicDetails[fieldIndex].value, onTap: _basicDetails[fieldIndex].onTap);
  }

  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _basicDetails = [
      (
        label: 'Gym Name',
        value: widget.orgDetails.name ?? '',
        onTap: () {
          context.push(
            GymDetailsUpdateTemplateScreen(
              title: 'Gym Name',
              questionText: 'What is your gym name?',
              label: 'Full Name',
              hintText: 'Enter Name',
              keyboardType: TextInputType.name,
              inputFormatters: const [],
              onSave: (value) {
                setState(() {
                  _basicDetails[0] = copyBasicDetails(value, 0);
                });
              },
              initialValue: _basicDetails[0].value,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Gym name is required';
                } else if ((value?.length ?? 0) < 3) {
                  return 'Gym name must be at least 3 characters';
                } else if ((value?.length ?? 0) > 50) {
                  return 'Gym name must be less than 50 characters';
                }
                return null;
              },
            ),
          );
        },
      ),
      (label: 'Location', value: '${widget.orgDetails.location?.street},${widget.orgDetails.location?.city}', onTap: () {}),
      (
        label: 'Email',
        value: widget.orgDetails.email ?? '',
        onTap: () {
          context.push(
            GymDetailsUpdateTemplateScreen(
              title: 'Add Email',
              questionText: 'Enter your gym mail?',
              label: 'Email',
              hintText: 'Enter email',
              keyboardType: TextInputType.emailAddress,
              inputFormatters: const [],
              onSave: (value) {
                setState(() {
                  _basicDetails[2] = copyBasicDetails(value, 2);
                });
              },
              initialValue: _basicDetails[2].value,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Email address is required';
                } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value!)) {
                  return 'Invalid email address';
                }
                return null;
              },
            ),
          );
        },
      ),
      (
        label: 'Mobile',
        value: widget.orgDetails.phoneNumber?.replaceAll('+91', '') ?? '',
        onTap: () {
          context.push(
            GymDetailsUpdateTemplateScreen(
              title: 'Add Mobile',
              questionText: 'Enter your gym number?',
              label: 'Mobile',
              hintText: 'Enter Number',
              onSave: (value) {
                setState(() {
                  _basicDetails[3] = copyBasicDetails(value, 3);
                });
              },
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              initialValue: _basicDetails[3].value,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Mobile number is required';
                } else if (value?.length != 10) {
                  return 'Mobile number must be 10 digits';
                }
                return null;
              },
            ),
          );
        },
      ),
    ];
    _socialMediaFields = [
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          controller: _socialUrlFields[0],
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Add URL',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
            prefixIcon: SizedBox(height: 24, width: 24, child: Center(child: SvgPicture.asset('assets/images/svg/icons/website.svg', height: 24, width: 24))),
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
                        child: ClipRRect(borderRadius: BorderRadius.circular(1000), child: const ColoredBox(color: AppColors.error, child: Icon(Icons.close, color: AppColors.light, size: 16))),
                      );
                    }
                    return SvgPicture.asset('assets/images/svg/icons/green_success.svg', height: 24, width: 24);
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
            hintText: 'Add URL',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
            prefixIcon: SizedBox(height: 24, width: 24, child: Center(child: SvgPicture.asset('assets/images/svg/icons/whatsapp.svg', height: 24, width: 24))),
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
                        child: ClipRRect(borderRadius: BorderRadius.circular(1000), child: const ColoredBox(color: AppColors.error, child: Icon(Icons.close, color: AppColors.light, size: 16))),
                      );
                    }
                    return SvgPicture.asset('assets/images/svg/icons/green_success.svg', height: 24, width: 24);
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
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
            prefixIcon: SizedBox(height: 24, width: 24, child: Center(child: SvgPicture.asset('assets/images/svg/icons/instagram.svg', height: 24, width: 24))),
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
                        child: ClipRRect(borderRadius: BorderRadius.circular(1000), child: const ColoredBox(color: AppColors.error, child: Icon(Icons.close, color: AppColors.light, size: 16))),
                      );
                    }
                    return SvgPicture.asset('assets/images/svg/icons/green_success.svg', height: 24, width: 24);
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
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
            prefixIcon: SizedBox(height: 24, width: 24, child: Center(child: SvgPicture.asset('assets/images/svg/icons/face_book.svg', height: 24, width: 24))),
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
                        child: ClipRRect(borderRadius: BorderRadius.circular(1000), child: const ColoredBox(color: AppColors.error, child: Icon(Icons.close, color: AppColors.light, size: 16))),
                      );
                    }
                    return SvgPicture.asset('assets/images/svg/icons/green_success.svg', height: 24, width: 24);
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
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
            prefixIcon: SizedBox(height: 24, width: 24, child: Center(child: SvgPicture.asset('assets/images/svg/icons/youtube.svg', height: 24, width: 24))),
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
                        child: ClipRRect(borderRadius: BorderRadius.circular(1000), child: const ColoredBox(color: AppColors.error, child: Icon(Icons.close, color: AppColors.light, size: 16))),
                      );
                    }
                    return SvgPicture.asset('assets/images/svg/icons/green_success.svg', height: 24, width: 24);
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
  Widget build(BuildContext context) {
    return BlocListener<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
      listenWhen: (p, c) => p.updateOrgDetails != c.updateOrgDetails,
      listener: (context, state) {
        state.updateOrgDetails?.fold(() {}, (either) {
          either.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              if (widget.orgDetails.id == null) {
                Dialogs.showSnack(msg: 'Gym details not found');
                return;
              }
              Dialogs.showSnack(msg: 'Gym details updated successfully');
              _cubit.fetchDetails(orgId: widget.orgDetails.id!);
              context.pop();
            },
          );
        });
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center, title: Text('Gym Details', style: AppStyles.text16Px.poppins.w500)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileImage(isEdit: true, onChanged: (image) => _pickedImage = image, radius: 100.w, url: widget.orgDetails.logo ?? '').pxy(y: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _basicDetails.length,
              separatorBuilder: (context, index) => const Divider(thickness: 1, color: Color(0xffDDDDDD)),
              itemBuilder: (context, index) {
                final e = _basicDetails[index];
                return InkWell(
                  onTap: e.onTap,
                  child: Row(
                    children: [
                      Text(e.label, style: AppStyles.text14Px.poppins.w400.textGrey),
                      const Spacer(),
                      Text(e.value, style: AppStyles.text14Px.poppins.w500.dark),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.dark).pOnly(left: 8),
                    ],
                  ).pxy(y: 16),
                );
              },
            ),
            Text('Social Media', style: AppStyles.text16Px.poppins.w600.dark).pOnly(bottom: 16),
            ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _socialMediaFields.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (BuildContext context, int index) {
                final fields = _socialMediaFields[index];
                return Field(data: fields.first);
              },
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
          buildWhen: (previous, current) => previous.updateOrgDetails != current.updateOrgDetails,
          builder: (context, state) {
            final isLoading = state.updateOrgDetails?.isNone() ?? false;
            return Button.filled(
              raduis: 12,
              title: 'Save',
              isLoading: isLoading,
              buttonColor: AppColors.primary,
              ontap: () async {
                if (isLoading) {
                  return;
                }
                if (_basicDetails[0].value.length < 3) {
                  await Dialogs.showSnack(msg: 'Gym name must be at least 3 characters');
                  return;
                } else if (!_basicDetails[2].value.isEmail) {
                  await Dialogs.showSnack(msg: 'Email address is required');
                  return;
                } else if (_basicDetails[3].value.length != 10) {
                  await Dialogs.showSnack(msg: 'Mobile number must be 10 digits');
                  return;
                } else if (_socialUrlFields[1].value.text.isNotEmpty && _socialUrlFields[1].value.text.length != 10) {
                  await Dialogs.showSnack(msg: 'Whatsapp number must be 10 digits');
                  return;
                }
                final body = FormData.fromMap({
                  'name': _basicDetails[0].value,
                  'email': _basicDetails[2].value,
                  'phone_number': '+91${_basicDetails[3].value}',
                  // 'location': {
                  //   'street': widget.orgDetails.location?.street,
                  //   'city': widget.orgDetails.location?.city,
                  // },
                  'social_media': [
                    if (_socialUrlFields[1].text.trim().isNotEmpty) {'platform': 'whatsapp', 'url': '+91${_socialUrlFields[1].text}'},
                  ],
                });
                // if (_socialUrlFields[0].text.trim().isNotEmpty) {
                //   body.fields.add(MapEntry('social_media.website', _socialUrlFields[0].text));
                // }
                // if (_socialUrlFields[1].text.trim().isNotEmpty) {
                //   body.fields.add(MapEntry('social_media.whatsapp', '+91${_socialUrlFields[1].text}'));
                // }
                // if (_socialUrlFields[2].text.trim().isNotEmpty) {
                //   body.fields.add(MapEntry('social_media.instagram', _socialUrlFields[2].text));
                // }
                // if (_socialUrlFields[3].text.trim().isNotEmpty) {
                //   body.fields.add(MapEntry('social_media.facebook', _socialUrlFields[3].text));
                // }
                // if (_socialUrlFields[4].text.trim().isNotEmpty) {
                //   body.fields.add(MapEntry('social_media.youtube', _socialUrlFields[4].text));
                // }
                if (_pickedImage != null) {
                  body.files.add(MapEntry('logo', await MultipartFile.fromFile(_pickedImage!.path, filename: _pickedImage!.name)));
                }
                await _cubit.updateOrgDetails(orgId: widget.orgDetails.id ?? 0, body: body);
              },
            ).pad(16).pxy(y: 16);
          },
        ),
      ),
    );
  }
}
