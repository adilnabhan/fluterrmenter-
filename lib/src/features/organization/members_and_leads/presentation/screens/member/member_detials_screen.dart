import 'package:mentor_mobile_app/imports_bindings.dart';

class MemberDetialsScreen extends StatefulWidget {
  const MemberDetialsScreen({required this.memberData, super.key});

  final MemberDataModel memberData;

  @override
  State<MemberDetialsScreen> createState() => _MemberDetialsScreenState();
}

class _MemberDetialsScreenState extends State<MemberDetialsScreen> {
  late final MembersAndLeadsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MembersAndLeadsCubit>();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchMemberDetails(memberId: widget.memberData.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersAndLeadsCubit, MembersAndLeadsState>(
      listenWhen: (p, c) => p.createOrUpdateMember != c.createOrUpdateMember,
      listener: (context, state) {
        state.createOrUpdateMember?.fold(() => null, (t) {
          return t.fold((l) {}, (r) {
            _fetch();
          });
        });
      },
      child: BlocBuilder<MembersAndLeadsCubit, MembersAndLeadsState>(
        buildWhen: (p, c) => p.memberDetails != c.memberDetails,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: const PopButton().center,
              titleTextStyle: AppStyles.text16Px.poppins.w500.dark,
              title: const Text('Member Details'),
              actions: [IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/images/svg/icons/call.svg'))],
            ),
            backgroundColor: AppColors.grey,
            body: state.memberDetails.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold(
                (error) => error.maybeWhen(network: (e) => ErrorUi.network(onTap: _fetch), notFound: (e) => ErrorUi.notFound(onTap: _fetch), orElse: () => ErrorUi.server(onTap: _fetch)),
                (data) {
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
                                  if (data.id == null) {
                                    Dialogs.showSnack(msg: 'Member not found');
                                  } else {
                                    context.push(BlocProvider.value(value: _cubit, child: UpdateBasicDetailsScreen(details: right(data))));
                                  }
                                },
                                child: Row(
                                  children: [
                                    AbsorbPointer(child: ProfileImage(isEdit: true, onChanged: (image) {}, radius: 80.w, url: '$data')),
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
                                  if (data.isActiveMember ?? false)
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
                                    child: Text(data.gender?.pascalCase ?? 'N/A', style: AppStyles.text14Px.poppins.w400.dark),
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
                        // Personal Details
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...[
                                (
                                  label: 'Date of Birth',
                                  value: data.dateOfBirth?.format('dd MMM yyyy') ?? '',
                                  onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateDOBScreen(details: right(data)))),
                                ),
                                (label: 'Height', value: '${data.height ?? ''} CM', onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateHeightScreen(details: data)))),
                                (label: 'Weight', value: '${data.weight ?? ''} KG', onTap: () => context.push(BlocProvider.value(value: _cubit, child: UpdateWeightScreen(details: data)))),
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
                            ],
                          ),
                        ).pOnly(bottom: 16),

                        Row(
                          children: [
                            Flexible(
                              child: SizedBox(
                                width: double.maxFinite,
                                child: _card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Fees', style: AppStyles.text14Px.poppins.w400.textGrey),
                                      const SizedBox(height: 8),
                                      Text('Fully Paid', style: AppStyles.text14Px.poppins.w500.dark),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: SizedBox(
                                width: double.maxFinite,
                                child: _card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Joined', style: AppStyles.text14Px.poppins.w400.textGrey),
                                      const SizedBox(height: 8),
                                      Text('Fully Paid', style: AppStyles.text14Px.poppins.w500.dark),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).pOnly(bottom: 16),

                        // Membership Details
                        if (data.memberships?.isNotEmpty ?? false) ...[
                          Text('Memberships', style: AppStyles.text16Px.poppins.w600.dark).pOnly(bottom: 16),
                          for (final memebership in data.memberships ?? <MembershipDataModel>[])
                            _card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  Text(memebership.membershipName ?? '', style: AppStyles.text14Px.poppins.w600.dark),
                                  // const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.dark).pOnly(left: 8),
                                  //   ],
                                  // ),
                                  // const SizedBox(height: 8),
                                  // Text(data.emergencyContactNumber ?? 'N/A', style: AppStyles.text14Px.poppins.w500.dark),
                                ],
                              ),
                            ).pOnly(bottom: 16),
                        ],

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
                                  Text(data.emergencyContactNumber ?? 'N/A', style: AppStyles.text14Px.poppins.w500.dark),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  if (data.emergencyContactNumber != null) {
                                    launchUrl(Uri.parse('tel:${data.emergencyContactNumber}'));
                                  } else {
                                    Dialogs.showSnack(msg: 'Emergency contact number not found');
                                  }
                                },
                                icon: SvgPicture.asset('assets/images/svg/icons/call.svg', colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),
                              ),
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
