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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 22),
            const OrganizationCreationCompletionStatusCard(progress: 3),
            const SizedBox(height: 28),
            Text(
              'Add Photos & Videos',
              style: AppStyles.text16Px.poppins.w700.dark,
            ),
            const SizedBox(height: 4),
            Text(
              'Please upload images sized 1485 × 1458 px to ensure the best quality',
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    responsiveSize(context, s: 2, m: 3, l: 4, xl: 6).toInt(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _images.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < _images.length) {
                  final image = _images[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.file(File(image.path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index);
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
          ],
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                context.push(
                  BlocProvider.value(
                    value: _gymCreationCubit,
                    child: const CreateOrganizationWorkingDetailsScreen(),
                  ),
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.primary,
                  // decoration: TextDecoration.underline,
                  // decorationColor: AppColors.primary,
                  // decorationThickness: 2, // Increased space between text and underline
                ),
              ),
            ),

            SizedBox(
              width: 84,
              child: FloatingActionButton(
                onPressed: () {
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
                        child: const CreateOrganizationWorkingDetailsScreen(),
                      ),
                    );
                  }
                },
                shape: const StadiumBorder(),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.light,
                elevation: 0,
                child: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
            ),
          ],
        ).pad(16),
      ),
    );
  }
}
