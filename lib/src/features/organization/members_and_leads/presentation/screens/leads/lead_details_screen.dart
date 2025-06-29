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
          final data = state.leadDetails.fold(() => null, (either) => either.fold((l) => null, (r) => r));
          return Scaffold(
            appBar: AppBar(
              leading: const PopButton().center,
              titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
              title: const Text('Trainer Details'),
              actions: [
                if (data?.mobileNumber?.isNotEmpty ?? false)
                  IconButton(
                    onPressed: () {
                      if (data?.mobileNumber?.isNotEmpty ?? false) {
                        launchUrl(Uri.parse('tel:${data?.mobileNumber}'));
                      } else {
                        Dialogs.showSnack(msg: 'Phone number not available');
                      }
                    },
                    icon: SvgPicture.asset('assets/images/svg/icons/call.svg'),
                  ),
              ],
            ),
            backgroundColor: AppColors.grey,
            body: state.leadDetails.fold(
              _buildShimmerLoading,
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

  Widget _buildShimmerLoading() {
    return RefreshIndicator(onRefresh: _fetch, child: ListView(padding: const EdgeInsets.all(16), children: [_buildProfileSectionShimmer(), _buildDetailsSectionShimmer()]));
  }

  Widget _buildProfileSectionShimmer() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header shimmer
          Row(
            children: [
              KShimmer(height: 80.w, width: 80.w, radius: 80.w),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KShimmer.text(width: 150, height: 16, radius: 4),
                    const SizedBox(height: 4),
                    KShimmer.text(width: 80, height: 12, radius: 4),
                    const SizedBox(height: 8),
                    const Divider(thickness: 1, color: Color(0xffDDDDDD)),
                  ],
                ),
              ),
              const KShimmer(height: 14, width: 14, radius: 7).pOnly(left: 8),
            ],
          ),

          const Divider(thickness: 1, color: Color(0xffDDDDDD)).pxy(y: 8),

          // Contact details shimmer
          Row(children: [KShimmer.text(width: 60, height: 14, radius: 4), const SizedBox(width: 8), KShimmer.text(width: 120, height: 14, radius: 4)]),
          const SizedBox(height: 8),
          Row(children: [KShimmer.text(width: 50, height: 14, radius: 4), const SizedBox(width: 8), KShimmer.text(width: 150, height: 14, radius: 4)]),

          const SizedBox(height: 16),

          // Status badges shimmer
          Row(spacing: 8, children: [KShimmer(height: 24, width: 60, radius: 12), KShimmer(height: 24, width: 50, radius: 12), KShimmer(height: 24, width: 60, radius: 12)]),
        ],
      ),
    ).pOnly(bottom: 16);
  }

  Widget _buildDetailsSectionShimmer() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Details rows shimmer
          for (int i = 0; i < 3; i++) ...[
            Row(
              children: [
                KShimmer.text(width: 80, height: 14, radius: 4),
                const Spacer(),
                KShimmer.text(width: 100, height: 14, radius: 4),
                const SizedBox(width: 8),
                const KShimmer(height: 12, width: 12, radius: 6),
              ],
            ).pxy(y: 12),
            if (i < 2) const Divider(height: 1, color: Color(0xffDDDDDD)),
          ],

          // Categories shimmer
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              KShimmer(height: 28, width: 80, radius: 14),
              KShimmer(height: 28, width: 90, radius: 14),
              KShimmer(height: 28, width: 70, radius: 14),
              KShimmer(height: 28, width: 85, radius: 14),
            ],
          ),
        ],
      ),
    ).pOnly(bottom: 32);
  }
}
