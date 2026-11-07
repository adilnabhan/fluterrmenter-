import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/themes/app_colors.dart';
import 'package:mentor_mobile_app/core/themes/app_styles.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/core/widgets/profile_image.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/organization_details_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/all_trainers_summary_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/trainer_attendance_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_content_constraint.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_screen.dart';

class DesktopTrainersView extends StatefulWidget {
  const DesktopTrainersView({
    super.key,
    required this.orgDetails,
  });

  final OrganizationDetailsModel orgDetails;

  @override
  State<DesktopTrainersView> createState() => _DesktopTrainersViewState();
}

class _DesktopTrainersViewState extends State<DesktopTrainersView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _trainers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrainers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.leadsListing,
        queryParameters: {'organization_id': widget.orgDetails.id},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is Map)
            ? (List<dynamic>.from(
                (response.data as Map)['results'] as List? ?? [],
              ))
            : (response.data as List<dynamic>);

        final parsed =
            data.map((e) => Map<String, dynamic>.from(e as Map)).where((t) {
          final bool isActive = t['is_active'] as bool? ?? true;
          final bool isRemoved = t['is_removed'] as bool? ?? false;
          final String status = (t['status'] as String? ?? '').toLowerCase();
          return isActive &&
              !isRemoved &&
              status != 'removed' &&
              status != 'inactive';
        }).toList();

        if (!mounted) return;
        setState(() {
          _trainers = parsed;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeTrainer(Map<String, dynamic> trainer) async {
    final linkId = trainer['link_id'] ?? trainer['id'];
    final String firstName = trainer['first_name'] as String? ?? '';
    final String lastName = trainer['last_name'] as String? ?? '';
    final String fallbackName = '$firstName $lastName'.trim();
    final String name = trainer['name'] as String? ??
        (fallbackName.isEmpty ? 'this trainer' : fallbackName);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogCtx.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Trainer', style: AppStyles.text18Px.poppins.w600),
        content: Text(
          'Are you sure you want to remove $name from this gym?\n\n'
          'The trainer will no longer have access to this gym\'s data (clients, workouts, reports).',
          style: AppStyles.text14Px.poppins.w400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || linkId == null) return;

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.removeTrainerFromGym(linkId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Dialogs.showSnack(msg: '$name removed successfully');
        _fetchTrainers();
      } else {
        Dialogs.showSnack(msg: 'Failed to remove trainer');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error removing trainer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final filtered = _trainers.where((t) {
      final name = (t['name'] as String? ?? '').toLowerCase();
      final first = (t['first_name'] as String? ?? '').toLowerCase();
      final last = (t['last_name'] as String? ?? '').toLowerCase();
      final loc = (t['location'] as String? ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) ||
          first.contains(q) ||
          last.contains(q) ||
          loc.contains(q);
    }).toList();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: DesktopContentConstraint(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── Action Bar: Search, Stats, Add Trainer ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? context.colors.card : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search trainers by name or specialization...',
                      hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Attendance Button
                OutlinedButton.icon(
                  onPressed: () {
                    if (widget.orgDetails.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => TrainerAttendanceScreen(
                            orgId: widget.orgDetails.id!,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: const Text('Attendance Log'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Reports Button
                OutlinedButton.icon(
                  onPressed: () {
                    if (widget.orgDetails.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => AllTrainersSummaryScreen(
                            orgId: widget.orgDetails.id!,
                            initialDate: DateTime.now(),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.insights_rounded, size: 16),
                  label: const Text('Performance'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Trainer Cards Grid ──
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filtered.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_rounded,
                      size: 64,
                      color: context.colors.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No trainers added yet'
                          : 'No trainers match "$_searchQuery"',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth < 750
                    ? 1
                    : (constraints.maxWidth < 1200 ? 2 : 3);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 170,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final trainer = filtered[index];
                    return _DesktopTrainerCard(
                      trainer: trainer,
                      onTap: () {
                        final mentorProfile = trainer['mentor_profile'];
                        final int? trainerId = (mentorProfile != null && mentorProfile is Map)
                            ? mentorProfile['id'] as int?
                            : trainer['id'] as int?;

                        if (trainerId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => TrainerMainProfileScreen(
                                isViewOnly: true,
                                trainerId: trainerId.toString(),
                              ),
                            ),
                          );
                        }
                      },
                      onRemove: () => _removeTrainer(trainer),
                    );
                  },
                );
              },
            ),

          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
}

class _DesktopTrainerCard extends StatefulWidget {
  const _DesktopTrainerCard({
    required this.trainer,
    required this.onTap,
    required this.onRemove,
  });

  final Map<String, dynamic> trainer;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_DesktopTrainerCard> createState() => _DesktopTrainerCardState();
}

class _DesktopTrainerCardState extends State<_DesktopTrainerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trainer;
    final isDark = context.isDarkMode;

    final String firstName = t['first_name'] as String? ?? '';
    final String lastName = t['last_name'] as String? ?? '';
    final String fallbackName = '$firstName $lastName'.trim();
    final String name = t['name'] as String? ?? (fallbackName.isEmpty ? 'Trainer' : fallbackName);
    final String? profilePic = t['profile_picture'] as String? ?? t['photo'] as String?;
    final String? phone = t['mobile_number'] as String? ?? t['phone'] as String?;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isDark ? context.colors.card : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.primary : context.colors.border,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ProfileImage(
                    url: profilePic,
                    radius: 56,
                    isEdit: false,
                    name: name,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.text15Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (phone != null && phone.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: context.colors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                phone,
                                style: AppStyles.text12Px.poppins.w400.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active Trainer',
                            style: AppStyles.text10Px.poppins.w600.copyWith(
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: context.colors.textSecondary,
                    ),
                    onSelected: (val) {
                      if (val == 'view') widget.onTap();
                      if (val == 'remove') widget.onRemove();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 18),
                            SizedBox(width: 8),
                            Text('View Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                            SizedBox(width: 8),
                            Text('Remove', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

