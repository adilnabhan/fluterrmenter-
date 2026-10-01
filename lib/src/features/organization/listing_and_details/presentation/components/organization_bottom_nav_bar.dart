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

    return Container(
      decoration: BoxDecoration(color: context.colors.surface),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color:
                        currentIndex == 3
                            ? AppColors.primary
                            : context.colors.textSecondary,
                    size: 24,
                  ),
                  label: 'Reports',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavBarItem(
                  icon: IgnorePointer(
                    child: ProfileImage(
                      url: profileImageUrl,
                      radius: 23,
                      isEdit: false,
                    ),
                  ),
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    const AccountSwitcherSheet().show(context);
                  },
                  profileImageUrl: profileImageUrl,
                ),
              ] else ...[
                _NavBarItem(
                  icon: Icon(
                    Icons.fitness_center_rounded,
                    color:
                        currentIndex == 1
                            ? AppColors.primary
                            : context.colors.textSecondary,
                    size: 24,
                  ),
                  label: 'Workouts',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavBarItem(
                  icon: Icon(
                    Icons.directions_walk_rounded,
                    color:
                        currentIndex == 2
                            ? AppColors.primary
                            : context.colors.textSecondary,
                    size: 24,
                  ),
                  label: 'Clients',
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavBarItem(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color:
                        currentIndex == 3
                            ? AppColors.primary
                            : context.colors.textSecondary,
                    size: 24,
                  ),
                  label: 'Reports',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavBarItem(
                  icon: IgnorePointer(
                    child: ProfileImage(
                      url: profileImageUrl,
                      radius: 23,
                      isEdit: false,
                    ),
                  ),
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    const AccountSwitcherSheet().show(context);
                  },
                  profileImageUrl: profileImageUrl,
                ),
              ],
            ],
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
    this.profileImageUrl,
  });
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label == 'Profile')
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: icon,
            )
          else
            icon,
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.text13Px.poppins.copyWith(
              color: isSelected ? AppColors.primary : context.colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
