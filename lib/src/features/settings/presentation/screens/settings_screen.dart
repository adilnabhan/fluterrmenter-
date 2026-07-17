import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_packages_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/bank_listing_view_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_details_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/organization_workout_library_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/contact_support_screen.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/faq_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_gallery_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_schedules_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_amenities_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';

class SettingsScreen extends StatelessWidget {
  final int? orgId;
  final String? name;
  final String? email;
  final String? logoUrl;
  final OrganizationListingAndDetailsCubit? orgDetailsCubit;

  const SettingsScreen({
    super.key,
    this.orgId,
    this.name,
    this.email,
    this.logoUrl,
    this.orgDetailsCubit,
  });

  OrganizationDetailsModel? get orgDetails {
    if (orgDetailsCubit != null) {
      OrganizationDetailsModel? fullDetails;
      orgDetailsCubit!.state.details.fold(
        () {},
        (either) => either.fold(
          (l) {},
          (r) {
            if (r.id == orgId) fullDetails = r;
          },
        ),
      );
      if (fullDetails != null) return fullDetails;
    }

    if (orgId == null) return null;
    return OrganizationDetailsModel(id: orgId, name: name, email: email, logo: logoUrl);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(
        title,
        style: AppStyles.text13Px.poppins.w500.copyWith(
          color: AppColors.textDark.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    IconData? icon,
    String? svgIconPath,
    required String title,
    bool isFirst = false,
    bool isLast = false,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border:
              isLast
                  ? null
                  : Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            if (svgIconPath != null)
              SvgPicture.asset(
                svgIconPath,
                width: 20,
                height: 20,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.textDark.withValues(alpha: 0.8),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: textColor ?? AppColors.textDark,
                ),
              ),
            ),
            if (textColor == null)
              Icon(Icons.chevron_right, size: 20, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text('Settings', style: AppStyles.text16Px.poppins.w600.dark),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: logoUrl != null && logoUrl!.isNotEmpty
                        ? Image.network(
                            logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          )
                        : const Icon(
                            Icons.fitness_center,
                            color: AppColors.primary,
                            size: 40,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? 'Amaze Fitness',
                          style: AppStyles.text16Px.poppins.w600.dark,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email ?? 'No email address',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionHeader('For Trainers and Clients'),
            _buildSettingsItem(
              icon: Icons.fitness_center,
              title: 'Workout Library',
              isFirst: true,
              onTap: () {
                if (orgDetails != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrganizationWorkoutLibraryScreen(orgDetails: orgDetails!),
                    ),
                  );
                }
              },
            ),
            _buildSettingsItem(
              icon: Icons.assignment, 
              title: 'Workout Plans',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutGroupsScreen()));
              },
            ),
            _buildSettingsItem(
              icon: Icons.photo_library_outlined,
              title: 'Gallery',
              onTap: () {
                if (orgDetails != null) {
                  Widget page = GymGalleryScreen(orgDetails: orgDetails!);
                  if (orgDetailsCubit != null) {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>.value(
                      value: orgDetailsCubit!,
                      child: page,
                    );
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            ),
            _buildSettingsItem(
              icon: Icons.inventory_2_outlined,
              title: 'Packages',
              onTap: () {
                if (orgDetails != null) {
                  Widget page = GymPackagesScreen(orgDetails: orgDetails!);
                  if (orgDetailsCubit != null) {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>.value(
                      value: orgDetailsCubit!,
                      child: page,
                    );
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            ),
            _buildSettingsItem(
              icon: Icons.schedule,
              title: 'Schedules',
              onTap: () {
                if (orgDetails != null) {
                  Widget page = GymSchedulesScreen(orgDetails: orgDetails!);
                  if (orgDetailsCubit != null) {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>.value(
                      value: orgDetailsCubit!,
                      child: page,
                    );
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            ),
            _buildSettingsItem(
              icon: Icons.sports_gymnastics,
              title: 'Amenities',
              isLast: true,
              onTap: () {
                if (orgDetails != null) {
                  Widget page = GymAmenitiesScreen(orgDetails: orgDetails!);
                  if (orgDetailsCubit != null) {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>.value(
                      value: orgDetailsCubit!,
                      child: page,
                    );
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            ),

            _buildSectionHeader('Account & Security'),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Gym Details',
              isFirst: true,
              onTap: () {
                if (orgDetails != null) {
                  Widget page = GymDetailsScreen(orgDetails: orgDetails!);
                  if (orgDetailsCubit != null) {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>.value(
                      value: orgDetailsCubit!,
                      child: page,
                    );
                  } else {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>(
                      create: (_) => OrganizationListingAndDetailsCubit(),
                      child: page,
                    );
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            ),
            _buildSettingsItem(
              icon: Icons.phone_outlined,
              title: 'Change Phone number',
            ),
            _buildSettingsItem(
              icon: Icons.credit_card_outlined,
              title: 'Bank Account Details',
              isLast: true,
              onTap: () {
                if (orgDetails != null) {
                  Widget page = BankListingViewScreen(orgDetails: orgDetails!);
                  if (orgDetailsCubit != null) {
                    page = BlocProvider<OrganizationListingAndDetailsCubit>.value(
                      value: orgDetailsCubit!,
                      child: page,
                    );
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            ),

            _buildSectionHeader('Preferences'),
            _buildSettingsItem(
              svgIconPath: 'assets/images/svg/icons/discipl_logo.svg',
              title: 'About Us',
              isFirst: true,
              onTap: () {
                launchUrl(Uri.parse('https://thediscipl.com/'));
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
            ),
            _buildSettingsItem(
              icon: Icons.contrast,
              title: 'Themes',
              isLast: true,
            ),

            _buildSectionHeader('Support & Legal'),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help Center / FAQ',
              isFirst: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqScreen()),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.headset_mic_outlined,
              title: 'Contact Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                launchUrl(Uri.parse('https://thediscipl.com/terms-conditions'));
              },
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              isLast: true,
              onTap: () {
                launchUrl(Uri.parse('https://thediscipl.com/privacy-policy'));
              },
            ),

            const SizedBox(height: 24),
            // Logout
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Logout',
              isFirst: true,
              isLast: true,
              iconColor: const Color(0xFFE53935),
              textColor: const Color(0xFFE53935),
              onTap: () {
                const LogoutSheet().show(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
