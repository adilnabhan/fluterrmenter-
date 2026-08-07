import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

class TrainerWorkoutLibraryScreen extends StatelessWidget {
  const TrainerWorkoutLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text(
          'Workout Library',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colors.background,
        elevation: 0,
      ),
      body: const SelectExerciseSheetContent(
        title: 'Workout Library',
        isPage: true,
      ),
    );
  }
}
