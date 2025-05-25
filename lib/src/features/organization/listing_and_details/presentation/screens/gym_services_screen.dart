import 'package:mentor_mobile_app/imports_bindings.dart';

class GymServicesScreen extends StatefulWidget {
  const GymServicesScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymServicesScreen> createState() => _GymServicesScreenState();
}

class _GymServicesScreenState extends State<GymServicesScreen> {
  late final List<String> _services;

  @override
  void initState() {
    super.initState();
    _services = [...?widget.orgDetails.services?.map((e) => e.name ?? '')];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text('Services', style: AppStyles.text16Px.poppins.w500)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Services Added', style: AppStyles.text16Px.poppins.w500.dark),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  context.push(GymAddOrEditServicesScreen(orgDetails: widget.orgDetails));
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
                              (service) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                                child: Text(service, style: AppStyles.text14Px.poppins.w400.dark),
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
      // bottomNavigationBar: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
      //   buildWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead || p.createOrUpdateMember != c.createOrUpdateMember,
      //   builder: (context, state) {
      //     return Button.filled(
      //       title: 'Save',
      //       // isLoading: widget.details?.fold((l) => state.createOrUpdateLead, (r) => state.createOrUpdateMember)?.isNone() ?? false,
      //       buttonColor: AppColors.primary,
      //       // ontap: _onContinue,
      //       ontap: () {},
      //     );
      //   },
      // ).pad(16).pxy(y: 16),
    );
  }
}
