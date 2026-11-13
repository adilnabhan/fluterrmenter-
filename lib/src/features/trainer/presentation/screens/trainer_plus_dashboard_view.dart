import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_plus_subscription_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_customers_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_pending_verifications_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_assigned_workouts_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_clients_trained_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reviews_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/client_attendance_screen.dart';

class TrainerPlusDashboardView extends StatefulWidget {
  final VoidCallback? onSwitchToStandard;

  const TrainerPlusDashboardView({
    super.key,
    this.onSwitchToStandard,
  });

  @override
  State<TrainerPlusDashboardView> createState() =>
      _TrainerPlusDashboardViewState();
}

class _TrainerPlusDashboardViewState extends State<TrainerPlusDashboardView> {
  static const Color brandRed = Color(0xFFC4161C);

  bool _isLoading = true;
  String _selectedGroupKey = 'all'; // 'all' or group ID string
  int? _selectedGroupId;

  List<Map<String, dynamic>> _groups = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _clients = [];
  String _clientsSubtitle = 'Gym members & independent';
  int _totalClientsCount = 0;
  bool _isPremium = true;

  @override
  void initState() {
    super.initState();
    _fetchPlusDashboardData();
  }

  Future<void> _fetchPlusDashboardData({int? groupId}) async {
    setState(() => _isLoading = true);

    try {
      final queryParams = <String, dynamic>{};
      if (groupId != null) {
        queryParams['group_id'] = groupId;
      }

      final res = await DioClient().dio.get<dynamic>(
        '${ApiUris.baseUrl}/api/v1/trainer/client-groups/dashboard/',
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (res.statusCode == 200 && res.data is Map) {
        final data = Map<String, dynamic>.from(res.data as Map);

        final rawGroups = (data['groups'] as List<dynamic>?) ?? [];
        final parsedGroups = rawGroups
            .map((g) => Map<String, dynamic>.from(g as Map))
            .toList();

        final rawStats = (data['stats'] as Map<String, dynamic>?) ?? {};
        final rawClients = (data['clients'] as List<dynamic>?) ?? [];
        final parsedClients = rawClients
            .map((c) => Map<String, dynamic>.from(c as Map))
            .toList();

        setState(() {
          _isPremium = data['is_premium'] == true;
          _groups = parsedGroups;
          _stats = rawStats;
          _clients = parsedClients;
          _selectedGroupId = groupId;
          _selectedGroupKey = groupId?.toString() ?? 'all';
          _clientsSubtitle = data['subtitle']?.toString() ??
              data['selected_group']?['subtitle']?.toString() ??
              'Gym members & independent';
          _totalClientsCount = (data['selected_group']?['clients_count'] as num? ??
                  parsedClients.length)
              .toInt();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching Plus dashboard: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateGroupDialog() async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'New Client Group',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Organize your clients into batches (e.g. Online, Strength, Morning Batch).',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Group name (e.g. Online)',
                filled: true,
                fillColor: const Color(0xFFF4F5FA),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop(name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final createRes = await DioClient().dio.post<dynamic>(
          '${ApiUris.baseUrl}/api/v1/trainer/client-groups/',
          data: {'name': result},
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
        if (createRes.statusCode == 201 || createRes.statusCode == 200) {
          Dialogs.showSnack(msg: 'Group "$result" created successfully!');
          _fetchPlusDashboardData();
        }
      } catch (e) {
        Dialogs.showSnack(msg: 'Failed to create group: $e');
      }
    }
  }

  Future<void> _showMoveClientSheet(Map<String, dynamic> client) async {
    final customerId = client['id'] ?? client['customer_id'];
    final clientName = client['name'] ?? client['full_name'] ?? 'Client';

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Move $clientName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the target group for this client:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 12),
                ..._groups
                    .where((g) => g['is_all'] != true && g['id'] != null)
                    .map((g) {
                  final gid = g['id'] as int;
                  final gname = g['name']?.toString() ?? 'Group';
                  final count = g['clients_count'] ?? 0;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.folder_outlined, color: brandRed),
                    title: Text(gname,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text('$count clients',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      try {
                        final moveRes = await DioClient().dio.post<dynamic>(
                          '${ApiUris.baseUrl}/api/v1/trainer/client-groups/move-client/',
                          data: {
                            'customer_id': customerId,
                            'target_group_id': gid,
                          },
                          options: Options(headers: {'X-Platform': platformSource})
                              .token,
                        );
                        if (moveRes.statusCode == 200) {
                          Dialogs.showSnack(
                            msg: '$clientName moved to $gname!',
                          );
                          _fetchPlusDashboardData(groupId: _selectedGroupId);
                        }
                      } catch (e) {
                        Dialogs.showSnack(msg: 'Failed to move client: $e');
                      }
                    },
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: brandRed),
      );
    }

    final activeClients = _stats['active_clients'] ?? 0;
    final pendingVerifications =
        _stats['pending_verifications_count'] ?? _stats['pending_verifications'] ?? 0;
    final assignedWorkouts =
        _stats['assigned_workouts_count'] ?? _stats['assigned_workouts'] ?? 0;
    final avgRating = _stats['average_rating']?.toString() ?? '4.8';
    final attendancePct = _stats['client_attendance']?.toString() ??
        _stats['attendance_percentage']?.toString() ??
        '86%';
    final clientsTrained =
        _stats['clients_trained_count'] ?? _stats['clients_trained'] ?? 0;

    final selectedGroupName = _groups.firstWhere(
      (g) => g['id'] == _selectedGroupId,
      orElse: () => {'name': 'All'},
    )['name'] ?? 'All';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: [ Plus ] pill switch + Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plus Badge Button (tappable to open subscription or settings)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => TrainerPlusSubscriptionScreen(
                        onSubscriptionSuccess: _fetchPlusDashboardData,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: brandRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: brandRed.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Plus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check_circle, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined,
                        color: Colors.black87),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.black87),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // "Your groups" header + "+ New group"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your groups',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              InkWell(
                onTap: _showCreateGroupDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: brandRed),
                      SizedBox(width: 4),
                      Text(
                        'New group',
                        style: TextStyle(
                          color: brandRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Horizontal Group Chips Row
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // "All" Chip
                _buildGroupChip(
                  keyId: 'all',
                  id: null,
                  label: 'All',
                  count: _groups.isNotEmpty
                      ? (_groups.firstWhere((g) => g['is_all'] == true,
                              orElse: () => {'clients_count': 60})['clients_count'] ??
                          60)
                      : 60,
                  isSelected: _selectedGroupId == null,
                ),
                const SizedBox(width: 8),

                // Dynamic group chips
                ..._groups.where((g) => g['is_all'] != true).map((g) {
                  final gid = g['id'] as int?;
                  final name = g['name']?.toString() ?? 'Group';
                  final count = g['clients_count'] ?? 0;
                  final isSelected = _selectedGroupId == gid;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildGroupChip(
                      keyId: gid.toString(),
                      id: gid,
                      label: name,
                      count: count,
                      isSelected: isSelected,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6 Stat Cards Grid (2 columns x 3 rows)
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Active Clients',
                  value: '$activeClients',
                  bgColor: const Color(0xFFDDE9FD),
                  textColor: const Color(0xFF1E3A8A),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) => const TrainerCustomersScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Pending Verifications',
                  value: '$pendingVerifications',
                  bgColor: const Color(0xFFFFE0E0),
                  textColor: brandRed,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) =>
                            const TrainerPendingVerificationsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Assigned Workouts',
                  value: '$assignedWorkouts',
                  bgColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                  hasBorder: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) =>
                            const TrainerAssignedWorkoutsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Average Rating',
                  value: '$avgRating',
                  bgColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                  hasBorder: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) => const TrainerReviewsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Client Attendance',
                  value: attendancePct.endsWith('%') ? attendancePct : '$attendancePct%',
                  bgColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                  hasBorder: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) => const ClientAttendanceScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Clients Trained',
                  value: '$clientsTrained',
                  bgColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                  hasBorder: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) =>
                            const TrainerClientsTrainedScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // "Clients in <Group>" section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clients in $selectedGroupName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _clientsSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const TrainerCustomersScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: brandRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Add client',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Client List Items
          if (_clients.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Center(
                child: Text(
                  'No clients in this group yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ..._clients.take(4).map((client) => _buildClientRow(client)),

          const SizedBox(height: 14),

          // "View all X clients ->"
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const TrainerCustomersScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'View all ${_totalClientsCount > 0 ? _totalClientsCount : _clients.length} clients',
                    style: const TextStyle(
                      color: brandRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, color: brandRed, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGroupChip({
    required String keyId,
    required int? id,
    required String label,
    required dynamic count,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _fetchPlusDashboardData(groupId: id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? brandRed : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$count clients',
              style: TextStyle(
                color: isSelected ? Colors.white70 : const Color(0xFF888888),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color textColor,
    bool hasBorder = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: hasBorder ? Border.all(color: const Color(0xFFE5E7EB)) : null,
          boxShadow: [
            if (!hasBorder)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.85),
                    height: 1.15,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 24,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientRow(Map<String, dynamic> client) {
    final String name = (client['name'] ?? client['full_name'] ?? 'Client').toString();
    final String? avatarStr = client['avatar']?.toString() ?? client['profile_picture']?.toString();
    final bool hasAvatar = avatarStr != null && avatarStr.isNotEmpty;
    final String type = client['client_type']?.toString().toLowerCase() == 'independent'
        ? 'Independent'
        : 'Gym member';
    final String status = client['status']?.toString() ?? 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF2F4F7),
            backgroundImage: hasAvatar ? NetworkImage(avatarStr) : null,
            child: hasAvatar
                ? null
                : const Icon(Icons.person, color: Colors.grey, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$type • $status',
                  style: TextStyle(
                    fontSize: 11,
                    color: status == 'Active' ? const Color(0xFF6B7280) : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          // "Move v" Button
          InkWell(
            onTap: () => _showMoveClientSheet(client),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Move',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF374151)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
