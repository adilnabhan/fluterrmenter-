import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';

class EditTrainerProfileScreen extends StatefulWidget {
  const EditTrainerProfileScreen({super.key});

  @override
  State<EditTrainerProfileScreen> createState() => _EditTrainerProfileScreenState();
}

class _EditTrainerProfileScreenState extends State<EditTrainerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  bool _isLoading = false;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppCubit>().state.currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    
    // We can prefill defaults or fetch actual details from profile
    _qualificationController = TextEditingController();
    _experienceController = TextEditingController();
    _bioController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = DioClient().dio;
      final formData = FormData.fromMap({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'experience': _experienceController.text.trim(),
        'bio': _bioController.text.trim(),
        'city': _addressController.text.trim(),
        if (_pickedImage != null)
          'profile_picture': await MultipartFile.fromFile(_pickedImage!.path),
      });

      final response = await dio.patch<dynamic>(
        ApiUris.updateMentorProfile,
        data: formData,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        Dialogs.showSnack(msg: 'Profile updated successfully');
        // Update user state locally
        final userState = context.read<AppCubit>().state.currentUser;
        if (userState != null) {
          final updatedUser = userState.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
          );
          context.read<AppCubit>().addUser(updatedUser);
        }
        Navigator.pop(context);
      } else {
        Dialogs.showSnack(msg: 'Failed to update profile');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: AppStyles.text16Px.poppins.w600.dark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Image picker header
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _pickedImage != null
                              ? FileImage(File(_pickedImage!.path))
                              : null,
                          child: _pickedImage == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _qualificationController,
                    decoration: const InputDecoration(
                      labelText: 'Qualification / Designation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Biography / Bio',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address (City)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
