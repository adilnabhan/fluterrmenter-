import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerEarlyBirdOfferScreen extends StatefulWidget {
  const CreateTrainerEarlyBirdOfferScreen({super.key});

  @override
  State<CreateTrainerEarlyBirdOfferScreen> createState() => _CreateTrainerEarlyBirdOfferScreenState();
}

class _CreateTrainerEarlyBirdOfferScreenState extends State<CreateTrainerEarlyBirdOfferScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        leading: const PopButton().center,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Icons
          Positioned(
            top: 20,
            left: 20,
            child: SvgPicture.asset('assets/images/svg/vectors/shoe.svg', height: 40, color: const Color(0xffFFB2B2).withOpacity(0.5)),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: SvgPicture.asset('assets/images/svg/vectors/dumble.svg', height: 40, color: const Color(0xffFFB2B2).withOpacity(0.5)),
          ),
          Positioned(
            top: 150,
            left: 40,
            child: SvgPicture.asset('assets/images/svg/vectors/hart.svg', height: 35, color: const Color(0xffFFB2B2).withOpacity(0.5)),
          ),
          Positioned(
            top: 130,
            right: 60,
            child: SvgPicture.asset('assets/images/svg/vectors/showing_power.svg', height: 40, color: const Color(0xffFFB2B2).withOpacity(0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Progress Indicator
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(8, (index) {
                          bool isActive = index <= 4; 
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

                      // Title
                      Text(
                        'Early Bird\nOffer 🔥',
                        style: AppStyles.text36Px.poppins.w700.dark.copyWith(height: 1.2),
                      ),
                      const SizedBox(height: 32),

                      // Pricing Card
                      _buildPricingCard(),
                      const SizedBox(height: 32),

                      // Coupon Section
                      Text(
                        'Have a Coupon Code?',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter Coupon Code to avail special discounts',
                        style: AppStyles.text12Px.poppins.w400.textGrey,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                hintText: 'Enter Coupon Code',
                                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Button.filled(
                            title: 'Apply',
                            size: const Size(100, 48),
                            ontap: () {},
                            buttonColor: AppColors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Coupon Code Discount:', style: AppStyles.text14Px.poppins.w400.textGrey),
                          Text('₹0/-', style: AppStyles.text14Px.poppins.w500.dark),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount to Pay:', style: AppStyles.text16Px.poppins.w600.dark),
                          Text('₹2,148/-', style: AppStyles.text16Px.poppins.w700.dark),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Button.filled(
                        title: 'Upgrade My Personal Training',
                        ontap: () => context.push(const CreateTrainerLocationDetailsScreen()),
                        buttonColor: AppColors.primary,
                        raduis: 12,
                      ),
                      const SizedBox(height: 12),
                      Button.outlined(
                        title: 'Maybe Later',
                        ontap: () => context.push(const TrainerCreationSuccessScreen()),
                        style: AppStyles.text14Px.poppins.w500.copyWith(color: const Color(0xff444444)),
                        raduis: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffFFEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [Color(0xffFF8A8A), Color(0xffFFD6A4)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹4,499',
                        style: AppStyles.text18Px.poppins.w400.copyWith(
                          color: const Color(0xff444444),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹2,148',
                        style: AppStyles.text28Px.poppins.w700.dark,
                      ),
                      Text(
                        '/year',
                        style: AppStyles.text14Px.poppins.w500.dark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(₹179/month billed annually)',
                    style: AppStyles.text12Px.poppins.w400.dark.copyWith(color: AppColors.dark.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),

          // Benefits
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildBenefitRow('EMI facility for members', 'Increase conversions by offering\nflexible payment options.'),
                const SizedBox(height: 16),
                _buildBenefitRow('Listing on Discipl Customer App.', 'Be discovered by serious fitness\nseekers across your region.'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Color(0xffDC2626), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'And all upcoming features.',
                        style: AppStyles.text14Px.poppins.w600.dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Color(0xffDC2626), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.text14Px.poppins.w600.dark,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppStyles.text12Px.poppins.w400.textGrey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
