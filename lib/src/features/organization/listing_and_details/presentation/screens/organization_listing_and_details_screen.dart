import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationListingAndDetailsScreen extends StatelessWidget {
  const OrganizationListingAndDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => OrganizationListingAndDetailsCubit(), child: const _OrganizationListingAndDetailsScreen());
  }
}

class _OrganizationListingAndDetailsScreen extends StatefulWidget {
  const _OrganizationListingAndDetailsScreen();

  @override
  State<_OrganizationListingAndDetailsScreen> createState() => _OrganizationListingAndDetailsScreenState();
}

class _OrganizationListingAndDetailsScreenState extends State<_OrganizationListingAndDetailsScreen> {
  late final OrganizationListingAndDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrganizationListingAndDetailsCubit>();
    _cubit.fetchList();
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        title: 'Active Members',
        color: const Color(0xff486CC2),
        count: 54,
        onTap: () {
          context.push(const ActiveMembersListingScreen());
        },
      ),
      (
        title: 'Total Leads & Members',
        color: const Color(0xff9C51BF),
        count: 72,
        onTap: () {
          context.push(const MembersAndLeadsListingScreen());
        },
      ),
      (
        title: 'Expired Members',
        color: const Color(0xff527F50),
        count: 33,
        onTap: () {
          context.push(const ExpiredMembersListingScreen());
        },
      ),
      (
        title: 'Upcoming Members',
        color: const Color(0xffC85074),
        count: 42,
        onTap: () {
          context.push(const UpcomingRenewalsListingScreen());
        },
      ),
    ];
    return BlocListener<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
      listenWhen: (p, c) => p.selectedOrganization != c.selectedOrganization,
      listener: (context, state) {
        if (state.selectedOrganization?.id != null) {
          _cubit.fetchDetails(orgId: state.selectedOrganization!.id!);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
            buildWhen: (p, c) => p.details != c.details || p.list != c.list,
            builder: (context, state) {
              final hasData = state.list.fold(() => false, (t) => t.fold((_) => false, (_) => true)) && state.details.fold(() => false, (t) => t.fold((_) => false, (_) => true));
              if (!hasData) {
                return const SizedBox.shrink();
              }
              return OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), side: const BorderSide(color: Color(0xffDDDDDD))),
                onPressed: () {},
                label: const Icon(Icons.keyboard_arrow_down_sharp, color: Color(0xff222222), size: 20),
                icon: Text('Discpl', style: AppStyles.text14Px.poppins.copyWith(color: const Color(0xff222222))),
              );
            },
          ),
          centerTitle: false,
          actions: [
            BlocBuilder<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
              buildWhen: (p, c) => p.details != c.details || p.list != c.list,
              builder: (context, state) {
                final hasData = state.list.fold(() => false, (t) => t.fold((_) => false, (_) => true)) && state.details.fold(() => false, (t) => t.fold((_) => false, (_) => true));
                if (!hasData) {
                  return const SizedBox.shrink();
                }
                return SvgPicture.asset('assets/images/svg/vectors/logo.svg', height: 24, width: 24);
              },
            ).pOnly(right: 16),
          ],
        ),
        body: BlocBuilder<OrganizationListingAndDetailsCubit, OrganizationListingAndDetailsState>(
          buildWhen: (p, c) => p.details != c.details || p.list != c.list,
          builder: (context, state) {
            return state.list.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold((l) => const Center(child: Text('Error')), (r) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 108),
                      itemCount: cards.length,
                      itemBuilder: (BuildContext context, int index) {
                        final card = cards[index];
                        return InkWell(
                          onTap: card.onTap,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ColoredBox(
                              color: card.color.withAlpha(25),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(card.count.toString(), style: AppStyles.text20Px.poppins.w800.copyWith(color: card.color)),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Flexible(child: Text(card.title, style: AppStyles.text14Px.poppins.w600.copyWith(color: card.color))),
                                      CircleAvatar(backgroundColor: card.color, radius: 18, child: const Icon(Icons.keyboard_arrow_right_outlined, color: AppColors.light)),
                                    ],
                                  ),
                                ],
                              ).pad(16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        child: ImageNetwork(
                          'https://images.ctfassets.net/0k812o62ndtw/WE3fGLHIvifgzs7iBw9Le/e66c3a58d6558193a49c1eaac72b713d/Gym_-_Kayla_-_7108-1024x683-27c3a53.jpg',
                          height: double.maxFinite,
                          width: double.maxFinite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text('Attendance Calendar', style: AppStyles.text18Px.poppins.w600.dark),
                    const SizedBox(height: 16),
                    const CustomCalendar(),
                    const SizedBox(height: 40),
                    Text('Member Insights', style: AppStyles.text18Px.poppins.w600.dark),
                    const SizedBox(height: 16),
                    const SizedBox(height: 40),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
