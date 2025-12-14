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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: SvgPicture.asset(
                  'assets/images/svg/icons/homeicon.svg',
                  color:
                      currentIndex == 0
                          ? AppColors.primary
                          : AppColors.textGrey,
                ),
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
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
                icon: SvgPicture.asset(
                  'assets/images/svg/icons/payments.svg',
                  color:
                      currentIndex == 2
                          ? AppColors.primary
                          : AppColors.textGrey,
                ),
                label: 'Payments',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: SvgPicture.asset(
                  'assets/images/svg/icons/reports.svg',
                  color:
                      currentIndex == 3
                          ? AppColors.primary
                          : AppColors.textGrey,
                ),
                label: 'Reports',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              // Use a generic profile icon for now as we don't have the image URL
              _NavBarItem(
                // icon: Icon(
                //   Icons.person_outline_rounded,
                //   color:
                //       currentIndex == 4
                //           ? AppColors.primary
                //           : AppColors.textGrey,
                //   size: 26,
                // ),
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
                profileImageUrl: profileImageUrl,
              ),
            ],
          ),
        ),
      ),
    )));
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
