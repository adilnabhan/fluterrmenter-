import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/app/cubit/app_cubit.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
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
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/gym_banners_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_notifications_screen.dart';

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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(
        title,
        style: AppStyles.text13Px.poppins.w500.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
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
          border:
              isLast
                  ? null
                  : Border(bottom: BorderSide(color: context.colors.divider)),
        ),
        child: Row(
          children: [
            if (svgIconPath != null)
              SvgPicture.asset(
                svgIconPath,
                width: 20,
                height: 20,
                colorFilter:
                    iconColor != null
                        ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                        : (context.isDarkMode
                            ? const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            )
                            : null),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 20,
                color: iconColor ?? context.colors.icon,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: textColor ?? context.colors.textPrimary,
                ),
              ),
            ),
            if (textColor == null)
              Icon(Icons.chevron_right, size: 20, color: context.colors.icon),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgDetails = this.orgDetails;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        leading: const PopButton().center,
        iconTheme: IconThemeData(color: context.colors.icon),
        title: Text(
          'Settings',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colors.background,
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
                color: context.colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.05),
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
                      color: context.colors.fieldFill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        logoUrl != null && logoUrl!.isNotEmpty
                            ? Image.network(
                              logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
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
                          style: AppStyles.text16Px.poppins.w600.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email ?? 'No email address',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: context.colors.textSecondary,
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

            _buildSectionHeader(context, 'For Trainers and Clients'),
            _buildSectionCard(context, [
              _buildSettingsItem(
                context,
                icon: Icons.fitness_center,
                title: 'Workout Library',
                isFirst: true,
                onTap: () {
                  if (orgDetails != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => OrganizationWorkoutLibraryScreen(
                              orgDetails: orgDetails!,
                            ),
                      ),
                    );
                  } else {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const SelectExerciseSheetContent(
                        title: 'Select Workout',
                        hideYouCreated: true,
                        showAddButton: false,
                      ),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.assignment,
                title: 'Workout Plans',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutGroupsScreen(orgId: orgId),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.photo_library_outlined,
                title: 'Gallery',
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = GymGalleryScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'Packages',
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = GymPackagesScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.schedule,
                title: 'Schedules',
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = GymSchedulesScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.sports_gymnastics,
                title: 'Amenities',
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = GymAmenitiesScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.add_photo_alternate_outlined,
                title: 'Banners',
                isLast: true,
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = GymBannersScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => page),
                    );
                  }
                },
              ),
            ]),

            _buildSectionHeader(context, 'Account & Security'),
            _buildSectionCard(context, [
              _buildSettingsItem(
                context,
                icon: Icons.person_outline,
                title: 'Gym Details',
                isFirst: true,
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = GymDetailsScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    } else {
                      page = BlocProvider<OrganizationListingAndDetailsCubit>(
                        create: (_) => OrganizationListingAndDetailsCubit(),
                        child: page,
                      );
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.phone_outlined,
                title: 'Change Phone number',
              ),
              _buildSettingsItem(
                context,
                icon: Icons.credit_card_outlined,
                title: 'Bank Account Details',
                isLast: true,
                onTap: () {
                  if (orgDetails != null) {
                    Widget page = BankListingViewScreen(orgDetails: orgDetails!);
                    if (orgDetailsCubit != null) {
                      page =
                          BlocProvider<
                            OrganizationListingAndDetailsCubit
                          >.value(value: orgDetailsCubit!, child: page);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page),
                    );
                  }
                },
              ),
            ]),

            _buildSectionHeader(context, 'Preferences'),
            _buildSectionCard(context, [
              _buildSettingsItem(
                context,
                svgIconPath: 'assets/images/svg/icons/discipl_logo.svg',
                title: 'About Us',
                isFirst: true,
                onTap: () {
                  launchUrl(Uri.parse('https://thediscipl.com/'));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => TrainerNotificationsScreen(
                        isTrainer: false,
                        orgId: orgId,
                      ),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.contrast,
                title: 'Themes',
                isLast: true,
              ),
            ]),

            _buildSectionHeader(context, 'Support & Legal'),
            _buildSectionCard(context, [
              _buildSettingsItem(
                context,
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
                context,
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
                context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {
                  launchUrl(Uri.parse('https://thediscipl.com/terms-conditions'));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                isLast: true,
                onTap: () {
                  launchUrl(Uri.parse('https://thediscipl.com/privacy-policy'));
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Logout
            _buildSectionCard(context, [
              _buildSettingsItem(
                context,
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
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final currentMode = state.themeMode;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Theme',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      Icons.wb_sunny_outlined,
                      color: context.colors.icon,
                    ),
                    title: Text(
                      'Light Mode',
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: currentMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) {
                          context.read<AppCubit>().changeThemeMode(val);
                          Navigator.pop(sheetContext);
                        }
                      },
                    ),
                    onTap: () {
                      context
                          .read<AppCubit>()
                          .changeThemeMode(ThemeMode.light);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.dark_mode_outlined,
                      color: context.colors.icon,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: currentMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) {
                          context.read<AppCubit>().changeThemeMode(val);
                          Navigator.pop(sheetContext);
                        }
                      },
                    ),
                    onTap: () {
                      context.read<AppCubit>().changeThemeMode(ThemeMode.dark);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.brightness_auto_outlined,
                      color: context.colors.icon,
                    ),
                    title: Text(
                      'System Default',
                      style: TextStyle(color: context.colors.textPrimary),
                    ),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: currentMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) {
                          context.read<AppCubit>().changeThemeMode(val);
                          Navigator.pop(sheetContext);
                        }
                      },
                    ),
                    onTap: () {
                      context
                          .read<AppCubit>()
                          .changeThemeMode(ThemeMode.system);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
