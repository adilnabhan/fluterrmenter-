import 'package:mentor_mobile_app/imports_bindings.dart';

class MembersAndLeadsListingScreen extends StatefulWidget {
  const MembersAndLeadsListingScreen({super.key});

  @override
  State<MembersAndLeadsListingScreen> createState() => _MembersAndLeadsListingScreenState();
}

class _MembersAndLeadsListingScreenState extends State<MembersAndLeadsListingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, titleTextStyle: AppStyles.text16Px.poppins.w500.dark, title: const Text('Members & Leads')),
      body: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: TextField(
                  onChanged: (q) {
                    EasyDebounce.debounce('search_query', const Duration(milliseconds: 100), () {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for name or phone number',
                    hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                    filled: false,
                    prefixIcon: SizedBox.square(dimension: 32, child: SvgPicture.asset('assets/images/svg/icons/search.svg', height: 32, width: 32, color: AppColors.textGrey).center),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                  ),
                ).pad(16),
              ),
              FloatingActionButton(
                backgroundColor: const Color(0xffFFF5F6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.primary)),
                foregroundColor: AppColors.primary,
                onPressed: () {},
                child: const Icon(Icons.add, color: AppColors.primary, size: 24),
              ).pOnly(right: 16),
            ],
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xffF7F7F7),
              child: Column(
                spacing: 16,
                children: [
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 140,

                          child: TabBar(
                            controller: _tabController,
                            tabs: const [Tab(text: 'Members'), Tab(text: 'Leads')],
                            indicator: const UnderlineTabIndicator(
                              borderSide: BorderSide(width: 2, color: Colors.red), // Red underline for the active tab
                            ),
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: Colors.red, // Red color for the active tab underline
                            unselectedLabelColor: Colors.grey, // Grey color for the inactive tab underline
                            labelColor: Colors.red, // Red color for the active tab text
                            labelStyle: AppStyles.text14Px.poppins.w500, // Style for the active tab text
                            unselectedLabelStyle: AppStyles.text14Px.poppins.w400, // Style for the inactive tab text
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), side: const BorderSide(color: Color(0xffDDDDDD))),
                          onPressed: () {},
                          icon: Text('Sort by', style: AppStyles.text12Px.poppins.copyWith(color: const Color(0xff222222))),
                          label: const Icon(Icons.keyboard_arrow_down_sharp),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 16);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ColoredBox(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                spacing: 8,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(80000)),
                                        child: ImageNetwork('https://starkfitnesskochi.com/wp-content/uploads/2024/10/Strength-Training-1-1-1-1-1.webp', height: 40, width: 40),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Praveen K', style: AppStyles.text14Px.poppins.w500.dark),
                                              const SizedBox(height: 4),
                                              Text('+91 9687451236', style: AppStyles.text12Px.poppins.w400.dark),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('memberId', style: AppStyles.text12Px.poppins.w400.textGrey),
                                    ],
                                  ),
                                  Text('Check In', style: AppStyles.text10Px.poppins.w400.textGrey, textAlign: TextAlign.end).align(Alignment.centerRight),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('6 MONTH PLAN + Admission', style: AppStyles.text12Px.poppins.w500.dark),
                                      const SizedBox(height: 4),
                                      Text('05:30 AM', style: AppStyles.text12Px.poppins.w500.dark),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ).pad(16),
            ),
          ),
        ],
      ),
    );
  }
}
