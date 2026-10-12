import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationBottomNavBar extends StatelessWidget {
  const OrganizationBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.profileImageUrl,
  });
  final int currentIndex;
  final void Function(int) onTap;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;

    final items = [
      _NavBarItem(
        icon: SvgPicture.asset(
          currentIndex == 0
              ? 'assets/images/svg/icons/home_filled.svg'
              : 'assets/images/svg/icons/homeicon.svg',
          width: 24,
          height: 24,
          colorFilter: currentIndex == 0
              ? null
              : ColorFilter.mode(
                  context.colors.textSecondary,
                  BlendMode.srcIn,
                ),
        ),
        label: 'Home',
        isSelected: currentIndex == 0,
        onTap: () => onTap(0),
      ),
      if (!isTrainer) ...[
        _NavBarItem(
          icon: SvgPicture.asset(
            'assets/images/svg/icons/trainers.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              currentIndex == 1
                  ? AppColors.primary
                  : context.colors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          label: 'Trainers',
          isSelected: currentIndex == 1,
          onTap: () => onTap(1),
        ),
        _NavBarItem(
          icon: SvgPicture.asset(
            'assets/images/svg/icons/payments.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              currentIndex == 2
                  ? AppColors.primary
                  : context.colors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          label: 'Payments',
          isSelected: currentIndex == 2,
          onTap: () => onTap(2),
        ),
        _NavBarItem(
          icon: SvgPicture.asset(
            currentIndex == 3
                ? 'assets/images/svg/icons/report_filled.svg'
                : 'assets/images/svg/icons/reports.svg',
            width: 24,
            height: 24,
            colorFilter: currentIndex == 3
                ? null
                : ColorFilter.mode(
                    context.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
          ),
          label: 'Reports',
          isSelected: currentIndex == 3,
          onTap: () => onTap(3),
        ),
        _NavBarItem(
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: currentIndex == 4
                    ? AppColors.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: IgnorePointer(
              child: ProfileImage(
                url: profileImageUrl,
                radius: 26,
                isEdit: false,
              ),
            ),
          ),
          label: 'Profile',
          isSelected: currentIndex == 4,
          onTap: () => onTap(4),
          onLongPress: () {
            HapticFeedback.lightImpact();
            const AccountSwitcherSheet().show(context);
          },
        ),
      ] else ...[
        _NavBarItem(
          icon: Icon(
            Icons.fitness_center_rounded,
            color: currentIndex == 1
                ? AppColors.primary
                : context.colors.textSecondary,
            size: 22,
          ),
          label: 'Workouts',
          isSelected: currentIndex == 1,
          onTap: () => onTap(1),
        ),
        _NavBarItem(
          icon: Icon(
            Icons.directions_walk_rounded,
            color: currentIndex == 2
                ? AppColors.primary
                : context.colors.textSecondary,
            size: 24,
          ),
          label: 'Clients',
          isSelected: currentIndex == 2,
          onTap: () => onTap(2),
        ),
        _NavBarItem(
          icon: SvgPicture.asset(
            currentIndex == 3
                ? 'assets/images/svg/icons/report_filled.svg'
                : 'assets/images/svg/icons/reports.svg',
            width: 24,
            height: 24,
            colorFilter: currentIndex == 3
                ? null
                : ColorFilter.mode(
                    context.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
          ),
          label: 'Reports',
          isSelected: currentIndex == 3,
          onTap: () => onTap(3),
        ),
        _NavBarItem(
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: currentIndex == 4
                    ? AppColors.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: IgnorePointer(
              child: ProfileImage(
                url: profileImageUrl,
                radius: 20,
                isEdit: false,
              ),
            ),
          ),
          label: 'Profile',
          isSelected: currentIndex == 4,
          onTap: () => onTap(4),
          onLongPress: () {
            HapticFeedback.lightImpact();
            const AccountSwitcherSheet().show(context);
          },
        ),
      ],
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: context.isDarkMode ? context.colors.card : Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: context.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFEBEBEB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDarkMode ? 0.35 : 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabCount = items.length;
              final slotWidth = constraints.maxWidth / tabCount;
              final pillWidth = (slotWidth - 6).clamp(48.0, 72.0);
              const pillHeight = 52.0;
              final pillLeft =
                  (currentIndex * slotWidth) + (slotWidth - pillWidth) / 2;
              final pillTop = (constraints.maxHeight - pillHeight) / 2;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Smooth sliding pill indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    left: pillLeft,
                    top: pillTop,
                    width: pillWidth,
                    height: pillHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? AppColors.primary.withValues(alpha: 0.22)
                            : const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),

                  // Tab items row
                  Row(
                    children: items,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 26,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 1,
                      end: isSelected ? 1.08 : 1.0,
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: icon,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppStyles.text12Px.poppins.copyWith(
                  fontSize: 11,
                  height: 1.1,
                  color: isSelected
                      ? AppColors.primary
                      : context.colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
