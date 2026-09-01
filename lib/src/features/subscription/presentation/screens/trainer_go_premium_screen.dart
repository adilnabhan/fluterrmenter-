import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class TrainerGoPremiumScreen extends StatefulWidget {
  const TrainerGoPremiumScreen({super.key});

  @override
  State<TrainerGoPremiumScreen> createState() => _TrainerGoPremiumScreenState();
}

class _TrainerGoPremiumScreenState extends State<TrainerGoPremiumScreen> {
  late final Razorpay _razorpay;
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  bool _isPremium = false;
  String? _premiumDate;
  String? _currentOrderId;
  final TextEditingController _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchPremiumStatus();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _fetchPremiumStatus() async {
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get(ApiUris.trainerPremiumStatus);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data;
        setState(() {
          _isPremium = data['is_premium'] ?? false;
          _premiumDate = data['premium_purchase_date'];
          if (data['whatsapp_number'] != null) {
            _whatsappController.text = data['whatsapp_number'].toString();
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startPremiumUpgrade() async {
    setState(() => _isProcessingPayment = true);
    try {
      final res = await DioClient().dio.post(ApiUris.trainerPremiumCreateOrder);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data;
        if (data['is_premium'] == true) {
          setState(() {
            _isPremium = true;
            _isProcessingPayment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already a Premium Trainer!')),
          );
          return;
        }

        _currentOrderId = data['order_id'];
        final keyId = data['key_id'] ?? 'rzp_test_placeholder';
        final amountPaise = data['amount_paise'] ?? 800000;

        final options = {
          'key': keyId,
          'amount': amountPaise,
          'name': 'Discipl Trainer Marketplace',
          'description': 'Lifetime Trainer Marketplace Access',
          'order_id': _currentOrderId,
          'timeout': 120,
          'prefill': {
            'contact': data['trainer_mobile'] ?? '',
            'email': data['trainer_email'] ?? '',
          },
        };

        _razorpay.open(options);
      } else {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initiate order. Please try again.')),
        );
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment initiation error: $e')),
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final verifyRes = await DioClient().dio.post(
        ApiUris.trainerPremiumVerify,
        data: {
          'razorpay_order_id': response.orderId ?? _currentOrderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'whatsapp_number': _whatsappController.text.trim(),
        },
      );

      if (verifyRes.statusCode == 200) {
        setState(() {
          _isPremium = true;
          _isProcessingPayment = false;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 28),
                  SizedBox(width: 8),
                  Text('Premium Unlocked!'),
                ],
              ),
              content: const Text(
                'Congratulations! You are now live on the Customer App Trainer Marketplace. Clients can discover and reach out to you directly on WhatsApp.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B2E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Awesome!'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() => _isProcessingPayment = false);
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification notice: $e')),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message ?? "Cancelled"}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessingPayment = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Trainer Marketplace Upgrade', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Hero Premium Status Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isPremium
                            ? [const Color(0xFF065F46), const Color(0xFF047857)]
                            : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (_isPremium ? const Color(0xFF065F46) : const Color(0xFF0F172A)).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isPremium ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isPremium ? 'VERIFIED PREMIUM' : 'MARKETPLACE UPGRADE',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                              ),
                            ),
                            Icon(
                              _isPremium ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                              color: _isPremium ? const Color(0xFF6EE7B7) : const Color(0xFFFBBF24),
                              size: 32,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isPremium ? 'You are a Premium Trainer!' : 'Unlock Direct Client Discovery',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isPremium
                              ? 'Your profile is live on the Discipl Customer App across all gym branches.'
                              : 'Get discovered by all gym members across the app. Clients can message you directly on WhatsApp for personal training.',
                          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, height: 1.4),
                        ),
                        if (!_isPremium) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: const [
                              Text(
                                '₹8,000',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'one-time lifetime fee',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // WhatsApp Contact Configuration
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'WhatsApp Lead Number',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Clients will click to open a direct chat with you on this number.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Color(0xFF64748B), size: 20),
                            hintText: 'e.g. 9876543210',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Benefits List
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What You Get as a Premium Trainer',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 14),
                        _buildBenefitRow(
                          Icons.visibility_rounded,
                          'Visible to All Customers',
                          'Listed in the Customer App "Trainers" tab to thousands of active gym members.',
                        ),
                        _buildBenefitRow(
                          Icons.chat_rounded,
                          'Direct WhatsApp Inquiries',
                          'One-tap contact button connects prospective clients straight to your phone.',
                        ),
                        _buildBenefitRow(
                          Icons.payments_outlined,
                          'Keep 100% of Your Fees',
                          'No commission or escrow — charge whatever you want and settle directly via UPI/Cash.',
                        ),
                        _buildBenefitRow(
                          Icons.person_add_rounded,
                          'Self-Client Manager',
                          'Dedicated tools in the Mentor App to manage your own freelance clients independently.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  if (!_isPremium)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isProcessingPayment ? null : _startPremiumUpgrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B2E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: _isProcessingPayment
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.bolt_rounded, color: Color(0xFFFBBF24)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Unlock Marketplace — Pay ₹8,000',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF059669), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
