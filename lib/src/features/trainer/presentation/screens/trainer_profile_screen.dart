import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
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

final ValueNotifier<int> trainerProfileRefreshTrigger = ValueNotifier<int>(0);

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
    } else {
      _handleRefresh(silent: true);
    }
    _fetchReviews();
    _fetchPortfolioImages();
    _fetchTransformations();
  }

  @override
  void dispose() {
    _heroPagerController.dispose();
    _transformationPageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransformations() async {
    if (!mounted) return;
    setState(() => _isLoadingTransformations = true);
    try {
      final currentUser = context.read<AppCubit>().state.currentUser;
      final orgId =
          widget.isViewOnly
              ? _fetchedUser?.mentor?.org?.id
              : currentUser?.organizationId ??
                  currentUser?.trainer?.organizationId ??
                  currentUser?.mentor?.org?.id;

      final Map<String, dynamic> params = {};
      if (orgId != null) {
        params['organization_id'] = orgId;
      }
      if (widget.isViewOnly && widget.trainerId != null) {
        params['trainer_id'] = widget.trainerId;
      }

      final res = await DioClient().dio.get<dynamic>(
        ApiUris.transformations,
        queryParameters: params,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (res.statusCode == 200) {
        final data = res.data;
        List<dynamic> results = [];
        if (data is Map) {
          results = data['transformations'] as List? ?? [];
        } else if (data is List) {
          results = data;
        }

        final mapped =
            results.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (mounted) {
          setState(() {
            _transformations = mapped;
            _isLoadingTransformations = false;
          });
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

        final int? parsedClientsCount = int.tryParse(
              (data['clients_count'] ??
                      data['client_count'] ??
                      data['clients'] ??
                      data['total_clients'] ??
                      mentorData?['clients_count'] ??
                      mentorData?['client_count'] ??
                      mentorData?['clients'] ??
                      '')
                  .toString(),
            );

        final int? parsedVerifiedWorkoutsCount = int.tryParse(
              (data['verified_workouts_count'] ??
                      data['verified_workout_count'] ??
                      data['verified_workouts'] ??
                      data['total_verified_workouts'] ??
                      mentorData?['verified_workouts_count'] ??
                      mentorData?['verified_workout_count'] ??
                      mentorData?['verified_workouts'] ??
                      '')
                  .toString(),
            );

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
          whatsapp: data['whatsapp']?.toString(),
          trainer: TrainerModel(
            certificates: mappedCerts,
            portfolioImages: mappedPortfolio,
            clientsCount: parsedClientsCount,
            verifiedWorkoutsCount: parsedVerifiedWorkoutsCount,
          ),
          mentor: Mentor(
            org: Org(
              id: mentorData?['organization']?['id'] as int?,
              name: mentorData?['organization']?['name']?.toString(),
            ),
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
        _fetchTransformations();
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

  Future<void> _handleRefresh({bool silent = false}) async {
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

        final int? refreshedClientsCount = int.tryParse(
              (data['clients_count'] ??
                      data['client_count'] ??
                      data['clients'] ??
                      data['total_clients'] ??
                      '')
                  .toString(),
            );

        final int? refreshedVerifiedWorkoutsCount = int.tryParse(
              (data['verified_workouts_count'] ??
                      data['verified_workout_count'] ??
                      data['verified_workouts'] ??
                      data['total_verified_workouts'] ??
                      '')
                  .toString(),
            );

        final updatedUser = currentUser!.copyWith(
          firstName: data['first_name']?.toString() ?? currentUser.firstName,
          lastName: data['last_name']?.toString() ?? currentUser.lastName,
          profilePicture:
              data['profile_picture']?.toString() ?? currentUser.profilePicture,
          bio: data['bio']?.toString() ?? currentUser.bio,
          location: data['location']?.toString() ?? currentUser.location,
          gender: data['gender']?.toString() ?? currentUser.gender,
          dateOfBirth: (data['date_of_birth'] ?? data['dob'] ?? data['dateOfBirth'])?.toString() ?? currentUser.dateOfBirth,
          experienceYears: int.tryParse((data['experience_years'] ?? data['experience_year'] ?? data['experience'])?.toString() ?? '') ?? currentUser.experienceYears,
          instagram: data['instagram']?.toString() ?? currentUser.instagram,
          facebook: data['facebook']?.toString() ?? currentUser.facebook,
          youtube: data['youtube']?.toString() ?? currentUser.youtube,
          whatsapp: data['whatsapp']?.toString() ?? currentUser.whatsapp,
          trainer:
              currentUser.trainer?.copyWith(
                clientsCount: refreshedClientsCount ?? currentUser.trainer?.clientsCount,
                verifiedWorkoutsCount: refreshedVerifiedWorkoutsCount ?? currentUser.trainer?.verifiedWorkoutsCount,
                portfolioImages: mappedPortfolio,
              ) ??
              TrainerModel(
                clientsCount: refreshedClientsCount,
                verifiedWorkoutsCount: refreshedVerifiedWorkoutsCount,
                portfolioImages: mappedPortfolio,
              ),
        );

        appCubit.addUser(updatedUser);
        if (!silent) Dialogs.showSnack(msg: 'Profile refreshed!');
      }
    } catch (e) {
      if (!silent) Dialogs.showSnack(msg: 'Failed to refresh profile.');
    }
  }

  static const List<String> _heroImages = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1470&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1470&auto=format&fit=crop',
  ];

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
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const Center(child: CircularProgressIndicator()),
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
    final List<String> heroCarousel =
        portfolioImages.isNotEmpty
            ? portfolioImages
                .map((e) => e.image ?? '')
                .where((img) => img.isNotEmpty)
                .toList()
            : _heroImages;
    if (heroCarousel.isEmpty) heroCarousel.addAll(_heroImages);

    return Scaffold(
      backgroundColor: context.colors.background,
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
                              child: ImageNetwork(
                                heroCarousel[index],
                                fit: BoxFit.cover,
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
                                            backgroundColor: context.colors.card
                                                .withOpacity(0.9),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            side: BorderSide(
                                              color: context.colors.border,
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
                                          label: Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                            color: context.colors.icon,
                                            size: 20,
                                          ),
                                          icon: Text(
                                            '$displayName (Trainer)',
                                            style: AppStyles
                                                .text14Px
                                                .poppins
                                                .w600
                                                .copyWith(
                                                  color:
                                                      context
                                                          .colors
                                                          .textPrimary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    CircleAvatar(
                                      backgroundColor: context.colors.card
                                          .withOpacity(0.9),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.settings,
                                          color: context.colors.icon,
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
                                  backgroundColor: context.colors.card
                                      .withOpacity(0.9),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: context.colors.icon,
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
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.05),
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
                          ? ImageNetwork(
                            user!.profilePicture!.toString(),
                            fit: BoxFit.cover,
                            errorWidget: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.colors.fieldFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 14,
                    color: context.colors.icon,
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
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.05),
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
              color: context.colors.textPrimary,
              height: 1.5,
            ),
          ),
          if ((user?.instagram?.toString().isNotEmpty == true) ||
              (user?.facebook?.toString().isNotEmpty == true) ||
              (user?.youtube?.toString().isNotEmpty == true) ||
              (user?.whatsapp?.toString().isNotEmpty == true)) ...[
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
                    child: _buildSocialSvgIcon(
                      'assets/images/svg/icons/fb.svg',
                      fallbackIcon: Icons.facebook,
                    ),
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
                  const SizedBox(width: 12),
                ],
                if (user?.whatsapp?.toString().isNotEmpty == true) ...[
                  GestureDetector(
                    onTap: () {
                      var whatsappUrl = user!.whatsapp!.toString().trim();
                      if (!whatsappUrl.startsWith('http')) {
                        whatsappUrl = 'https://wa.me/$whatsappUrl';
                      }
                      launchUrl(
                        Uri.parse(whatsappUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: _buildSocialSvgIcon(
                      'assets/images/svg/icons/whatsapp.svg',
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
        color: context.colors.fieldFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppStyles.text12Px.poppins.w500.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSocialSvgIcon(String asset, {IconData? fallbackIcon}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: SvgPicture.asset(
        asset,
        width: 20,
        height: 20,
        placeholderBuilder:
            (context) => Icon(
              fallbackIcon ?? Icons.public,
              size: 20,
              color: AppColors.primary,
            ),
      ),
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
                                  child: ImageNetwork(
                                    beforeImg,
                                    fit: BoxFit.cover,
                                    errorWidget: const SizedBox(),
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
                                  child: ImageNetwork(
                                    afterImg,
                                    fit: BoxFit.cover,
                                    errorWidget: const SizedBox(),
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

  Widget _buildCertificatesButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.05),
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
              color: Colors.red.shade50.withOpacity(
                context.isDarkMode ? 0.15 : 1.0,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.red.shade400,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'View Certificates',
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: context.colors.icon, size: 20),
        ],
      ),
    );
  }

  Widget _buildPortfolioButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.05),
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
              color: Colors.red.shade50.withOpacity(
                context.isDarkMode ? 0.15 : 1.0,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.collections_outlined,
              color: Colors.red.shade400,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Manage Portfolio Images',
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: context.colors.icon, size: 20),
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
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating & Reviews',
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: AppStyles.text24Px.poppins.w700.copyWith(
                  color: context.colors.textPrimary,
                ),
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
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...reviews.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReviewItem(r),
            ),
          ),
          if (reviews.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _showAllReviewsSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all Reviews',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: const Color(0xffD92D20),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xffD92D20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllReviewsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Reviews (${_reviews.length})',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.colors.icon),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _reviews.isEmpty
                    ? Center(
                        child: Text(
                          'No reviews yet',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _reviews.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildReviewItem(_reviews[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffEEEEEE)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xffEEEEEE),
                backgroundImage:
                    avatar != null && avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                child:
                    avatar == null || avatar.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.grey,
                          )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color: const Color(0xff666666),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF8E7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ReadMoreText(text: comment),
          ],
        ],
      ),
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
      final currentUser = context.read<AppCubit>().state.currentUser;
      final orgId =
          currentUser?.organizationId ??
          currentUser?.trainer?.organizationId ??
          currentUser?.mentor?.org?.id;

      final formData = FormData.fromMap({
        'description': _descController.text,
        'before_image': await MultipartFile.fromFile(_beforeFile!.path),
        'after_image': await MultipartFile.fromFile(_afterFile!.path),
        if (orgId != null) 'organization_id': orgId,
      });
      final res = await DioClient().dio.post<dynamic>(
        ApiUris.transformations,
        data: formData,
        options: Options(headers: {'X-Platform': platformSource}),
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
      String errMsg = 'Failed to add transformation';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          errMsg = data['message'].toString();
        } else if (data != null) {
          errMsg = data.toString();
        } else {
          errMsg = e.message ?? e.toString();
        }
      } else {
        errMsg = e.toString();
      }
      Fluttertoast.showToast(msg: errMsg);
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
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: const Color(0xffD92D20),
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
