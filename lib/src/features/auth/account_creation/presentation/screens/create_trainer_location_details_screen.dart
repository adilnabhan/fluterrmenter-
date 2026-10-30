import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/services/google/services/location_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
class CreateTrainerLocationDetailsScreen extends StatefulWidget {
  const CreateTrainerLocationDetailsScreen({super.key});

  @override
  State<CreateTrainerLocationDetailsScreen> createState() => _CreateTrainerLocationDetailsScreenState();
}

class _CreateTrainerLocationDetailsScreenState extends State<CreateTrainerLocationDetailsScreen> {
  late final List<List<FieldData<dynamic>>> _locationFields;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _locationFields = [
      [
        FieldData(
          type: FieldType.word,
          label: 'Street / Road Name',
          requiredLabel: true,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Street Name',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          label: 'City',
          requiredLabel: true,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'City Name',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          label: 'State',
          requiredLabel: true,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'State',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
          ),
        ),
      ],
      [
        FieldData(
          type: FieldType.word,
          label: 'Pin code',
          requiredLabel: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          controller: TextEditingController(),
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Pin code',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
          ),
        ),
      ],
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var row in _locationFields) {
      for (var field in row) {
        field.controller?.dispose();
        field.focusNode?.dispose();
      }
    }
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _onNext() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = LocalStorageService().getUser();
      final String street = _locationFields[0][0].controller?.text.trim() ?? '';
      final String city = _locationFields[1][0].controller?.text.trim() ?? '';
      final String state = _locationFields[2][0].controller?.text.trim() ?? '';
      final String pincode = _locationFields[3][0].controller?.text.trim() ?? '';
      final List<String> parts = [street, city, state, pincode].where((e) => e.isNotEmpty).toList();
      final String locationStr = parts.join(', ');

      final formData = FormData.fromMap({
        'location': locationStr,
        'user_type': 'trainer',
      });
      
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
            location: updatedUser.location,
          );
          LocalStorageService().saveUser(mergedUser);
        }
      }

      if (mounted) {
        context.push(const TrainerCreationSuccessScreen());
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to upload location. Please try again.');
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 10),
                  // Progress Indicator (Step 8/8 or 7/8)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      bool isActive = index <= 5; 
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
                    'Put Your\nPlace on\nthe Map 🌍',
                    style: AppStyles.text30Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Place yourself on the map and let your influence grow.',
                    style: AppStyles.text14Px.poppins.w400.textGrey,
                  ),
                  const SizedBox(height: 32),

                  // Search Field Placeholder
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for your location',
                      hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/images/svg/icons/search.svg', height: 20, width: 20, color: AppColors.textGrey),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffEEEEEE))),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Location Button
                  InkWell(
                    onTap: () async {
                      try {
                        Fluttertoast.showToast(msg: 'Fetching location...');
                        final placemarks = await LocationService().currentLocation();
                        if (placemarks.isNotEmpty) {
                          final place = placemarks.first;
                          if (!mounted) return;
                          setState(() {
                            _locationFields[0][0].controller?.text = place.street ?? place.subLocality ?? place.name ?? '';
                            _locationFields[1][0].controller?.text = place.locality ?? place.subAdministrativeArea ?? '';
                            _locationFields[2][0].controller?.text = place.administrativeArea ?? '';
                            _locationFields[3][0].controller?.text = place.postalCode ?? '';
                          });
                          Fluttertoast.showToast(msg: 'Location fetched successfully');
                        }
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffFFDADA)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Use your current location', style: AppStyles.text14Px.poppins.w600.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Location Fields
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _locationFields.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return Field(data: _locationFields[index][0]);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Bottom Button
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
              child: Button.filled(
                title: 'Next',
                ontap: _onNext,
                isLoading: _isLoading,
                buttonColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
