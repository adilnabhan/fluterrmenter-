import 'package:mentor_mobile_app/imports_bindings.dart';

import 'dart:ui';

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
      decoration: const BoxDecoration(color: Colors.white),
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
                  // color:
                  //     currentIndex == 0
                  //         ? AppColors.primary
                  //         : AppColors.textGrey,
                ),
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              if (!isTrainer) ...[
                _NavBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/svg/icons/trainers.svg',
                    color:
                        currentIndex == 1
                            ? AppColors.primary
                            : AppColors.textGrey,
                  ),
                  label: 'Trainers',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
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
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                  profileImageUrl: profileImageUrl,
                ),
              ] else ...[
                _NavBarItem(
                  icon: Icon(
                    Icons.fitness_center_rounded,
                    color:
                        currentIndex == 1
                            ? AppColors.primary
                            : AppColors.textGrey,
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
                            : AppColors.textGrey,
                    size: 24,
                  ),
                  label: 'Clients',
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
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
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
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
    this.profileImageUrl,
  });
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profileImageUrl != null && label == 'Profile')
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: IgnorePointer(
                child: ProfileImage(
                  url: profileImageUrl,
                  radius: 25,
                  isEdit: false,
                ),
              ),
            )
          else
            icon,
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.text13Px.poppins.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
