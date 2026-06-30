import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateTrainerResultsScreen extends StatefulWidget {
  const CreateTrainerResultsScreen({super.key});

  @override
  State<CreateTrainerResultsScreen> createState() => _CreateTrainerResultsScreenState();
}

class _CreateTrainerResultsScreenState extends State<CreateTrainerResultsScreen> {
  final List<XFile> _galleryImages = [];
  final List<TransformationPair> _transformations = [
    TransformationPair(),
    TransformationPair(),
    TransformationPair(),
  ];

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
                    bool isActive = index <= 1;
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
                  'Results &\nRecognition 📸',
                  style: AppStyles.text30Px.poppins.w600.dark,
                ),
                const SizedBox(height: 16),

                Text(
                  'Give members a visual feel of what\nthey can expect.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 32),

                // Gallery Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _galleryImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _galleryImages.length) {
                      return _buildImageItem(_galleryImages[index], () {
                        if (!mounted) return;
                        setState(() => _galleryImages.removeAt(index));
                      });
                    }
                    return _buildAddButton(() {
                      ImagePickerDialog(
                        allowMultiple: true,
                        needRemove: false,
                        onPickedImages: (images) {
                          if (!mounted) return;
                          setState(() => _galleryImages.addAll(images));
                        },
                      ).show(context);
                    });
                  },
                ),

                const SizedBox(height: 32),
                Text(
                  'Show the transformations you have\ngiven to your clients.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 16),

                // Transformations List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transformations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _TransformationCard(
                      pair: _transformations[index],
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Buttons
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => context.push(const TrainerCreationSuccessScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFE0E0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Skip',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Button.filled(
                  title: "Next -> Let's Add Some Details!",
                  ontap: () {
                    // Commented out API calls as requested
                    /*
                    final galleryPaths = _galleryImages.map((e) => e.path).toList();
                    final transformationsData = _transformations
                        .where((t) => t.before != null && t.after != null)
                        .map((t) => {'before': t.before!.path, 'after': t.after!.path})
                        .toList();
                    // Call API here...
                    */
                    context.push(const CreateTrainerCareerDetailsScreen());
                  },
                  buttonColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(XFile image, VoidCallback onDelete) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(image.path), fit: BoxFit.cover),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1, style: BorderStyle.solid),
        ),
        child: const Center(child: Icon(Icons.add, size: 32, color: AppColors.primary)),
      ),
    );
  }
}

class TransformationPair {
  XFile? before;
  XFile? after;
}

class _TransformationCard extends StatelessWidget {
  const _TransformationCard({required this.pair, required this.onChanged});

  final TransformationPair pair;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildImageSlot(context, pair.before, 'Before', (file) {
          pair.before = file;
          onChanged();
        })),
        const SizedBox(width: 16),
        Expanded(child: _buildImageSlot(context, pair.after, 'After', (file) {
          pair.after = file;
          onChanged();
        })),
      ],
    );
  }

  Widget _buildImageSlot(BuildContext context, XFile? image, String label, void Function(XFile) onPicked) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: InkWell(
        onTap: () {
          ImagePickerDialog(
            needRemove: false,
            onPickedImage: (file) {
              if (file != null) onPicked(file);
            },
          ).show(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffF0F0F0),
            borderRadius: BorderRadius.circular(12),
            border: image == null ? Border.all(color: const Color(0xFFFFDADA), style: BorderStyle.values[1]) : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(image.path), fit: BoxFit.cover),
                )
              else
                const Center(child: Icon(Icons.add, color: AppColors.primary, size: 24)),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text(label, style: AppStyles.text10Px.poppins.w500.dark.copyWith(fontStyle: FontStyle.italic)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
