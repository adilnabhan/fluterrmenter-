import 'package:mentor_mobile_app/imports_bindings.dart';

class GymTrainersScreen extends StatefulWidget {
  const GymTrainersScreen({required this.orgDetails, super.key});

  final OrganizationDetailsModel orgDetails;

  @override
  State<GymTrainersScreen> createState() => _GymTrainersScreenState();
}

class _GymTrainersScreenState extends State<GymTrainersScreen> {
  late final List<({String urlOrPath, String type})> _images;

  @override
  void initState() {
    super.initState();
    _images = widget.orgDetails.photos?.map((image) => (urlOrPath: image.image ?? '', type: 'network')).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text('Trainers', style: AppStyles.text16Px.poppins.w500)),
      body: Column(
        children: [
          Row(
            children: [
              Text('Available Trainers', style: AppStyles.text16Px.poppins.w500.dark),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
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
                if (_images.isEmpty) {
                  return Center(child: Text('No Photos found!', style: AppStyles.text14Px.poppins.w400.dark));
                }
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: responsiveSize(context, s: 2, m: 3, l: 4, xl: 6).toInt(), crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemCount: _images.length,
                  itemBuilder: (BuildContext context, int index) {
                    final image = _images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: switch (image.type) {
                        'network' => ImageNetwork(image.urlOrPath),
                        _ => Image.file(File(image.urlOrPath), fit: BoxFit.cover),
                      },
                    );
                  },
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
