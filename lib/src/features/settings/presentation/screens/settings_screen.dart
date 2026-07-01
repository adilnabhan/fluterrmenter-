import 'package:mentor_mobile_app/imports_bindings.dart';

class SettingsScreen extends StatelessWidget {
  final String? name;
  final String? email;
  final String? logoUrl;

  const SettingsScreen({super.key, this.name, this.email, this.logoUrl});

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
    required IconData icon,
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
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textDark.withOpacity(0.8),
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
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
                                    size: 30,
                                  ),
                            )
                            : const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                              size: 30,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? 'Amaze Fitness',
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email ?? 'johndoe@gmail.com',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textDark.withOpacity(0.5),
                          ),
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
            ),
            _buildSettingsItem(icon: Icons.assignment, title: 'Workout Plans'),
            _buildSettingsItem(
              icon: Icons.calendar_today,
              title: 'Membership Plans',
              isLast: true,
            ),

            _buildSectionHeader('Account & Security'),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Manage Gym Profile',
              isFirst: true,
            ),
            _buildSettingsItem(
              icon: Icons.phone_outlined,
              title: 'Change Phone number',
            ),
            _buildSettingsItem(
              icon: Icons.credit_card_outlined,
              title: 'Bank Account Details',
              isLast: true,
            ),

            _buildSectionHeader('Preferences'),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About Us',
              isFirst: true,
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
            ),
            _buildSettingsItem(
              icon: Icons.headset_mic_outlined,
              title: 'Contact Support',
            ),
            _buildSettingsItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              isLast: true,
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
                // Logout logic
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
