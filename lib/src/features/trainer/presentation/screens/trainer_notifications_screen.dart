import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_pending_verifications_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_assigned_workouts_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/member_detials_screen.dart';

class TrainerNotificationsScreen extends StatefulWidget {
  final bool isTrainer;
  final int? orgId;

  const TrainerNotificationsScreen({
    super.key,
    this.isTrainer = true,
    this.orgId,
  });

  @override
  State<TrainerNotificationsScreen> createState() =>
      _TrainerNotificationsScreenState();
}

typedef NotificationsScreen = TrainerNotificationsScreen;

class _TrainerNotificationsScreenState
    extends State<TrainerNotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String _selectedFilter = 'all'; // 'all' | 'unread'
  int _unreadCount = 0;

  String get _listUri => widget.isTrainer
      ? ApiUris.mentorNotifications
      : ApiUris.fitnessCenterNotifications;

  String get _unreadCountUri => widget.isTrainer
      ? ApiUris.mentorNotificationsUnreadCount
      : ApiUris.fitnessCenterNotificationsUnreadCount;

  String _readUri(dynamic id) => widget.isTrainer
      ? ApiUris.mentorNotificationRead(id)
      : ApiUris.fitnessCenterNotificationRead(id);

  String get _readAllUri => widget.isTrainer
      ? ApiUris.mentorNotificationsReadAll
      : ApiUris.fitnessCenterNotificationsReadAll;

  String _deleteUri(dynamic id) => widget.isTrainer
      ? ApiUris.deleteMentorNotification(id)
      : ApiUris.deleteFitnessCenterNotification(id);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      Response<dynamic>? response;
      try {
        response = await DioClient().dio.get<dynamic>(
          _unreadCountUri,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        response = await DioClient().dio.get<dynamic>(
          ApiUris.mentorNotificationsUnreadCount,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }
      if (response.statusCode == 200 && response.data is Map) {
        final count = response.data['unread_count'] as int? ??
            response.data['count'] as int? ??
            0;
        if (mounted) setState(() => _unreadCount = count);
      }
    } catch (_) {}
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      Response<dynamic>? response;

      String uri = _listUri;
      final queryParams = <String>[];
      if (_selectedFilter == 'unread') {
        queryParams.add('is_read=false');
      } else if (_selectedFilter == 'read') {
        queryParams.add('is_read=true');
      }
      if (queryParams.isNotEmpty) {
        uri += '?${queryParams.join('&')}';
      }

      try {
        response = await DioClient().dio.get<dynamic>(
          uri,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        // Fallback to mentor notifications if needed
        try {
          String fallbackUri = ApiUris.mentorNotifications;
          if (queryParams.isNotEmpty) {
            fallbackUri += '?${queryParams.join('&')}';
          }
          response = await DioClient().dio.get<dynamic>(
            fallbackUri,
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } catch (_) {}
      }

      if (response != null &&
          response.statusCode == 200 &&
          response.data != null) {
        var rawList = <dynamic>[];
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['results'] is List) {
            rawList = map['results'] as List;
          } else if (map['data'] is List) {
            rawList = map['data'] as List;
          } else if (map['notifications'] is List) {
            rawList = map['notifications'] as List;
          }
        }

        final parsed =
            rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        if (mounted) {
          setState(() {
            _notifications = parsed;
            _isLoading = false;
            if (_selectedFilter == 'all') {
              _unreadCount = parsed.where((n) => n['is_read'] != true).length;
            }
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;
    setState(() {
      item['is_read'] = true;
      if (_unreadCount > 0) _unreadCount--;
    });
    try {
      await DioClient().dio.patch<dynamic>(
        _readUri(id),
        options: Options(headers: {'X-Platform': platformSource}),
      );
    } catch (_) {
      try {
        await DioClient().dio.patch<dynamic>(
          ApiUris.mentorNotificationRead(id),
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {}
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadItems =
        _notifications.where((n) => n['is_read'] != true).toList();
    if (unreadItems.isEmpty) {
      Dialogs.showSnack(msg: 'All notifications are already read');
      return;
    }

    setState(() {
      for (final n in _notifications) {
        n['is_read'] = true;
      }
      _unreadCount = 0;
    });

    try {
      await DioClient().dio.patch<dynamic>(
        _readAllUri,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      Dialogs.showSnack(msg: 'All notifications marked as read');
    } catch (_) {
      try {
        await DioClient().dio.patch<dynamic>(
          ApiUris.mentorNotificationsReadAll,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        Dialogs.showSnack(msg: 'All notifications marked as read');
      } catch (_) {}
    }
  }

  Future<void> _deleteNotification(dynamic id, int index) async {
    if (id == null) return;
    final item = _notifications[index];
    final wasUnread = item['is_read'] != true;

    setState(() {
      _notifications.removeAt(index);
      if (wasUnread && _unreadCount > 0) _unreadCount--;
    });

    try {
      await DioClient().dio.delete<dynamic>(
        _deleteUri(id),
        options: Options(headers: {'X-Platform': platformSource}),
      );
    } catch (_) {
      try {
        await DioClient().dio.delete<dynamic>(
          ApiUris.deleteMentorNotification(id),
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        if (mounted) {
          setState(() {
            _notifications.insert(index, item);
            if (wasUnread) _unreadCount++;
          });
          Dialogs.showSnack(msg: 'Failed to delete notification');
        }
      }
    }
  }

  String _formatNotificationTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final str = timestamp.toString();
    try {
      final parsed = DateTime.tryParse(str);
      if (parsed != null) {
        final now = DateTime.now();
        final diff = now.difference(parsed);
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        if (diff.inDays < 7) return '${diff.inDays}d ago';
        return DateFormat('dd MMM, yyyy').format(parsed);
      }
    } catch (_) {}
    return str;
  }

  IconData _getIconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('workout') || t.contains('exercise') || t.contains('plan')) {
      return Icons.fitness_center_rounded;
    }
    if (t.contains('payment') || t.contains('due') || t.contains('fee')) {
      return Icons.payment_rounded;
    }
    if (t.contains('verify') || t.contains('verification')) {
      return Icons.verified_outlined;
    }
    if (t.contains('member') ||
        t.contains('client') ||
        t.contains('customer') ||
        t.contains('lead')) {
      return Icons.person_outline_rounded;
    }
    if (t.contains('expire') || t.contains('cancel')) {
      return Icons.event_busy_rounded;
    }
    return Icons.notifications_none_rounded;
  }

  Color _getColorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('workout') || t.contains('exercise')) {
      return const Color(0xFF27AE60);
    }
    if (t.contains('payment') || t.contains('due') || t.contains('fee')) {
      return const Color(0xFFE67E22);
    }
    if (t.contains('verify') || t.contains('verification')) {
      return const Color(0xFF16A34A);
    }
    if (t.contains('member') ||
        t.contains('client') ||
        t.contains('customer')) {
      return const Color(0xFF3B66D4);
    }
    if (t.contains('expire') || t.contains('cancel')) {
      return const Color(0xFFE74C3C);
    }
    return AppColors.primary;
  }

  void _onNotificationTap(Map<String, dynamic> item) {
    if (item['is_read'] != true) {
      _markAsRead(item);
    }

    final type = (item['type'] ??
            item['notification_type'] ??
            item['category'] ??
            '')
        .toString()
        .toLowerCase();
    final action = item['action'] is Map
        ? Map<String, dynamic>.from(item['action'] as Map)
        : <String, dynamic>{};

    final customerIdRaw = action['customer_id'] ??
        action['client_id'] ??
        item['customer_id'] ??
        item['client_id'];
    final customerId =
        customerIdRaw != null ? int.tryParse(customerIdRaw.toString()) : null;

    if (type.contains('verify') || type.contains('verification')) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const TrainerPendingVerificationsScreen(),
        ),
      );
    } else if (type.contains('assigned_workout')) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const TrainerAssignedWorkoutsScreen(),
        ),
      );
    } else {
      final title = (item['title'] ??
              item['subject'] ??
              item['name'] ??
              'Notification')
          .toString();
      final body = (item['message'] ??
              item['body'] ??
              item['description'] ??
              '')
          .toString();
      final orgName = (item['organization_name'] ?? '').toString();

      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColorForType(type).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(type),
                  color: _getColorForType(type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.text15Px.poppins.w600.dark,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (orgName.isNotEmpty) ...[
                Text(
                  orgName,
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                body.isNotEmpty ? body : 'No additional details available.',
                style: AppStyles.text13Px.poppins.w400.copyWith(
                  color: const Color(0xff444444),
                ),
              ),
            ],
          ),
          actions: [
            if (customerId != null && customerId > 0)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (widget.isTrainer) {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => TrainerClientDetailScreen(
                          customerId: customerId,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => MemberDetialsScreen(
                          memberId: customerId,
                          orgId: widget.orgId,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('View Member'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: const PopButton().center,
        title: Text(
          'Notifications',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: Icon(
              Icons.done_all_rounded,
              color: context.colors.icon,
              size: 22,
            ),
            onPressed: _markAllAsRead,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh, color: context.colors.icon),
            onPressed: () {
              _fetchNotifications();
              _fetchUnreadCount();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs (All vs Unread)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'unread',
                  _unreadCount > 0 ? 'Unread ($_unreadCount)' : 'Unread',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await _fetchNotifications();
                      await _fetchUnreadCount();
                    },
                    child: _notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _notifications[index];
                              final title = (item['title'] ??
                                      item['subject'] ??
                                      item['name'] ??
                                      'Notification')
                                  .toString();
                              final body = (item['message'] ??
                                      item['body'] ??
                                      item['description'] ??
                                      '')
                                  .toString();
                              final type = (item['type'] ??
                                      item['notification_type'] ??
                                      '')
                                  .toString();
                              final timeStr = _formatNotificationTime(
                                item['created_at'] ??
                                    item['timestamp'] ??
                                    item['date'],
                              );
                              final isRead =
                                  item['is_read'] as bool? ?? false;
                              final color = _getColorForType(type);

                              return Dismissible(
                                key: ValueKey(
                                  item['id'] ?? 'notif_$index',
                                ),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE74C3C),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _deleteNotification(item['id'], index);
                                },
                                child: Material(
                                  color: isRead
                                      ? context.colors.card
                                      : color.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: () => _onNotificationTap(item),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isRead
                                              ? context.colors.border
                                              : color.withValues(alpha: 0.35),
                                          width: isRead ? 1.0 : 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                alpha: 0.12,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getIconForType(type),
                                              color: color,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        title,
                                                        style: AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w600
                                                            .copyWith(
                                                          color: context
                                                              .colors
                                                              .textPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                    if (!isRead) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: color,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (body.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    body,
                                                    style: AppStyles
                                                        .text12Px
                                                        .poppins
                                                        .w400
                                                        .copyWith(
                                                      color: context
                                                          .colors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                                if (timeStr.isNotEmpty) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    timeStr,
                                                    style: AppStyles
                                                        .text10Px
                                                        .poppins
                                                        .w400
                                                        .copyWith(
                                                      color: context
                                                          .colors
                                                          .textSecondary
                                                          .withValues(
                                                        alpha: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        if (_selectedFilter != value) {
          setState(() {
            _selectedFilter = value;
          });
          _fetchNotifications();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xffF2F3F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppStyles.text12Px.poppins.w500.copyWith(
            color: isSelected ? Colors.white : const Color(0xff555555),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'unread'
                      ? 'No Unread Notifications'
                      : 'No Notifications Yet',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedFilter == 'unread'
                      ? "You've read all your notifications."
                      : "You're all caught up! Updates, alerts, and workout completions will appear here.",
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationBellButton extends StatefulWidget {
  final int? orgId;
  final bool isTrainer;

  const NotificationBellButton({
    super.key,
    this.orgId,
    this.isTrainer = false,
  });

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.mentorNotificationsUnreadCount,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final count = response.data['unread_count'] as int? ?? 0;
        if (mounted) setState(() => _unreadCount = count);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => TrainerNotificationsScreen(
              isTrainer: widget.isTrainer,
              orgId: widget.orgId,
            ),
          ),
        );
        _fetchUnreadCount();
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.black87,
          ),
          if (_unreadCount > 0)
            Positioned(
              right: 1,
              top: 1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xffE74C3C),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
