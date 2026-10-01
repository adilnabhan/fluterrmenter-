import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/leads/add_or_edit_lead_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/cubit/members_and_leads_cubit.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class AddTrainerSearchScreen extends StatefulWidget {
  final int orgId;
  const AddTrainerSearchScreen({super.key, required this.orgId});

  @override
  State<AddTrainerSearchScreen> createState() => _AddTrainerSearchScreenState();
}

class _AddTrainerSearchScreenState extends State<AddTrainerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _foundTrainer;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final cleanVal = value.trim();
      if (cleanVal.length >= 10) {
        _searchTrainer(cleanVal);
      } else {
        setState(() {
          _foundTrainer = null;
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _searchTrainer(String mobile) async {
    setState(() {
      _isSearching = true;
      _foundTrainer = null;
      _errorMessage = null;
    });

    try {
      final res = await DioClient().dio.get<dynamic>(
        ApiUris.searchTrainer,
        queryParameters: {'mobile': mobile, 'organization_id': widget.orgId},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (res.statusCode == 200 && res.data is Map) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(res.data as Map);
        if (data['found'] == true && data['trainer'] is Map) {
          setState(() {
            _foundTrainer = Map<String, dynamic>.from(data['trainer'] as Map);
            _isSearching = false;
          });
        } else {
          setState(() {
            _errorMessage =
                data['message']?.toString() ??
                'No trainer found with this mobile number.';
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Search failed. Please try again.';
          _isSearching = false;
        });
      }
    } catch (e) {
      String msg = 'Failed to search trainer.';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      setState(() {
        _errorMessage = msg;
        _isSearching = false;
      });
    }
  }

  Future<void> _addExistingTrainer() async {
    if (_foundTrainer == null) return;
    setState(() => _isSubmitting = true);

    try {
      final dynamic rawTrainerId = _foundTrainer!['id'] ??
          _foundTrainer!['trainer_id'] ??
          _foundTrainer!['user_id'];
      final int? trainerId = rawTrainerId is num
          ? rawTrainerId.toInt()
          : int.tryParse(rawTrainerId?.toString() ?? '');
      if (trainerId == null) {
        Dialogs.showSnack(msg: 'Unable to identify trainer ID.');
        return;
      }
      final res = await DioClient().dio.post<dynamic>(
        ApiUris.addExistingTrainer,
        data: {'trainer_id': trainerId, 'organization_id': widget.orgId},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final msg =
            res.data is Map ? (res.data as Map)['message']?.toString() : null;
        Dialogs.showSnack(msg: msg ?? 'Trainer added successfully!');
        if (mounted) Navigator.pop(context, true);
      } else {
        final msg =
            res.data is Map ? (res.data as Map)['message']?.toString() : null;
        Dialogs.showSnack(msg: msg ?? 'Failed to add trainer.');
      }
    } catch (e) {
      String msg = 'Failed to add trainer.';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        } else if (data is Map && data['detail'] != null) {
          msg = data['detail'].toString();
        }
      }
      Dialogs.showSnack(msg: msg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTrainerCard(Map<String, dynamic> trainer) {
    final String fullName = trainer['full_name']?.toString().trim() ?? '';
    final String first = trainer['first_name']?.toString().trim() ?? '';
    final String last = trainer['last_name']?.toString().trim() ?? '';
    final String combined = '$first $last'.trim();
    final String name = fullName.isNotEmpty
        ? fullName
        : (combined.isNotEmpty
            ? combined
            : (trainer['name']?.toString().trim().isNotEmpty ?? false
                ? trainer['name'].toString().trim()
                : 'Unknown Trainer'));

    final mobile = trainer['mobile']?.toString() ??
        trainer['mobile_number']?.toString() ??
        trainer['phone']?.toString() ??
        '';
    final email = trainer['email']?.toString() ?? '';
    final bio = trainer['bio']?.toString() ?? '';

    final dynamic rawExp =
        trainer['experience_years'] ?? trainer['experience'];
    final int experience = rawExp is num
        ? rawExp.toInt()
        : int.tryParse(rawExp?.toString() ?? '') ?? 0;

    final List<String> specs = [];
    final dynamic specRaw =
        trainer['specializations'] ?? trainer['specialization'];
    if (specRaw is List) {
      for (final s in specRaw) {
        if (s is Map) {
          final str =
              (s['name'] ?? s['title'] ?? s['specialization'])?.toString().trim() ??
                  '';
          if (str.isNotEmpty) specs.add(str);
        } else if (s != null) {
          final str = s.toString().trim();
          if (str.isNotEmpty) specs.add(str);
        }
      }
    } else if (specRaw is String && specRaw.trim().isNotEmpty) {
      specs.addAll(
        specRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    final rawImg = (trainer['profile_image'] ??
            trainer['profile_picture'] ??
            trainer['image_url'])
        ?.toString()
        .trim();
    final bool hasValidImage = rawImg != null &&
        rawImg.isNotEmpty &&
        rawImg != 'null' &&
        (rawImg.startsWith('http://') || rawImg.startsWith('https://'));

    final dynamic rawLinked = trainer['already_linked_to_this_gym'] ??
        trainer['is_linked'] ??
        trainer['already_linked'];
    final bool alreadyLinked = rawLinked == true ||
        rawLinked == 1 ||
        rawLinked == '1' ||
        rawLinked.toString().toLowerCase() == 'true';

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: hasValidImage
                      ? CachedNetworkImage(
                          imageUrl: rawImg!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown Trainer',
                      style: AppStyles.text16Px.poppins.w600.dark,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mobile,
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: AppStyles.text13Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (experience > 0) ...[
            Text(
              'Experience: $experience years',
              style: AppStyles.text13Px.poppins.w600.dark,
            ),
            const SizedBox(height: 8),
          ],
          if (bio.isNotEmpty) ...[
            Text(
              bio,
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (specs.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  specs.map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF0F4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spec,
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xff486CC2),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                alreadyLinked
                    ? Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Already added to this gym',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : ElevatedButton(
                      onPressed: _isSubmitting ? null : _addExistingTrainer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Add Existing Trainer',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const PopButton().center,
        title: const Text('Add Trainer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Trainer', style: AppStyles.text20Px.poppins.w600.dark),
            const SizedBox(height: 24),
            Text(
              'Search Trainer by mobile number',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter 10-digit number',
                hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                  color: AppColors.textGrey,
                ),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color: AppColors.textGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Trainer doesn't have Discipl app? ",
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    MembersAndLeadsCubit? cubit;
                    try {
                      cubit = context.read<MembersAndLeadsCubit>();
                    } catch (_) {
                      cubit = null;
                    }

                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                cubit != null
                                    ? BlocProvider.value(
                                      value: cubit,
                                      child: const AddOrEditLeadScreen(),
                                    )
                                    : BlocProvider(
                                      create:
                                          (_) => MembersAndLeadsCubit(
                                            orgId: widget.orgId,
                                          ),
                                      child: const AddOrEditLeadScreen(),
                                    ),
                      ),
                    );
                    if (res != null && res == true) {
                      if (mounted) Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    'Click here',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_foundTrainer != null) _buildTrainerCard(_foundTrainer!),
            if (_errorMessage != null && !_isSearching)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppStyles.text13Px.poppins.w500.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final number = _searchController.text.trim();
                              final message = Uri.encodeComponent(
                                "Hi! Please download the Discipl Trainer app to register your profile.",
                              );
                              try {
                                await launchUrl(
                                  Uri.parse(
                                    'https://wa.me/$number?text=$message',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (_) {
                                Dialogs.showSnack(
                                  msg: 'Could not open WhatsApp.',
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.share,
                              size: 14,
                              color: Color(0xFF25D366),
                            ),
                            label: Text(
                              'Invite',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: const Color(0xFF25D366),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFF25D366),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
