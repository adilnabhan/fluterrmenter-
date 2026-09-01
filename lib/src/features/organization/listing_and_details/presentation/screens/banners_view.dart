
import 'package:flutter/scheduler.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/models/banner_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BannersView extends StatefulWidget {
  const BannersView({required this.banners, super.key});

  final List<BannerModel> banners;

  @override
  State<BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<BannersView> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final int _bannerCount;
  late final Duration _autoScrollDuration;
  late final Duration _animationDuration;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _bannerCount = widget.banners.length;
    _pageController = PageController();
    _autoScrollDuration = const Duration(seconds: 3);
    _animationDuration = const Duration(milliseconds: 400);

    if (_bannerCount > 1) {
      _ticker = Ticker(_autoScroll);
      _ticker!.start();
    }
  }

  void _autoScroll(Duration elapsed) {
    if (!mounted) return;
    if (_bannerCount <= 1) return;
    if (elapsed.inMilliseconds % _autoScrollDuration.inMilliseconds < 50) {
      final nextPage = (_currentPage + 1) % _bannerCount;
      _pageController.animateToPage(
        nextPage,
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onBannerTap(BannerModel banner) async {
    if (banner.redirectType == null || banner.contactNumber == null) return;
    
    final phone = banner.contactNumber!;
    Uri? uri;
    if (banner.redirectType == 'whatsapp') {
      uri = Uri.parse('https://wa.me/');
    } else if (banner.redirectType == 'phone') {
      uri = Uri.parse('tel:');
    }
    
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerCount == 1) {
      final banner = widget.banners[0];
      final imageUrl = banner.bannerImage ?? '';
      
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: GestureDetector(
          onTap: () => _onBannerTap(banner),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: ImageNetwork(
              imageUrl,
              height: double.maxFinite,
              width: double.maxFinite,
              errorWidget: ColoredBox(
                color: Colors.grey.shade200,
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _bannerCount,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                final imageUrl = banner.bannerImage ?? '';
                
                return GestureDetector(
                  onTap: () => _onBannerTap(banner),
                  child: ImageNetwork(
                    imageUrl,
                    height: double.maxFinite,
                    width: double.maxFinite,
                    errorWidget: ColoredBox(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_bannerCount, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color:
                      index == _currentPage
                          ? Colors.red
                          : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
