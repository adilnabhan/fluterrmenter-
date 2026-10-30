import 'package:mentor_mobile_app/imports_bindings.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/src/features/organization/creation/presentation/components/brand_logo_picker.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_certificates_screen.dart';

class _LocalCertificate {
  final File file;
  final String name;
  final String issuedBy;
  final String issuedDate;

  _LocalCertificate({
    required this.file,
    required this.name,
    required this.issuedBy,
    required this.issuedDate,
  });
}

class CreateTrainerProfessionalDetailsScreen extends StatefulWidget {
  const CreateTrainerProfessionalDetailsScreen({super.key});

  @override
  State<CreateTrainerProfessionalDetailsScreen> createState() =>
      _CreateTrainerProfessionalDetailsScreenState();
}

class _CreateTrainerProfessionalDetailsScreenState
    extends State<CreateTrainerProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<String> _specializations;
  late final FieldData<dynamic> _experience;
  late final FieldData<dynamic> _bio;
  final List<_LocalCertificate> _localCertificates = [];
  XFile? _profileImage;
  final ValueNotifier<List<({String label, String value})>>
  _selectedSpecializations =
      ValueNotifier<List<({String label, String value})>>([]);

  @override
  void initState() {
    _experience = FieldData(
      type: FieldType.word,
      label: 'Year of Experience',
      controller: TextEditingController(),
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(),
    );

    _specializations = FieldData<String>(
      type: FieldType.checkbox,
      label: 'Specializations',
      requiredLabel: true,
      items: [],
      controller: TextEditingController(),
      focusNode: FocusNode(),
      selectedValues: _selectedSpecializations,
      decoration: const InputDecoration(hintText: 'Select categories'),
    );

    _bio = FieldData(
      type: FieldType.word,
      label: 'Personal Bio',
      controller: TextEditingController(),
      focusNode: FocusNode(),
      maxLines: 5,
      decoration: const InputDecoration(hintText: '150 words'),
    );

    super.initState();
  }

  @override
  void dispose() {
    _experience.controller?.dispose();
    _specializations.controller?.dispose();
    _bio.controller?.dispose();
    _experience.focusNode?.dispose();
    _specializations.focusNode?.dispose();
    _bio.focusNode?.dispose();
    _selectedSpecializations.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _openAddCertificateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCertificateSheet(
        onSubmit: (file, name, issuedBy, issuedDate) {
          setState(() {
            _localCertificates.add(
              _LocalCertificate(
                file: file,
                name: name,
                issuedBy: issuedBy,
                issuedDate: issuedDate,
              ),
            );
          });
        },
      ),
    );
  }

  Future<void> _onNext() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = LocalStorageService().getUser();
      // Update bio and experience
      final formData = FormData.fromMap({
        'experience_years':
            int.tryParse(_experience.controller?.text.trim() ?? '0') ?? 0,
        'bio': _bio.controller?.text.trim() ?? '',
        'user_type': 'trainer',
      });

      if (_profileImage != null) {
        formData.files.add(
          MapEntry(
            'profile_image',
            await MultipartFile.fromFile(_profileImage!.path),
          ),
        );
      }
      final authToken = user?.access ?? (mounted ? context.read<AppCubit>().state.currentUser?.access : null);
      final authHeaders = {
        'X-Platform': platformSource,
        if (authToken != null && authToken.isNotEmpty) 'Authorization': 'JWT $authToken',
      };

      final response = await DioClient().dio.put<dynamic>(
        ApiUris.editTrainerBasicDetails,
        data: formData,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final updatedUser = LoginSuccessModel.fromJson(responseData);
        if (user != null) {
          final mergedUser = user.copyWith(
            experienceYears: updatedUser.experienceYears,
            bio: updatedUser.bio,
          );
          LocalStorageService().saveUser(mergedUser);
        }
      }

      // Upload Certificates
      for (final cert in _localCertificates) {
        final certFormData = FormData.fromMap({
          'certificate_name': cert.name,
          'issued_by': cert.issuedBy,
          if (cert.issuedDate.isNotEmpty) 'issued_date': cert.issuedDate,
          'certificate_file': await MultipartFile.fromFile(cert.file.path),
        });
        await DioClient().dio.post<dynamic>(
          ApiUris.certificates,
          data: certFormData,
          options: Options(headers: authHeaders),
        );
      }

      if (mounted) {
        context.push(const CreateTrainerResultsScreen());
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to upload details. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 10),
            // Progress Indicator (2/10 steps done)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                bool isActive = index <= 0;
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
                            isActive ? AppColors.primary : AppColors.borderGrey,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 40),
            Center(
              child: BrandLogoPicker(
                isEdit: true,
                onChanged: (image) {
                  setState(() {
                    _profileImage = image;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Upload Profile Photo',
                style: AppStyles.text14Px.poppins.w500.dark,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Your Fitness\nJourney So Far 🏆',
              style: AppStyles.text30Px.poppins.w600.dark,
            ),
            const SizedBox(height: 16),
            Text(
              'Let users and centers know your expertise.',
              style: AppStyles.text14Px.poppins.w400.textGrey,
            ),
            const SizedBox(height: 32),
            Field(data: _experience),
            // Text(
            //   'Specializations*',
            //   style: AppStyles.text14Px.poppins.w500.dark,
            // ),
            const SizedBox(height: 16),
            Field<String>(
              data: _specializations.copyWith(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  await AddCategorySheet(
                    selectedValues:
                        _specializations.selectedValues?.value ?? [],
                    onSubmit: (values) {
                      _specializations.selectedValues?.value = [...values];
                    },
                  ).show(context);
                  if (context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Certifications', style: AppStyles.text14Px.poppins.w500.dark),
            const SizedBox(height: 8),
            // Certification Upload Box
            InkWell(
              onTap: _openAddCertificateSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffFFDADA)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Certificates',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_localCertificates.isNotEmpty) ...[
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _localCertificates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cert = _localCertificates[index];
                  final isPdf = cert.file.path.toLowerCase().endsWith('.pdf');

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
                        child: isPdf
                            ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  cert.file,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image, color: Colors.red),
                                ),
                              ),
                      ),
                      title: Text(
                        cert.name.isNotEmpty ? cert.name : 'Certificate',
                        style: AppStyles.text14Px.poppins.w600.dark,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: cert.issuedBy.isNotEmpty
                          ? Text(
                              cert.issuedBy,
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: AppColors.textGrey,
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _localCertificates.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            Field(data: _bio),
            const SizedBox(height: 40),
            Button.filled(
              title: 'Next',
              ontap: _onNext,
              isLoading: _isLoading,
              buttonColor: AppColors.primary,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
