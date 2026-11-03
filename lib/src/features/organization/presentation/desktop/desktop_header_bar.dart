import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/core/extensions/typography_extension.dart';
import 'package:mentor_mobile_app/core/themes/app_styles.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/cubit/listing_and_details/organization_listing_and_details_cubit.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_notifications_screen.dart';

/// Clean top bar for the desktop dashboard view.
class DesktopHeaderBar extends StatelessWidget {
  const DesktopHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.cubit,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final OrganizationListingAndDetailsCubit cubit;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final selectedOrg = cubit.state.selectedOrganization;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: title.isNotEmpty ? 14 : 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? context.colors.card : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title and breadcrumb / subtitle
          if (title.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppStyles.text20Px.poppins.w700.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            const Spacer(),

          // Custom trailing widget if passed
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 16),
          ],

          // Notifications
          NotificationBellButton(
            orgId: selectedOrg?.id,
            isTrainer: false,
            iconColor: context.colors.icon,
          ),
          const SizedBox(width: 8),

          // Settings Button
          IconButton(
            tooltip: 'Gym Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => SettingsScreen(
                    orgId: selectedOrg?.id,
                    name: selectedOrg?.name,
                    email: selectedOrg?.email,
                    logoUrl: selectedOrg?.logo,
                    orgDetailsCubit: cubit,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.settings_outlined,
              color: context.colors.icon,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

