import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/account_switcher_sheet.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_settings_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/edit_trainer_profile_screen.dart';

class TrainerMainProfileScreen extends StatefulWidget {
  const TrainerMainProfileScreen({super.key});

  @override
  State<TrainerMainProfileScreen> createState() =>
      _TrainerMainProfileScreenState();
}

class _TrainerMainProfileScreenState extends State<TrainerMainProfileScreen> {
  final PageController _heroPagerController = PageController();
  int _heroCurrentIndex = 0;

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

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _HeroImageFullScreen(
          images: _heroImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;

    final trainerName =
        '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim();
    final displayName =
        trainerName.isNotEmpty ? trainerName : 'Trainer Profile';

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Dialogs.showSnack(msg: "Add action coming soon!");
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                        itemCount: _heroImages.length,
                        onPageChanged: (i) =>
                            setState(() => _heroCurrentIndex = i),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _openFullScreen(context, index),
                            child: Image.network(
                              _heroImages[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(color: Colors.grey.shade900),
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
                                const Color(0xffF7F7F7).withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top bar (Account switcher + Settings)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        side: const BorderSide(color: Colors.transparent),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        const AccountSwitcherSheet().show(context);
                                      },
                                      label: const Icon(
                                        Icons.keyboard_arrow_down_sharp,
                                        color: Color(0xff222222),
                                        size: 20,
                                      ),
                                      icon: Text(
                                        '$displayName (Trainer)',
                                        style: AppStyles.text14Px.poppins.w600.copyWith(
                                          color: const Color(0xff222222),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.white.withOpacity(0.8),
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
                                          builder: (context) => const TrainerProfileSettingsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_heroImages.length, (i) {
                                final isActive = i == _heroCurrentIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: isActive ? 16 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
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
                  _buildTagsAndDescriptionCard(),
                  const SizedBox(height: 16),
                  _buildTransformationCard(),
                  const SizedBox(height: 16),
                  _buildCertificatesButton(),
                  const SizedBox(height: 16),
                  _buildReviewsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
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
                  image: DecorationImage(
                    image: NetworkImage(
                      user?.profilePicture?.toString() ??
                          'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
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
                        _buildStatItem('12', 'Clients'),
                        _buildStatItem('19', 'Verified\nWorkouts'),
                        _buildStatItem('4.5', 'Rating', isRating: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                child: const Icon(Icons.edit, size: 14, color: Colors.black54),
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

  Widget _buildTagsAndDescriptionCard() {
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
              _buildTag('Calisthenics'),
              _buildTag('Muscle building'),
              _buildTag('Fat Loss'),
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
                'Pudussery',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Description here. Lorem ipsum dolor sit amet, consectetur adipisci elit, sed eiusmod.',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSocialSvgIcon('assets/images/svg/icons/instagram.svg'),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 12),
              _buildSocialSvgIcon('assets/images/svg/icons/youtube.svg'),
            ],
          ),
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

  Widget _buildTransformationCard() {
    return const _TransformationCarousel();
  }
}

class _TransformationCarousel extends StatefulWidget {
  const _TransformationCarousel();

  @override
  State<_TransformationCarousel> createState() =>
      _TransformationCarouselState();
}

class _TransformationCarouselState extends State<_TransformationCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Sample transformation pairs (before/after)
  final List<Map<String, String>> _transformations = [
    {
      'before':
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&fit=crop',
      'after':
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&fit=crop',
    },
    {
      'before':
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&fit=crop',
      'after':
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&fit=crop',
    },
    {
      'before':
          'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=400&fit=crop',
      'after':
          'https://images.unsplash.com/photo-1534368959876-26bf04f2c947?w=400&fit=crop',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE6E6E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Tab indicator row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    _currentPage * 2, // jump within same pair — no-op here
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Before',
                      style: AppStyles.text14Px.poppins.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'After',
                    style: AppStyles.text14Px.poppins.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // PageView carousel
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _transformations.length,
              onPageChanged: (index) =>
                  setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final pair = _transformations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            pair['before']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Container(
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            pair['after']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Container(
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        ),
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
          const SizedBox(height: 14),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_transformations.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
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

Widget _buildReviewsSection() {
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
              Text('4.5', style: AppStyles.text24Px.poppins.w700),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index == 4 ? Icons.star_half : Icons.star,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          Text(
            '128 Reviews',
            style: AppStyles.text10Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewItem(),
          const SizedBox(height: 12),
          _buildReviewItem(),
          const SizedBox(height: 12),
          _buildReviewItem(),
          const SizedBox(height: 16),
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

Widget _buildReviewItem() {
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
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('David James', style: AppStyles.text12Px.poppins.w600),
                    Text(
                      '05 Jun 2027',
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
                    Text('4.5', style: AppStyles.text10Px.poppins.w600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipisci elit, sed eiusmod. Lorem ipsum dolor sit amet, consectetur adipisci elit, s...',
            style: AppStyles.text10Px.poppins.w400.copyWith(
              color: AppColors.textDark,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
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
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
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
