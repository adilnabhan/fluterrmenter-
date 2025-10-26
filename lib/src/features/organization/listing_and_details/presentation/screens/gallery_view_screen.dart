import 'package:mentor_mobile_app/imports_bindings.dart';

class GalleryViewScreen extends StatefulWidget {
  const GalleryViewScreen({
    required this.orgDetails,
    required this.initialIndex,
    super.key,
  });
  final OrganizationDetailsModel orgDetails;
  final int initialIndex;

  @override
  State<GalleryViewScreen> createState() => _GalleryViewScreenState();
}

class _GalleryViewScreenState extends State<GalleryViewScreen> {
  late List<PhotoModel> photos;
  late PageController _pageController;
  late int _currentIndex;
  late final OrganizationListingAndDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    photos = widget.orgDetails.photos ?? [];
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _onDeleteImage() async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return BlocListener<
          OrganizationListingAndDetailsCubit,
          OrganizationListingAndDetailsState
        >(
          bloc: _cubit,
          listenWhen: (p, c) => p.updateOrgDetails != c.updateOrgDetails,
          listener:
              (context, state) => state.updateOrgDetails?.fold(
                () {},
                (t) => t.fold((l) {}, (r) => context.pop()),
              ),
          child: BlocBuilder<
            OrganizationListingAndDetailsCubit,
            OrganizationListingAndDetailsState
          >(
            bloc: _cubit,
            buildWhen: (p, c) => p.updateOrgDetails != c.updateOrgDetails,
            builder: (context, state) {
              return PopScope(
                canPop: state.updateOrgDetails?.isNone() ?? false,
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Delete Photo',
                    style: AppStyles.text16Px.poppins.w600,
                  ),
                  content: Text(
                    'Are you sure you want to delete this photo?',
                    style: AppStyles.text14Px.poppins.w400,
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed:
                          (state.updateOrgDetails?.isNone() ?? false)
                              ? () {}
                              : context.pop,
                      child: Text(
                        'Cancel',
                        style: AppStyles.text14Px.poppins.w500.dark,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed:
                          (state.updateOrgDetails?.isNone() ?? false)
                              ? () {}
                              : () => _cubit.deletePhoto(
                                orgId: widget.orgDetails.id!,
                                photoId: photos[_currentIndex].id!,
                              ),
                      child: Text(
                        state.updateOrgDetails?.isNone() ?? false
                            ? 'Deleting...'
                            : 'Delete',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      OrganizationListingAndDetailsCubit,
      OrganizationListingAndDetailsState
    >(
      listenWhen: (p, c) => p.details != c.details,
      listener: (context, state) {
        state.details.fold(
          () {},
          (t) => t.fold((l) {}, (r) => setState(() => photos = r.photos ?? [])),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text('Gallery', style: AppStyles.text16Px.poppins.w500),
          actions:
              photos.isNotEmpty
                  ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: _onDeleteImage,
                    ),
                  ]
                  : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child:
                      photos.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No Photos Available!',
                                  style:
                                      AppStyles.text16Px.poppins.w500.textGrey,
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () {
                                    AddGymGalleryPhotosSheet(
                                      orgDetails: widget.orgDetails,
                                    ).show(context, _cubit);
                                  },
                                  label: const Text('Add Photos'),
                                  icon: SvgPicture.asset(
                                    'assets/images/svg/icons/camera_outlined.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  style: const ButtonStyle(
                                    foregroundColor: WidgetStatePropertyAll(
                                      AppColors.primary,
                                    ),
                                    backgroundColor: WidgetStatePropertyAll(
                                      Color(0xffFFEAEA),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : PageView.builder(
                            controller: _pageController,
                            itemCount: photos.length,
                            onPageChanged: _onPageChanged,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ImageNetwork(
                                  photos[index].image ?? '',
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              );
                            },
                          ),
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border:
                              isSelected
                                  ? Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  )
                                  : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ImageNetwork(
                            photos[index].image ?? '',
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
