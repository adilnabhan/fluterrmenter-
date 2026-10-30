import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/widgets/dialogs/image_picker_dialog.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/auth/account_creation/presentation/screens/create_trainer_social_media_screen.dart';

class TransformationPair {
  XFile? before;
  XFile? after;
}

class CreateTrainerResultsScreen extends StatefulWidget {
  const CreateTrainerResultsScreen({super.key});

  @override
  State<CreateTrainerResultsScreen> createState() =>
      _CreateTrainerResultsScreenState();
}

class _CreateTrainerResultsScreenState
    extends State<CreateTrainerResultsScreen> {
  final List<XFile> _galleryImages = [];
  final List<TransformationPair> _transformations = [
    TransformationPair(),
  ];
  bool _isLoading = false;

  void _pickImage(void Function(XFile file) onPicked) {
    ImagePickerDialog(
      needRemove: false,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 75,
      onPickedImage: (file) {
        if (file != null) {
          onPicked(file);
        }
      },
    ).show(context);
  }

  Future<void> _onNext() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AppCubit>().state.currentUser;
      final localUser = LocalStorageService().getUser();
      final user = localUser ?? currentUser;

      final orgId =
          user?.organizationId ??
          user?.trainer?.organizationId ??
          user?.mentor?.org?.id;
      final trainerId =
          user?.trainer?.id?.toString() ??
          user?.mentor?.id?.toString() ??
          user?.id?.toString();

      final authToken = user?.access;
      final authHeaders = {
        'X-Platform': platformSource,
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'JWT $authToken',
      };

      // 1. Upload Gallery/Portfolio images
      for (final img in _galleryImages) {
        try {
          final formData = FormData.fromMap({
            'image': await MultipartFile.fromFile(img.path),
          });
          await DioClient().dio.post<dynamic>(
            ApiUris.portfolioImages,
            data: formData,
            options: Options(headers: authHeaders),
          );
        } catch (_) {}
      }

      // 2. Upload Transformations (same flow as Trainer Profile)
      for (final pair in _transformations) {
        if (pair.before == null && pair.after == null) continue;

        bool success = false;
        if (trainerId != null && trainerId.isNotEmpty) {
          try {
            bool beforeOk = true;
            bool afterOk = true;

            if (pair.before != null) {
              final beforeData = FormData.fromMap({
                'image': await MultipartFile.fromFile(pair.before!.path),
                'image_type': 'before',
              });
              final resB = await DioClient().dio.post<dynamic>(
                ApiUris.trainerTransformationImages(trainerId),
                data: beforeData,
                options: Options(headers: authHeaders),
              );
              beforeOk = resB.statusCode == 200 || resB.statusCode == 201;
            }

            if (pair.after != null) {
              final afterData = FormData.fromMap({
                'image': await MultipartFile.fromFile(pair.after!.path),
                'image_type': 'after',
              });
              final resA = await DioClient().dio.post<dynamic>(
                ApiUris.trainerTransformationImages(trainerId),
                data: afterData,
                options: Options(headers: authHeaders),
              );
              afterOk = resA.statusCode == 200 || resA.statusCode == 201;
            }

            if (beforeOk && afterOk) {
              success = true;
            }
          } catch (_) {}
        }

        // Fallback endpoint
        if (!success && pair.before != null && pair.after != null) {
          try {
            final formDataMap = <String, dynamic>{
              'before_image': await MultipartFile.fromFile(pair.before!.path),
              'after_image': await MultipartFile.fromFile(pair.after!.path),
            };
            if (orgId != null) formDataMap['organization_id'] = orgId;

            final res = await DioClient().dio.post<dynamic>(
              ApiUris.transformations,
              data: FormData.fromMap(formDataMap),
              options: Options(headers: authHeaders),
            );
            if (res.statusCode == 200 || res.statusCode == 201) {
              success = true;
            }
          } catch (_) {}
        }
      }

      if (mounted) {
        context.push(const CreateTrainerSocialMediaScreen());
      }
    } catch (e) {
      if (mounted) {
        context.push(const CreateTrainerSocialMediaScreen());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    bool isActive = index <= 1;
                    return Row(
                      children: [
                        Container(
                          width: 25,
                          height: 1,
                          color:
                              isActive ? AppColors.primary : AppColors.borderGrey,
                        ),
                        Transform.rotate(
                          angle: 0.785398,
                          child: Container(
                            width: 8,
                            height: 8,
                            color:
                                isActive
                                    ? AppColors.primary
                                    : AppColors.borderGrey,
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
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                        maxWidth: 1080,
                        maxHeight: 1080,
                        imageQuality: 75,
                        onPickedImages: (images) {
                          if (!mounted) return;
                          setState(() => _galleryImages.addAll(images));
                        },
                      ).show(context);
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Transformations Header
                Text(
                  'Transformations',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                const SizedBox(height: 6),
                Text(
                  'Show the transformations you have given to your clients.',
                  style: AppStyles.text14Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 16),

                // Transformations List (Starts with 1, with option to add more)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transformations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final pair = _transformations[index];
                    return _buildTransformationCard(pair, index);
                  },
                ),

                const SizedBox(height: 16),

                // Add Another Transformation Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _transformations.add(TransformationPair());
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffFFDADA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Another Transformation',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
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
                  onTap: () =>
                      context.push(const CreateTrainerSocialMediaScreen()),
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
                  isLoading: _isLoading,
                  ontap: _onNext,
                  buttonColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationCard(TransformationPair pair, int index) {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Row(
              children: [
                // Left: Before
                Expanded(
                  child: _buildTransformationSlot(
                    label: 'Before',
                    image: pair.before,
                    isLeft: true,
                    onTap: () => _pickImage((file) {
                      setState(() => pair.before = file);
                    }),
                    onRemove: () => setState(() => pair.before = null),
                  ),
                ),
                // Divider line
                Container(width: 2, color: Colors.white),
                // Right: After
                Expanded(
                  child: _buildTransformationSlot(
                    label: 'After',
                    image: pair.after,
                    isLeft: false,
                    onTap: () => _pickImage((file) {
                      setState(() => pair.after = file);
                    }),
                    onRemove: () => setState(() => pair.after = null),
                  ),
                ),
              ],
            ),
            // Delete card button if more than 1 transformation exists
            if (_transformations.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() => _transformations.removeAt(index)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformationSlot({
    required String label,
    required XFile? image,
    required bool isLeft,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null) ...[
            Image.file(
              File(image.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              bottom: 8,
              left: isLeft ? 8 : null,
              right: !isLeft ? 8 : null,
              child: InkWell(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Change',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF757575),
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add $label',
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Label Pill Badge
          Positioned(
            top: 12,
            left: isLeft ? 12 : null,
            right: !isLeft ? 12 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.primary,
              ),
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
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 32, color: AppColors.primary),
        ),
      ),
    );
  }
}
