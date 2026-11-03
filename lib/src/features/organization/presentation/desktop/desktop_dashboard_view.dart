import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/core/extensions/typography_extension.dart';
import 'package:mentor_mobile_app/core/themes/app_colors.dart';
import 'package:mentor_mobile_app/core/themes/app_styles.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/cubit/listing_and_details/organization_listing_and_details_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/organization_home_data_model.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/upcoming_payments_widget.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/client_attendance_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/trainer_attendance_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/active_members_listing_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/expired_members_listing_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/freezed_members_listing_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/upcoming_renewals_listing_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/members_and_leads_listing_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_content_constraint.dart';
import 'package:mentor_mobile_app/src/features/organization/presentation/desktop/desktop_stat_card.dart';

class DesktopDashboardView extends StatefulWidget {
  const DesktopDashboardView({
    super.key,
    required this.cubit,
    required this.orgHomeData,
    required this.onNavigateToTab,
  });

  final OrganizationListingAndDetailsCubit cubit;
  final OrganizationHomeDataModel orgHomeData;
  final ValueChanged<int> onNavigateToTab;

  @override
  State<DesktopDashboardView> createState() => _DesktopDashboardViewState();
}

class _DesktopDashboardViewState extends State<DesktopDashboardView> {
  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;
    final orgHomeData = widget.orgHomeData;
    final onNavigateToTab = widget.onNavigateToTab;
    final selectedOrg = cubit.state.selectedOrganization;
    final orgId = selectedOrg?.id;
    final isDark = context.isDarkMode;

    final statCards = [
      (
        title: 'Active clients',
        color: const Color(0xFF15803D),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDCFCE7),
            Color(0xFFBBF7D0),
          ],
        ),
        prefix: null,
        count: orgHomeData.activeCustomersCount ?? 0,
        onTap: () {
          if (orgId != null) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ActiveMembersListingScreen(orgId: orgId),
              ),
            );
          }
        },
      ),
      (
        title: 'Expired Clients',
        color: const Color(0xFFC0392B),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFCDD2),
            Color(0xFFFFAB91),
          ],
        ),
        prefix: null,
        count: orgHomeData.expiredCustomersCount ?? 0,
        onTap: () {
          if (orgId != null) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ExpiredMembersListingScreen(orgId: orgId),
              ),
            );
          }
        },
      ),
      (
        title: 'Total clients',
        color: const Color(0xFF9C51BF),
        gradient: null,
        prefix: null,
        count: orgHomeData.totalCustomers ??
            orgHomeData.totalCustomersCount ??
            ((orgHomeData.trainerCount ?? 0) +
                (orgHomeData.activeCustomersCount ?? 0)),
        onTap: () {
          if (orgId != null) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => MembersAndLeadsListingScreen(orgId: orgId),
              ),
            );
          }
        },
      ),
      (
        title: 'Freezed Clients',
        color: const Color(0xFF0284C7),
        gradient: null,
        prefix: null,
        count: orgHomeData.freezedCustomersCount ?? 0,
        onTap: () {
          if (orgId != null) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => FreezedMembersListingScreen(orgId: orgId),
              ),
            );
          }
        },
      ),
      (
        title: 'Upcoming Renewals',
        color: const Color(0xFFC85074),
        gradient: null,
        prefix: null,
        count: orgHomeData.upcomingRenewalsCount ?? 0,
        onTap: () {
          if (orgId != null) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => UpcomingRenewalsListingScreen(orgId: orgId),
              ),
            );
          }
        },
      ),
      (
        title: 'Total Payments',
        color: const Color(0xFF0D9488),
        gradient: null,
        prefix: '₹',
        count: orgHomeData.allPaymentCount ?? 0,
        onTap: () => onNavigateToTab(3), // Navigate to Payments tab
      ),
    ];

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: DesktopContentConstraint(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── Welcome Banner / Quick Info ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF261819), const Color(0xFF1A1A1A)]
                    : [const Color(0xFFFFF1F1), const Color(0xFFF9FAFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to ${selectedOrg?.name ?? "Your Fitness Center"}',
                        style: AppStyles.text20Px.poppins.w700.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor attendance, revenue, trainer performance, and memberships in one central dashboard.',
                        style: AppStyles.text13Px.poppins.w400.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _ActionPillButton(
                      label: 'Mark Trainer Attendance',
                      icon: Icons.assignment_ind_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        if (orgId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => TrainerAttendanceScreen(orgId: orgId),
                            ),
                          );
                        }
                      },
                    ),
                    _ActionPillButton(
                      label: 'Mark Client Attendance',
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF16A34A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => ClientAttendanceScreen(
                            orgId: cubit.state.selectedOrganization?.id ?? 0,
                          ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Section Title ──
          Text(
            'Performance Overview',
            style: AppStyles.text18Px.poppins.w700.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // ── Responsive Metrics Grid ──
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth < 650
                  ? 1
                  : (constraints.maxWidth < 950
                      ? 2
                      : 3);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 130,
                ),
                itemCount: statCards.length,
                itemBuilder: (context, index) {
                  final card = statCards[index];
                  return DesktopStatCard(
                    title: card.title,
                    count: card.count,
                    color: card.color,
                    gradient: card.gradient,
                    prefix: card.prefix,
                    onTap: card.onTap,
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // ── Upcoming Payments Calendar ──
          if (orgId != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: UpcomingPaymentsWidget(orgId: orgId),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    ),
  );
}
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppStyles.text13Px.poppins.w600.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

