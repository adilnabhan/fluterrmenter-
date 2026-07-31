import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class GymBannersScreen extends StatefulWidget {
  const GymBannersScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymBannersScreen> createState() => _GymBannersScreenState();
}

class _GymBannersScreenState extends State<GymBannersScreen> {
  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  void _showLoading() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _fetchBanners() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.gymBanners,
        queryParameters: {'organization_id': widget.orgDetails.id},
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = (response.data is List)
            ? response.data as List
            : (response.data is Map && (response.data as Map)['results'] is List)
                ? (response.data as Map)['results'] as List
                : [];
        if (mounted) {
          setState(() {
            _banners = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Failed to load banners');
    }
  }

  void _showBannerForm({Map<String, dynamic>? existingBanner}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BannerFormSheet(
        orgId: widget.orgDetails.id ?? 0,
        existingBanner: existingBanner,
        onSuccess: _fetchBanners,
      ),
    );
  }

  Future<void> _deleteBanner(int bannerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    _showLoading();
    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.gymBannerDetail(bannerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (mounted) Navigator.pop(context); // Close loading dialog
      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 204) {
        Dialogs.showSnack(msg: 'Banner deleted successfully');
        _fetchBanners();
      } else {
        Dialogs.showSnack(msg: 'Failed to delete banner');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text('Banners', style: AppStyles.text16Px.poppins.w500),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _banners.isEmpty
              ? _buildEmptyState()
              : _buildBannersList(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xffEBEBEB))),
        ),
        child: Button.filled(
          raduis: 12,
          title: 'Add Banner',
          buttonColor: AppColors.primary,
          ontap: () => _showBannerForm(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Banners Uploaded',
              style: AppStyles.text18Px.poppins.w600.dark,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload banners to promote schedules, events, or updates. Banners will be displayed only to trainers and clients in this gym.',
              style: AppStyles.text14Px.poppins.w400.textGrey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _banners.length,
      itemBuilder: (context, index) {
        final banner = _banners[index];
        final id = banner['id'] as int? ?? 0;
        final imageUrl = banner['image'] as String? ?? '';
        final title = banner['title'] as String? ?? '';
        final websiteUrl = banner['website_url'] as String? ?? '';
        final whatsappNumber = banner['whatsapp_number'] as String? ?? '';
        final isActive = banner['is_active'] as bool? ?? true;
        final displayOrder = banner['display_order'] as int? ?? 1;
        final visibility = banner['visibility'] as String? ?? 'customer';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error),
                              ),
                            )
                          : Container(color: Colors.grey.shade200),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => _deleteBanner(id),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: AppStyles.text10Px.poppins.w600.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title.isNotEmpty ? title : 'Untitled Banner',
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Order: $displayOrder',
                            style: AppStyles.text12Px.poppins.w500.textGrey,
                          ),
                        ),
                      ],
                    ),
                    if (websiteUrl.isNotEmpty || whatsappNumber.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      if (websiteUrl.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.link, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                websiteUrl,
                                style: AppStyles.text12Px.poppins.w400.textGrey,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (whatsappNumber.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              whatsappNumber,
                              style: AppStyles.text12Px.poppins.w400.textGrey,
                            ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          visibility == 'both'
                              ? 'Visible on both Customer & Trainer apps'
                              : visibility == 'trainer'
                                  ? 'Visible on Trainer app only'
                                  : 'Visible on Customer app only',
                          style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showBannerForm(existingBanner: banner),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: AppStyles.text12Px.poppins.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerFormSheet extends StatefulWidget {
  final int orgId;
  final Map<String, dynamic>? existingBanner;
  final VoidCallback onSuccess;

  const _BannerFormSheet({
    required this.orgId,
    this.existingBanner,
    required this.onSuccess,
  });

  @override
  State<_BannerFormSheet> createState() => _BannerFormSheetState();
}

class _BannerFormSheetState extends State<_BannerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _webUrlController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _orderController;
  bool _isActive = true;
  String _visibility = 'customer';
  XFile? _localImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingBanner;
    _titleController = TextEditingController(text: existing?['title'] as String? ?? '');
    _webUrlController = TextEditingController(text: existing?['website_url'] as String? ?? '');
    _whatsappController = TextEditingController(text: existing?['whatsapp_number'] as String? ?? '');
    _orderController = TextEditingController(text: existing?['display_order']?.toString() ?? '1');
    _isActive = existing?['is_active'] as bool? ?? true;
    _visibility = existing?['visibility'] as String? ?? 'customer';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _webUrlController.dispose();
    _whatsappController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() {
        _localImage = file;
      });
    }
  }

  Future<void> _submit() async {
    final existing = widget.existingBanner;
    final isEdit = existing != null;

    if (_localImage == null && !isEdit) {
      Dialogs.showSnack(msg: 'Please select a banner image');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> fields = {
        'organization': widget.orgId,
        'title': _titleController.text.trim(),
        'website_url': _webUrlController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim(),
        'display_order': int.tryParse(_orderController.text) ?? 1,
        'is_active': _isActive,
        'visibility': _visibility,
      };

      if (_localImage != null) {
        fields['image'] = await MultipartFile.fromFile(
          _localImage!.path,
          filename: _localImage!.name,
        );
      }

      final formData = FormData.fromMap(fields);

      final response = isEdit
          ? await DioClient().dio.put<dynamic>(
              ApiUris.gymBannerDetail(existing['id'] as int),
              data: formData,
              options: Options(headers: {'X-Platform': platformSource}),
            )
          : await DioClient().dio.post<dynamic>(
              ApiUris.gymBanners,
              data: formData,
              options: Options(headers: {'X-Platform': platformSource}),
            );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        Dialogs.showSnack(
          msg: isEdit ? 'Banner updated successfully' : 'Banner uploaded successfully',
        );
        widget.onSuccess();
        if (mounted) Navigator.pop(context);
      } else {
        Dialogs.showSnack(msg: 'Operation failed');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingBanner != null;
    final networkImageUrl = widget.existingBanner?['image'] as String? ?? '';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Banner' : 'Add New Banner',
                    style: AppStyles.text18Px.poppins.w600.dark,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _localImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_localImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : networkImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: networkImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>
                                    const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Select Banner Image',
                                  style: AppStyles.text14Px.poppins.w500.textGrey,
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter banner title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _webUrlController,
                decoration: const InputDecoration(
                  labelText: 'Website URL (Optional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Number (Optional)',
                  hintText: '+91...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _visibility,
                decoration: const InputDecoration(
                  labelText: 'Visibility',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer Mobile App Only')),
                  DropdownMenuItem(value: 'trainer', child: Text('Trainer Mobile App Only')),
                  DropdownMenuItem(value: 'both', child: Text('Both Mobile Apps')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _visibility = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(
                        labelText: 'Display Order',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Text(
                        'Active',
                        style: AppStyles.text14Px.poppins.w600.dark,
                      ),
                      Switch(
                        value: _isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Button.filled(
                raduis: 12,
                title: isEdit ? 'Update Banner' : 'Upload Banner',
                isLoading: _isSaving,
                buttonColor: AppColors.primary,
                ontap: _submit,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
