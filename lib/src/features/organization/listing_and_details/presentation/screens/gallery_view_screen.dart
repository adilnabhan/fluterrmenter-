import 'package:mentor_mobile_app/imports_bindings.dart';

class GalleryViewScreen extends StatefulWidget {
  const GalleryViewScreen({required this.images, required this.initialIndex, super.key});
  final List<PhotoModel> images;
  final int initialIndex;

  @override
  State<GalleryViewScreen> createState() => _GalleryViewScreenState();
}

class _GalleryViewScreenState extends State<GalleryViewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: Text('Gallery', style: AppStyles.text16Px.poppins.w500),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return ClipRRect(borderRadius: BorderRadius.circular(24), child: ImageNetwork(images[index].image ?? '', fit: BoxFit.cover, width: double.infinity, height: double.infinity));
                  },
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = index == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: Container(
                      decoration: BoxDecoration(border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null, borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: ImageNetwork(images[index].image ?? '', width: 70, height: 70, fit: BoxFit.cover)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
