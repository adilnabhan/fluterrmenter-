import 'package:mentor_mobile_app/imports_bindings.dart';

class GymPhotosCollectingScreen extends StatefulWidget {
  const GymPhotosCollectingScreen({super.key});

  @override
  State<GymPhotosCollectingScreen> createState() => _GymPhotosCollectingScreenState();
}

class _GymPhotosCollectingScreenState extends State<GymPhotosCollectingScreen> {
  final List<XFile> _images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 22),
          const GymProfileCompletionStatusCard(progress: 3),
          const SizedBox(height: 28),
          Text('Use your current location', style: AppStyles.text16Px.poppins.w700.dark),
          const SizedBox(height: 4),
          Text('How your gym’s equipment, ambiance, trainers, & more.', style: AppStyles.text12Px.poppins.w400.textGrey),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: responsiveSize(context, s: 2, m: 3, l: 4, xl: 6).toInt(), crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: _images.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index < _images.length) {
                final image = _images[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(40), child: Image.file(File(image.path), fit: BoxFit.cover)),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                        child: SizedBox.square(dimension: 32, child: SvgPicture.asset('assets/images/svg/icons/close.svg', height: 32, width: 32).center),
                      ),
                    ),
                  ],
                );
              }
              return InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  ImagePickerDialog(
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
                  decoration: BoxDecoration(color: const Color(0xffFDD6D6), borderRadius: BorderRadius.circular(40), border: Border.all(color: AppColors.primary)),
                  child: Center(child: SvgPicture.asset('assets/images/svg/icons/camera_plus.svg', height: 28)),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 84,
        child: FloatingActionButton(
          onPressed: () {},
          shape: const StadiumBorder(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.light,
          elevation: 0,
          child: const Icon(Icons.keyboard_arrow_right_outlined),
        ),
      ),
    );
  }
}
