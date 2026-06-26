import 'package:mentor_mobile_app/imports_bindings.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text('Trainer Profile', style: AppStyles.text16Px.poppins.w600.dark),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: AppColors.dark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 24),
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.lightPrimary,
                  child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'John Doe',
                  style: AppStyles.text22Px.poppins.w600.dark,
                ),
                const SizedBox(height: 4),
                Text(
                  'Elite Personal Trainer',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Experience & Specializations
          _buildSectionTitle('Expertise'),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoCard('5 Years', 'Experience'),
              const SizedBox(width: 16),
              _buildInfoCard('12+', 'Clients'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Powerlifting', 'Calisthenics', 'HIIT', 'Yoga'].map((s) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F7F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s, style: AppStyles.text12Px.poppins.w400.dark),
              )
            ).toList(),
          ),
          const SizedBox(height: 32),

          // Bio
          _buildSectionTitle('About Me'),
          const SizedBox(height: 12),
          Text(
            'Passionate about helping individuals transform their lives through fitness and proper nutrition. Specialized in strength training and functional movement.',
            style: AppStyles.text14Px.poppins.w400.textGrey,
          ),
          const SizedBox(height: 32),

          // Certifications
          _buildSectionTitle('Certifications'),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xffF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xffFFCECE),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Certified_Trainer.pdf',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text10Px.poppins.w400.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          
          Button.filled(
            title: 'Close',
            ontap: () => context.pop(),
            buttonColor: AppColors.primary,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.text16Px.poppins.w600.dark,
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffFFF5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffFFDADA)),
        ),
        child: Column(
          children: [
            Text(value, style: AppStyles.text16Px.poppins.w600.primary),
            Text(label, style: AppStyles.text12Px.poppins.w400.textGrey),
          ],
        ),
      ),
    );
  }
}
