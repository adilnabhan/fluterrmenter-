import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerProfessionalDetailsScreen extends StatefulWidget {
  const CreateTrainerProfessionalDetailsScreen({super.key});

  @override
  State<CreateTrainerProfessionalDetailsScreen> createState() =>
      _CreateTrainerProfessionalDetailsScreenState();
}

class _CreateTrainerProfessionalDetailsScreenState
    extends State<CreateTrainerProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<String> _specializations;
    late final FieldData<dynamic> _experience;
  late final FieldData<dynamic> _bio;
  final List<XFile> _certificates = [];
  final ValueNotifier<List<({String label, String value})>> _selectedSpecializations =
      ValueNotifier<List<({String label, String value})>>([]);

  @override
  void initState() {
    _experience = FieldData(
      type: FieldType.word,
      label: 'Year of Experience',
      controller: TextEditingController(),
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        hintText: 'Year of Experience',
      ),
    );

    _specializations = FieldData<String>(
      type: FieldType.checkbox,
      label: 'Specializations',
      requiredLabel: true,
      items: [],
      controller: TextEditingController(),
      focusNode: FocusNode(),
      selectedValues: _selectedSpecializations,
      decoration: const InputDecoration(
        hintText: 'Select categories',
      ),
    );

    _bio = FieldData(
      type: FieldType.word,
      label: 'Personal Bio',
      controller: TextEditingController(),
      focusNode: FocusNode(),
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: '150 words',
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _experience.controller?.dispose();
    _specializations.controller?.dispose();
    _bio.controller?.dispose();
    _experience.focusNode?.dispose();
    _specializations.focusNode?.dispose();
    _bio.focusNode?.dispose();
    _selectedSpecializations.dispose();
    super.dispose();
  }

  void _onNext() {
    // Collect data and move to success or next screen
    // API calls commented out as per user request
    context.push(const CreateTrainerResultsScreen());
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
            const SizedBox(height: 10),
            // Progress Indicator (2/10 steps done)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                bool isActive = index <= 0;
                return Row(
                  children: [
                    Container(
                      width: 25,
                      height: 1,
                      color: isActive ? AppColors.primary : AppColors.borderGrey,
                    ),
                    Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: 8,
                        height: 8,
                        color: isActive ? AppColors.primary : AppColors.borderGrey,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 40),
            Text(
              'Your Fitness\nJourney So Far 🏆',
              style: AppStyles.text30Px.poppins.w600.dark,
            ),
            const SizedBox(height: 16),
            Text(
              'Let users and centers know your expertise.',
              style: AppStyles.text14Px.poppins.w400.textGrey,
            ),
            const SizedBox(height: 32),
            Field(data: _experience),
            // Text(
            //   'Specializations*',
            //   style: AppStyles.text14Px.poppins.w500.dark,
            // ),
            const SizedBox(height: 16),
            Field<String>(
              data: _specializations.copyWith(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  await AddCategorySheet(
                    selectedValues: _specializations.selectedValues?.value ?? [],
                    onSubmit: (values) {
                      _specializations.selectedValues?.value = [...values];
                    },
                  ).show(context);
                  if (context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Certifications',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
            const SizedBox(height: 8),
            // Certification Upload Box
            InkWell(
              onTap: () {
                ImagePickerDialog(
                  allowMultiple: true,
                  needRemove: false,
                  onPickedImages: (images) {
                    if (!mounted) return;
                    setState(() {
                      _certificates.addAll(images);
                    });
                  },
                ).show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffFFDADA)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Certificates',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_certificates.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _certificates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final file = _certificates[index];
                    return Stack(
                      children: [
                        Container(
                          width: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xffF7F7F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffEEEEEE)),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: AppColors.primary.withOpacity(0.5),
                                    size: 40,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xffFFCECE),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyles.text12Px.poppins.w400.dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: () => setState(() => _certificates.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            Field(data: _bio),
            const SizedBox(height: 40),
            Button.filled(
              title: 'Next',
              ontap: _onNext,
              buttonColor: AppColors.primary,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
