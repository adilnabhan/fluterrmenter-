import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/organization_dashboard_scaffold.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_dashboard_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_customers_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reports_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_profile_screen.dart';

class TrainerMainScreen extends StatelessWidget {
  const TrainerMainScreen({this.initialIndex = 0, super.key});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;

    final isTrainer = user?.userRole == 35;

    final quickActionsFab = FloatingActionButton(
      onPressed: () {
        showModalBottomSheet<dynamic>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const TrainerQuickActionsSheet(),
        );
      },
      backgroundColor: AppColors.primary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 24),
    );

    return OrganizationDashboardScaffold(
      initialIndex: initialIndex,
      profileImageUrl: user?.profilePicture as String?,
      floatingActionButtons: isTrainer
          ? [quickActionsFab, null, quickActionsFab, null]
          : [quickActionsFab, quickActionsFab, null, null],
      pages: isTrainer
          ? const [
              TrainerDashboardScreen(),
              WorkoutGroupsScreen(),
              TrainerCustomersScreen(),
              TrainerProfileSettingsScreen(),
            ]
          : const [
              TrainerDashboardScreen(),
              TrainerCustomersScreen(),
              WorkoutGroupsScreen(),
              TrainerProfileSettingsScreen(),
            ],
    );
  }
}
