import 'package:mentor_mobile_app/imports_bindings.dart';

class GymLocationDetailsScreen extends StatefulWidget {
  const GymLocationDetailsScreen({super.key});

  @override
  State<GymLocationDetailsScreen> createState() =>
      _GymLocationDetailsScreenState();
}

class _GymLocationDetailsScreenState extends State<GymLocationDetailsScreen> {
  late final List<List<FieldData<dynamic>>> _locationDetails;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
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
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
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
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
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
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
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
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
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
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
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
          textInputAction: TextInputAction.done,
          label: 'Contact Number',
          requiredLabel: true,

          controller: TextEditingController(),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Contact Number is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _locationDetails[5][0].focusNode?.requestFocus();
          },
          decoration: InputDecoration(
            hintText: 'Enter your contact number',
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
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
          textInputAction: TextInputAction.done,
          label: 'Email',
          requiredLabel: true,

          controller: TextEditingController(),
          focusNode: FocusNode(),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Email is required';
            }
            if (value?.isNotEmpty ?? false) {
              if (!RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              ).hasMatch(value!)) {
                return 'Invalid email address!';
              }
            }
            return null;
          },
          onSubmitted: (value) {
            _onContinue();
            _locationDetails[5][0].focusNode?.unfocus();
          },
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            hintStyle: AppStyles.text14Px.poppins400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
      ],
    ];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in _locationDetails) {
      for (final field in element) {
        field.controller?.dispose();
        field.focusNode?.dispose();
      }
    }
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(const GymLocationDetailsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 3,
                ).pOnly(right: 6),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for your location',
                      filled: false,
                      prefixIcon: SizedBox.square(
                        dimension: 32,
                        child:
                            SvgPicture.asset(
                              'assets/images/svg/icons/search.svg',
                              height: 32,
                              width: 32,
                            ).center,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/svg/icons/map.svg',
                    height: 32,
                    width: 32,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Use your current location',
                      style: AppStyles.text14Px.poppins600.dark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ListView.separated(
              itemCount: _locationDetails.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 22);
              },
              itemBuilder: (BuildContext context, int index) {
                final fields = _locationDetails[index];
                if (fields.length > 1) {
                  return Row(
                    children: [
                      Expanded(child: Field(data: fields[0])),
                      const SizedBox(width: 16),
                      Expanded(child: Field(data: fields[1])),
                    ],
                  );
                }
                return Field(data: _locationDetails[index][0]);
              },
            ),
            const SizedBox(height: 88),
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
    );
  }
}
