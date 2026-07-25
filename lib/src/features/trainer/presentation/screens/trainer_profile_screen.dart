import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/account_switcher_sheet.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_settings_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/edit_trainer_profile_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_certificates_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_portfolio_screen.dart';

import 'package:mentor_mobile_app/src/features/auth/login/domain/models/login_with_otp_model.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainerMainProfileScreen extends StatefulWidget {
  final String? trainerId;
  final bool isViewOnly;

  const TrainerMainProfileScreen({
    this.trainerId,
    this.isViewOnly = false,
    super.key,
  });

  @override
  State<TrainerMainProfileScreen> createState() =>
      _TrainerMainProfileScreenState();
}

class _TrainerMainProfileScreenState extends State<TrainerMainProfileScreen> {
  final PageController _heroPagerController = PageController();
  int _heroCurrentIndex = 0;
  bool _isLoading = false;
  LoginSuccessModel? _fetchedUser;

  List<Map<String, dynamic>> _reviews = [];
  int _reviewsCount = 0;
  double _averageRating = 0.0;
  bool _isLoadingReviews = false;

  List<Map<String, dynamic>> _transformations = [];
  bool _isLoadingTransformations = false;
  final PageController _transformationPageController = PageController();
  int _transformationCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isViewOnly && widget.trainerId != null) {
      _fetchTrainerDetails();
    }
    _fetchReviews();
    _fetchPortfolioImages();
    _fetchTransformations();
  }

  Future<void> _fetchTransformations() async {
    if (!mounted) return;
    setState(() => _isLoadingTransformations = true);
    try {
      final uri =
          (widget.isViewOnly && widget.trainerId != null)
              ? '${ApiUris.transformations}?trainer_id=${widget.trainerId}'
              : ApiUris.transformations;
      final res = await DioClient().dio.get(uri);
      if (res.statusCode == 200) {
        final data = res.data;
        if (data is List) {
          final mapped =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (mounted) {
            setState(() {
              _transformations = mapped;
              _isLoadingTransformations = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => _isLoadingTransformations = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTransformations = false);
    }
  }

  Future<void> _fetchPortfolioImages() async {
    try {
      final uri =
          (widget.isViewOnly && widget.trainerId != null)
              ? '${ApiUris.portfolioImages}?trainer_id=${widget.trainerId}'
              : ApiUris.portfolioImages;
      final response = await DioClient().dio.get<dynamic>(uri);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          final mapped =
              data.map((e) {
                if (e is Map<String, dynamic>) {
                  return PortfolioImageModel.fromJson(e);
                }
                return const PortfolioImageModel();
              }).toList();
          if (mounted) {
            if (!widget.isViewOnly) {
              final appCubit = context.read<AppCubit>();
              final currentUser = appCubit.state.currentUser;
              if (currentUser != null) {
                final updatedUser = currentUser.copyWith(
                  trainer:
                      currentUser.trainer?.copyWith(portfolioImages: mapped) ??
                      TrainerModel(portfolioImages: mapped),
                );
                appCubit.addUser(updatedUser);
              }
            } else {
              setState(() {
                if (_fetchedUser != null) {
                  _fetchedUser = _fetchedUser!.copyWith(
                    trainer:
                        _fetchedUser!.trainer?.copyWith(
                          portfolioImages: mapped,
                        ) ??
                        TrainerModel(portfolioImages: mapped),
                  );
                }
              });
            }
          }
        }
      }
    } catch (e) {
      // Silently fail or log
    }
  }

  Future<void> _fetchReviews() async {
    if (!mounted) return;
    setState(() => _isLoadingReviews = true);
    try {
      final uri =
          (widget.isViewOnly && widget.trainerId != null)
              ? '${ApiUris.trainerReviews}?trainer_id=${widget.trainerId}'
              : ApiUris.trainerReviews;
      final res = await DioClient().dio.get(uri);
      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map) {
          final results = data['results'] as List? ?? [];
          final count = data['count'] as int? ?? 0;
          final mappedReviews =
              results.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          double avg = 0.0;
          if (mappedReviews.isNotEmpty) {
            double sum = 0.0;
            for (var r in mappedReviews) {
              sum += (r['rating'] as num?)?.toDouble() ?? 0.0;
            }
            avg = sum / mappedReviews.length;
          }

          if (!mounted) return;
          setState(() {
            _reviews = mappedReviews;
            _reviewsCount = count;
            _averageRating = avg;
            _isLoadingReviews = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() => _isLoadingReviews = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _fetchTrainerDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get(
        ApiUris.leadDetails(widget.trainerId!),
      );
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final mentorData =
            data['mentor_profile'] is Map
                ? data['mentor_profile'] as Map<String, dynamic>
                : null;

        final certsRaw =
            data['certificates'] is List ? data['certificates'] as List : [];
        final mappedCerts =
            certsRaw.map((e) {
              if (e is Map<String, dynamic>) {
                return CertificateModel.fromJson(e);
              }
              return const CertificateModel();
            }).toList();

        final portfolioRaw =
            data['portfolio_images'] is List
                ? data['portfolio_images'] as List
                : [];
        final mappedPortfolio =
            portfolioRaw.map((e) {
              if (e is Map<String, dynamic>) {
                return PortfolioImageModel.fromJson(e);
              }
              return const PortfolioImageModel();
            }).toList();

        final fetched = LoginSuccessModel(
          id: data['id'] as int?,
          firstName: data['first_name']?.toString(),
          lastName: data['last_name']?.toString(),
          profilePicture: data['profile_picture'],
          bio:
              data['bio']?.toString() ??
              mentorData?['experience']?.toString() ??
              mentorData?['designation']?.toString() ??
              '',
          location: data['location']?.toString(),
          instagram: data['instagram']?.toString(),
          facebook: data['facebook']?.toString(),
          youtube: data['youtube']?.toString(),
          trainer: TrainerModel(
            certificates: mappedCerts,
            portfolioImages: mappedPortfolio,
            clientsCount: data['clients_count'] as int?,
            verifiedWorkoutsCount: data['verified_workouts_count'] as int?,
          ),
          mentor: Mentor(
            org: Org(name: mentorData?['organization']?['name']?.toString()),
          ),
        );

        if (!mounted) return;
        setState(() {
          _fetchedUser = fetched;
          _isLoading = false;

          final ratingVal =
              data['avg_rating'] ?? data['average_rating'] ?? data['rating'];
          if (ratingVal != null) {
            _averageRating =
                (ratingVal is num)
                    ? ratingVal.toDouble()
                    : double.tryParse(ratingVal.toString()) ?? 0.0;
          }

          final countVal = data['review_count'] ?? data['reviews_count'];
          if (countVal != null) {
            _reviewsCount =
                (countVal is num)
                    ? countVal.toInt()
                    : int.tryParse(countVal.toString()) ?? 0;
          }

          if (data['reviews'] is List) {
            _reviews =
                (data['reviews'] as List)
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
            if (countVal == null) {
              _reviewsCount = _reviews.length;
            }
          }
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Failed to load trainer details.');
    }
  }

  Future<void> _handleRefresh() async {
    _fetchPortfolioImages();
    if (widget.isViewOnly && widget.trainerId != null) {
      await _fetchTrainerDetails();
      return;
    }

    final appCubit = context.read<AppCubit>();
    final currentUser = appCubit.state.currentUser;
    final trainerId = currentUser?.trainer?.id?.toString();

    if (trainerId == null) {
      // Fallback: If trainer ID is missing, just finish refresh.
      return;
    }

    try {
      // Use the trainer's own basic details endpoint instead of the mentor endpoint
      final res = await DioClient().dio.get(ApiUris.editTrainerBasicDetails);
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;

        final portfolioRaw =
            data['portfolio_images'] is List
                ? data['portfolio_images'] as List
                : [];
        final mappedPortfolio =
            portfolioRaw.map((e) {
              if (e is Map<String, dynamic>) {
                return PortfolioImageModel.fromJson(e);
              }
              return const PortfolioImageModel();
            }).toList();

        final updatedUser = currentUser!.copyWith(
          firstName: data['first_name']?.toString() ?? currentUser.firstName,
          lastName: data['last_name']?.toString() ?? currentUser.lastName,
          profilePicture:
              data['profile_picture']?.toString() ?? currentUser.profilePicture,
          bio: data['bio']?.toString() ?? currentUser.bio,
          location: data['location']?.toString() ?? currentUser.location,
          instagram: data['instagram']?.toString() ?? currentUser.instagram,
          facebook: data['facebook']?.toString() ?? currentUser.facebook,
          youtube: data['youtube']?.toString() ?? currentUser.youtube,
          trainer:
              currentUser.trainer?.copyWith(
                clientsCount: data['clients_count'] as int?,
                verifiedWorkoutsCount: data['verified_workouts_count'] as int?,
                portfolioImages: mappedPortfolio,
              ) ??
              TrainerModel(
                clientsCount: data['clients_count'] as int?,
                verifiedWorkoutsCount: data['verified_workouts_count'] as int?,
                portfolioImages: mappedPortfolio,
              ),
        );

        appCubit.addUser(updatedUser);
        Dialogs.showSnack(msg: 'Profile refreshed!');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to refresh profile.');
    }
  }

  static const List<String> _heroImages = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1470&auto=format&fit=crop',
  ];

  @override
  void dispose() {
    _heroPagerController.dispose();
    super.dispose();
  }

  void _openFullScreen(
    BuildContext context,
    int initialIndex,
    LoginSuccessModel? user,
  ) {
    final portfolioImages = user?.trainer?.portfolioImages;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (_) => TrainerPortfolioScreen(
              heroImages: _heroImages,
              initialIndex: initialIndex,
              isViewOnly: widget.isViewOnly,
              initialPortfolioImages: portfolioImages,
              trainerId: widget.trainerId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isViewOnly && _isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF7F7F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user =
        widget.isViewOnly
            ? _fetchedUser
            : context.watch<AppCubit>().state.currentUser;

    final trainerName =
        '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim();
    final displayName =
        trainerName.isNotEmpty ? trainerName : 'Trainer Profile';

    final portfolioImages = user?.trainer?.portfolioImages ?? [];
    final heroCarousel =
        portfolioImages.isNotEmpty
            ? portfolioImages
                .map((e) => e.image ?? '')
                .where((img) => img.isNotEmpty)
                .toList()
            : _heroImages;
    if (heroCarousel.isEmpty) heroCarousel.addAll(_heroImages);

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      floatingActionButton:
          widget.isViewOnly
              ? null
              : FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Dialogs.showSnack(msg: "Add action coming soon!");
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.add, color: Colors.white),
              ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero image + overlapping profile card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Hero image carousel
                  SizedBox(
                    height: 320,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _heroPagerController,
                          itemCount: heroCarousel.length,
                          onPageChanged:
                              (i) => setState(() => _heroCurrentIndex = i),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap:
                                  () => _openFullScreen(context, index, user),
                              child: Image.network(
                                heroCarousel[index],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (_, child, progress) =>
                                        progress == null
                                            ? child
                                            : Container(
                                              color: Colors.grey.shade900,
                                            ),
                              ),
                            );
                          },
                        ),
                        // Subtle gradient at the very bottom edge
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
                                  const Color(
                                    0xffF7F7F7,
                                  ).withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top bar (Account switcher + Settings)
                        if (!widget.isViewOnly)
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
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.8),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            const AccountSwitcherSheet().show(
                                              context,
                                            );
                                          },
                                          label: const Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                            color: Color(0xff222222),
                                            size: 20,
                                          ),
                                          icon: Text(
                                            '$displayName (Trainer)',
                                            style: AppStyles
                                                .text14Px
                                                .poppins
                                                .w600
                                                .copyWith(
                                                  color: const Color(
                                                    0xff222222,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    CircleAvatar(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.8,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.settings,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const TrainerProfileSettingsScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            top: 0,
                            left: 0,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: .8,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Dot indicators with pill background
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(heroCarousel.length, (
                                  i,
                                ) {
                                  final isActive = i == _heroCurrentIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: isActive ? 16 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color:
                                          isActive
                                              ? Colors.white
                                              : Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile card overlapping the image
                  Positioned(
                    bottom: -60,
                    left: 16,
                    right: 16,
                    child: _buildProfileCard(user),
                  ),
                ],
              ),
              const SizedBox(height: 76),
              // Rest of the content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildTagsAndDescriptionCard(user),
                    const SizedBox(height: 16),
                    _buildTransformationCard(),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TrainerCertificatesScreen(
                                  trainerId: widget.trainerId,
                                  isViewOnly: widget.isViewOnly,
                                  initialCertificates:
                                      widget.isViewOnly
                                          ? null
                                          : user?.trainer?.certificates,
                                ),
                          ),
                        );
                      },
                      child: _buildCertificatesButton(),
                    ),
                    const SizedBox(height: 16),
                    _buildReviewsSection(
                      _reviews,
                      _reviewsCount,
                      _averageRating,
                      _isLoadingReviews,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      user?.profilePicture?.toString().isNotEmpty == true
                          ? Image.network(
                            user!.profilePicture!.toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          )
                          : const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName ?? "Praveen"} ${user?.lastName ?? "K"}',
                      style: AppStyles.text18Px.poppins.w600,
                    ),
                    Text(
                      'Trainer',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          '${user?.trainer?.clientsCount ?? 0}',
                          'Clients',
                        ),
                        _buildStatItem(
                          '${user?.trainer?.verifiedWorkoutsCount ?? 0}',
                          'Verified\nWorkouts',
                        ),
                        _buildStatItem(
                          _averageRating.toStringAsFixed(1),
                          'Rating',
                          isRating: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.isViewOnly)
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditTrainerProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isRating = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRating) const Icon(Icons.star, color: Colors.amber, size: 14),
            if (isRating) const SizedBox(width: 2),
            Text(value, style: AppStyles.text14Px.poppins.w600),
          ],
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsAndDescriptionCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Empty for now, or display real tags if available.
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                user?.location?.toString().isNotEmpty == true
                    ? user!.location!.toString()
                    : 'Not provided',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user?.bio?.toString().isNotEmpty == true
                ? user!.bio!.toString()
                : 'No description provided.',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          if ((user?.instagram?.toString().isNotEmpty == true) ||
              (user?.facebook?.toString().isNotEmpty == true) ||
              (user?.youtube?.toString().isNotEmpty == true)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (user?.instagram?.toString().isNotEmpty == true) ...[
                  GestureDetector(
                    onTap:
                        () => launchUrl(Uri.parse(user!.instagram!.toString())),
                    child: _buildSocialSvgIcon(
                      'assets/images/svg/icons/instagram.svg',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (user?.facebook?.toString().isNotEmpty == true) ...[
                  GestureDetector(
                    onTap:
                        () => launchUrl(Uri.parse(user!.facebook!.toString())),
                    child: _buildSocialIcon(Icons.facebook),
                  ),
                  const SizedBox(width: 12),
                ],
                if (user?.youtube?.toString().isNotEmpty == true) ...[
                  GestureDetector(
                    onTap:
                        () => launchUrl(Uri.parse(user!.youtube!.toString())),
                    child: _buildSocialSvgIcon(
                      'assets/images/svg/icons/youtube.svg',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppStyles.text12Px.poppins.w500.copyWith(
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildSocialSvgIcon(String asset) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        asset,
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(Colors.red.shade400, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.red.shade400),
    );
  }

  Future<void> _deleteTransformation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transformation'),
            content: const Text(
              'Are you sure you want to delete this transformation?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    try {
      await DioClient().dio.delete<dynamic>(ApiUris.deleteTransformation(id));
      Fluttertoast.showToast(msg: 'Transformation deleted');
      _fetchTransformations();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete transformation');
    }
  }

  Widget _buildTransformationCard() {
    if (widget.isViewOnly && _transformations.isEmpty)
      return const SizedBox.shrink();

    final itemCount =
        widget.isViewOnly
            ? _transformations.length
            : _transformations.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transformations', style: AppStyles.text14Px.poppins.w600),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingTransformations)
          const Center(child: CircularProgressIndicator())
        else if (itemCount == 0)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _transformationPageController,
              itemCount: itemCount,
              onPageChanged:
                  (index) =>
                      setState(() => _transformationCurrentIndex = index),
              itemBuilder: (context, index) {
                if (!widget.isViewOnly && index == _transformations.length) {
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (context) => _AddTransformationSheet(
                              onSuccess: _fetchTransformations,
                            ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add Before',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Before',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 2, color: Colors.white),
                          Expanded(
                            child: Stack(
                              children: [
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add After',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'After',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final trans = _transformations[index];
                final String beforeImg =
                    (trans['before_image_url'] ?? trans['before_image'] ?? '')
                        .toString();
                final String afterImg =
                    (trans['after_image_url'] ?? trans['after_image'] ?? '')
                        .toString();
                final String desc = (trans['description'] ?? '').toString();

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    beforeImg,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Before',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 2, color: Colors.white),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    afterImg,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'After',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (desc.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              desc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (!widget.isViewOnly)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: InkWell(
                            onTap:
                                () => _deleteTransformation(trans['id'] as int),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (itemCount > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              final isActive = index == _transformationCurrentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? Colors.red : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _AddTransformationSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddTransformationSheet({required this.onSuccess});
  @override
  State<_AddTransformationSheet> createState() =>
      _AddTransformationSheetState();
}

class _AddTransformationSheetState extends State<_AddTransformationSheet> {
  File? _beforeFile;
  File? _afterFile;
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_beforeFile == null || _afterFile == null) {
      Fluttertoast.showToast(msg: 'Please select both before and after images');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final formData = FormData.fromMap({
        'description': _descController.text,
        'before_image_file': await MultipartFile.fromFile(_beforeFile!.path),
        'after_image_file': await MultipartFile.fromFile(_afterFile!.path),
      });
      final res = await DioClient().dio.post<dynamic>(
        ApiUris.transformations,
        data: formData,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Transformation added successfully');
        widget.onSuccess();
        if (mounted) Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Failed to add transformation');
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to add transformation');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Transformation',
                style: AppStyles.text16Px.poppins.w600,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder:
                          (c) => ImagePickerDialog(
                            onPickedImage: (f) {
                              if (f != null)
                                setState(() => _beforeFile = File(f.path));
                            },
                          ),
                    );
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _beforeFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _beforeFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey),
                                SizedBox(height: 4),
                                Text(
                                  'Before',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder:
                          (c) => ImagePickerDialog(
                            onPickedImage: (f) {
                              if (f != null)
                                setState(() => _afterFile = File(f.path));
                            },
                          ),
                    );
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _afterFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_afterFile!, fit: BoxFit.cover),
                            )
                            : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey),
                                SizedBox(height: 4),
                                Text(
                                  'After',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              hintText: 'Add a description...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Save Transformation',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Widget _buildCertificatesButton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.description_outlined,
            color: Colors.red.shade400,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text('View Certificates', style: AppStyles.text14Px.poppins.w600),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
      ],
    ),
  );
}

Widget _buildPortfolioButton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.collections_outlined,
            color: Colors.red.shade400,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text('Manage Portfolio Images', style: AppStyles.text14Px.poppins.w600),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
      ],
    ),
  );
}

Widget _buildReviewsSection(
  List<Map<String, dynamic>> reviews,
  int count,
  double avg,
  bool isLoading,
) {
  if (isLoading) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
  if (reviews.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating & Reviews', style: AppStyles.text14Px.poppins.w600),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              avg.toStringAsFixed(1),
              style: AppStyles.text24Px.poppins.w700,
            ),
            const SizedBox(width: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < avg.floor()
                      ? Icons.star
                      : (index < avg ? Icons.star_half : Icons.star_border),
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
          ],
        ),
        Text(
          '$count Reviews',
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 16),
        ...reviews.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewItem(r),
          ),
        ),
        if (count > reviews.length)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all Reviews',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Colors.red),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget _buildReviewItem(Map<String, dynamic> review) {
  final name = review['customer_name']?.toString() ?? 'User';

  String date = '';
  if (review['created_at'] != null) {
    try {
      final dt = DateTime.parse(review['created_at'].toString());
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      date =
          '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {}
  }

  final rating = review['rating']?.toString() ?? '0.0';
  final comment = review['comment']?.toString() ?? '';
  final avatar = review['profile_picture']?.toString();

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  avatar != null && avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
              child:
                  avatar == null || avatar.isEmpty
                      ? const Icon(Icons.person, size: 16, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppStyles.text12Px.poppins.w600),
                  if (date.isNotEmpty)
                    Text(
                      date,
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 10),
                  const SizedBox(width: 2),
                  Text(rating, style: AppStyles.text10Px.poppins.w600),
                ],
              ),
            ),
          ],
        ),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            comment,
            style: AppStyles.text10Px.poppins.w400.copyWith(
              color: AppColors.textDark,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    ),
  );
}

// ─── Full-Screen Hero Image Viewer ───────────────────────────────────────────

class _HeroImageFullScreen extends StatefulWidget {
  const _HeroImageFullScreen({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_HeroImageFullScreen> createState() => _HeroImageFullScreenState();
}

class _HeroImageFullScreenState extends State<_HeroImageFullScreen> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable paged image viewer
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder:
                      (_, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                ),
              );
            },
          ),

          // Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Dot indicators
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        isActive ? Colors.white : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

          // Image counter
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
