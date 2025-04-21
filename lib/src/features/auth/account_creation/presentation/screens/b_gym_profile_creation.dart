import 'package:mentor_mobile_app/imports_bindings.dart';

class GymProfileCreationScreen extends StatefulWidget {
  const GymProfileCreationScreen({super.key});

  @override
  State<GymProfileCreationScreen> createState() =>
      GymProfileCreationScreenState();
}

class GymProfileCreationScreenState extends State<GymProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _brandName;
  late final FieldData<String> _brandCategory;
  // late final FieldData<dynamic> _brandLogo;
  late final FieldData<dynamic> _brandDescription;
  XFile? _selectedBrandLogo;

  @override
  void initState() {
    _brandName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Brand Name ',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Brand name is required';
        }
        return null;
      },
      onSubmitted: (value) {
        // _brandDetials[1].focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Enter your brand name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _brandCategory = FieldData<String>(
      type: FieldType.radio,
      items: [
        (label: 'Gym', value: 'Gym'),
        (label: 'Coaching', value: 'Coaching'),
        (label: 'Salons', value: 'Salons'),
      ],
      textInputAction: TextInputAction.next,
      label: 'Brand Category ',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Brand category is required';
        }
        return null;
      },
      onSubmitted: (value) {
        // _brandDetials[1].focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Select your brand category',
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
      label: 'Describe your brand ',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Brand description is required';
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
        hintText: 'Highlight key features in a sentence or two',
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
    _brandName.focusNode?.dispose();
    _brandCategory.focusNode?.dispose();
  }

  void _onContinue() {
    if ((_formKey.currentState?.validate() ?? false) &&
        _selectedBrandLogo != null) {
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
            const GymProfileCompletionStatusCard(progress: 1),
            const SizedBox(height: 28),
            Field(data: _brandName),
            const SizedBox(height: 16),
            Field<String>(data: _brandCategory),
            const SizedBox(height: 16),
            Text('Brand Logo', style: AppStyles.text14Px.poppins.w500.dark),
            const SizedBox(height: 8),
            BrandLogoPicker(
              isEdit: true,
              onChanged: (brandLogo) {
                _selectedBrandLogo = brandLogo;
              },
            ),
            const SizedBox(height: 16),
            Field(data: _brandDescription),
            const SizedBox(height: 32),
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
