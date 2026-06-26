import 'package:mentor_mobile_app/imports_bindings.dart';

class OrganizationEmiScreen extends StatefulWidget {
  const OrganizationEmiScreen({super.key});

  // final OrganizationDetailsModel orgDetails;
  // const OrganizationEmiScreen({required this.orgDetails, super.key});

  @override
  State<OrganizationEmiScreen> createState() => _OrganizationEmiScreenState();
}

class _OrganizationEmiScreenState extends State<OrganizationEmiScreen> {
  bool completedAnimation = true;
  @override
  void initState() {
    // Future.delayed(const Duration(seconds: 1), () {
    //   setState(() {
    //     completedAnimation = true;
    //   });
    // });
    // context.read<OrganizationListingAndDetailsCubit>().fetchList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizationListingAndDetailsCubit()..fetchList(),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            child: switch (completedAnimation) {
              true => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SvgPicture.asset('assets/images/svg/vectors/onboarding_success.svg', height: 140)
                  //     .animate(
                  //       onComplete: (controller) {
                  //         context.pushAndRemoveUntil(const OrganizationListingScreen());
                  //       },
                  //     )
                  //     .scale(duration: const Duration(seconds: 2), curve: Curves.elasticOut, begin: Offset.zero, end: const Offset(1, 1)),
                  // const SizedBox(height: 16),
                  Text(
                    'Emi Screen Here',
                    style: AppStyles.text16Px.poppins.w700.dark,
                    textAlign: TextAlign.center,
                  ),
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  // OrganizationCreationCompletionStatusCard(progress: 5),
                  // SubscriptionPlanChooseCom(
                  //   orgDetails: OrganizationDetailsModel(),
                  // ),
                  // SubscriptionPlanChooseCom(
                  //   orgDetails: widget.orgDetails,
                  // ),
                  // BlocBuilder<
                  //   OrganizationListingAndDetailsCubit,
                  //   OrganizationListingAndDetailsState
                  // >(
                  //   builder: (context, state) {
                  //     return state.list.fold(
                  //       () {
                  //         return const CircularProgressIndicator();
                  //       },
                  //       (a) => a.fold(
                  //         (l) {
                  //           Dialogs.showSnack(msg: l.msg);
                  //           return const SizedBox(); // or any fallback widget
                  //         },
                  //         (r) {
                  //           context.pushAndRemoveUntil(
                  //             SubscriptionPlanChooseCom(
                  //               orgDetails: OrganizationDetailsModel(
                  //                 id: state.selectedOrganization?.id,
                  //               ),
                  //             ),
                  //           );
                  //           return const SizedBox(); // or the widget you actually want to return
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 24),
                  BlocBuilder<
                    OrganizationListingAndDetailsCubit,
                    OrganizationListingAndDetailsState
                  >(
                    builder: (context, state) {
                      return state.list.fold(
                        () {
                          return Button.filled(
                            title: 'Loading...',
                            ontap: () {},
                            isDisabled: true,
                          );
                        },
                        (a) => a.fold(
                          (l) {
                            return Button.filled(
                              title: 'Continue',
                              ontap: () {
                                Dialogs.showSnack(msg: l.msg);
                              },
                            );
                          },
                          (r) {
                            return Button.filled(
                              title: 'Continue',
                              ontap: () {
                                final cubit = context.read<OrganizationListingAndDetailsCubit>();
                                context.pushAndRemoveUntil(
                                  BlocProvider.value(
                                    value: cubit,
                                    child: SubscriptionPlanChooseCom(
                                      orgDetails: OrganizationDetailsModel(
                                        id: state.selectedOrganization?.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              //   ],
              // ),
              // ignore: prefer_const_constructors
              false => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  OrganizationCreationCompletionStatusCard(progress: 5),
                ],
              ),
            },
          ).pad(16),
        ),
      ),
    );
  }
}
