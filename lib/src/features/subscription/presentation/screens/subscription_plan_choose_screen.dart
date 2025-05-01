import 'package:mentor_mobile_app/imports_bindings.dart';

class SubscriptionPlanChooseScreen extends StatefulWidget {
  const SubscriptionPlanChooseScreen({super.key});

  @override
  State<SubscriptionPlanChooseScreen> createState() => _SubscriptionPlanChooseScreenState();
}

class _SubscriptionPlanChooseScreenState extends State<SubscriptionPlanChooseScreen> {
  late SubscriptionPlanEntity _selectedPlan;

  final List<SubscriptionPlanEntity> _subscriptions = [
    SubscriptionPlanEntity(title: '6 Month Plan', perMonthPrice: 299, totalPrice: 1794, perMonthOriginalPrice: 1200, totalDiscount: 1200),
    SubscriptionPlanEntity(title: 'Monthly Plan', perMonthPrice: 499, totalPrice: 499),
  ];

  @override
  void initState() {
    _selectedPlan = _subscriptions[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2C1212), AppColors.dark], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent, // Background color
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text('Choose\nSubscription plan', style: AppStyles.text24Px.poppins.w700.light),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: AppStyles.text14Px.poppins.w400.light,
                    children: const [TextSpan(text: '15-day', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' trial period is available for both\nsubscription plans')],
                  ),
                ),
                const Spacer(flex: 4),
                _buildPlanOption(plan: _subscriptions[0]),
                const SizedBox(height: 16),
                _buildPlanOption(plan: _subscriptions[1]),
                const Spacer(),
                Button.filled(title: 'Continue', ontap: () {}, buttonColor: Colors.white, style: AppStyles.text14Px.poppins.w600.dark, raduis: 12),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanOption({required SubscriptionPlanEntity plan}) {
    final isSelected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !isSelected ? const Color(0xFF270A0A).withAlpha(150) : null,
          gradient: !isSelected ? null : const LinearGradient(colors: [Color(0xFF290F0F), Color(0xff581F1F)]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xffC39191) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(plan.title, style: AppStyles.text14Px.poppins.w500.light),
                if (plan.totalDiscount != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Total ₹${plan.totalPrice}', style: AppStyles.text12Px.poppins.w400.light),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(color: Color(0xff713E3E), borderRadius: BorderRadius.all(Radius.circular(6))),
                        child: Text('Save ₹${plan.totalDiscount}', style: AppStyles.text12Px.poppins.w400.light),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppStyles.text16Px.poppins.w700.light,
                    children: [
                      if (plan.perMonthOriginalPrice != null)
                        TextSpan(text: '₹${plan.perMonthOriginalPrice}', style: AppStyles.text14Px.poppins.w300.light.copyWith(decoration: TextDecoration.lineThrough)),
                      if (plan.perMonthOriginalPrice != null) const WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(text: '₹${plan.perMonthPrice}', style: AppStyles.text16Px.poppins.w700.light),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('per month', style: AppStyles.text12Px.poppins.w400.light),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
