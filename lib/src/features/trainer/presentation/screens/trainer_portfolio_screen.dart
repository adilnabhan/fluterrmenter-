import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/widgets/dialogs/image_picker_dialog.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/auth/login/domain/models/login_with_otp_model.dart';

class TrainerPortfolioScreen extends StatefulWidget {
  const TrainerPortfolioScreen({super.key, this.heroImages, this.initialIndex});
  
  final List<String>? heroImages;
  final int? initialIndex;

  @override
  State<TrainerPortfolioScreen> createState() => _TrainerPortfolioScreenState();
}

class _TrainerPortfolioScreenState extends State<TrainerPortfolioScreen> {
  bool _isLoading = false;
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _uploadPortfolioImage() async {
    await ImagePickerDialog(
      needRemove: false,
      onPickedImage: (file) async {
        if (file != null) {
          await _submitPortfolioImage(File(file.path));
        }
      },
    ).show(context);
  }

  Future<void> _submitPortfolioImage(File file) async {
    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(file.path),
        'type': 'result',
      });

      final response = await DioClient().dio.post<dynamic>(
        ApiUris.portfolioImages,
        data: formData,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Portfolio image uploaded');
        _fetchTrainerDetails(); // Refresh to get the new image
      } else {
        Fluttertoast.showToast(msg: 'Failed to upload image');
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.response?.data?.toString() ?? 'Error uploading image',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePortfolioImage(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Image'),
            content: const Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.deletePortfolioImage(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Fluttertoast.showToast(msg: 'Image deleted');
        _fetchTrainerDetails();
      } else {
        Fluttertoast.showToast(msg: 'Failed to delete image');
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.response?.data?.toString() ?? 'Error deleting image',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTrainerDetails() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.editTrainerBasicDetails,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final updatedUser = LoginSuccessModel.fromJson(data);
        if (mounted) {
          context.read<AppCubit>().addUser(updatedUser);
        }
      }
    } catch (e) {
      // Silently fail or log
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;
    var portfolioImages = user?.trainer?.portfolioImages ?? [];
    final hasNoRealImages = portfolioImages.isEmpty;

    // Use hero images as a fallback to preview the UI if there are no real images
    if (hasNoRealImages && widget.heroImages != null) {
      portfolioImages = widget.heroImages!.map((img) => PortfolioImageModel(image: img)).toList();
    }

    final currentImage = portfolioImages.isNotEmpty && _currentIndex < portfolioImages.length 
        ? portfolioImages[_currentIndex].image ?? '' 
        : '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Blurred)
          if (currentImage.isNotEmpty)
            Image.network(
              currentImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassCircle(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      if (portfolioImages.isNotEmpty)
                        _buildGlassCircle(
                          icon: Icons.delete_outline,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            if (hasNoRealImages) {
                              Fluttertoast.showToast(msg: 'Cannot delete preview images');
                              return;
                            }
                            if (_currentIndex < portfolioImages.length) {
                              _deletePortfolioImage(portfolioImages[_currentIndex].id!);
                            }
                          },
                        ),
                    ],
                  ),
                ),
                
                // PageView or Empty State
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : hasNoRealImages && (widget.heroImages == null || widget.heroImages!.isEmpty)
                        ? _buildImmersiveEmptyState()
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              PageView.builder(
                          controller: _pageController,
                          itemCount: portfolioImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      portfolioImages[index].image ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Left Arrow
                        if (_currentIndex > 0)
                          Positioned(
                            left: 8,
                            child: _buildGlassCircle(
                              icon: Icons.arrow_back_ios_new,
                              size: 40,
                              onTap: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        // Right Arrow
                        if (_currentIndex < portfolioImages.length - 1)
                          Positioned(
                            right: 8,
                            child: _buildGlassCircle(
                              icon: Icons.arrow_forward_ios,
                              size: 40,
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                ),
                
                // Thumbnails
                if (portfolioImages.isNotEmpty && !_isLoading)
                  Container(
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 24, top: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: portfolioImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isSelected = _currentIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected 
                                        ? Border.all(color: Colors.white, width: 2)
                                        : Border.all(color: Colors.transparent, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      portfolioImages[index].image ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Floating Action Button
                        FloatingActionButton(
                          heroTag: 'upload_trainer_portfolio_btn',
                          onPressed: _uploadPortfolioImage,
                          backgroundColor: Colors.red,
                          elevation: 0,
                          mini: true,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCircle({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    double size = 48,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.2),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: size * 0.45),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImmersiveEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Portfolio Images',
            style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to upload a portfolio image.',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
