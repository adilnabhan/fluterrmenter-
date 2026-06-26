import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerPackagesScreen extends StatefulWidget {
  const CreateTrainerPackagesScreen({super.key});

  @override
  State<CreateTrainerPackagesScreen> createState() => _CreateTrainerPackagesScreenState();
}

class _CreateTrainerPackagesScreenState extends State<CreateTrainerPackagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (index) {
                    bool isActive = index <= 7; 
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
                  'Define Your\nServices &\nPricing 💸',
                  style: AppStyles.text30Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Let clients know what you offer.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Text('Packages', style: AppStyles.text16Px.poppins.w600.dark),
                    const Spacer(),
                    InkWell(
                      onTap: () => context.push(const CreateTrainerAddEditPackageScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFEAEA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('Add', style: AppStyles.text14Px.poppins.w500.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sample Package 1
                _buildPackageCard(
                  name: 'Variable Plan',
                  actualPrice: '3,000',
                  offerPrice: '1,000',
                  emiOptions: [
                    {'months': '2', 'price': '1,500'},
                    {'months': '4', 'price': '1,000'},
                    {'months': '6', 'price': '5,000'},
                  ],
                ),
                const SizedBox(height: 16),

                // Sample Package 2
                _buildPackageCard(
                  name: 'Monthly Plan',
                  actualPrice: '1,500',
                  offerPrice: null,
                  emiOptions: [],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Button.filled(
              title: 'Next',
              ontap: () => context.push(const TrainerCreationSuccessScreen()),
              buttonColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String name,
    required String actualPrice,
    String? offerPrice,
    required List<Map<String, String>> emiOptions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppStyles.text16Px.poppins.w600.dark),
              InkWell(
                onTap: () => context.push(const CreateTrainerAddEditPackageScreen()),
                child: Text('Edit', style: AppStyles.text14Px.poppins.w500.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Actual Price', style: AppStyles.text14Px.poppins.w400.dark),
              Text('₹$actualPrice', style: AppStyles.text14Px.poppins.w500.dark),
            ],
          ),
          if (offerPrice != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Offer Price', style: AppStyles.text14Px.poppins.w400.dark),
                Text('₹$offerPrice', style: AppStyles.text14Px.poppins.w500.dark),
              ],
            ),
          ],
          if (emiOptions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EMI Option', style: AppStyles.text14Px.poppins.w600.dark),
                  const SizedBox(height: 12),
                  ...emiOptions.map((emi) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${emi['months']} Month', style: AppStyles.text13Px.poppins.w400.dark),
                        Text('₹${emi['price']}', style: AppStyles.text13Px.poppins.w500.dark),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
