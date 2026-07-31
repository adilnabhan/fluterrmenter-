import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/edit_trainer_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/contact_support_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/screens/bank_listing_view_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/organization_details_model.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/faq_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class TrainerProfileSettingsScreen extends StatefulWidget {
  const TrainerProfileSettingsScreen({super.key});

  @override
  State<TrainerProfileSettingsScreen> createState() =>
      _TrainerProfileSettingsScreenState();
}

class _TrainerProfileSettingsScreenState
    extends State<TrainerProfileSettingsScreen> {
  String? _freshProfileUrl;

  @override
  void initState() {
    super.initState();
    _fetchFreshProfilePicture();
  }

  Future<void> _fetchFreshProfilePicture() async {
    try {
      final res = await DioClient().dio.get(ApiUris.editTrainerBasicDetails);
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        final url = data['profile_picture']?.toString();
        if (mounted && url != null && url.isNotEmpty && url != 'null') {
          setState(() => _freshProfileUrl = url);
        }
      }
    } catch (_) {
      // Silently fall back to cached URL
    }
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
    final user = context.watch<AppCubit>().state.currentUser;

    final trainerName =
        '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim();

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
                  // Profile Photo
                  Builder(
                    builder: (context) {
                      // Prefer fresh URL from API, fall back to cached
                      String? profileUrl = _freshProfileUrl;
                      if (profileUrl == null || profileUrl.isEmpty) {
                        final pp = user?.profilePicture;
                        if (pp is String) {
                          profileUrl = pp;
                        } else if (pp is Map) {
                          profileUrl = (pp['url'] ?? pp['image'] ?? pp['profile_image'] ?? pp['profile_picture'])?.toString();
                        }
                      }
                      final hasImage = profileUrl != null && profileUrl.isNotEmpty && profileUrl != 'null';
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasImage
                            ? Image.network(
                                profileUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (_, error, ___) {
                                  debugPrint('=== Image load error: $error');
                                  return const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 40,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 40,
                              ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainerName.isNotEmpty ? trainerName : 'Trainer Profile',
                          style: AppStyles.text16Px.poppins.w600.dark,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'No email address',
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

            _buildSectionHeader('Account & Security'),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Manage Trainer Profile',
              isFirst: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditTrainerProfileScreen(),
                  ),
                );
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
                if (user?.mentor?.org?.id != null) {
                  final orgDetails = OrganizationDetailsModel(
                    id: user!.mentor!.org!.id,
                    name: user.mentor!.org!.name,
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BankListingViewScreen(orgDetails: orgDetails)));
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
