import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/auth/login/domain/models/login_with_otp_model.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainerCertificatesScreen extends StatefulWidget {
  final String? trainerId;
  final bool isViewOnly;
  final List<CertificateModel>? initialCertificates;

  const TrainerCertificatesScreen({
    super.key, 
    this.trainerId,
    this.isViewOnly = false,
    this.initialCertificates,
  });

  @override
  State<TrainerCertificatesScreen> createState() =>
      _TrainerCertificatesScreenState();
}

class _TrainerCertificatesScreenState extends State<TrainerCertificatesScreen> {
  bool _isLoading = false;
  List<CertificateModel> _certificates = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialCertificates != null) {
      _certificates = widget.initialCertificates!;
    } else {
      _fetchCertificates();
    }
  }

  void _uploadCertificate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _AddCertificateSheet(
            onSubmit: (file, name, issuedBy, issuedDate) {
              _submitCertificate(file, name, issuedBy, issuedDate);
            },
          ),
    );
  }

  Future<void> _submitCertificate(
    File file,
    String name,
    String issuedBy,
    String issuedDate,
  ) async {
    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'certificate_name': name,
        'issued_by': issuedBy,
        'issued_date': issuedDate,
        'certificate_file': await MultipartFile.fromFile(file.path),
      });

      final response = await DioClient().dio.post<dynamic>(
        ApiUris.certificates,
        data: formData,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Certificate uploaded successfully');
        _fetchCertificates(); // Refresh to get the new certificate in context
      } else {
        Fluttertoast.showToast(msg: 'Failed to upload certificate');
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.response?.data?.toString() ?? 'Error uploading certificate',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCertificate(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Certificate'),
            content: const Text(
              'Are you sure you want to delete this certificate?',
            ),
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
        ApiUris.deleteCertificate(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Fluttertoast.showToast(msg: 'Certificate deleted');
        _fetchCertificates();
      } else {
        Fluttertoast.showToast(msg: 'Failed to delete certificate');
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.response?.data?.toString() ?? 'Error deleting certificate',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCertificates() async {
    setState(() => _isLoading = true);
    try {
      final uri =
          widget.trainerId != null
              ? '${ApiUris.certificates}?trainer_id=${widget.trainerId}'
              : ApiUris.certificates;

      final response = await DioClient().dio.get<dynamic>(
        uri,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> certList = [];
        if (data is List) {
          certList = data;
        } else if (data is Map && data.containsKey('results')) {
          certList = data['results'] as List;
        } else if (data is Map && data.containsKey('data')) {
          certList = data['data'] as List;
        }

        if (mounted) {
          setState(() {
            _certificates =
                certList
                    .map(
                      (e) =>
                          CertificateModel.fromJson(e as Map<String, dynamic>),
                    )
                    .toList();
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load certificates');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final certificates = _certificates;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Certificates',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : certificates.isEmpty
              ? _buildEmptyState()
              : _buildCertificatesList(certificates),
      floatingActionButton:
          !widget.isViewOnly
              ? FloatingActionButton(
                onPressed: _isLoading ? null : _uploadCertificate,
                backgroundColor: Colors.red,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Certificates Yet',
            style: AppStyles.text16Px.poppins.w600.dark,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first certificate.',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesList(List<CertificateModel> certificates) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cert = certificates[index];
        final isPdf = cert.certificate?.toLowerCase().endsWith('.pdf') == true;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  isPdf
                      ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cert.certificate ?? '',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  const Icon(Icons.image, color: Colors.red),
                        ),
                      ),
            ),
            title: Text(
              cert.name?.isNotEmpty == true ? cert.name! : 'Certificate',
              style: AppStyles.text14Px.poppins.w600.dark,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle:
                cert.issuingAuthority?.isNotEmpty == true
                    ? Text(
                      cert.issuingAuthority!,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    )
                    : null,
            trailing:
                !widget.isViewOnly
                    ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteCertificate(cert.id!),
                    )
                    : null,
            onTap: () async {
              if (cert.certificate == null || cert.certificate!.isEmpty) {
                Fluttertoast.showToast(msg: 'Certificate file is missing');
                return;
              }

              Fluttertoast.showToast(msg: 'Opening certificate...');

              var urlString = cert.certificate!;
              if (urlString.startsWith('/')) {
                urlString = 'https://discipl-backend.onrender.com$urlString';
              } else if (!urlString.startsWith('http')) {
                urlString = 'https://$urlString';
              }

              final uri = Uri.tryParse(urlString);
              if (uri != null) {
                try {
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched) {
                    Fluttertoast.showToast(
                      msg: 'Could not find an app to open: $urlString',
                    );
                  }
                } catch (e) {
                  Fluttertoast.showToast(msg: 'Error launching: $e');
                }
              } else {
                Fluttertoast.showToast(msg: 'Invalid URL format');
              }
            },
          ),
        );
      },
    );
  }
}

class _AddCertificateSheet extends StatefulWidget {
  final Function(File file, String name, String issuedBy, String issuedDate)
  onSubmit;

  const _AddCertificateSheet({required this.onSubmit});

  @override
  State<_AddCertificateSheet> createState() => _AddCertificateSheetState();
}

class _AddCertificateSheetState extends State<_AddCertificateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuedByController = TextEditingController();
  final _issuedDateController = TextEditingController();
  File? _selectedFile;

  @override
  void dispose() {
    _nameController.dispose();
    _issuedByController.dispose();
    _issuedDateController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _issuedDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        Fluttertoast.showToast(msg: 'Please select a certificate file');
        return;
      }
      widget.onSubmit(
        _selectedFile!,
        _nameController.text.trim(),
        _issuedByController.text.trim(),
        _issuedDateController.text.trim(),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Add Certificate',
                    style: AppStyles.text18Px.poppins.w600.dark,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Certificate Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _issuedByController,
                    decoration: InputDecoration(
                      labelText: 'Issued By',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _issuedDateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Issued Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator:
                        (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _selectedFile == null
                          ? 'Select Certificate File'
                          : _selectedFile!.path
                              .split('\\')
                              .last
                              .split('/')
                              .last,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Upload Certificate',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
