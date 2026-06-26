import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateOrganizationPhotosCollectingScreen extends StatefulWidget {
  const CreateOrganizationPhotosCollectingScreen({super.key});

  @override
  State<CreateOrganizationPhotosCollectingScreen> createState() =>
      _CreateOrganizationPhotosCollectingScreenState();
}

class _CreateOrganizationPhotosCollectingScreenState
    extends State<CreateOrganizationPhotosCollectingScreen> {
  late final OrganizationCreationCubit _gymCreationCubit;
  final List<XFile> _images = [];

  @override
  void initState() {
    _gymCreationCubit = context.read<OrganizationCreationCubit>();
    super.initState();
    if (_gymCreationCubit.state.gymPhotos.isNotEmpty) {
      _images.addAll(
        _gymCreationCubit.state.gymPhotos.map((path) => XFile(path)),
      );
    }
  }

  Future<void> _pickImageDialog() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> pickedImages = await picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            // Fixed header section (non-scrollable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NEW UI - Progress Indicator (line-then-diamond structure)
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      bool isActive = index <= 3; // 4 steps completed
                      return Row(
                        children: [
                          Container(
                            width: 25,
                            height: 1,
                            color:
                                isActive
                                    ? AppColors.primary
                                    : AppColors.borderGrey,
                          ),
                          Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 8,
                              height: 8,
                              color:
                                  isActive
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 40),

                  // NEW UI - Title
                  Text(
                    'Showcase\nYour Space 📸',
                    style: AppStyles.text30Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 16),

                  // NEW UI - Subtitle
                  Text(
                    'Give members a visual feel of your facility\nand what they can expect.',
                    style: AppStyles.text14Px.poppins.w400.textGrey,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Scrollable image grid section only
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _images.length + 1, // No limit on images
                  itemBuilder: (BuildContext context, int index) {
                    if (index < _images.length) {
                      final image = _images[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    // Add photo button
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap:
                      // _pickImageDialog,
                          () {
                            ImagePickerDialog(
                              allowMultiple: true,
                              needRemove: false,
                              onPickedImages: (images) {
                                setState(() {
                                  _images.addAll(images);
                                });
                              },
                            ).show(context);

                          },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /* COMMENTED OUT - OLD SCROLLABLE ENTIRE PAGE STRUCTURE
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NEW UI - Progress Indicator (line-then-diamond structure)
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (index) {
                        bool isActive = index <= 3; // 4 steps completed
                        return Row(
                          children: [
                            Container(
                              width: 25,
                              height: 1,
                              color:
                                  isActive
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                            ),
                            Transform.rotate(
                              angle: 0.785398,
                              child: Container(
                                width: 8,
                                height: 8,
                                color:
                                    isActive
                                        ? AppColors.primary
                                        : AppColors.borderGrey,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    // NEW UI - Title
                    Text(
                      'Showcase\nYour Space 📸',
                      style: AppStyles.text30Px.poppins.w600.dark,
                    ),
                    const SizedBox(height: 16),

                    // NEW UI - Subtitle
                    Text(
                      'Give members a visual feel of your facility\nand what they can expect.',
                      style: AppStyles.text14Px.poppins.w400.textGrey,
                    ),
                    const SizedBox(height: 32),

                    // NEW UI - Photo Grid (2 columns, unlimited images)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                      itemCount: _images.length + 1, // No limit on images
                      itemBuilder: (BuildContext context, int index) {
                        if (index < _images.length) {
                          final image = _images[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(image.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        // Add photo button
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            ImagePickerDialog(
                              needRemove: false,
                              onPickedImage: (image) {
                                if (image != null) {
                                  setState(() {
                                    _images.add(image);
                                  });
                                }
                              },
                            ).show(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            */

            // Fixed bottom section with buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NEW UI - Upload Image Button
                  InkWell(
                    onTap: () {
                      // ImagePickerDialog(
                      //   needRemove: false,
                      //   onPickedImage: (image) {
                      //     if (image != null) {
                      //       setState(() {
                      //         _images.add(image);
                      //       });
                      //     }
                      //   },
                      // ).show(context);
                      context.push(
                        BlocProvider.value(
                          value: _gymCreationCubit,
                          child: const CreateOrganizationWorkingDetailsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFE0E0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.camera_alt_outlined,
                          //   color: AppColors.primary,
                          //   size: 20,
                          // ),
                          // const SizedBox(width: 8),
                          Text(
                            'Skip For Now',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // NEW UI - Next Button
                  Button.filled(
                    title: "Next → Let's Add Some Details",
                    ontap: () {
                      final error = _gymCreationCubit.addGymPhotos(
                        gymPhotos: _images.map((e) => e.path).toList(),
                      );
                      if (error != null) {
                        Dialogs.showSnack(msg: error);
                        return;
                      } else {
                        context.push(
                          BlocProvider.value(
                            value: _gymCreationCubit,
                            child:
                                const CreateOrganizationWorkingDetailsScreen(),
                          ),
                        );
                      }
                    },
                    buttonColor: AppColors.primary,
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
