import 'package:mentor_mobile_app/imports_bindings.dart';

class GymGalleryScreen extends StatefulWidget {
  const GymGalleryScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymGalleryScreen> createState() => _GymGalleryScreenState();
}

class _GymGalleryScreenState extends State<GymGalleryScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;
  late List<PhotoModel> _images;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _images = widget.orgDetails.photos ?? [];

    //  Preload all images to avoid slow first-time loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final img in _images) {
        if (img.image != null && img.image!.isNotEmpty) {
          precacheImage(NetworkImage(img.image!), context);
        }
      }
    });
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
          (t) =>
              t.fold((l) {}, (r) => setState(() => _images = r.photos ?? [])),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text('Gallery', style: AppStyles.text16Px.poppins.w500),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Text('Photos', style: AppStyles.text16Px.poppins.w500.dark),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    AddGymGalleryPhotosSheet(
                      orgDetails: widget.orgDetails,
                    ).show(
                      context,
                      context.read<OrganizationListingAndDetailsCubit>(),
                    );
                  },
                  label: const Text('Add'),
                  icon: SvgPicture.asset(
                    'assets/images/svg/icons/camera_outlined.svg',
                    width: 16,
                    height: 16,
                  ),
                  style: const ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(AppColors.primary),
                    backgroundColor: WidgetStatePropertyAll(Color(0xffFFEAEA)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_images.isEmpty) {
                    return Center(
                      child: Text(
                        'No Photos found!',
                        style: AppStyles.text14Px.poppins.w400.dark,
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          responsiveSize(
                            context,
                            s: 2,
                            m: 3,
                            l: 4,
                            xl: 6,
                          ).toInt(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          context.push(
                            BlocProvider.value(
                              value: _cubit,
                              child: GalleryViewScreen(
                                orgDetails: widget.orgDetails,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: ImageNetwork(_images[index].image ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ).pad(16),
      ),
    );
  }
}
