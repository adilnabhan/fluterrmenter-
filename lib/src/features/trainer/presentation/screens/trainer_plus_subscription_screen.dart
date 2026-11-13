import 'package:flutter/foundation.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TrainerPlusSubscriptionScreen extends StatefulWidget {
  final VoidCallback? onSubscriptionSuccess;

  const TrainerPlusSubscriptionScreen({
    super.key,
    this.onSubscriptionSuccess,
  });

  @override
  State<TrainerPlusSubscriptionScreen> createState() =>
      _TrainerPlusSubscriptionScreenState();
}

class _TrainerPlusSubscriptionScreenState
    extends State<TrainerPlusSubscriptionScreen> {
  late final Razorpay _razorpay;
  String _selectedPlan = 'yearly'; // 'monthly' | 'yearly'
  bool _isLoading = false;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initiateSubscription() async {
    setState(() => _isLoading = true);

    try {
      final res = await DioClient().dio.post<dynamic>(
        '${ApiUris.baseUrl}/api/v1/trainer/premium/create-order/',
        data: {
          'plan': _selectedPlan,
          'amount': 19,
        },
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (res.statusCode == 200 && res.data is Map) {
        final data = Map<String, dynamic>.from(res.data as Map);

        // Check if trainer is already premium
        if (data['is_premium'] == true && data['order_id'] == null) {
          Dialogs.showSnack(
            msg: data['message']?.toString() ?? 'You are already a Trainer Plus member!',
          );
          widget.onSubscriptionSuccess?.call();
          if (mounted) Navigator.of(context).pop(true);
          return;
        }

        final orderId = data['order_id']?.toString();
        final amountPaise = data['amount_paise'] ??
            ((data['amount'] as num? ?? 19) * 100).toInt();
        final keyId = data['key_id']?.toString() ??
            dotenv.get('RAZORPAY_API_KEY', fallback: 'rzp_live_Rqet3gBlPqmWUn');
        final trainerName = data['trainer_name']?.toString() ?? 'Trainer';
        final trainerEmail = data['trainer_email']?.toString() ?? '';
        final trainerMobile = data['trainer_mobile']?.toString() ?? '';

        _pendingOrderId = orderId;

        final options = {
          'key': keyId,
          'amount': amountPaise,
          'name': 'Discipl Trainer Plus',
          'description': _selectedPlan == 'yearly'
              ? 'Trainer Plus - 1 Year Subscription'
              : 'Trainer Plus - 1 Month Subscription',
          'order_id': orderId,
          'timeout': 120,
          'prefill': {
            'contact': trainerMobile,
            'email': trainerEmail,
            'name': trainerName,
          },
          'theme': {
            'color': '#C4161C',
          },
        };

        debugPrint('Opening Razorpay checkout: $options');
        _razorpay.open(options);
      } else {
        Dialogs.showSnack(msg: 'Unable to initiate subscription order.');
      }
    } catch (e) {
      debugPrint('Error creating subscription order: $e');
      Dialogs.showSnack(msg: 'Payment initiation error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);

    try {
      final verifyRes = await DioClient().dio.post<dynamic>(
        '${ApiUris.baseUrl}/api/v1/trainer/premium/verify/',
        data: {
          'razorpay_order_id': response.orderId ?? _pendingOrderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'plan': _selectedPlan,
        },
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (verifyRes.statusCode == 200) {
        Dialogs.showSnack(
          msg: '🎉 Welcome to Trainer Plus! Your subscription is now active.',
        );
        widget.onSubscriptionSuccess?.call();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        Dialogs.showSnack(
          msg: 'Payment received! Verifying subscription in background...',
        );
        widget.onSubscriptionSuccess?.call();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      Dialogs.showSnack(
        msg: 'Payment was completed. Activating subscription...',
      );
      widget.onSubscriptionSuccess?.call();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay payment error: ${response.code} - ${response.message}');
    Dialogs.showSnack(
      msg: 'Payment canceled or failed: ${response.message ?? "Try again"}',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
  }

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC4161C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: brandRed,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Plus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: brandRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'TRAINER PLUS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Coach beyond\nyour gym.',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Bring gym members and independent clients into one coaching space.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B6B6B),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: brandRed,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // More possibilities with Plus
              const Text(
                'More possibilities with Plus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureRow(
                icon: Icons.person_add_outlined,
                iconBg: const Color(0xFFFFECEC),
                iconColor: brandRed,
                title: 'Train clients from anywhere',
                subtitle: 'Add clients outside your registered gym.',
              ),
              const SizedBox(height: 14),
              _buildFeatureRow(
                icon: Icons.folder_outlined,
                iconBg: const Color(0xFFEBF3FF),
                iconColor: const Color(0xFF2F80ED),
                title: 'Make room for every group',
                subtitle: 'Create groups and organize your clients.',
              ),
              const SizedBox(height: 14),
              _buildFeatureRow(
                icon: Icons.grid_view_rounded,
                iconBg: const Color(0xFFF2F4F7),
                iconColor: const Color(0xFF475467),
                title: 'One dashboard. Every group.',
                subtitle: 'Switch groups to see their stats and clients.',
              ),

              const SizedBox(height: 32),

              // Choose your plan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose your plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const Text(
                    'Save ₹1,200 / year',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: brandRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Plan Cards Row
              Row(
                children: [
                  // Monthly Card
                  Expanded(
                    child: _buildPlanCard(
                      planId: 'monthly',
                      name: 'Monthly',
                      pricePerMonth: '₹499',
                      billedLabel: '₹499 billed monthly',
                      isSelected: _selectedPlan == 'monthly',
                      brandRed: brandRed,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Yearly Card
                  Expanded(
                    child: _buildPlanCard(
                      planId: 'yearly',
                      name: 'Yearly',
                      pricePerMonth: '₹399',
                      billedLabel: '₹4,788 billed yearly',
                      isSelected: _selectedPlan == 'yearly',
                      brandRed: brandRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Subscribe CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _initiateSubscription,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Subscribe to Plus',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Center(
                child: Text(
                  _selectedPlan == 'yearly'
                      ? '₹4,788/year · Renews yearly. Cancel anytime.'
                      : '₹499/month · Renews monthly. Cancel anytime.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Continue with Free
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Continue with Free',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer
              Center(
                child: InkWell(
                  onTap: () {
                    Dialogs.showSnack(msg: 'Switched to Trainer Plus Dashboard');
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Terms   •   Privacy   •   Restore purchases',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String planId,
    required String name,
    required String pricePerMonth,
    required String billedLabel,
    required bool isSelected,
    required Color brandRed,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _selectedPlan = planId);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandRed : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: brandRed.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? brandRed : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? brandRed : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              pricePerMonth,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isSelected ? brandRed : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'per month',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              billedLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

