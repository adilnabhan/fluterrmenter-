import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  const OrganizationDetailsScreen({required this.orgId, super.key});

  final int orgId;

  @override
  State<OrganizationDetailsScreen> createState() =>
      _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchDetails(orgId: widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton().center,
        title: Text('Profile', style: AppStyles.text16Px.poppins.w500),
      ),
      body: BlocBuilder<
        OrganizationListingAndDetailsCubit,
        OrganizationListingAndDetailsState
      >(
        builder: (context, state) {
          return state.details.fold(
            () {
              return const Center(child: CircularProgressIndicator());
            },
            (either) {
              return either.fold(
                (error) =>
                    error
                        .maybeWhen(
                          network: (e) => ErrorUi.network(onTap: _fetch),
                          notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                          orElse: () => ErrorUi.server(onTap: _fetch),
                        )
                        .center,
                (orgDetails) {
                  return RefreshIndicator(
                    onRefresh: _fetch,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap:
                                    () => context.push(
                                      BlocProvider.value(
                                        value: _cubit,
                                        child: GymDetailsScreen(
                                          orgDetails: orgDetails,
                                        ),
                                      ),
                                    ),
                                child: AbsorbPointer(
                                  child: ProfileImage(
                                    isEdit: true,
                                    onChanged: (image) {},
                                    radius: 80.w,
                                    url: orgDetails.logo ?? '',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orgDetails.name ?? '',
                                    style: AppStyles.text14Px.poppins.w500,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    orgDetails.email ?? '',
                                    style: AppStyles.text12Px.poppins.w400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          _buildProfileListItem('Gym Details', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child: GymDetailsScreen(orgDetails: orgDetails),
                              ),
                            );
                          }),
                          _buildProfileListItem('Gallery', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child: GymGalleryScreen(orgDetails: orgDetails),
                              ),
                            );
                          }),
                          _buildProfileListItem('Services', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child: GymServicesScreen(
                                  orgDetails: orgDetails,
                                ),
                              ),
                            );
                          }),
                          _buildProfileListItem('Packages', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child: GymPackagesScreen(
                                  orgDetails: orgDetails,
                                ),
                              ),
                            );
                          }),
                          // _buildProfileListItem('Trainers', () {
                          //   context.push(BlocProvider.value(value: _cubit, child: GymTrainersScreen(orgDetails: orgDetails)));
                          // }),
                          _buildProfileListItem('Schedules', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child: GymSchedulesScreen(
                                  orgDetails: orgDetails,
                                ),
                              ),
                            );
                          }),
                          _buildProfileListItem('Services', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child: GymAmenitiesScreen(
                                  orgDetails: orgDetails,
                                ),
                              ),
                            );
                          }),
                          // _buildProfileListItem('Payment UpComing', () {
                          //   context.push(
                          //     BlocProvider.value(
                          //       value: _cubit,
                          //       child: PaymentUpcomingViewScreen(
                          //      orgId: orgDetails,
                          //       ),
                          //     ),
                          //   );
                          // }),
                          _buildProfileListItem('Bank A/c Details', () {
                            context.push(
                              BlocProvider.value(
                                value: _cubit,
                                child:  BankListingViewScreen(
                                  orgDetails: orgDetails,
                                ),
                              ),
                            );
                          }),
                          // _buildProfileListItem('Wishes', () {
                          //   context.push(BlocProvider.value(value: _cubit, child: GymDetailsScreen(orgDetails: orgDetails)));
                          // }),
                          // _buildProfileListItem('Permissions', () {
                          //   context.push(BlocProvider.value(value: _cubit, child: GymDetailsScreen(orgDetails: orgDetails)));
                          // }),
                          _ProfileListItem(
                            label: 'Logout',
                            onTap: () => const LogoutSheet().show(context),
                            isLogout: true,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileListItem(String label, VoidCallback onTap) {
    return Column(
      children: [
        _ProfileListItem(label: label, onTap: onTap),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.grey, // Light grey color for the divider
        ),
      ],
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style:
            isLogout
                ? AppStyles.text14Px.poppins.w500.copyWith(color: Colors.red)
                : AppStyles.text14Px.poppins.w500,
      ),
      trailing:
          isLogout
              ? null
              : const Icon(Icons.chevron_right, color: Colors.black),
      onTap: onTap,
    );
  }
}
