import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class AddOrEditLeadScreen extends StatefulWidget {
  const AddOrEditLeadScreen({this.leadeDetails, super.key});

  final LeadDetailsModel? leadeDetails;

  @override
  State<AddOrEditLeadScreen> createState() => _AddOrEditLeadScreenState();
}

class _AddOrEditLeadScreenState extends State<AddOrEditLeadScreen> {
  late final MembersAndLeadsCubit _cubit;
  late final List<FieldData<dynamic>> _fields;
  final _formKey = GlobalKey<FormState>();
  late final ValueNotifier<List<PlatformFile?>> _documents = ValueNotifier([
    null,
    null,
    null,
  ]);
  late final ValueNotifier<XFile?> _proofImage;
  XFile? _profilePicture;

  @override
  void initState() {
    _cubit = context.read<MembersAndLeadsCubit>();
    _proofImage = ValueNotifier(null);

    final isEdit = widget.leadeDetails != null;

    if (!isEdit) {
      _fields = [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.next,
          label: 'Full Name',
          requiredLabel: true,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Member name is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _fields[1].focusNode?.requestFocus();
          },
          controller: TextEditingController(),
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: 'Enter Name',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'Mobile Number',
          requiredLabel: true,
          controller: TextEditingController(),
          focusNode: FocusNode(),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value?.trim().length != 10) {
              return 'Mobile number must be 10 digits';
            }
            return null;
          },
          onSubmitted: (value) {
            _onContinue();
          },
          decoration: InputDecoration(
            hintText: 'Enter Mobile Number',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
      ];
    } else {
      _fields = [
        FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Full Name',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Member name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[1].focusNode?.requestFocus();
        },
        controller: TextEditingController(),
        // focusNode: FocusNode(),
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintText: 'Enter Name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Email Address',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isNotEmpty ?? false) {
            if (!RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value!)) {
              return 'Invalid email address!';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[2].focusNode?.requestFocus();
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Mobile Number',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: (value) {
          if (value?.trim().length != 10) {
            return 'Mobile number must be 10 digits';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[3].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Expirience',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.number,
        maxLength: 2,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Expriece is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[4].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: '4',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          suffixIcon: SizedBox.square(
            dimension: 22,
            child: Center(
              child: Text(
                'YEARS   ',
                style: AppStyles.text14Px.poppins.w400.dark,
              ),
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.done,
        label: 'Blood Group',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        items: [
          (label: 'A+', value: 'A+'),
          (label: 'A-', value: 'A-'),
          (label: 'B+', value: 'B+'),
          (label: 'B-', value: 'B-'),
          (label: 'AB+', value: 'AB+'),
          (label: 'AB-', value: 'AB-'),
          (label: 'O+', value: 'O+'),
          (label: 'O-', value: 'O-'),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Blood Group must be selected';
          }
          return null;
        },
        onValueChanged: (p0) {
          _fields[5].focusNode?.requestFocus();
        },
        onSubmitted: (value) {
          _fields[5].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Blood Group',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.done,
        label: 'Gender',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        items: [
          (label: 'Male', value: 'male'),
          (label: 'Female', value: 'female'),
          (label: 'Other', value: 'other'),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Geneder must be selected';
          }
          return null;
        },
        onValueChanged: (p0) {
          _fields[6].focusNode?.requestFocus();
        },
        onSubmitted: (value) {
          _fields[6].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Gender',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.date,
        textInputAction: TextInputAction.done,
        label: 'Date of Birth',
        requiredLabel: true,
        controller: TextEditingController(),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Date of Birth must be selected';
          }
          return null;
        },
        onSubmitted: (value) {
          _fields[7].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Date of Birth',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Emergency Contact',
        requiredLabel: true,
        controller: TextEditingController(),
        focusNode: FocusNode(),
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Emergency Contact is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _onContinue();
          _fields[7].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
    };
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_fields[0].focusNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in _fields) {
      element.controller?.dispose();
      element.focusNode?.dispose();
    }
  }

  void _onContinue() {
    if (_cubit.state.createOrUpdateLead?.isNone() ?? false) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final isEdit = widget.leadeDetails != null;
      final fullName = _fields[0].controller?.text;
      final emailAddress = isEdit ? _fields[1].controller?.text : null;
      final mobileNo = isEdit ? _fields[2].controller?.text : _fields[1].controller?.text;
      final experience = isEdit ? _fields[3].controller?.text : null;
      final bloodGroup = isEdit ? _fields[4].controller?.text : null;
      final gender = isEdit ? _fields[5].controller?.text : null;
      final dateOfBirth = isEdit ? _fields[6].selectedDateTime?.format('yyyy-MM-dd') : null;
      final emergencyContactNo = isEdit ? _fields[7].controller?.text : null;
      final documents = isEdit
          ? _documents.value
              .where((e) => e?.path?.trim().isNotEmpty ?? false)
              .toList()
          : <PlatformFile>[];
      final proofImage = isEdit ? _proofImage.value?.path : null;
      final profilePicuture = isEdit ? _profilePicture?.path : null;
      _cubit.createOrUpdateLeadDetails(
        leadId: widget.leadeDetails?.id,
        fullName: fullName,
        mobileNumber: mobileNo,
        email: emailAddress,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodGroup: bloodGroup,
        emergencyContactNumber: emergencyContactNo,
        experience: experience?.toNum.toInt(),
        addressProof: proofImage,
        trainerCertificates: documents
            .map((e) => e?.path ?? '')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        profilePicture: profilePicuture,
      );
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead,
      bloc: _cubit,
      listener: (context, state) {
        state.createOrUpdateLead?.fold(() => null, (t) {
          return t.fold(
            (l) {
              return Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              if (widget.leadeDetails?.id != null) {
                Dialogs.showSnack(msg: 'Trainer details updated successfully');
              } else {
                Dialogs.showSnack(msg: 'Trainer added successfully');
              }
              context.pop();
            },
          );
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton().center,
          titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
          title: const Text('Add Trainer'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileImage(
                isEdit: true,
                onChanged: (image) => _profilePicture = image,
                radius: 80,
              ).pOnly(bottom: 16),
              ListView.separated(
                itemCount: _fields.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 22);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Field(
                    data: _fields[index].copyWith(
                      decoration: _fields[index].decoration?.copyWith(
                        filled: false,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.borderGrey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: AppColors.error),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (widget.leadeDetails != null) ...[
                const SizedBox(height: 22),
                Text('Documents', style: AppStyles.text14Px.poppins.w500.dark),
              const SizedBox(height: 22),
              ValueListenableBuilder(
                valueListenable: _documents,
                builder: (context, documents, child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          responsiveSize(
                            context,
                            s: 2,
                            m: 3,
                            l: 4,
                            xl: 6,
                          ).toInt(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      final document = documents[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          FilePicker.platform
                              .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              )
                              .then((value) {
                                if (value != null && value.files.isNotEmpty) {
                                  documents[index] = value.files.first;
                                  _documents.notifyListeners();
                                }
                              });
                        },
                        child: Center(
                          child: Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: const Color(0xffF7F7F7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffEEEEEE),
                              ),
                            ),
                            child: switch (document) {
                              != null => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: PDFView(
                                      filePath: document.path,
                                      swipeHorizontal: true,
                                      autoSpacing: false,
                                      pageFling: false,
                                      backgroundColor: Colors.grey,
                                      onRender: (pages) {},
                                      onError: (error) {},
                                      onPageError: (page, error) {},
                                      onViewCreated:
                                          (
                                            PDFViewController pdfViewController,
                                          ) {},
                                    ).pOnly(left: 12, right: 12, top: 12),
                                  ),
                                  Container(
                                    width: double.maxFinite,
                                    decoration: const BoxDecoration(
                                      color: Color(0xffFFCECE),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/svg/icons/image.svg',
                                          height: 22,
                                          width: 22,
                                        ).pOnly(right: 16),
                                        Flexible(
                                          child: Text(
                                            document.path?.split('/').last ??
                                                '',
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: AppStyles
                                                .text12Px
                                                .poppins
                                                .w400
                                                .dark
                                                .copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ).pxy(x: 16, y: 8),
                                  ),
                                ],
                              ),
                              _ => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xffFFCECE),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add\nFitness Certificate',
                                    textAlign: TextAlign.center,
                                    style: AppStyles.text12Px.poppins.w400.dark,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                'Address Proof',
                style: AppStyles.text14Px.poppins.w500.dark,
              ),
              const SizedBox(height: 22),
              ValueListenableBuilder(
                valueListenable: _proofImage,
                builder: (context, proofImage, child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          responsiveSize(
                            context,
                            s: 2,
                            m: 3,
                            l: 4,
                            xl: 6,
                          ).toInt(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ImagePickerDialog(
                            onPickedImage: (image) {
                              if (image != null) {
                                _proofImage.value = image;
                              }
                            },
                          ).show(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffF7F7F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xffEEEEEE)),
                          ),
                          child: Center(
                            child: switch (proofImage) {
                              != null => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: Image.file(
                                        File(proofImage.path),
                                        fit: BoxFit.cover,
                                        width: double.maxFinite,
                                      ),
                                    ).pOnly(left: 12, right: 12, top: 12),
                                  ),
                                  Container(
                                    width: double.maxFinite,
                                    decoration: const BoxDecoration(
                                      color: Color(0xffFFCECE),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/svg/icons/image.svg',
                                          height: 22,
                                          width: 22,
                                        ).pOnly(right: 16),
                                        Flexible(
                                          child: Text(
                                            proofImage.path.split('/').last,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: AppStyles
                                                .text12Px
                                                .poppins
                                                .w400
                                                .dark
                                                .copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ).pxy(x: 16, y: 8),
                                  ),
                                ],
                              ),
                              _ => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xffFFCECE),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add\nAddress Proof',
                                    textAlign: TextAlign.center,
                                    style: AppStyles.text12Px.poppins.w400.dark,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
                const SizedBox(height: 22),
              ],
            ],
          ),
        ),
        bottomNavigationBar:
            BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
              buildWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead,
              builder: (context, state) {
                return Button.filled(
                  title: 'Save',
                  isLoading: state.createOrUpdateLead?.isNone() ?? false,
                  buttonColor: AppColors.primary,
                  ontap: _onContinue,
                );
              },
            ).pad(16).pxy(y: 16),
      ),
    );
  }
}
