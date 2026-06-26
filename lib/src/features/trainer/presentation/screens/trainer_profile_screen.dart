import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/logout_sheet.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/presentation/components/sheets/account_switcher_sheet.dart';

class TrainerProfileSettingsScreen extends StatelessWidget {
  const TrainerProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text('Profile', style: AppStyles.text16Px.poppins.w500),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffEEEEEE)),
            ),
            child: Row(
              children: [
                ProfileImage(
                  isEdit: false,
                  radius: 80.w,
                  url: user?.profilePicture as String? ?? '',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim(),
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No email address',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.mobileNumber != null ? user!.mobileNumber.toString() : '',
                        style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu items list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffEEEEEE)),
            ),
            child: Column(
              children: [
                _buildProfileListItem(
                  context,
                  label: 'Account Verification',
                  icon: Icons.verified_user_outlined,
                  onTap: () {},
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xffF5F5F5)),
                _buildProfileListItem(
                  context,
                  label: 'Terms & Conditions',
                  icon: Icons.description_outlined,
                  onTap: () {},
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xffF5F5F5)),
                _buildProfileListItem(
                  context,
                  label: 'Privacy Policy',
                  icon: Icons.lock_outline_rounded,
                  onTap: () {},
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xffF5F5F5)),
                _buildProfileListItem(
                  context,
                  label: 'Switch/Add Account',
                  icon: Icons.people_outline,
                  onTap: () => const AccountSwitcherSheet().show(context),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xffF5F5F5)),
                _buildProfileListItem(
                  context,
                  label: 'Logout',
                  icon: Icons.logout,
                  isLogout: true,
                  onTap: () => const LogoutSheet().show(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileListItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isLogout ? Colors.red : AppColors.primary, size: 22),
      title: Text(
        label,
        style: isLogout
            ? AppStyles.text14Px.poppins.w500.copyWith(color: Colors.red)
            : AppStyles.text14Px.poppins.w500,
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.chevron_right, color: Color(0xffCCCCCC), size: 20),
      onTap: onTap,
    );
  }
}
