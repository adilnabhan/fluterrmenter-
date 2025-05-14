import 'package:mentor_mobile_app/imports_bindings.dart';

class GymSchedulesScreen extends StatefulWidget {
  const GymSchedulesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymSchedulesScreen> createState() => _GymSchedulesScreenState();
}

class _GymSchedulesScreenState extends State<GymSchedulesScreen> {
  late final List<List<FieldData<dynamic>>> _gymWorkingDetailsFields;

  @override
  void initState() {
    super.initState();
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
          label: 'Ending',
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
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text('Schedules', style: AppStyles.text16Px.poppins.w500)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
              if (fields.first.label == 'Amenities') {
                return InkWell(
                  onTap: () {
                    AddAmenitiesSheet(
                      selectedValues: [...fields.first.selectedValues?.value.map((e) => (label: e.label, value: '${e.value}')) ?? []],
                      onSubmit: (values) {
                        fields.first.selectedValues?.value = values.map((e) => (label: e.label, value: e.value)).toList();
                      },
                    ).show(context);
                  },
                  child: AbsorbPointer(child: Field<String>(data: fields.first as FieldData<String>)),
                );
              }
              return Field(data: fields.first);
            },
          ),
        ],
      ),
      bottomNavigationBar: Button.filled(
        raduis: 12,
        title: 'Save',
        // isLoading: widget.details?.fold((l) => state.createOrUpdateLead, (r) => state.createOrUpdateMember)?.isNone() ?? false,
        buttonColor: AppColors.primary,
        // ontap: _onContinue,
        ontap: () {},
      ).pad(16).pxy(y: 16),
    );
  }
}
