import 'package:mentor_mobile_app/imports_bindings.dart';

class GymAddPackageScreen extends StatefulWidget {
  const GymAddPackageScreen({super.key});

  @override
  State<GymAddPackageScreen> createState() => _GymAddPackageScreenState();
}

class _GymAddPackageScreenState extends State<GymAddPackageScreen> {
  late String _selectedPriceType;
  late final MembershipCubit _cubit;
  late final FieldData<String> _packageTypeField;
  late final FieldData<dynamic> _actualPriceField;
  late final FieldData<dynamic> _offerPriceField;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembershipCubit>();
    _packageTypeField = FieldData<String>(
      type: FieldType.radio,
      textInputAction: TextInputAction.done,
      label: 'Package Type',
      requiredLabel: true,
      controller: TextEditingController(),
      items: [(label: 'Monthly Plan', value: 'Monthly Plan'), (label: 'Quarterly Plan', value: 'Quarterly Plan'), (label: 'Yearly Plan', value: 'Yearly Plan')],
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Package type must be selected';
        }
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Select Package Type',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    _actualPriceField = FieldData<String>(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Actual Price',
      requiredLabel: true,
      inputFormatters: [],
      keyboardType: TextInputType.number,
      controller: TextEditingController(),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Actual price is required!';
        }
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter actual price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
    _offerPriceField = FieldData<String>(
      type: FieldType.radio,
      textInputAction: TextInputAction.done,
      label: 'Offer Price',
      requiredLabel: true,
      controller: TextEditingController(),
      inputFormatters: [],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Offer price is required';
        }
        return null;
      },
      onValueChanged: (p0) {},
      onSubmitted: (value) {},
      decoration: InputDecoration(
        hintText: 'Enter offer price',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text('Add Package', style: AppStyles.text16Px.poppins.w500)),
      body: Column(
        children: [
          Field(data: _packageTypeField),
          // Row(
          //   children: [
          //     Text('Current Packages', style: AppStyles.text16Px.poppins.w500.dark),
          //     const Spacer(),
          //     FilledButton.icon(
          //       onPressed: () {},
          //       label: const Text('Add'),
          //       icon: const Icon(Icons.add),
          //       style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.primary), backgroundColor: WidgetStatePropertyAll(Color(0xffFFEAEA))),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ...['Monthly Price', 'Total Price'].map(_sortTile),
            ],
          ).pOnly(bottom: 32, top: 16),
          Field(data: _actualPriceField),
          const SizedBox(height: 16),
          if (_selectedPriceType == 'Monthly Price') Field(data: _offerPriceField),
          const SizedBox(height: 16),
        ],
      ).pad(16),
      bottomNavigationBar: BlocBuilder<MembershipCubit, MembershipState>(
        buildWhen: (p, c) => p.createOrUpdatePackage != c.createOrUpdatePackage,
        builder: (context, state) {
          final isLoading = state.createOrUpdatePackage?.isNone() ?? false;
          return Button.filled(
            title: 'Save',
            isLoading: isLoading,
            buttonColor: AppColors.primary,
            // ontap: _onContinue,
            ontap: () {
              if (isLoading) {
                return;
              }
            },
          );
        },
      ).pad(16).pxy(y: 16),
    );
  }

  Widget _sortTile(String priceType) {
    final isSelected = _selectedPriceType == priceType;
    if (isSelected) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xffFBEEEE), shape: const StadiumBorder(), foregroundColor: AppColors.primary),
        onPressed: () {},
        label: Text(priceType),
        icon: const Icon(Icons.radio_button_checked),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xffDDDDDD)), shape: const StadiumBorder(), foregroundColor: const Color(0xff444444)),
      onPressed: () {
        setState(() {
          _selectedPriceType = priceType;
        });
      },
      label: Text(priceType.pascalCase),
      icon: const Icon(Icons.radio_button_off),
    );
  }
}
