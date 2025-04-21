import 'package:mentor_mobile_app/imports_bindings.dart';

class GymWorkingDetailsScreen extends StatefulWidget {
  const GymWorkingDetailsScreen({super.key});

  @override
  State<GymWorkingDetailsScreen> createState() =>
      _GymWorkingDetailsScreenState();
}

class _GymWorkingDetailsScreenState extends State<GymWorkingDetailsScreen> {
  final _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final _selectedWeekDays = ValueNotifier(<String>[]);
  final _gymWorkingDetailsFields = [
    [
      FieldData<DateTime>(
        type: FieldType.time,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        decoration: InputDecoration(hintText: 'Starting time'),
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
        decoration: InputDecoration(hintText: 'Ending time'),
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
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Service Offerings',
        requiredLabel: true,
        controller: TextEditingController(),
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
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Amenities',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Amenities is required';
          }
          return null;
        },
        onSubmitted: (value) {},
        decoration: InputDecoration(
          hintText: 'Highlight what your business offers',
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
        textInputAction: TextInputAction.done,
        label: 'Social Media',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          // if (value?.trim().isEmpty ?? true) {
          //   return 'Contact Number is required';
          // }
          return null;
        },
        onSubmitted: (value) {},
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
        ),
      ),
    ],
    [
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          // if (value?.trim().isNotEmpty ?? true) {
          //   return 'Contact Number is required';
          // }
          // return null;
        },
        onSubmitted: (value) {},
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
                'assets/images/svg/icons/whatsapp.svg',
                height: 24,
                width: 24,
              ),
            ),
          ),
        ),
      ),
    ],
  ];

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
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 22),
          const GymProfileCompletionStatusCard(progress: 4),
          const SizedBox(height: 32),
          Text(
            'Set your working days & hours',
            style: AppStyles.text14Px.poppins.w500.dark,
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: _selectedWeekDays,
            builder: (context, selectedWeekDays, child) {
              return GridView.builder(
                shrinkWrap: true,
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF4F5FA),
                        borderRadius: BorderRadius.circular(8),
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
                            colorFilter: const ColorFilter.mode(
                              AppColors.dark,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          ListView.separated(
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
                  children: [
                    Expanded(child: Field(data: fields[0])),
                    const SizedBox(width: 16),
                    Expanded(child: Field(data: fields[1])),
                  ],
                );
              }
              return Field(data: fields.first);
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 84,
        child: FloatingActionButton(
          onPressed: () {},
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
