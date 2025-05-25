import 'package:mentor_mobile_app/imports_bindings.dart';

class GymSchedulesScreen extends StatefulWidget {
  const GymSchedulesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymSchedulesScreen> createState() => _GymSchedulesScreenState();
}

class _GymSchedulesScreenState extends State<GymSchedulesScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;
  final _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late final ValueNotifier<List<String>> _selectedWeekDays;
  late final List<List<FieldData<dynamic>>> _gymWorkingDetailsFields;

  @override
  void initState() {
    super.initState();
    _selectedWeekDays = ValueNotifier([...widget.orgDetails.workingDays?.where((e) => e.isOpen ?? false).map((e) => e.day?.pascalCase ?? '') ?? []]);
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    final morningOpeningTime = widget.orgDetails.workingDays?.firstOrNull?.morningOpeningTime;
    final morningClosingTime = widget.orgDetails.workingDays?.firstOrNull?.morningClosingTime;
    final eveningOpeningTime = widget.orgDetails.workingDays?.firstOrNull?.eveningOpeningTime;
    final eveningClosingTime = widget.orgDetails.workingDays?.firstOrNull?.eveningClosingTime;
    _gymWorkingDetailsFields = [
      [
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(text: morningOpeningTime != null ? DateFormat('HH:mm:ss').parse(morningOpeningTime).format('HH:mm a') : null),
          focusNode: FocusNode(),
          label: 'Morning',
          requiredLabel: true,
          decoration: const InputDecoration(hintText: 'Starting time'),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
        ),
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(text: morningClosingTime != null ? DateFormat('HH:mm:ss').parse(morningClosingTime).format('HH:mm a') : null),
          focusNode: FocusNode(),
          decoration: const InputDecoration(hintText: 'Ending time'),
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
          controller: TextEditingController(text: eveningOpeningTime != null ? DateFormat('HH:mm:ss').parse(eveningOpeningTime).format('HH:mm a') : null),
          focusNode: FocusNode(),
          label: 'Evening',
          requiredLabel: true,
          decoration: const InputDecoration(hintText: 'Starting time'),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
        ),
        FieldData<DateTime>(
          type: FieldType.time,
          controller: TextEditingController(text: eveningClosingTime != null ? DateFormat('HH:mm:ss').parse(eveningClosingTime).format('HH:mm a') : null),
          focusNode: FocusNode(),
          decoration: const InputDecoration(hintText: 'Ending time'),
          validator: (value) {
            if (value == null) {
              return 'Please select a time';
            }
            return null;
          },
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
        appBar: AppBar(leading: const PopButton().center, title: Text('Schedules', style: AppStyles.text16Px.poppins.w500)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _selectedWeekDays,
              builder: (context, selectedWeekDays, child) {
                return GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: responsiveSize(context, s: 3).toInt(), crossAxisSpacing: 26, mainAxisSpacing: 26, mainAxisExtent: 52),
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
                        decoration: BoxDecoration(color: const Color(0xffF4F5FA), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(day, style: AppStyles.text14Px.w400.poppins),
                            SvgPicture.asset(
                              isSelected ? 'assets/images/svg/icons/checkbox_filled.svg' : 'assets/images/svg/icons/checkbox_blank.svg',
                              height: 18,
                              width: 18,
                              colorFilter: const ColorFilter.mode(AppColors.dark, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
                  return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Field(data: fields[0])), const SizedBox(width: 16), Expanded(child: Field(data: fields[1]))]);
                }
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
                final workingDaysInLowercase = _selectedWeekDays.value.map((e) => e.toLowerCase()).toList();
                final morningStartingTime = _gymWorkingDetailsFields.first.first.selectedTime;
                final morningEndingTime = _gymWorkingDetailsFields.first.last.selectedTime;
                final eveningStartingTime = _gymWorkingDetailsFields.last.first.selectedTime;
                final eveningEndingTime = _gymWorkingDetailsFields.last.last.selectedTime;
                if (workingDaysInLowercase.isEmpty) {
                  await Dialogs.showSnack(msg: 'Please select at least one working day');
                  return;
                } else if (morningStartingTime == null) {
                  await Dialogs.showSnack(msg: 'Please select morning starting time');
                  return;
                } else if (morningEndingTime == null) {
                  await Dialogs.showSnack(msg: 'Please select morning ending time');
                  return;
                } else if (eveningStartingTime == null) {
                  await Dialogs.showSnack(msg: 'Please select evening starting time');
                  return;
                } else if (eveningEndingTime == null) {
                  await Dialogs.showSnack(msg: 'Please select evening ending time');
                  return;
                }
                final body = {
                  //* Working Details
                  'working_days':
                      ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'].map((day) {
                        return {
                          'day': day,
                          'is_open': workingDaysInLowercase.contains(day),
                          'morning_opening_time': '${morningStartingTime.hour.toString().padLeft(2, '0')}:${morningStartingTime.minute.toString().padLeft(2, '0')}',
                          'morning_closing_time': '${morningEndingTime.hour.toString().padLeft(2, '0')}:${morningEndingTime.minute.toString().padLeft(2, '0')}',
                          'evening_opening_time': '${eveningStartingTime.hour.toString().padLeft(2, '0')}:${eveningStartingTime.minute.toString().padLeft(2, '0')}',
                          'evening_closing_time': '${eveningEndingTime.hour.toString().padLeft(2, '0')}:${eveningEndingTime.minute.toString().padLeft(2, '0')}',
                        };
                      }).toList(),
                };
                await _cubit.updateOrgDetails(orgId: widget.orgDetails.id ?? 0, body: body);
              },
            ).pad(16).pxy(y: 16);
          },
        ),
      ),
    );
  }
}
