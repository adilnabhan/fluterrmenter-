import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';
import 'package:mentor_mobile_app/core/widgets/dialogs/dialog.dart';

class BirthdayWishesDialog extends StatefulWidget {
  const BirthdayWishesDialog({
    required this.client,
    this.organizationName,
    super.key,
  });

  final Map<String, dynamic> client;
  final String? organizationName;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> client,
    String? organizationName,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BirthdayWishesDialog(
        client: client,
        organizationName: organizationName,
      ),
    );
  }

  @override
  State<BirthdayWishesDialog> createState() => _BirthdayWishesDialogState();
}

class _BirthdayWishesDialogState extends State<BirthdayWishesDialog> {
  late final TextEditingController _messageController;
  final FocusNode _focusNode = FocusNode();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    final fullName = (widget.client['name'] ??
            widget.client['client_name'] ??
            widget.client['customer_name'] ??
            'Client')
        .toString()
        .trim();
    final firstName = fullName.split(' ').first;
    final orgName = widget.organizationName?.trim().isNotEmpty == true
        ? widget.organizationName!.trim()
        : 'Team';

    final defaultMessage =
        'Happy birthday, $firstName! 🎉\n\n'
        'Wishing you a wonderful day and a year full of happiness, good health and new personal bests. Keep shining!\n\n'
        'With warm wishes,\n'
        'Team $orgName';

    _messageController = TextEditingController(text: defaultMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<String?> _resolvePhoneNumber() async {
    final raw = widget.client['phone'] ??
        widget.client['mobile'] ??
        widget.client['whatsapp'] ??
        widget.client['whatsapp_number'] ??
        widget.client['phone_number'];

    if (raw != null && raw.toString().trim().isNotEmpty && raw.toString().trim() != 'null') {
      return raw.toString().trim();
    }

    // Try fetching from client detail API if customer id is available
    final rawId = widget.client['id'] ?? widget.client['customer_id'];
    final customerId = int.tryParse(rawId?.toString() ?? '');
    if (customerId != null && customerId > 0) {
      try {
        final res = await DioClient().dio.get<dynamic>(
          ApiUris.trainerCustomerDetails(customerId),
        );
        if (res.statusCode == 200 && res.data is Map) {
          final data = res.data as Map;
          final profile = (data['profile'] is Map) ? data['profile'] as Map : data;
          final phone = profile['phone'] ??
              profile['mobile'] ??
              profile['whatsapp'] ??
              profile['phone_number'];
          if (phone != null && phone.toString().trim().isNotEmpty) {
            return phone.toString().trim();
          }
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> _shareOnWhatsApp() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final text = _messageController.text.trim();
      final encodedText = Uri.encodeComponent(text);
      final phone = await _resolvePhoneNumber();

      String targetUrl;
      if (phone != null && phone.isNotEmpty) {
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
        targetUrl = 'https://wa.me/$cleanPhone?text=$encodedText';
      } else {
        targetUrl = 'https://wa.me/?text=$encodedText';
      }

      final uri = Uri.parse(targetUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to whatsapp scheme
        final schemeUri = Uri.parse('whatsapp://send?text=$encodedText');
        if (await canLaunchUrl(schemeUri)) {
          await launchUrl(schemeUri);
        } else {
          unawaited(
            Dialogs.showSnack(
              msg:
                  'Could not open WhatsApp. Please ensure WhatsApp is installed.',
            ),
          );
        }
      }
    } catch (e) {
      unawaited(Dialogs.showSnack(msg: 'Error launching WhatsApp: $e'));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (widget.client['name'] ??
            widget.client['client_name'] ??
            widget.client['customer_name'] ??
            'Client')
        .toString()
        .trim();
    final imgUrl = (widget.client['profile_picture'] ??
            widget.client['image'] ??
            widget.client['avatar'] ??
            widget.client['profile_image'])
        ?.toString();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Birthday wishes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Client Info Row
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 2.2,
                    ),
                  ),
                  child: ClipOval(
                    child: (imgUrl != null &&
                            imgUrl.isNotEmpty &&
                            imgUrl != 'null')
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const ColoredBox(
                              color: Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF94A3B8),
                                size: 28,
                              ),
                            ),
                            errorWidget: (_, __, ___) => const ColoredBox(
                              color: Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF94A3B8),
                                size: 28,
                              ),
                            ),
                          )
                        : const ColoredBox(
                            color: Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF94A3B8),
                              size: 28,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.cake_rounded,
                              size: 13,
                              color: Color(0xFFB45309),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Birthday today',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // "Your message" header with "Make it your own" edit action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your message',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: _focusNode.requestFocus,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Make it your own',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Message text container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: 7,
                minLines: 4,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF334155),
                ),
                decoration: const InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Share on WhatsApp Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSharing ? null : _shareOnWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: _isSharing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/svg/icons/whatsapp.svg',
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Share on WhatsApp',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Bottom subtle note
            const Center(
              child: Text(
                'Opens WhatsApp. Review and send there.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
