import 'package:flutter/cupertino.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class AddGymGalleryPhotosSheet extends StatefulWidget {
  const AddGymGalleryPhotosSheet({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  Future<void> show(
    BuildContext context,
    OrganizationListingAndDetailsCubit cubit,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder:
          (context) => BlocProvider.value(
            value: cubit,
            child: AddGymGalleryPhotosSheet(orgDetails: orgDetails),
          ),
    );
  }

  @override
  State<AddGymGalleryPhotosSheet> createState() =>
      _AddGymGalleryPhotosSheetState();
}

class _AddGymGalleryPhotosSheetState extends State<AddGymGalleryPhotosSheet> {
  late final OrganizationListingAndDetailsCubit _cubit;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
  }

  // Future<void> _pickImageDialog() async {
  //   await ImagePickerDialog(
  //     needRemove: false,
  //     onPickedImage: (xFile) {
  //       if (xFile != null && xFile.path.isNotEmpty) {
  //         setState(() => _images.add(xFile.path));
  //       }
  //     },
  //   ).show(context);
  // }

  Future<void> _pickImageDialog() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> pickedImages = await picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(
          pickedImages.map((e) => e.path),
        );
      });
    }
  }


  Future<void> _onSave() async {
    if (_cubit.state.updateOrgDetails?.isNone() ?? false) return;

    await _cubit.updateOrgDetails(
      orgId: widget.orgDetails.id!,
      body: FormData.fromMap({
        'photos': await Future.wait(
          _images.map(
            (imagePath) => MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split('/').last,
            ),
          ),
        ),
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      OrganizationListingAndDetailsCubit,
      OrganizationListingAndDetailsState
    >(
      listenWhen: (p, c) => p.updateOrgDetails != c.updateOrgDetails,
      listener: (context, state) {
        state.updateOrgDetails?.fold(
          () {},
          (t) => t.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              _cubit.fetchDetails(orgId: widget.orgDetails.id!);
              context.pop();
              Dialogs.showSnack(msg: 'Photos added successfully');
            },
          ),
        );
      },
      child: BlocBuilder<
        OrganizationListingAndDetailsCubit,
        OrganizationListingAndDetailsState
      >(
        buildWhen: (p, c) => p.updateOrgDetails != c.updateOrgDetails,
        builder: (context, state) {
          return AbsorbPointer(
            absorbing: state.updateOrgDetails?.isNone() ?? false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.photo, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Add Images',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ).pOnly(left: 16),
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
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
                        itemCount: _images.length + 1,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (BuildContext context, int index) {
                          if (index > 0) {
                            final image = _images[index - 1];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.file(
                                    File(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index - 1);
                                      });
                                    },
                                    child: SizedBox.square(
                                      dimension: 32,
                                      child:
                                          SvgPicture.asset(
                                            'assets/images/svg/icons/close.svg',
                                            height: 32,
                                            width: 32,
                                          ).center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: _pickImageDialog,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffFDD6D6),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/svg/icons/camera_plus.svg',
                                  height: 28,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade100,
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel',
                                    style: AppStyles.text16Px.poppins.w500
                                        .copyWith(color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CupertinoButton.filled(
                                  borderRadius: BorderRadius.circular(12),
                                  onPressed: _onSave,
                                  child:
                                      (state.updateOrgDetails?.isNone() ??
                                              false)
                                          ? const SizedBox.square(
                                            dimension: 24,
                                            child: Center(
                                              child: CupertinoActivityIndicator(
                                                color: AppColors.light,
                                              ),
                                            ),
                                          )
                                          : Text(
                                            'Save',
                                            style:
                                                AppStyles.text16Px.poppins.w500,
                                          ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
