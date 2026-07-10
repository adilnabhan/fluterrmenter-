import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/settings/presentation/screens/contact_support_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = const [
    {
      'question': '1. What is Discipl?',
      'answer': 'Discipl is a fitness and wellness platform that helps users discover fitness centers, connect with trainers, participate in fitness challenges, track their progress, and maintain a healthy lifestyle.'
    },
    {
      'question': '2. How do I create an account?',
      'answer': 'Download the Discipl app, register using your mobile number, verify the OTP, and complete your profile.'
    },
    {
      'question': '3. Is Discipl free to use?',
      'answer': 'Yes, the basic features of Discipl are free to use. Some premium features or services may be available through paid subscriptions in the future.'
    },
    {
      'question': '4. How do I find fitness centers near me?',
      'answer': 'Go to the “Fitness Centers” section in the app. Discipl will display nearby gyms, fitness studios, yoga centers, and other fitness facilities based on your location.'
    },
    {
      'question': '5. Can I purchase gym memberships through Discipl?',
      'answer': 'Depending on the fitness center, you may be able to enquire about memberships and available packages through the app.'
    },
    {
      'question': '6. What is the WhatsApp Enquiry feature?',
      'answer': 'The WhatsApp Enquiry feature allows you to directly contact a fitness center through WhatsApp to learn about membership plans, facilities, offers, and other details.'
    },
    {
      'question': '7. Does Discipl own or operate the listed fitness centers?',
      'answer': 'No. Discipl acts as a platform connecting users with independent fitness centers and trainers. Each fitness center is responsible for its own services, pricing, facilities, and policies.'
    },
    {
      'question': '8. How do I track my workouts?',
      'answer': 'You can log your workouts manually and maintain your fitness activity records within the app.'
    },
    {
      'question': '9. What are fitness challenges?',
      'answer': 'Fitness challenges are activity-based programs designed to motivate users to achieve health and fitness goals while engaging with the Discipl community.'
    },
    {
      'question': '10. How do leaderboards work?',
      'answer': 'Leaderboards rank participants based on challenge criteria such as challenge completion, activity levels, or other fitness-related achievements.'
    },
    {
      'question': '11. How is my health data used?',
      'answer': 'Discipl uses your information only to provide app features, improve user experience, and support fitness-related services in accordance with the Privacy Policy.'
    },
    {
      'question': '12. Is my personal information secure?',
      'answer': 'Yes. Discipl follows industry-standard security practices to protect user information and data.'
    },
    {
      'question': '13. Can I delete my account?',
      'answer': 'Yes. You can request account deletion through the app settings or by contacting Discipl support.'
    },
    {
      'question': '14. What should I do if my workout records or app data are not updating?',
      'answer': 'Ensure you have a stable internet connection and the latest version of the app installed. If the issue persists, contact support.'
    },
    {
      'question': '15. What happens if challenge results appear incorrect?',
      'answer': 'You can report the issue through the support section. The Discipl team will review the information and provide assistance.'
    },
    {
      'question': '16. Can businesses advertise on Discipl?',
      'answer': 'Yes. Brands and businesses can promote products and services through Discipl’s advertising and sponsorship opportunities.'
    },
    {
      'question': '17. How can fitness centers join Discipl?',
      'answer': 'Fitness centers can register through the Discipl Mentor App or contact the Discipl team for onboarding assistance.'
    },
    {
      'question': '18. How can I contact Discipl support?',
      'answer': 'You can reach the Discipl support team through:\n\n• In-app support\n• Email support\n• Official WhatsApp support\n• Social media channels'
    },
    {
      'question': '19. Does Discipl provide medical advice?',
      'answer': 'No. Discipl does not provide medical diagnosis, treatment, or professional healthcare advice. Always consult a qualified healthcare professional before starting any fitness or nutrition program.'
    },
    {
      'question': '20. Can Discipl guarantee fitness results?',
      'answer': 'No. Individual results depend on factors such as consistency, lifestyle, nutrition, training, and personal health conditions.'
    },
    {
      'question': '21. Are rewards and offers guaranteed?',
      'answer': 'Rewards, offers, and promotional benefits are subject to eligibility criteria, availability, partner participation, and applicable terms and conditions.'
    },
    {
      'question': '22. Can Discipl change its features, challenges, or programs?',
      'answer': 'Yes. Discipl reserves the right to modify, suspend, or discontinue any feature, challenge, reward program, or promotional activity at any time.'
    },
    {
      'question': '23. Where can I find the Terms & Conditions and Privacy Policy?',
      'answer': 'The latest Terms & Conditions and Privacy Policy are available within the Discipl app and on the official website.'
    }
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final question = faq['question']!.toLowerCase();
      final answer = faq['answer']!.toLowerCase();
      return question.contains(_searchQuery) || answer.contains(_searchQuery);
    }).toList();

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
        title: Text(
          'Help Center / FAQ',
          style: AppStyles.text18Px.poppins.w600,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: TextField(
                  controller: _searchController,
                  style: AppStyles.text14Px.poppins.copyWith(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search FAQs',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.transparent,
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: const Icon(Icons.clear, color: Color(0xFF9E9E9E), size: 20),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 20,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textGrey.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No FAQs matched your search.',
                            style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFaqs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filteredFaqs.length) {
                        return const _StillNeedHelpCard();
                      }
                      final faq = filteredFaqs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _FaqItemTile(
                          question: faq['question']!,
                          answer: faq['answer']!,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaqItemTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItemTile({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItemTile> createState() => _FaqItemTileState();
}

class _FaqItemTileState extends State<_FaqItemTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? AppColors.primary.withOpacity(0.5) : const Color(0xFFE4E7EC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            widget.question,
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: _isExpanded ? AppColors.primary : Colors.black87,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: _isExpanded ? AppColors.primary : const Color(0xFF667085),
            size: 24,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.answer,
                  style: AppStyles.text14Px.poppins.w400.copyWith(
                    color: const Color(0xFF475467),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StillNeedHelpCard extends StatelessWidget {
  const _StillNeedHelpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.help_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Still Need Help?',
            style: AppStyles.text18Px.poppins.w600.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'If your question is not listed here, please contact the Discipl Support Team.',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactSupportScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Contact Support',
              style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
