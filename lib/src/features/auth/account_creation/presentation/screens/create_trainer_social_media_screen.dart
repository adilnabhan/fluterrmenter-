import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerSocialMediaScreen extends StatefulWidget {
  const CreateTrainerSocialMediaScreen({super.key});

  @override
  State<CreateTrainerSocialMediaScreen> createState() => _CreateTrainerSocialMediaScreenState();
}

class _CreateTrainerSocialMediaScreenState extends State<CreateTrainerSocialMediaScreen> {
  late final List<TextEditingController> _socialUrlControllers;
  late final List<FieldData<dynamic>> _socialFields;

  @override
  void initState() {
    super.initState();
    _socialUrlControllers = List.generate(5, (index) => TextEditingController());
    
    _socialFields = [
      _buildSocialField(0, 'Website', 'assets/images/svg/icons/website.svg'),
      _buildSocialField(1, 'WhatsApp', 'assets/images/svg/icons/whatsapp.svg', keyboardType: TextInputType.phone),
      _buildSocialField(2, 'Instagram', 'assets/images/svg/icons/instagram.svg'),
      _buildSocialField(3, 'Facebook', 'assets/images/svg/icons/face_book.svg'),
      _buildSocialField(4, 'YouTube', 'assets/images/svg/icons/youtube.svg'),
    ];
  }

  FieldData<dynamic> _buildSocialField(int index, String hint, String iconPath, {TextInputType? keyboardType}) {
    return FieldData(
      type: FieldType.word,
      controller: _socialUrlControllers[index],
      focusNode: FocusNode(),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: 'Add URL',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEEEEEE)),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(iconPath, height: 24, width: 24),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _socialUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (index) {
                    bool isActive = index <= 3;
                    return Row(
                      children: [
                        Container(
                          width: 25,
                          height: 1,
                          color: isActive ? AppColors.primary : AppColors.borderGrey,
                        ),
                        Transform.rotate(
                          angle: 0.785398,
                          child: Container(
                            width: 8,
                            height: 8,
                            color: isActive ? AppColors.primary : AppColors.borderGrey,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 40),

                Text(
                  'Show Your\nSocial Media\nHandles 📱',
                  style: AppStyles.text30Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your social links help users choose\nconfidently.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 32),

                Text(
                  'Social Media',
                  style: AppStyles.text14Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),
                
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _socialFields.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return Field(data: _socialFields[index]);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Button.filled(
              title: 'Next',
              ontap: () {
                // Commented out API calls
                /*
                final socialData = [
                  if (_socialUrlControllers[0].text.isNotEmpty) {'platform': 'website', 'url': _socialUrlControllers[0].text},
                  if (_socialUrlControllers[1].text.isNotEmpty) {'platform': 'whatsapp', 'url': _socialUrlControllers[1].text},
                  if (_socialUrlControllers[2].text.isNotEmpty) {'platform': 'instagram', 'url': _socialUrlControllers[2].text},
                  if (_socialUrlControllers[3].text.isNotEmpty) {'platform': 'facebook', 'url': _socialUrlControllers[3].text},
                  if (_socialUrlControllers[4].text.isNotEmpty) {'platform': 'youtube', 'url': _socialUrlControllers[4].text},
                ];
                */
                context.push(const CreateTrainerEarlyBirdOfferScreen());
              },
              buttonColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
