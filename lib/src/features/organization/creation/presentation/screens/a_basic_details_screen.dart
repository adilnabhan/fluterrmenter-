import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateOrganizationBasicDetailsScreen extends StatelessWidget {
  const CreateOrganizationBasicDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizationCreationCubit(),
      child: const _GymProfileCreationScreen(),
    );
  }
}

class _GymProfileCreationScreen extends StatefulWidget {
  const _GymProfileCreationScreen();

  @override
  State<_GymProfileCreationScreen> createState() =>
      _GymProfileCreationScreenState();
}

class _GymProfileCreationScreenState extends State<_GymProfileCreationScreen> {
  late final OrganizationCreationCubit _gymCreationCubit;
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _brandName;
  late final FieldData<String> _brandCategory;
  // late final FieldData<dynamic> _brandLogo;
  late final FieldData<dynamic> _brandDescription;
  XFile? _selectedBrandLogo;

  @override
  void initState() {
    _gymCreationCubit = context.read<OrganizationCreationCubit>();
    _brandName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Fitness center Name',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Fitness center name is required';
        }
        return null;
      },
      onSubmitted: (value) {
        // _brandDetials[1].focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Name of Fitness center',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _brandCategory = FieldData<String>(
      type: FieldType.checkbox,
      items: [],
      textInputAction: TextInputAction.next,
      label: 'Categories',
      requiredLabel: true,
      selectedValues: ValueNotifier([]),
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Fitness center category is required';
        }
        return null;
      },
      onSubmitted: (value) {
        // _brandDetials[1].focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Select categories',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _brandDescription = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Description (What makes your place special?)',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Fitness center description is required';
        }
        return null;
      },
      onSubmitted: (value) {
        // _brandDetials[1].focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '150 words',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _brandName.controller?.dispose();
    _brandCategory.controller?.dispose();
    _brandCategory.selectedValues?.dispose();
    _brandName.focusNode?.dispose();
    _brandCategory.focusNode?.dispose();
  }

  void _onContinue() {
    _formKey.currentState?.validate();
    final brandName = _brandName.controller?.text;
    final brandCategory =
        _brandCategory.selectedValues?.value.map((e) => e.value).toList() ??
        <String>[];
    final brandDescription = _brandDescription.controller?.text;
    final error = _gymCreationCubit.addBrandDetails(
      brandName: brandName,
      brandCategory: brandCategory,
      brandDescription: brandDescription,
      brandLogo: _selectedBrandLogo?.path,
    );
    if (error != null) {
      Dialogs.showSnack(msg: error);
      return;
    } else {
      context.push(
        BlocProvider.value(
          value: _gymCreationCubit,
          child: const CreateOrganizationLocationDetailsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (index) {
                  bool isActive = index <= 1;
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
                'Show the World\nWhat You’ve\nGot 💪',
                style: AppStyles.text30Px.poppins.w600.dark,
              ),
              const SizedBox(height: 16),
              Text(
                'This is what users will see when they\nsearch your fitness center.',
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    BrandLogoPicker(
                      isEdit: true,
                      onChanged: (brandLogo) {
                        _selectedBrandLogo = brandLogo;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set Fitness center logo',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Field(data: _brandName),
              const SizedBox(height: 16),
              Field<String>(
                data: _brandCategory.copyWith(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    await AddCategorySheet(
                      selectedValues:
                          _brandCategory.selectedValues?.value ?? [],
                      onSubmit: (values) {
                        _brandCategory.selectedValues?.value = [...values];
                      },
                    ).show(context);
                    if (context.mounted) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Field(data: _brandDescription),
              const SizedBox(height: 32),
              Button.filled(
                title: 'Next → Let’s Add Your Location',
                ontap: _onContinue,
                buttonColor: AppColors.primary,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
