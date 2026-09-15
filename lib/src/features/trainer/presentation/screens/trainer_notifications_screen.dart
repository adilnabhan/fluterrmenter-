import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_pending_verifications_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_assigned_workouts_screen.dart';

class TrainerNotificationsScreen extends StatefulWidget {
  const TrainerNotificationsScreen({super.key});

  @override
  State<TrainerNotificationsScreen> createState() =>
      _TrainerNotificationsScreenState();
}

class _TrainerNotificationsScreenState
    extends State<TrainerNotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      Response<dynamic>? response;

      // Try trainer-specific notifications endpoint first
      try {
        response = await DioClient().dio.get<dynamic>(
          ApiUris.trainerNotifications,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        // Fallback to communication/notifications
        try {
          response = await DioClient().dio.get<dynamic>(
            ApiUris.notifications,
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
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
    if (t.contains('verify') || t.contains('verification')) {
      return Icons.verified_outlined;
    }
    if (t.contains('workout') || t.contains('exercise') || t.contains('plan')) {
      return Icons.fitness_center_outlined;
    }
    if (t.contains('client') || t.contains('customer') || t.contains('lead')) {
      return Icons.person_outline_rounded;
    }
    if (t.contains('payment') || t.contains('subscription') || t.contains('renewal')) {
      return Icons.payment_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  Color _getColorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('verify') || t.contains('verification')) {
      return const Color(0xFF16A34A);
    }
    if (t.contains('workout') || t.contains('exercise')) {
      return const Color(0xFFD97706);
    }
    if (t.contains('client') || t.contains('customer')) {
      return const Color(0xFF3B66D4);
    }
    if (t.contains('payment')) {
      return const Color(0xFF9C51BF);
    }
    return AppColors.primary;
  }

  void _onNotificationTap(Map<String, dynamic> item) {
    final type = (item['type'] ?? item['notification_type'] ?? item['category'] ?? '')
        .toString()
        .toLowerCase();

    if (type.contains('verify') || type.contains('verification')) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const TrainerPendingVerificationsScreen(),
        ),
      );
    } else if (type.contains('workout') || type.contains('assigned')) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const TrainerAssignedWorkoutsScreen(),
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
            icon: Icon(Icons.refresh, color: context.colors.icon),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                        final body = (item['body'] ??
                                item['message'] ??
                                item['description'] ??
                                '')
                            .toString();
                        final type = (item['type'] ??
                                item['notification_type'] ??
                                '')
                            .toString();
                        final timeStr = _formatNotificationTime(
                          item['created_at'] ?? item['timestamp'] ?? item['date'],
                        );
                        final isRead = item['is_read'] as bool? ?? false;
                        final color = _getColorForType(type);

                        return Material(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => _onNotificationTap(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isRead
                                      ? context.colors.border
                                      : color.withValues(alpha: 0.3),
                                  width: isRead ? 1.0 : 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
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
                                                style: AppStyles.text14Px.poppins
                                                    .w600
                                                    .copyWith(
                                                  color: context
                                                      .colors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (!isRead) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (body.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            body,
                                            style: AppStyles.text12Px.poppins
                                                .w400
                                                .copyWith(
                                              color: context
                                                  .colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                        if (timeStr.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            timeStr,
                                            style: AppStyles.text10Px.poppins
                                                .w400
                                                .copyWith(
                                              color: context
                                                  .colors.textSecondary
                                                  .withValues(alpha: 0.8),
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
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 46,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Notifications Yet',
                  style: AppStyles.text18Px.poppins.w600.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "You're all caught up! Updates, client activities, and session alerts will appear here.",
                  style: AppStyles.text13Px.poppins.w400.copyWith(
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
