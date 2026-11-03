import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/cubit/listing_and_details/organization_listing_and_details_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/organization_details_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/organization_home_data_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_add_or_edit_package_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/cubit/members_and_leads_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/leads/add_trainer_search_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/add_customer_search_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/cubit/membership_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_dashboard_view.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_header_bar.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_members_view.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_navigation_sidebar.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_payments_view.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_profile_view.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_reports_view.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_trainers_view.dart';

class DesktopOrganizationScaffold extends StatefulWidget {
  const DesktopOrganizationScaffold({
    super.key,
    required this.cubit,
    required this.state,
    required this.orgDetails,
  });

  final OrganizationListingAndDetailsCubit cubit;
  final OrganizationListingAndDetailsState state;
  final OrganizationDetailsModel orgDetails;

  @override
  State<DesktopOrganizationScaffold> createState() =>
      _DesktopOrganizationScaffoldState();
}

class _DesktopOrganizationScaffoldState
    extends State<DesktopOrganizationScaffold> {
  int _currentIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<({String title, String subtitle})> _titles = const [
    (
      title: '',
      subtitle: '',
    ),
    (
      title: 'Gym Trainers',
      subtitle: 'Manage trainers, view attendance logs, and track performance',
    ),
    (
      title: 'Members & Leads',
      subtitle: 'Customer directory, active subscriptions, and renewals',
    ),
    (
      title: 'Payment History',
      subtitle: 'Recent transactions, invoice status, and fee collections',
    ),
    (
      title: 'Reports & Analytics',
      subtitle: 'Revenue trends, budget tracking, and trainer statistics',
    ),
    (
      title: 'Gym Profile & Setup',
      subtitle: 'Facilities, operating schedules, packages, and gallery',
    ),
  ];

  void _onSelectTab(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);
  }

  Widget _buildActiveView(int index, OrganizationHomeDataModel homeData, int orgId) {
    switch (index) {
      case 0:
        return DesktopDashboardView(
          cubit: widget.cubit,
          orgHomeData: homeData,
          onNavigateToTab: _onSelectTab,
        );
      case 1:
        return DesktopTrainersView(
          orgDetails: widget.orgDetails,
        );
      case 2:
        return DesktopMembersView(
          orgId: orgId,
        );
      case 3:
        return DesktopPaymentsView(
          orgId: orgId,
        );
      case 4:
        return DesktopReportsView(
          orgId: orgId,
        );
      case 5:
        return DesktopProfileView(
          orgId: orgId,
        );
      default:
        return DesktopDashboardView(
          cubit: widget.cubit,
          orgHomeData: homeData,
          onNavigateToTab: _onSelectTab,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgId = widget.state.selectedOrganization?.id ?? 0;
    final currentMeta = _titles[_currentIndex];
    final isDark = context.isDarkMode;
    final showQuickActions = _currentIndex == 0 || _currentIndex == 1;

    return Scaffold(
      backgroundColor: isDark ? context.colors.background : const Color(0xFFF8F9FA),
      floatingActionButton: showQuickActions
          ? FloatingActionButton(
              tooltip: 'Quick Actions',
              backgroundColor: AppColors.primary,
              elevation: 4,
              hoverElevation: 6,
              shape: const CircleBorder(),
              onPressed: () => _showQuickActionsMenu(context, orgId),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Row(
        children: [
          // ── Persistent Navigation Sidebar ──
          DesktopNavigationSidebar(
            currentIndex: _currentIndex,
            onSelectTab: _onSelectTab,
            isCollapsed: _isSidebarCollapsed,
            onToggleCollapse: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            cubit: widget.cubit,
          ),

          // ── Main Content Area ──
          Expanded(
            child: Column(
              children: [
                // ── Top Header Bar ──
                DesktopHeaderBar(
                  title: currentMeta.title,
                  subtitle: currentMeta.subtitle,
                  cubit: widget.cubit,
                ),

                // ── Active Page Body ──
                Expanded(
                  child: widget.state.homeData.fold(
                    () => const Center(child: CircularProgressIndicator()),
                    (either) => either.fold(
                      (error) => Center(
                        child: Text(
                          'Error loading dashboard data',
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                      ),
                      (homeData) {
                        return _buildActiveView(_currentIndex, homeData, orgId);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context, int orgId) {
    if (orgId == 0) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: context.colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppStyles.text18Px.poppins.w700.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _QuickActionTile(
                    icon: Icons.person_add_rounded,
                    color: const Color(0xFF16A34A),
                    title: 'Add Customer / Member',
                    subtitle: 'Register a new gym client',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(create: (_) => MembersAndLeadsCubit(orgId: orgId)),
                              BlocProvider(create: (_) => MembershipCubit(orgId: orgId.toString())),
                            ],
                            child: AddCustomerSearchScreen(orgId: orgId),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickActionTile(
                    icon: Icons.sports_gymnastics_rounded,
                    color: const Color(0xFF2563EB),
                    title: 'Add Trainer',
                    subtitle: 'Link a trainer to your gym',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => BlocProvider(
                            create: (_) => MembersAndLeadsCubit(orgId: orgId),
                            child: AddTrainerSearchScreen(orgId: orgId),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickActionTile(
                    icon: Icons.card_membership_rounded,
                    color: const Color(0xFF9333EA),
                    title: 'Add Membership Plan',
                    subtitle: 'Create a new subscription package',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => BlocProvider(
                            create: (_) => MembershipCubit(orgId: orgId.toString()),
                            child: const GymAddOrEditPackageScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

