import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentor_mobile_app/core/bloc/bloc.dart';
import 'package:mentor_mobile_app/core/extensions/typography_extension.dart';
import 'package:mentor_mobile_app/core/themes/app_colors.dart';
import 'package:mentor_mobile_app/core/themes/app_styles.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/core/widgets/profile_image.dart';
import 'package:mentor_mobile_app/src/app/cubit/app_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/creation/presentation/screens/screens.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/cubit/listing_and_details/organization_listing_and_details_cubit.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/organization_selection_sheet.dart';

class DesktopNavigationSidebar extends StatelessWidget {
  const DesktopNavigationSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.cubit,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final OrganizationListingAndDetailsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final selectedOrg = cubit.state.selectedOrganization;
    final width = isCollapsed ? 80.0 : 260.0;
    final defaultIconColor = isDark ? context.colors.textSecondary : Colors.black;
    final hoverIconColor = isDark ? context.colors.textPrimary : Colors.black;

    final navItems = [
      (
        index: 0,
        title: 'Home',
        iconBuilder: (BuildContext context, bool isSelected, bool isHovered) =>
            SvgPicture.asset(
              isSelected
                  ? 'assets/images/svg/icons/home_filled.svg'
                  : 'assets/images/svg/icons/homeicon.svg',
              width: 22,
              height: 22,
              colorFilter: isSelected
                  ? null
                  : ColorFilter.mode(
                      isHovered ? hoverIconColor : defaultIconColor,
                      BlendMode.srcIn,
                    ),
            ),
      ),
      (
        index: 1,
        title: 'Trainers',
        iconBuilder: (BuildContext context, bool isSelected, bool isHovered) =>
            SvgPicture.asset(
              isSelected
                  ? 'assets/images/svg/icons/coachIconSelected.svg'
                  : 'assets/images/svg/icons/trainers.svg',
              width: isSelected ? 20 : 22,
              height: isSelected ? 20 : 22,
              colorFilter: isSelected
                  ? null
                  : ColorFilter.mode(
                      isHovered ? hoverIconColor : defaultIconColor,
                      BlendMode.srcIn,
                    ),
            ),
      ),
      (
        index: 2,
        title: 'Members & Leads',
        iconBuilder: (BuildContext context, bool isSelected, bool isHovered) =>
            SvgPicture.asset(
              isSelected
                  ? 'assets/images/svg/icons/clientselected.svg'
                  : 'assets/images/svg/icons/clients.svg',
              width: 22,
              height: 22,
              colorFilter: isSelected
                  ? null
                  : ColorFilter.mode(
                      isHovered ? hoverIconColor : defaultIconColor,
                      BlendMode.srcIn,
                    ),
            ),
      ),
      (
        index: 3,
        title: 'Payments',
        iconBuilder: (BuildContext context, bool isSelected, bool isHovered) =>
            SvgPicture.asset(
              isSelected
                  ? 'assets/images/svg/icons/paymentsIconSelected.svg'
                  : 'assets/images/svg/icons/payments.svg',
              width: isSelected ? 20 : 22,
              height: isSelected ? 17 : 22,
              colorFilter: isSelected
                  ? null
                  : ColorFilter.mode(
                      isHovered ? hoverIconColor : defaultIconColor,
                      BlendMode.srcIn,
                    ),
            ),
      ),
      (
        index: 4,
        title: 'Reports & Analytics',
        iconBuilder: (BuildContext context, bool isSelected, bool isHovered) =>
            SvgPicture.asset(
              isSelected
                  ? 'assets/images/svg/icons/report_filled.svg'
                  : 'assets/images/svg/icons/reports.svg',
              width: 22,
              height: 22,
              colorFilter: isSelected
                  ? null
                  : ColorFilter.mode(
                      isHovered ? hoverIconColor : defaultIconColor,
                      BlendMode.srcIn,
                    ),
            ),
      ),
      (
        index: 5,
        title: 'Gym Profile',
        iconBuilder: (BuildContext context, bool isSelected, bool isHovered) {
          final logoUrl = selectedOrg?.logo;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isHovered
                        ? context.colors.textSecondary
                        : Colors.transparent),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: (logoUrl != null && logoUrl.isNotEmpty)
                  ? ProfileImage(
                      url: logoUrl,
                      radius: 20,
                      isEdit: false,
                      name: selectedOrg?.name,
                    )
                  : SvgPicture.asset(
                      'assets/images/svg/icons/discipl_logo.svg',
                      width: 16,
                      height: 16,
                    ),
            ),
          );
        },
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = !isCollapsed && constraints.maxWidth >= 170;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Logo & Header ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 16 : 12,
                  vertical: 18,
                ),
                child: isExpanded
                    ? Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              const OrganizationSelectionSheet().show(context, cubit);
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: (selectedOrg?.logo != null && selectedOrg!.logo!.isNotEmpty)
                                    ? ProfileImage(
                                        url: selectedOrg.logo,
                                        radius: 38,
                                        isEdit: false,
                                        name: selectedOrg.name,
                                      )
                                    : Center(
                                        child: SvgPicture.asset(
                                          'assets/images/svg/icons/discipl_logo.svg',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                const OrganizationSelectionSheet().show(context, cubit);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        selectedOrg?.name ?? 'DISCIPL',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyles.text14Px.poppins.w700.copyWith(
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: isDark ? context.colors.textSecondary : Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Collapse Sidebar',
                            onPressed: onToggleCollapse,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(
                              Icons.menu_open_rounded,
                              size: 20,
                              color: isDark ? context.colors.textSecondary : Colors.black,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: IconButton(
                          tooltip: 'Expand Sidebar',
                          onPressed: onToggleCollapse,
                          icon: (selectedOrg?.logo != null && selectedOrg!.logo!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ProfileImage(
                                    url: selectedOrg.logo,
                                    radius: 26,
                                    isEdit: false,
                                    name: selectedOrg.name,
                                  ),
                                )
                              : Icon(
                                  Icons.menu_rounded,
                                  size: 22,
                                  color: context.colors.textPrimary,
                                ),
                        ),
                      ),
              ),

              const Divider(height: 1, thickness: 1),

              const SizedBox(height: 8),

              // ── Navigation Menu Items ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  children: navItems.map((item) {
                    final isSelected = currentIndex == item.index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Tooltip(
                        message: !isExpanded ? item.title : '',
                        child: _SidebarItem(
                          iconBuilder: item.iconBuilder,
                          title: item.title,
                          isSelected: isSelected,
                          isCollapsed: !isExpanded,
                          onTap: () => onSelectTab(item.index),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // ── Theme Mode & Profile Footer ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 14 : 10,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme Mode Switcher
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        final appCubit = context.read<AppCubit>();
                        final next = appCubit.state.themeMode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                        appCubit.changeThemeMode(next);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          mainAxisAlignment:
                              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              size: 18,
                              color: isDark ? context.colors.textSecondary : Colors.black,
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isDark ? 'Light Mode' : 'Dark Mode',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.text13Px.poppins.w500.copyWith(
                                    color: isDark ? context.colors.textSecondary : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.iconBuilder,
    required this.title,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  final Widget Function(BuildContext context, bool isSelected, bool isHovered)
      iconBuilder;
  final String title;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final bgColor = widget.isSelected
        ? (isDark
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.primary.withValues(alpha: 0.1))
        : (_isHovered
            ? (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF3F4F6))
            : Colors.transparent);

    final textColor = widget.isSelected
        ? AppColors.primary
        : (_isHovered
            ? (isDark ? context.colors.textPrimary : Colors.black)
            : (isDark ? context.colors.textSecondary : Colors.black));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: widget.isSelected
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 0 : 14,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: widget.isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Center(
                      child: widget.iconBuilder(
                        context,
                        widget.isSelected,
                        _isHovered,
                      ),
                    ),
                  ),
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.text13Px.poppins.copyWith(
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (widget.isSelected)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

