import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/widgets/dialogs/image_picker_dialog.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditTrainerProfileScreen extends StatefulWidget {
  const EditTrainerProfileScreen({super.key});

  @override
  State<EditTrainerProfileScreen> createState() =>
      _EditTrainerProfileScreenState();
}

class _EditTrainerProfileScreenState extends State<EditTrainerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _experienceController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  late TextEditingController _youtubeController;
  late TextEditingController _whatsappController;

  String _selectedGender = 'male';
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppCubit>().state.currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _dobController = TextEditingController(text: user?.dateOfBirth ?? '');
    _experienceController = TextEditingController(
      text: user?.experienceYears?.toString() ?? '',
    );
    _bioController = TextEditingController(text: user?.bio ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _instagramController = TextEditingController(text: user?.instagram ?? '');
    _facebookController = TextEditingController(text: user?.facebook ?? '');
    _youtubeController = TextEditingController(text: user?.youtube ?? '');
    _whatsappController = TextEditingController(text: user?.whatsapp ?? '');
    final currentGender = user?.gender?.toLowerCase() ?? 'male';
    if (['male', 'female', 'other'].contains(currentGender)) {
      _selectedGender = currentGender;
    }

    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    try {
      final res = await DioClient().dio.get<dynamic>(
        ApiUris.editTrainerBasicDetails,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map<String, dynamic>;

        final firstName = data['first_name']?.toString() ?? '';
        final lastName = data['last_name']?.toString() ?? '';
        final email = data['email']?.toString() ?? '';
        final dob = (data['date_of_birth'] ?? data['dob'] ?? data['dateOfBirth'])?.toString() ?? '';
        final expRaw = (data['experience_years'] ?? data['experience_year'] ?? data['experience'])?.toString() ?? '';
        final bio = data['bio']?.toString() ?? '';
        final location = data['location']?.toString() ?? '';
        final instagram = data['instagram']?.toString() ?? '';
        final facebook = data['facebook']?.toString() ?? '';
        final youtube = data['youtube']?.toString() ?? '';
        final whatsapp = data['whatsapp']?.toString() ?? '';
        final gender = (data['gender']?.toString() ?? 'male').toLowerCase();

        if (mounted) {
          setState(() {
            if (firstName.isNotEmpty && _firstNameController.text.isEmpty) {
              _firstNameController.text = firstName;
            }
            if (lastName.isNotEmpty && _lastNameController.text.isEmpty) {
              _lastNameController.text = lastName;
            }
            if (email.isNotEmpty && _emailController.text.isEmpty) {
              _emailController.text = email;
            }
            if (dob.isNotEmpty && dob != 'null') {
              _dobController.text = dob;
            }
            if (expRaw.isNotEmpty && expRaw != 'null') {
              _experienceController.text = expRaw;
            }
            if (bio.isNotEmpty && bio != 'null' && _bioController.text.isEmpty) {
              _bioController.text = bio;
            }
            if (location.isNotEmpty && location != 'null' && _locationController.text.isEmpty) {
              _locationController.text = location;
            }
            if (instagram.isNotEmpty && instagram != 'null' && _instagramController.text.isEmpty) {
              _instagramController.text = instagram;
            }
            if (facebook.isNotEmpty && facebook != 'null' && _facebookController.text.isEmpty) {
              _facebookController.text = facebook;
            }
            if (youtube.isNotEmpty && youtube != 'null' && _youtubeController.text.isEmpty) {
              _youtubeController.text = youtube;
            }
            if (whatsapp.isNotEmpty && whatsapp != 'null' && _whatsappController.text.isEmpty) {
              _whatsappController.text = whatsapp;
            }

            if (['male', 'female', 'other'].contains(gender)) {
              _selectedGender = gender;
            }
          });
        }

        final currentUser = context.read<AppCubit>().state.currentUser;
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            firstName: firstName.isNotEmpty ? firstName : currentUser.firstName,
            lastName: lastName.isNotEmpty ? lastName : currentUser.lastName,
            email: email.isNotEmpty ? email : currentUser.email,
            dateOfBirth: dob.isNotEmpty && dob != 'null' ? dob : currentUser.dateOfBirth,
            experienceYears: int.tryParse(expRaw) ?? currentUser.experienceYears,
            gender: ['male', 'female', 'other'].contains(gender) ? gender : currentUser.gender,
            bio: bio.isNotEmpty && bio != 'null' ? bio : currentUser.bio,
            location: location.isNotEmpty && location != 'null' ? location : currentUser.location,
            instagram: instagram.isNotEmpty && instagram != 'null' ? instagram : currentUser.instagram,
            facebook: facebook.isNotEmpty && facebook != 'null' ? facebook : currentUser.facebook,
            youtube: youtube.isNotEmpty && youtube != 'null' ? youtube : currentUser.youtube,
            whatsapp: whatsapp.isNotEmpty && whatsapp != 'null' ? whatsapp : currentUser.whatsapp,
          );
          context.read<AppCubit>().addUser(updatedUser);
        }
      }
    } catch (_) {
      // Quietly ignore
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await ImagePickerDialog(
      needRemove: _selectedImage != null,
      onPickedImage: (file) {
        if (file != null) {
          setState(() {
            _selectedImage = File(file.path);
          });
        }
      },
    ).show(context);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = FormData.fromMap({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender,
        'date_of_birth': _dobController.text.trim(),
        'experience_years':
            int.tryParse(_experienceController.text.trim()) ?? 0,
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'youtube': _youtubeController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'user_type': 'trainer',
      });

      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            'profile_image',
            await MultipartFile.fromFile(_selectedImage!.path),
          ),
        );
      }

      final response = await DioClient().dio.put<dynamic>(
        ApiUris.editTrainerBasicDetails,
        data: formData,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (mounted) {
          final responseData = response.data as Map<String, dynamic>;
          final updatedUser = LoginSuccessModel.fromJson(responseData);
          final String? newProfilePic =
              (responseData['profile_picture']?.toString() ??
              responseData['profile_image']?.toString() ??
              responseData['data']?['profile_picture']?.toString() ??
              responseData['data']?['profile_image']?.toString() ??
              updatedUser.profilePicture) as String?;

          final currentUser = context.read<AppCubit>().state.currentUser;
          if (currentUser != null) {
            final mergedUser = currentUser.copyWith(
              firstName:
                  _firstNameController.text.trim().isNotEmpty
                      ? _firstNameController.text.trim()
                      : currentUser.firstName,
              lastName:
                  _lastNameController.text.trim().isNotEmpty
                      ? _lastNameController.text.trim()
                      : currentUser.lastName,
              email:
                  _emailController.text.trim().isNotEmpty
                      ? _emailController.text.trim()
                      : currentUser.email,
              mobileNumber:
                  updatedUser.mobileNumber ?? currentUser.mobileNumber,
              gender: _selectedGender,
              dateOfBirth:
                  _dobController.text.trim().isNotEmpty
                      ? _dobController.text.trim()
                      : currentUser.dateOfBirth,
              experienceYears:
                  int.tryParse(_experienceController.text.trim()) ??
                  currentUser.experienceYears,
              bio:
                  _bioController.text.trim().isNotEmpty
                      ? _bioController.text.trim()
                      : currentUser.bio,
              location:
                  _locationController.text.trim().isNotEmpty
                      ? _locationController.text.trim()
                      : currentUser.location,
              instagram:
                  _instagramController.text.trim().isNotEmpty
                      ? _instagramController.text.trim()
                      : currentUser.instagram,
              facebook:
                  _facebookController.text.trim().isNotEmpty
                      ? _facebookController.text.trim()
                      : currentUser.facebook,
              youtube:
                  _youtubeController.text.trim().isNotEmpty
                      ? _youtubeController.text.trim()
                      : currentUser.youtube,
              whatsapp:
                  _whatsappController.text.trim().isNotEmpty
                      ? _whatsappController.text.trim()
                      : currentUser.whatsapp,
              profilePicture: newProfilePic ?? currentUser.profilePicture,
            );
            context.read<AppCubit>().addUser(mergedUser);
          } else {
            context.read<AppCubit>().addUser(updatedUser);
          }

          Fluttertoast.showToast(msg: 'Profile updated successfully');
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to update profile');
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.response?.data?.toString() ?? 'Failed to update profile',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.currentUser;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        iconTheme: IconThemeData(color: context.colors.icon),
        title: Text(
          'Edit Profile',
          style: AppStyles.text18Px.poppins.w600.copyWith(color: context.colors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.colors.icon,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                          image:
                              _selectedImage != null
                                  ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                  : (user?.profilePicture != null &&
                                      user!.profilePicture
                                          .toString()
                                          .isNotEmpty)
                                  ? DecorationImage(
                                    image: NetworkImage(
                                      user.profilePicture.toString(),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            _selectedImage == null &&
                                    (user?.profilePicture == null ||
                                        user!.profilePicture.toString().isEmpty)
                                ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'First Name',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter first name',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Text(
                'Last Name',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter last name',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Email Address',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Location',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter location',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          dropdownColor: context.colors.card,
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: context.colors.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: context.colors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: context.colors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male', style: TextStyle(color: context.colors.textPrimary)),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female', style: TextStyle(color: context.colors.textPrimary)),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other', style: TextStyle(color: context.colors.textPrimary)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedGender = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Experience (Years)',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'E.g. 5',
                            hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                            filled: true,
                            fillColor: context.colors.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: context.colors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: context.colors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Date of Birth',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                style: TextStyle(color: context.colors.textPrimary),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1995, 1, 1),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _dobController.text =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  suffixIcon: Icon(Icons.calendar_today, size: 20, color: context.colors.icon),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Bio',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tell us a bit about yourself...',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Social Links',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'WhatsApp',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'WhatsApp Number',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Instagram',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _instagramController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Instagram Profile URL',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Facebook',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _facebookController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Facebook Profile URL',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'YouTube',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _youtubeController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'YouTube Channel URL',
                  hintStyle: TextStyle(color: context.colors.textSecondary.withOpacity(0.6)),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Save Changes',
                            style: AppStyles.text16Px.poppins.w600,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
