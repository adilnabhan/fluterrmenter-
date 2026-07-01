import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_or_edit_memeber_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/leads/add_or_edit_lead_screen.dart';

class QuickActionsFab extends StatelessWidget {
  final int orgId;

  const QuickActionsFab({super.key, required this.orgId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _QuickActionsSheet(orgId: orgId),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({required this.orgId});
  final int orgId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppStyles.text20Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          _ActionCard(
            icon: Icons.calendar_today,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFF9C51BF),
            title: 'Add Membership Plan',
            subtitle: 'Create Membership templates',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BlocProvider(
                        create:
                            (context) =>
                                MembershipCubit(orgId: orgId.toString()),
                        child: const GymAddOrEditPackageScreen(),
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.person_add,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFF4CAF50),
            title: 'Add Customer',
            subtitle: 'Add a new customer',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => MembersAndLeadsCubit(orgId: orgId),
                    child: AddOrEditMemeberScreen(orgId: orgId),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.sports_gymnastics,
            iconColor: Colors.white,
            iconBgColor: const Color(0xFF2196F3),
            title: 'Add Trainer',
            subtitle: 'Add a new trainer',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => MembersAndLeadsCubit(orgId: orgId),
                    child: const AddOrEditLeadScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFD30000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.text16Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: AppColors.textDark,
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
