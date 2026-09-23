import 'dart:ui';
import 'package:mentor_mobile_app/imports_bindings.dart';

class GalleryViewScreen extends StatefulWidget {
  const GalleryViewScreen({
    required this.orgDetails,
    required this.initialIndex,
    required this.cubit,
    super.key,
  });
  final OrganizationDetailsModel orgDetails;
  final int initialIndex;
  final OrganizationListingAndDetailsCubit cubit;

  @override
  State<GalleryViewScreen> createState() => _GalleryViewScreenState();
}

class _GalleryViewScreenState extends State<GalleryViewScreen> {
  late List<PhotoModel> photos;
  late PageController _pageController;
  late int _currentIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    photos = widget.orgDetails.photos ?? [];
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onDeleteImage() async {
    if (photos.isEmpty || _currentIndex >= photos.length) return;
    final photoId = photos[_currentIndex].id;
    if (photoId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Photo', style: AppStyles.text16Px.poppins.w600),
          content: Text(
            'Are you sure you want to delete this photo?',
            style: AppStyles.text14Px.poppins.w400,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppStyles.text14Px.poppins.w500.dark),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });
      widget.cubit.deletePhoto(
        orgId: widget.orgDetails.id!,
        photoId: photoId,
      );
    }
  }

  Widget _buildGlassCircle({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    double size = 48,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.2),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: size * 0.45),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImmersiveEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Photos Available',
            style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add photos.',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
      bloc: widget.cubit,
      listenWhen: (p, c) => p.details != c.details || p.updateOrgDetails != c.updateOrgDetails,
      listener: (context, state) {
        if (state.updateOrgDetails?.isSome() ?? false) {
           state.updateOrgDetails!.fold(() {}, (t) => t.fold((l) {
              setState(() => _isLoading = false);
              Dialogs.showSnack(msg: l.msg);
           }, (r) {
              setState(() => _isLoading = false);
           }));
        }
        state.details.fold(
          () {},
          (t) => t.fold((l) {}, (r) {
            setState(() {
              photos = r.photos ?? [];
              if (_currentIndex >= photos.length && photos.isNotEmpty) {
                _currentIndex = photos.length - 1;
              } else if (photos.isEmpty) {
                _currentIndex = 0;
              }
            });
          }),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image (Blurred)
            if (photos.isNotEmpty && _currentIndex < photos.length)
              ImageNetwork(
                photos[_currentIndex].image ?? '',
                fit: BoxFit.cover,
                errorWidget: const SizedBox(),
              ),
            
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassCircle(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.pop(context),
                        ),
                        if (photos.isNotEmpty)
                          _buildGlassCircle(
                            icon: Icons.delete_outline,
                            iconColor: Colors.redAccent,
                            onTap: _onDeleteImage,
                          ),
                      ],
                    ),
                  ),
                  
                  // PageView or Empty State
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : photos.isEmpty
                          ? _buildImmersiveEmptyState()
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: photos.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(24),
                                            child: ImageNetwork(
                                              photos[index].image ?? '',
                                              fit: BoxFit.cover,
                                              errorWidget: Container(
                                                color: Colors.grey.shade800,
                                                child: const Center(
                                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Left Arrow
                                if (_currentIndex > 0)
                                  Positioned(
                                    left: 8,
                                    child: _buildGlassCircle(
                                      icon: Icons.arrow_back_ios_new,
                                      size: 40,
                                      onTap: () {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ),
                                // Right Arrow
                                if (_currentIndex < photos.length - 1)
                                  Positioned(
                                    right: 8,
                                    child: _buildGlassCircle(
                                      icon: Icons.arrow_forward_ios,
                                      size: 40,
                                      onTap: () {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                  ),
                  
                  // Thumbnails
                  if (!_isLoading)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 24, top: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: photos.isNotEmpty ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: photos.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final isSelected = _currentIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected 
                                          ? Border.all(color: Colors.white, width: 2)
                                          : Border.all(color: Colors.transparent, width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ImageNetwork(
                                        photos[index].image ?? '',
                                        fit: BoxFit.cover,
                                        errorWidget: Container(color: Colors.grey.shade800),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ) : const SizedBox(),
                          ),
                          if (photos.isNotEmpty) const SizedBox(width: 16),
                          // Floating Action Button
                          FloatingActionButton(
                            heroTag: 'upload_org_gallery_btn',
                            onPressed: () {
                              AddGymGalleryPhotosSheet(
                                orgDetails: widget.orgDetails,
                              ).show(context, widget.cubit);
                            },
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            mini: true,
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
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
}
