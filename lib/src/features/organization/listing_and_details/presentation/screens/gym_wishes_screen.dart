import 'package:mentor_mobile_app/imports_bindings.dart';

class GymWishesScreen extends StatefulWidget {
  const GymWishesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymWishesScreen> createState() => _GymWishesScreenState();
}

class _GymWishesScreenState extends State<GymWishesScreen> {
  late final List<({String label, String value, void Function() onTap})>
  _basicDetails;
  late final List<List<FieldData<dynamic>>> _socialMediaFields;
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
    _basicDetails = [
      (label: 'Gym Name', value: widget.orgDetails.name ?? '', onTap: () {}),
      (
        label: 'Location',
        value:
            '${widget.orgDetails.location?.street},${widget.orgDetails.location?.city}',
        onTap: () {},
      ),
      (label: 'Email', value: widget.orgDetails.email ?? '', onTap: () {}),
      (
        label: 'Mobile',
        value: widget.orgDetails.phoneNumber ?? '',
        onTap: () {},
      ),
    ];
    _socialMediaFields = [
      [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'Social Media',
          requiredLabel: true,
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
                  valueListenable: _socialUrlFields[0],
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (!Uri.parse(value.text).isAbsolute) {
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
                    if (!Uri.parse(value.text).isAbsolute) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text('Gym Details', style: AppStyles.text16Px.poppins.w500),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _basicDetails.length,
            separatorBuilder:
                (context, index) =>
                    const Divider(thickness: 1, color: Color(0xffDDDDDD)),
            itemBuilder: (context, index) {
              final e = _basicDetails[index];
              return InkWell(
                onTap: e.onTap,
                child: Row(
                  children: [
                    Text(
                      e.label,
                      style: AppStyles.text14Px.poppins.w400.textGrey,
                    ),
                    const Spacer(),
                    Text(e.value, style: AppStyles.text14Px.poppins.w500.dark),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.dark,
                    ).pOnly(left: 8),
                  ],
                ).pxy(y: 16),
              );
            },
          ),
          Text(
            'Social Media',
            style: AppStyles.text16Px.poppins.w600.dark,
          ).pOnly(bottom: 16),
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
      bottomNavigationBar: BlocBuilder<
        MembersAndLeadsCubit,
        MembersAndLeadsState
      >(
        buildWhen:
            (p, c) =>
                p.createOrUpdateLead != c.createOrUpdateLead ||
                p.createOrUpdateMember != c.createOrUpdateMember,
        builder: (context, state) {
          return Button.filled(
            title: 'Save',
            // isLoading: widget.details?.fold((l) => state.createOrUpdateLead, (r) => state.createOrUpdateMember)?.isNone() ?? false,
            buttonColor: AppColors.primary,
            // ontap: _onContinue,
            ontap: () {},
          );
        },
      ).pad(16).pxy(y: 16),
    );
  }
}
