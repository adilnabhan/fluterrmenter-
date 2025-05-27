import 'package:mentor_mobile_app/imports_bindings.dart';

class LeadDetailsScreen extends StatefulWidget {
  const LeadDetailsScreen({required this.leadData, super.key});

  final Result leadData;

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  late final MembersAndLeadsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchLeadDetails(leadId: widget.leadData.userId ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.createOrUpdateLead != c.createOrUpdateLead,
      listener: (context, state) {
        state.createOrUpdateLead?.fold(() => null, (t) {
          return t.fold((l) {}, (r) {
            _fetch();
          });
        });
      },
      child: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        buildWhen: (p, c) => p.leadDetails != c.leadDetails,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: const PopButton().center,
              titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
              title: Text('#${widget.leadData.userId ?? 0}'),
              actions: [IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/images/svg/icons/call.svg'))],
            ),
            backgroundColor: AppColors.grey,
            body: state.leadDetails.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold(
                (error) => error.maybeWhen(network: (e) => ErrorUi.network(onTap: _fetch), notFound: (e) => ErrorUi.notFound(onTap: _fetch), orElse: () => ErrorUi.server(onTap: _fetch)),
                (data) {
                  final hasCategories = data.mentorProfile?.categories?.isNotEmpty ?? false;
                  return RefreshIndicator(
                    onRefresh: _fetch,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Profile Section
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.push(BlocProvider.value(value: _cubit, child: UpdateBasicDetailsScreen(details: Left(data))));
                                },
                                child: Row(
                                  children: [
                                    AbsorbPointer(child: ProfileImage(isEdit: true, onChanged: (image) {}, radius: 80.w, url: '${data.profilePicture ?? ''}')),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${data.firstName ?? ''} ${data.lastName ?? ''}', style: AppStyles.text14Px.poppins.w500),
                                        const SizedBox(height: 4),
                                        Text('#${data.id}', style: AppStyles.text12Px.poppins.w400),
                                        const Divider(thickness: 1, color: Color(0xffDDDDDD)),
                                      ],
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.dark).pOnly(left: 8),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 1, color: Color(0xffDDDDDD)).pxy(y: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: 'Mobile : ', style: AppStyles.text14Px.poppins.w400.textGrey),
                                    TextSpan(text: data.mobileNumber ?? 'N/A', style: AppStyles.text13Px.poppins.w500.dark),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: 'Email : ', style: AppStyles.text14Px.poppins.w400.textGrey),
                                    TextSpan(text: data.email ?? 'N/A', style: AppStyles.text13Px.poppins.w500.dark),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                                    child: Row(
                                      children: [
                                        CircleAvatar(backgroundColor: Colors.green.shade700, radius: 3).pOnly(right: 8),
                                        Text('Active', style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.green.shade700)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16)),
                                    child: Text(data.gender ?? 'N/A', style: AppStyles.text14Px.poppins.w400.dark),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16)),
                                    child: Text(data.bloodGroup ?? 'N/A', style: AppStyles.text14Px.poppins.w400.dark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).pOnly(bottom: 16),
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...[
                                (
                                  label: 'Experience',
                                  value: '${data.mentorProfile?.experience ?? 0} years',
                                  onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateDOBScreen(details: left(data)))),
                                ),
                                (label: 'Date of Birth', value: data.dateOfBirth?.format('dd MMM yyyy') ?? '', onTap: () {}),
                                (label: 'Category', value: 'Add', onTap: () {}),
                              ].map((e) {
                                return InkWell(
                                  onTap: e.onTap,
                                  child: Row(
                                    children: [
                                      Text(e.label, style: AppStyles.text14Px.poppins.w400.textGrey),
                                      const Spacer(),
                                      Text(e.value, style: AppStyles.text14Px.poppins.w500.dark),
                                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.dark).pOnly(left: 8),
                                    ],
                                  ).pxy(y: 12),
                                );
                              }),
                              // Categories
                              if (hasCategories) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      data.mentorProfile!.categories!
                                          .map(
                                            (category) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                                              child: Text(category.name ?? '', style: AppStyles.text14Px.poppins.w400.dark),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ],
                          ),
                        ).pOnly(bottom: 16),

                        // Emergency Contact
                        _card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Emergency Contact', style: AppStyles.text14Px.poppins.w400.textGrey),
                                  const SizedBox(height: 8),
                                  Text(data.mentorProfile?.emergencyContact ?? 'N/A', style: AppStyles.text14Px.poppins.w500.dark),
                                ],
                              ),
                              IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/images/svg/icons/call.svg', colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn))),
                            ],
                          ),
                        ).pOnly(bottom: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(16)), child: child);
  }
}
