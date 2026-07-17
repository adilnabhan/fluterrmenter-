import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/account_switcher_sheet.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/organization_workout_library_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  const OrganizationDetailsScreen({
    required this.orgId,
    super.key,
    this.canFetch = true,
  });

  final int orgId;
  final bool canFetch;

  @override
  State<OrganizationDetailsScreen> createState() =>
      _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final OrganizationListingAndDetailsCubit _cubit;
  final PageController _heroPagerController = PageController();
  int _heroCurrentIndex = 0;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    if (widget.canFetch) {
      _fetch();
    }
  }

  @override
  void dispose() {
    _heroPagerController.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool isRefresh = false}) async {
    await _cubit.fetchDetails(orgId: widget.orgId, isRefresh: isRefresh);
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;
    final userName = '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim();
    final displayName = userName.isNotEmpty ? userName : 'Owner Profile';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: BlocBuilder<
        OrganizationListingAndDetailsCubit,
        OrganizationListingAndDetailsState
      >(
        builder: (context, state) {
          return state.details.fold(
            () {
              return const Center(child: CircularProgressIndicator());
            },
            (either) {
              return either.fold(
                (error) =>
                    error
                        .maybeWhen(
                          network: (e) => ErrorUi.network(onTap: () => _fetch()),
                          notFound: (e) => ErrorUi.notFound(onTap: () => _fetch()),
                          orElse: () => ErrorUi.server(onTap: () => _fetch()),
                        )
                        .center,
                (orgDetails) {
                  return RefreshIndicator(
                    onRefresh: () => _fetch(isRefresh: true),
                    child: _buildContent(orgDetails, displayName),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    OrganizationDetailsModel orgDetails,
    String displayName,
  ) {
    final photos = orgDetails.photos ?? [];
    final heroImages =
        photos
            .where((p) => p.image != null && p.image!.isNotEmpty)
            .map((p) => p.image!)
            .toList();

    // Fallback if no gallery photos
    if (heroImages.isEmpty && orgDetails.logo != null) {
      heroImages.add(orgDetails.logo!);
    }

    final categories = orgDetails.categories ?? [];
    final amenities = orgDetails.amenities ?? [];
    final location = orgDetails.location;
    final locationStr = [
      location?.city,
      location?.state,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Hero Image Carousel ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (heroImages.isNotEmpty)
                      PageView.builder(
                        controller: _heroPagerController,
                        itemCount: heroImages.length,
                        onPageChanged:
                            (i) => setState(() => _heroCurrentIndex = i),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              context.push(
                                GalleryViewScreen(
                                  orgDetails: orgDetails,
                                  initialIndex: index,
                                  cubit: _cubit,
                                ),
                              );
                            },
                            child: Image.network(
                              heroImages[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (_, child, progress) =>
                                      progress == null
                                          ? child
                                          : Container(
                                            color: Colors.grey.shade200,
                                          ),
                              errorBuilder:
                                  (_, __, ___) =>
                                      Container(color: Colors.grey.shade300),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFFF7F8FA).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top bar buttons
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Title + Dropdown (Glassmorphism Pill)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Material(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    child: InkWell(
                                      onTap: () {
                                        const AccountSwitcherSheet().show(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              orgDetails.name ?? displayName,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Right: Share & Settings (Glassmorphism Circles)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Material(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        child: InkWell(
                                          onTap: () {
                                            Dialogs.showSnack(
                                              msg: 'Share coming soon!',
                                            );
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.shortcut,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Material(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SettingsScreen(
                                                  orgId: orgDetails.id,
                                                  name: orgDetails.name,
                                                  email: orgDetails.email,
                                                  logoUrl: orgDetails.logo,
                                                  orgDetailsCubit: _cubit,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.settings_outlined,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Dot indicators
                    if (heroImages.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(heroImages.length, (i) {
                            final isActive = i == _heroCurrentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? AppColors.primary
                                        : Colors.grey.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Section 2: Overlapping Profile Card ──
              Positioned(
                bottom: -55,
                left: 16,
                right: 16,
                child: _buildProfileCard(orgDetails),
              ),
            ],
          ),
          const SizedBox(height: 68),

          // ── Section 3: About Section ──
          _buildAboutSection(orgDetails, categories, locationStr),

          // ── Section 4: Amenities & Schedule Tabs ──
          const SizedBox(height: 16),
          _buildAmenitiesAndScheduleTabs(orgDetails, amenities),

          // ── Section 8: Transformation Section ──
          const SizedBox(height: 16),
          _buildTransformationSection(orgDetails),

          // ── Section 8.5: Ratings & Reviews ──
          if (orgDetails.id != null) ...[
            const SizedBox(height: 16),
            _OrganizationReviewsWidget(orgId: orgDetails.id!),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Profile Card
  // ────────────────────────────────────────────
  Widget _buildProfileCard(OrganizationDetailsModel orgDetails) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Org Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: orgDetails.logo != null && orgDetails.logo!.isNotEmpty
                ? Image.network(
                    orgDetails.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  )
                : const Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                    size: 40,
                  ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Name + Edit icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        orgDetails.name ?? 'Organization',
                        style: AppStyles.text16Px.poppins.w600.dark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              orgId: orgDetails.id,
                              name: orgDetails.name,
                              email: orgDetails.email,
                              logoUrl: orgDetails.logo,
                              orgDetailsCubit: _cubit,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F3F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Coaches
                    Column(
                      children: [
                        Text(
                          orgDetails.trainersCount?.toString() ?? '0',
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                        Text(
                          'Trainers',
                          style: AppStyles.text10Px.poppins.w500.textGrey,
                        ),
                      ],
                    ),
                    // Members
                    Column(
                      children: [
                        Text(
                          orgDetails.membersCount?.toString() ?? '0',
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                        Text(
                          'Members',
                          style: AppStyles.text10Px.poppins.w500.textGrey,
                        ),
                      ],
                    ),
                    // Rating
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFB800), // Gold/Yellow star
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              orgDetails.rating?.toString() ?? '0.0',
                              style: AppStyles.text13Px.poppins.w600.dark,
                            ),
                            Text(
                              '(${orgDetails.ratingCount ?? 0})',
                              style: AppStyles.text10Px.poppins.w400.dark,
                            ),
                          ],
                        ),
                        Text(
                          'Rating',
                          style: AppStyles.text10Px.poppins.w500.textGrey,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Social Media Row
  // ────────────────────────────────────────────
  Widget _buildSocialMediaRow(OrganizationDetailsModel orgDetails) {
    final socialItems = <({String svg, String? url})>[];

    if (orgDetails.instagram?.url != null) {
      socialItems.add((
        svg: 'assets/images/svg/icons/instagram.svg',
        url: orgDetails.instagram!.url,
      ));
    }
    if (orgDetails.facebook?.url != null) {
      socialItems.add((
        svg: 'assets/images/svg/icons/fb.svg',
        url: orgDetails.facebook!.url,
      ));
    }
    if (orgDetails.youtube?.url != null) {
      socialItems.add((
        svg: 'assets/images/svg/icons/yt.svg',
        url: orgDetails.youtube!.url,
      ));
    }

    if (socialItems.isEmpty) return const SizedBox.shrink();

    return Row(
      children:
          socialItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (item.url != null && item.url!.isNotEmpty) {
                    _launchUrl(item.url!);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      item.svg,
                      width: 20,
                      height: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // ────────────────────────────────────────────
  // About Section
  // ────────────────────────────────────────────
  Widget _buildAboutSection(
    OrganizationDetailsModel orgDetails,
    List<AmenityModel> categories,
    String locationStr,
  ) {
    if (categories.isEmpty &&
        locationStr.isEmpty &&
        (orgDetails.description == null || orgDetails.description!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags
            if (categories.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    categories.map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.name ?? '',
                          style: AppStyles.text13Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Location
            if (locationStr.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SvgPicture.asset(
                      'assets/images/svg/icons/location.svg',
                      width: 16,
                      height: 16,
                      color: const Color(0xFF5F8265),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationStr,
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Description
            if (orgDetails.description != null &&
                orgDetails.description!.isNotEmpty) ...[
              _ReadMoreText(text: orgDetails.description!),
              const SizedBox(height: 20),
            ],

            // Social Media
            _buildSocialMediaRow(orgDetails),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // Amenities & Schedule Tabs
  // ────────────────────────────────────────────
  Widget _buildAmenitiesAndScheduleTabs(
    OrganizationDetailsModel orgDetails,
    List<AmenityModel> amenities,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs row
          Transform.translate(
            offset: const Offset(0, 1),
            child: Row(
              children: [
                Expanded(child: _buildCustomTab('Amenities', 0)),
                Expanded(child: _buildCustomTab('Schedule', 1)),
              ],
            ),
          ),
          // Content container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft:
                    _selectedTabIndex == 0
                        ? Radius.zero
                        : const Radius.circular(20),
                topRight:
                    _selectedTabIndex == 1
                        ? Radius.zero
                        : const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                _selectedTabIndex == 0
                    ? _buildAmenitiesGrid(amenities)
                    : _ScheduleTabView(orgDetails: orgDetails),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: isSelected ? Border(
            top: BorderSide(color: Colors.grey.shade200),
            left: BorderSide(color: Colors.grey.shade200),
            right: BorderSide(color: Colors.grey.shade200),
          ) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppStyles.text14Px.poppins.copyWith(
              color: isSelected ? AppColors.textDark : AppColors.textGrey,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesGrid(List<AmenityModel> amenities) {
    if (amenities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No amenities added yet'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final itemWidth = (constraints.maxWidth - (spacing * 3)) / 4;

          return Wrap(
            spacing: spacing,
            runSpacing: 24,
            children:
                amenities.map((amenity) {
                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                          child: Icon(
                            _getAmenityIcon(amenity.name ?? ''),
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          amenity.name ?? '',
                          textAlign: TextAlign.center,
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  IconData _getAmenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wifi') || lower.contains('wi-fi')) {
      return Icons.wifi;
    }
    if (lower.contains('elevator') || lower.contains('lift')) {
      return Icons.elevator;
    }
    if (lower.contains('locker')) return Icons.lock_outline;
    if (lower.contains('ac') || lower.contains('air')) {
      return Icons.ac_unit;
    }
    if (lower.contains('cctv') || lower.contains('camera')) {
      return Icons.videocam_outlined;
    }
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('shower')) return Icons.shower;
    if (lower.contains('steam') || lower.contains('sauna')) {
      return Icons.hot_tub;
    }
    if (lower.contains('pool') || lower.contains('swimming')) {
      return Icons.pool;
    }
    if (lower.contains('water') || lower.contains('drink')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('cardio')) return Icons.favorite_border;
    if (lower.contains('yoga') || lower.contains('meditation')) {
      return Icons.self_improvement;
    }
    if (lower.contains('cafe') || lower.contains('juice')) {
      return Icons.local_cafe;
    }
    if (lower.contains('towel')) return Icons.dry_cleaning;
    return Icons.check_circle_outline;
  }

  // Replaced by _ScheduleTabView
  // End of old schedule view

  // ────────────────────────────────────────────
  // Transformation (Before / After)
  // ────────────────────────────────────────────
  Widget _buildTransformationSection(OrganizationDetailsModel orgDetails) {
    // Temporarily pass empty list until the transformation API is available
    return const _TransformationCarousel(photos: []);
  }


}

class _TransformationCarousel extends StatefulWidget {
  final List<PhotoModel> photos;
  const _TransformationCarousel({required this.photos});

  @override
  State<_TransformationCarousel> createState() =>
      _TransformationCarouselState();
}

class _TransformationCarouselState extends State<_TransformationCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    int pageCount = (widget.photos.length / 2).ceil();
    if (pageCount == 0) pageCount = 1; // Always show at least 1 empty page

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: pageCount,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final beforeIdx = index * 2;
              final afterIdx = index * 2 + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTransformImage(
                        widget.photos.length > beforeIdx
                            ? widget.photos[beforeIdx].image
                            : null,
                        'Add Before',
                        isBefore: true,
                      ),
                    ),
                    Container(width: 2, color: Colors.white),
                    Expanded(
                      child: _buildTransformImage(
                        widget.photos.length > afterIdx
                            ? widget.photos[afterIdx].image
                            : null,
                        'Add After',
                        isBefore: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageCount, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentPage == index
                        ? AppColors.primary
                        : const Color(0xFFE5E5E5),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTransformImage(
    String? imageUrl,
    String fallbackText, {
    required bool isBefore,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius:
            isBefore
                ? const BorderRadius.horizontal(left: Radius.circular(16))
                : const BorderRadius.horizontal(right: Radius.circular(16)),
        image:
            imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child: Stack(
        children: [
          // Fallback + icon
          if (imageUrl == null || imageUrl.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.grey, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    fallbackText,
                    textAlign: TextAlign.center,
                    style: AppStyles.text13Px.poppins.w600.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          // Pill
          Positioned(
            top: 12,
            left: isBefore ? 12 : null,
            right: !isBefore ? 12 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isBefore ? 'Before' : 'After',
                style: AppStyles.text13Px.poppins.w500.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTabView extends StatefulWidget {
  final OrganizationDetailsModel orgDetails;
  const _ScheduleTabView({required this.orgDetails});

  @override
  State<_ScheduleTabView> createState() => _ScheduleTabViewState();
}

class _ScheduleTabViewState extends State<_ScheduleTabView> {
  int _selectedDayIndex = -1;

  @override
  void initState() {
    super.initState();
    final workingDays = widget.orgDetails.workingDays ?? [];
    _selectedDayIndex = workingDays.indexWhere((d) => d.isOpen == true);
    if (_selectedDayIndex == -1 && workingDays.isNotEmpty) {
      _selectedDayIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workingDays = widget.orgDetails.workingDays ?? [];
    if (workingDays.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No schedule added yet')),
      );
    }

    final selectedDay =
        _selectedDayIndex >= 0 && _selectedDayIndex < workingDays.length
            ? workingDays[_selectedDayIndex]
            : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days Wrap
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children:
                workingDays.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final day = entry.value;
                  final isOpen = day.isOpen ?? false;
                  final isSelected = idx == _selectedDayIndex;

                  final displayDay =
                      (day.day != null && day.day!.length > 3)
                          ? day.day!.substring(0, 3)
                          : (day.day ?? '');

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDayIndex = idx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOpen
                                ? (isSelected
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(
                                      0xFFDCFCE7,
                                    ).withValues(alpha: 0.4))
                                : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        displayDay,
                        style: AppStyles.text13Px.poppins.w500.copyWith(
                          color:
                              isOpen
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),

          if (selectedDay != null) ...[
            if (selectedDay.isOpen != true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Closed on this day',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else ...[
              _buildTimeSection(
                'Morning',
                selectedDay.morningOpeningTime,
                selectedDay.morningClosingTime,
              ),
              _buildTimeSection(
                'Evening',
                selectedDay.eveningOpeningTime,
                selectedDay.eveningClosingTime,
              ),
              _buildTimeSection(
                'Ladies Batch Evening',
                selectedDay.ladiesOpeningTime,
                selectedDay.ladiesClosingTime,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, String? openTime, String? closeTime) {
    if (openTime == null ||
        openTime.isEmpty ||
        closeTime == null ||
        closeTime.isEmpty) {
      return const SizedBox.shrink();
    }

    String formatTime(String time) {
      try {
        if (time.length > 5) {
          final parsed = DateFormat('HH:mm:ss').parse(time);
          return DateFormat('hh:mm a').format(parsed);
        }
        return time;
      } catch (e) {
        return time;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTimeBox(formatTime(openTime))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeBox(formatTime(closeTime))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: AppStyles.text13Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const Icon(Icons.access_time, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

class _OrganizationReviewsWidget extends StatefulWidget {
  final int orgId;

  const _OrganizationReviewsWidget({required this.orgId});

  @override
  State<_OrganizationReviewsWidget> createState() => _OrganizationReviewsWidgetState();
}

class _OrganizationReviewsWidgetState extends State<_OrganizationReviewsWidget> {
  bool _isLoading = true;
  String? _error;
  int _reviewCount = 0;
  double _avgRating = 0.0;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  String _period = 'latest';

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.fcOrganizationReviews,
        queryParameters: {
          'organization_id': widget.orgId,
          if (_period != 'latest') 'period': _period,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final Map<String, dynamic> data = responseData.containsKey('results') && responseData['results'] is Map 
            ? responseData['results'] as Map<String, dynamic> 
            : responseData;
            
        setState(() {
          _reviewCount = data['review_count'] as int? ?? 0;
          _avgRating = (data['avg_rating'] as num?)?.toDouble() ?? 0.0;
          _reviews = data['reviews'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load reviews';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading reviews: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildStars(double rating, {double size = 20}) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: size);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rating & Reviews',
                style: AppStyles.text18Px.poppins.w600.copyWith(color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _period,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    style: AppStyles.text13Px.poppins.w500.copyWith(color: AppColors.textDark),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _period) {
                        _period = newValue;
                        _fetchReviews();
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'latest', child: Text('Latest')),
                      DropdownMenuItem(value: 'last_3_months', child: Text('Last 3 Months')),
                      DropdownMenuItem(value: 'last_6_months', child: Text('Last 6 Months')),
                      DropdownMenuItem(value: 'last_12_months', child: Text('Last 12 Months')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _avgRating.toStringAsFixed(1),
                style: AppStyles.text24Px.poppins.w700.copyWith(color: AppColors.textDark, fontSize: 32),
              ),
              const SizedBox(width: 12),
              _buildStars(_avgRating, size: 28),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$_reviewCount Reviews',
            style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          ..._reviews.map((r) {
            final review = r as Map<String, dynamic>;
            final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
            final createdStr = review['created'] as String? ?? '';
            String formattedDate = createdStr;
            try {
               final dt = DateTime.parse(createdStr);
               formattedDate = dt.ddMMMYYYY;
            } catch (_) {}

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: review['profile_picture'] as String? ?? '',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['customer_name'] as String? ?? 'User',
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                            ),
                            Text(
                              formattedDate,
                              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review['comment'] as String? ?? '',
                    style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textDark, height: 1.5),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _ReadMoreText extends StatefulWidget {
  final String text;
  const _ReadMoreText({required this.text});

  @override
  State<_ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<_ReadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final style = AppStyles.text13Px.poppins.w400.copyWith(
      color: AppColors.textDark,
      height: 1.5,
    );

    return LayoutBuilder(
      builder: (context, size) {
        final span = TextSpan(text: widget.text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: 3,
          textDirection: Directionality.of(context),
        );
        tp.layout(maxWidth: size.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: style,
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Read less' : 'Read more',
                  style: AppStyles.text13Px.poppins.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Text(widget.text, style: style);
        }
      },
    );
  }
}
