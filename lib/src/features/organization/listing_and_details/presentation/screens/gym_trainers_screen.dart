import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_screen.dart';

class GymTrainersScreen extends StatefulWidget {
  const GymTrainersScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymTrainersScreen> createState() => _GymTrainersScreenState();
}

class _GymTrainersScreenState extends State<GymTrainersScreen> {
  List<Map<String, dynamic>> _trainers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.leadsListing,
        queryParameters: {'organization_id': widget.orgDetails.id},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (List<dynamic>.from(
                  (response.data as Map)['results'] as List? ?? [],
                ))
                : (response.data as List<dynamic>);

        final parsed =
            data.map((e) => Map<String, dynamic>.from(e as Map)).where((t) {
              final bool isActive = t['is_active'] as bool? ?? true;
              final bool isRemoved = t['is_removed'] as bool? ?? false;
              final String status =
                  (t['status'] as String? ?? '').toLowerCase();
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
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load trainers');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading trainers: ${e.toString()}');
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Remove Trainer',
          style: AppStyles.text16Px.poppins.w600,
        ),
        content: Text(
          'Are you sure you want to remove $name from this gym?\n\n'
          'The trainer will no longer have access to this gym\'s data (clients, workouts, reports), '
          'but all historical records will be preserved for reporting.',
          style: AppStyles.text14Px.poppins.w400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Remove',
              style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.removeTrainerFromGym(linkId),
        queryParameters: {
          if (widget.orgDetails.id != null)
            'organization_id': widget.orgDetails.id,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Dialogs.showSnack(msg: '$name removed successfully');
        if (mounted) {
          setState(() {
            _trainers.removeWhere(
              (t) =>
                  (t['link_id'] ?? t['id']) == linkId ||
                  t['id'] == trainer['id'] ||
                  (t['link_id'] != null && t['link_id'] == trainer['link_id']),
            );
            _isLoading = false;
          });
        }
        _fetchTrainers();
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to remove trainer');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error removing trainer: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final filteredTrainers =
        _trainers.where((trainer) {
          final name = (trainer['name'] as String? ?? '').toLowerCase();
          final first = (trainer['first_name'] as String? ?? '').toLowerCase();
          final last = (trainer['last_name'] as String? ?? '').toLowerCase();

          final dynamic mentorProfile = trainer['mentor_profile'];
          final loc =
              (trainer['location'] as String? ??
                      (mentorProfile != null && mentorProfile is Map
                          ? mentorProfile['location'] as String?
                          : null) ??
                      'Balussery')
                  .toLowerCase();

          return name.contains(_searchQuery.toLowerCase()) ||
              first.contains(_searchQuery.toLowerCase()) ||
              last.contains(_searchQuery.toLowerCase()) ||
              loc.contains(_searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: Text('Trainers', style: AppStyles.text16Px.poppins.w600),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (ctx) {
                    return SettingsScreen(
                      orgId: widget.orgDetails.id,
                      name: widget.orgDetails.name,
                      email: widget.orgDetails.email,
                      logoUrl: widget.orgDetails.logo,
                      orgDetailsCubit:
                          context.read<OrganizationListingAndDetailsCubit>(),
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search trainers...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffDDDDDD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffDDDDDD)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _searchQuery = value;
                      });
                      if (value.isEmpty) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 0,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder:
                              (context) => BlocProvider(
                                create:
                                    (context) => MembersAndLeadsCubit(
                                      orgId: widget.orgDetails.id ?? 0,
                                    ),
                                child: AddTrainerSearchScreen(
                                  orgId: widget.orgDetails.id ?? 0,
                                ),
                              ),
                        ),
                      );
                      _fetchTrainers();
                    },
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchTrainers,
              child: _isLoading
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const KShimmer(width: 48, height: 48, radius: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    KShimmer(width: 120, height: 14, radius: 4),
                                    SizedBox(height: 6),
                                    KShimmer(width: 80, height: 12, radius: 4),
                                  ],
                                ),
                              ),
                              const KShimmer(width: 20, height: 20, radius: 4),
                            ],
                          ),
                        );
                      },
                    )
                  : filteredTrainers.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No Trainers found!',
                                  style: AppStyles.text14Px.poppins.w400.dark,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredTrainers.length,
                          itemBuilder: (context, index) {
                            final trainer = filteredTrainers[index];
                            final String firstName =
                                trainer['first_name'] as String? ?? '';
                            final String lastName =
                                trainer['last_name'] as String? ?? '';
                            final String fallbackName =
                                '$firstName $lastName'.trim();
                            final String name =
                                trainer['name'] as String? ??
                                (fallbackName.isEmpty ? 'N/A' : fallbackName);
                            final String spec =
                                trainer['specialization'] as String? ?? '';
                            final String? profilePic =
                                trainer['profile_picture'] as String? ??
                                trainer['profile_image'] as String? ??
                                trainer['image_url'] as String?;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => TrainerMainProfileScreen(
                                      trainerId: trainer['id']?.toString(),
                                      isViewOnly: true,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.iconBackground,
                                        ),
                                        child: ClipOval(
                                          child:
                                              profilePic != null &&
                                                      profilePic.isNotEmpty
                                                  ? Image.network(
                                                    profilePic,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) => const Icon(
                                                          Icons.person,
                                                          color: AppColors.primary,
                                                        ),
                                                  )
                                                  : const Icon(
                                                    Icons.person,
                                                    color: AppColors.primary,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style:
                                                  AppStyles.text15Px.poppins.w600,
                                            ),
                                            if (spec.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                spec,
                                                style: AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w400
                                                    .copyWith(
                                                      color: AppColors.textDark,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        onSelected: (value) {
                                          if (value == 'remove') {
                                            _removeTrainer(trainer);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem<String>(
                                            value: 'remove',
                                            child: Row(
                                              children: [
                                                Icon(Icons.person_remove_outlined, color: Colors.red, size: 20),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Remove',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ).pad(16),
    );
  }
}


