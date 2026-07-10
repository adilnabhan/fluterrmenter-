import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF444444),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text('Contact Support', style: AppStyles.text18Px.poppins.w600),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ContactCard(
            icon: Icons.mail_outline,
            isSvg: false,
            title: 'Email',
            subtitle: 'info@thediscipl.com',
            description:
                'Get in touch via email for general inquiries or partnerships',
            onTap: () => _launchUrl('mailto:info@thediscipl.com'),
          ),
          const SizedBox(height: 16),
          _ContactCard(
            icon: 'assets/images/svg/icons/call.svg',
            isSvg: true,
            title: 'Phone',
            subtitle: '+91 9746458284',
            description:
                'Call us during business hours for immediate assistance',
            onTap: () => _launchUrl('tel:+919746458284'),
          ),
          const SizedBox(height: 16),
          _ContactCard(
            icon: 'assets/images/svg/icons/yt.svg',
            isSvg: true,
            title: 'Youtube',
            subtitle: '@DisciplFitnessHub',
            description:
                'Join Discipl and embrace a disciplined and fulfilling approach to fitness and wellness.',
            onTap:
                () => _launchUrl('https://www.youtube.com/@DisciplFitnessHub'),
          ),
          const SizedBox(height: 16),
          _ContactCard(
            icon: 'assets/images/svg/icons/fb.svg',
            isSvg: true,
            title: 'Facebook',
            subtitle: 'facebook.com/thediscipl',
            description:
                'Digitalize your fitness center and transform yourself through discipl.',
            onTap: () => _launchUrl('https://www.facebook.com/thediscipl'),
          ),
          const SizedBox(height: 16),
          _ContactCard(
            icon: 'assets/images/svg/icons/instagram.svg',
            isSvg: true,
            title: 'Instagram',
            subtitle: '@discipl__',
            description: 'Disciple - Walk Earn Live',
            onTap: () => _launchUrl('https://www.instagram.com/discipl__'),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final dynamic icon;
  final bool isSvg;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.isSvg,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isSvg
                ? SvgPicture.asset(
                  icon as String,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                )
                : Icon(icon as IconData, color: AppColors.primary, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
