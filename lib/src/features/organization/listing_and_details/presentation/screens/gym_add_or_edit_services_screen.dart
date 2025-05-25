import 'package:mentor_mobile_app/imports_bindings.dart';

class GymServicesScreen extends StatefulWidget {
  const GymServicesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymServicesScreen> createState() => _GymServicesScreenState();
}

class _GymServicesScreenState extends State<GymServicesScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;
  late final List<String> _services;
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _services = [...?widget.orgDetails.services?.map((e) => e.name ?? '')];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
      listenWhen: (p, c) => p.updateOrgDetails != c.updateOrgDetails,
      listener: (context, state) {
        state.updateOrgDetails?.fold(() {}, (either) {
          either.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              if (widget.orgDetails.id == null) {
                Dialogs.showSnack(msg: 'Gym details not found');
                return;
              }
              Dialogs.showSnack(msg: 'Gym details updated successfully');
              _cubit.fetchDetails(orgId: widget.orgDetails.id!);
              context.pop();
            },
          );
        });
      },
      child: Scaffold(
        appBar: AppBar(leading: const PopButton().center, title: Text('Services', style: AppStyles.text16Px.poppins.w500)),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 16,
                children: [
                  Flexible(
                    child: Field(
                      data: FieldData<String>(
                        type: FieldType.word,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          if (_controller.text.isEmpty) {
                            Dialogs.showSnack(msg: 'Please enter a service name');
                            return;
                          }
                          setState(() {
                            _services.add(_controller.text);
                            _controller.clear();
                          });
                        },
                        controller: _controller,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.lightPrimary.withAlpha(50),
                          hintText: 'Enter service name',
                          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                          border: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.lightPrimary), borderRadius: BorderRadius.circular(16)),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: AppColors.borderGrey)),
                          enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: AppColors.borderGrey)),
                          errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: AppColors.error)),
                          focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: AppColors.borderGrey)),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        Dialogs.showSnack(msg: 'Please enter a service name');
                        return;
                      }
                      setState(() {
                        _services.add(_controller.text);
                        _controller.clear();
                      });
                    },
                    style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.primary), backgroundColor: WidgetStatePropertyAll(Color(0xffFFEAEA))),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_services.isEmpty) {
                      return Center(child: Text('No Services found!', style: AppStyles.text14Px.poppins.w400.dark));
                    }
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _services
                                .map(
                                  (service) => Chip(
                                    label: Text(service, style: AppStyles.text14Px.poppins.w400.dark),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setState(() {
                                        _services.remove(service);
                                      });
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    shape: const StadiumBorder(),
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ).pad(16),
        ),
        bottomNavigationBar: BlocBuilder<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
          buildWhen: (previous, current) => previous.updateOrgDetails != current.updateOrgDetails,
          builder: (context, state) {
            final isLoading = state.updateOrgDetails?.isNone() ?? false;
            return Button.filled(
              raduis: 12,
              title: 'Save',
              isLoading: isLoading,
              buttonColor: AppColors.primary,
              ontap: () async {
                if (isLoading) {
                  return;
                }
                final services = widget.orgDetails.services?.map((e) => e.name).toList() ?? [];
                final listServices = _services.where((e) => !services.contains(e)).map((e) => {'name': e}).toList();
                if (listServices.isEmpty) {
                  await Dialogs.showSnack(msg: 'No new services to add');
                  return;
                }
                final body = {'services': listServices};
                await _cubit.updateOrgDetails(orgId: widget.orgDetails.id ?? 0, body: body);
              },
            ).pad(16).pxy(y: 16);
          },
        ),
      ),
    );
  }
}
