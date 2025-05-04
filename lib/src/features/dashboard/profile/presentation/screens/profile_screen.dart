import 'package:mentor_mobile_app/imports_bindings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text('Profile', style: AppStyles.text16Px.poppins.w500)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                ProfileImage(isEdit: true, onChanged: (image) {}, radius: 80.w),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('Amaze Fitness', style: AppStyles.text14Px.poppins.w500), const SizedBox(height: 4), Text('amazefitness123@gmail.com', style: AppStyles.text12Px.poppins.w400)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...[
            _buildProfileListItem('Gym Details', () {}),
            _buildProfileListItem('Gallery', () {}),
            _buildProfileListItem('Services', () {}),
            _buildProfileListItem('Packages', () {}),
            _buildProfileListItem('Trainers', () {}),
            _buildProfileListItem('Schedules', () {}),
            _buildProfileListItem('Amenities', () {}),
            _buildProfileListItem('Wishes', () {}),
            _buildProfileListItem('Permissions', () {}),
            _ProfileListItem(label: 'Logout', onTap: () {}, isLogout: true),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileListItem(String label, VoidCallback onTap) {
    return Column(
      children: [
        _ProfileListItem(label: label, onTap: onTap),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.grey, // Light grey color for the divider
        ),
      ],
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({required this.label, required this.onTap, this.isLogout = false});
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: isLogout ? AppStyles.text14Px.poppins.w500.copyWith(color: Colors.red) : AppStyles.text14Px.poppins.w500),
      trailing: isLogout ? null : const Icon(Icons.chevron_right, color: Colors.black),
      onTap: onTap,
    );
  }
}
