import 'package:mentor_mobile_app/imports_bindings.dart';

class GymPhotosCollectingScreen extends StatefulWidget {
  const GymPhotosCollectingScreen({super.key});

  @override
  State<GymPhotosCollectingScreen> createState() =>
      _GymPhotosCollectingScreenState();
}

class _GymPhotosCollectingScreenState extends State<GymPhotosCollectingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 22),
          const GymProfileCompletionStatusCard(progress: 3),
          const SizedBox(height: 32),
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
