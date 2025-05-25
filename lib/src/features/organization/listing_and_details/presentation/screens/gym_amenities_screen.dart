import 'package:mentor_mobile_app/imports_bindings.dart';

class GymAmenitiesScreen extends StatefulWidget {
  const GymAmenitiesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymAmenitiesScreen> createState() => _GymAmenitiesScreenState();
}

class _GymAmenitiesScreenState extends State<GymAmenitiesScreen> {
  late final List<AmenityModel> _amenities;
  late final OrganizationListingAndDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _amenities = [...?widget.orgDetails.amenities];
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
        appBar: AppBar(leading: const PopButton().center, title: Text('Aminities', style: AppStyles.text16Px.poppins.w500)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Aminities Added', style: AppStyles.text16Px.poppins.w500.dark),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    AddAmenitiesSheet(
                      selectedValues: [..._amenities.map((e) => (label: e.name ?? '', value: '${e.id}'))],
                      onSubmit: (values) {
                        setState(() {
                          _amenities
                            ..clear()
                            ..addAll(values.map((e) => AmenityModel(id: e.value.toNum.toInt(), name: e.label)).toList());
                        });
                      },
                    ).show(context);
                  },
                  label: const Text('Add'),
                  icon: const Icon(Icons.add),
                  style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.primary), backgroundColor: WidgetStatePropertyAll(Color(0xffFFEAEA))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_amenities.isEmpty) {
                    return Center(child: Text('No Aminities found!', style: AppStyles.text14Px.poppins.w400.dark));
                  }
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _amenities
                              .map(
                                (e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                                  child: Text(e.name ?? '', style: AppStyles.text14Px.poppins.w400.dark),
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
        bottomNavigationBar: BlocBuilder<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
          bloc: _cubit,
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
                await _cubit.updateOrgDetails(orgId: widget.orgDetails.id ?? 0, body: {'amenities': _amenities.map((e) => e.id).toList()});
              },
            ).pad(16).pxy(y: 16);
          },
        ),
      ),
    );
  }
}
