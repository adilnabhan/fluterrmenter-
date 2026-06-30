import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerCareerDetailsScreen extends StatefulWidget {
  const CreateTrainerCareerDetailsScreen({super.key});

  @override
  State<CreateTrainerCareerDetailsScreen> createState() => _CreateTrainerCareerDetailsScreenState();
}

class _CreateTrainerCareerDetailsScreenState extends State<CreateTrainerCareerDetailsScreen> {
  final List<Map<String, String>> _trainedCenters = [];
  final List<String> _selectedInterests = [];
  final List<String> _preferredLocations = [];
  final List<String> _languagesKnown = [];
  final TextEditingController _payRangeController = TextEditingController();

  final List<({String title, String subtitle, String value})> _interestOptions = [
    (
      title: 'Freelance Training',
      subtitle: 'Enhance your skills and earn through flexible freelance opportunities.',
      value: 'freelance'
    ),
    (
      title: 'Join Fitness Center',
      subtitle: 'Be a part of professional fitness team and work with dedicated clients.',
      value: 'join_center'
    ),
    (
      title: 'Collaborate for Events / workshops',
      subtitle: 'Team up with other professionals to host or support fitness events.',
      value: 'collaborate'
    ),
  ];

  @override
  void dispose() {
    _payRangeController.dispose();
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
                    bool isActive = index <= 2;
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
                  'Grow Your\nFitness Career 🌟',
                  style: AppStyles.text30Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Find new opportunities, connect with\ncenters, and expand your reach.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 32),

                // Current Training Centers
                _buildSectionLabel('Where you currently Train.'),
                const SizedBox(height: 16),
                if (_trainedCenters.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _trainedCenters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final center = _trainedCenters[index];
                      return _buildCenterCard(center, () {
                        if (!mounted) return;
                        setState(() => _trainedCenters.removeAt(index));
                      });
                    },
                  ),
                const SizedBox(height: 12),
                _buildAddButton('+ Add Fitness Center', () {
                  _showAddCenterSheet();
                }),

                const SizedBox(height: 32),
                // What are you looking for?
                _buildSectionLabel('What are you looking for?'),
                const SizedBox(height: 4),
                Text(
                  'Select all that matches your interest.',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 16),
                ..._interestOptions.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInterestCard(opt),
                )),

                const SizedBox(height: 32),
                // Opportunities matching
                _buildSectionLabel('Help us match you with the right\nopportunities.'),
                const SizedBox(height: 16),
                
                // Locations
                _buildAddButton('+ Add Preferred Locations', () {
                  _showAddLocationSheet();
                }),
                const SizedBox(height: 12),
                _buildTags(_preferredLocations, (String val) => setState(() => _preferredLocations.remove(val))),

                const SizedBox(height: 16),
                // Languages
                _buildAddButton('+ Add Languages Known', () {
                  _showAddLanguageSheet();
                }),
                const SizedBox(height: 12),
                _buildTags(_languagesKnown, (String val) => setState(() => _languagesKnown.remove(val))),

                const SizedBox(height: 24),
                // Pay Range
                _buildPayRangeField(),
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
              ontap: () => context.push(const CreateTrainerSocialMediaScreen()),
              buttonColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppStyles.text14Px.poppins.w600.dark,
    );
  }

  Widget _buildAddButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffFFF5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffFFDADA)),
        ),
        child: Center(
          child: Text(
            text,
            style: AppStyles.text14Px.poppins.w500.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterCard(Map<String, String> center, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffF0F0F0),
            child: Icon(Icons.business, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(center['name'] ?? '', style: AppStyles.text14Px.poppins.w600.dark),
                Text(center['type'] ?? '', style: AppStyles.text12Px.poppins.w400.textGrey),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: Text('Remove', style: AppStyles.text12Px.poppins.w500.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestCard(({String title, String subtitle, String value}) opt) {
    bool isSelected = _selectedInterests.contains(opt.value);
    return InkWell(
      onTap: () {
        if (!mounted) return;
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(opt.value);
          } else {
            _selectedInterests.add(opt.value);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffFFF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xffFFDADA) : const Color(0xffEEEEEE),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt.title,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ArcText(
                    opt.subtitle,
                    style: AppStyles.text12Px.poppins.w400.textGrey,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xffCCCCCC)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(List<String> tags, void Function(String) onRemove) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xffF7F7F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag, style: AppStyles.text12Px.poppins.w400.dark),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => onRemove(tag),
              child: const Icon(Icons.close, size: 14, color: Colors.grey),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPayRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _payRangeController,
          decoration: InputDecoration(
            hintText: 'Expected Pay Range (Optional)',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffEEEEEE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffEEEEEE)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCenterSheet() {
    // Show Modal Bottom Sheet for searching and adding centers
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCenterSheet(
        onAdd: (Map<String, String> center) {
          if (!mounted) return;
          setState(() => _trainedCenters.add(center));
        },
      ),
    );
  }

  void _showAddLocationSheet() {
    // Placeholder using AddCategorySheet structure or similar
    // For now, adding a simple manual entry or dummy data
    if (!mounted) return;
    setState(() {
      if (!_preferredLocations.contains('Location 1')) {
        _preferredLocations.add('Location 1');
      }
    });
  }

  void _showAddLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddLanguageSheet(
        onSelect: (String lang) {
          if (!_languagesKnown.contains(lang)) {
            if (!mounted) return;
            setState(() => _languagesKnown.add(lang));
          }
        },
      ),
    );
  }
}

class _AddCenterSheet extends StatefulWidget {
  const _AddCenterSheet({required this.onAdd});
  final void Function(Map<String, String>) onAdd;

  @override
  State<_AddCenterSheet> createState() => _AddCenterSheetState();
}

class _AddCenterSheetState extends State<_AddCenterSheet> {
  String _selectedWorkType = 'Full-time';
  final List<String> _workTypes = ['Full-time', 'Freelance', 'Contract'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Search your Fitness Center', style: AppStyles.text18Px.poppins.w600.dark),
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or location',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          // Dummy results
          Expanded(
            child: ListView.separated(
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                String name = index == 0 ? 'Olympion Gym' : 'Pulse Studio';
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: Color(0xffF0F0F0)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppStyles.text14Px.poppins.w600.dark),
                              Text('Ballygunge', style: AppStyles.text12Px.poppins.w400.textGrey),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedWorkType,
                              decoration: const InputDecoration(
                                labelText: 'Type of work',
                                border: OutlineInputBorder(),
                              ),
                              items: _workTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setState(() => _selectedWorkType = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Button.filled(
                            title: 'Done',
                            size: const Size(80, 48),
                            ontap: () {
                              widget.onAdd({'name': name, 'type': _selectedWorkType});
                              context.pop();
                            },
                            buttonColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
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

class _AddLanguageSheet extends StatelessWidget {
  const _AddLanguageSheet({required this.onSelect});
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final List<String> langs = ['Malayalam', 'English', 'Tamil', 'Hindi', 'Bengali'];
    return Container(
      height: context.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Languages Known', style: AppStyles.text18Px.poppins.w600.dark),
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Language',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: langs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(langs[index], style: AppStyles.text14Px.poppins.w500.dark),
                  trailing: const Icon(Icons.check, color: AppColors.primary),
                  onTap: () {
                    onSelect(langs[index]);
                    context.pop();
                  },
                );
              },
            ),
          ),
          Button.filled(
            title: 'Done',
            ontap: () => context.pop(),
            buttonColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// Simple helper to wrap text if it's too long, though ArcText might not be the right name if it's not curved
class ArcText extends StatelessWidget {
  const ArcText(this.text, {required this.style, super.key});
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}