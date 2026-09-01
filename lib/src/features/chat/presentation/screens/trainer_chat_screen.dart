import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';

class TrainerChatScreen extends StatefulWidget {
  const TrainerChatScreen({
    required this.customerId,
    required this.customerName,
    this.conversationId,
    this.customerPhoto,
    this.customerPhone,
    super.key,
  });

  final int customerId;
  final String customerName;
  final int? conversationId;
  final String? customerPhoto;
  final String? customerPhone;

  @override
  State<TrainerChatScreen> createState() => _TrainerChatScreenState();
}

class _TrainerChatScreenState extends State<TrainerChatScreen> {
  int? _conversationId;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _initChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    if (_conversationId == null) {
      await _resolveConversation();
    } else {
      await _fetchMessages(showLoading: true);
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_conversationId != null && mounted && !_isSending) {
        _fetchMessages(showLoading: false);
      }
    });
  }

  Future<void> _resolveConversation() async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.chatDirect,
        data: {'customer_id': widget.customerId},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final conv = data['conversation'] as Map<dynamic, dynamic>?;
        if (conv != null && conv['id'] != null) {
          setState(() {
            _conversationId = conv['id'] as int;
          });
          await _fetchMessages(showLoading: true);
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessages({bool showLoading = false}) async {
    if (_conversationId == null) return;

    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.chatMessages(_conversationId!),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final rawMsgs = data['messages'] as List<dynamic>? ?? [];

        final List<Map<String, dynamic>> parsed = rawMsgs
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final bool hasNew = parsed.length != _messages.length;

        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(parsed);
            _isLoading = false;
          });

          if (hasNew) {
            _scrollToBottom();
          }
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    _textController.clear();
    setState(() {
      _isSending = true;
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender_role': 'trainer',
        'is_me': true,
        'text': text,
        'created_at': DateTime.now().toIsoformatString(),
        'is_read': false,
      });
    });
    _scrollToBottom();

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.chatMessages(_conversationId!),
        data: {'text': text},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 201) {
        _fetchMessages(showLoading: false);
      }
    } catch (_) {
      Dialogs.showSnack(msg: 'Failed to send message.');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return DateFormat('hh:mm a').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        leading: const PopButton().center,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iconBackground,
              ),
              child: ClipOval(
                child: widget.customerPhoto != null && widget.customerPhoto!.isNotEmpty
                    ? Image.network(
                        widget.customerPhoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, size: 22, color: AppColors.primary),
                      )
                    : const Icon(Icons.person, size: 22, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName,
                    style: AppStyles.text16Px.poppins.w600.dark,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.customerPhone ?? 'Client',
                    style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_outlined, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Start conversation with ${widget.customerName}',
                              style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final bool isMe = msg['is_me'] == true || msg['sender_role'] == 'trainer';
                          final text = msg['text'] as String? ?? '';
                          final timeStr = _formatTime(msg['created_at'] as String?);

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.76,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    text,
                                    style: AppStyles.text14Px.poppins.w400.copyWith(
                                      color: isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe ? Colors.white70 : AppColors.textGrey,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg['is_read'] == true ? Icons.done_all : Icons.done,
                                          size: 13,
                                          color: Colors.white70,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeIso on DateTime {
  String toIsoformatString() => toIso8601String();
}
