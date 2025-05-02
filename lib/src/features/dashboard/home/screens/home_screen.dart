import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/dashboard/home/components/calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cards = [
      (title: 'Active Members', color: const Color(0xff486CC2), count: 54),
      (title: 'Total Leads & Members', color: const Color(0xff9C51BF), count: 72),
      (title: 'Expired Members', color: const Color(0xff527F50), count: 33),
      (title: 'Upcoming Members', color: const Color(0xffC85074), count: 42),
    ];
    return Scaffold(
      appBar: AppBar(
        title: OutlinedButton.icon(onPressed: () {}, label: const Icon(Icons.keyboard_arrow_down_sharp), icon: const Text('Discpl')),
        centerTitle: false,
        actions: [SvgPicture.asset('assets/images/svg/vectors/logo.svg', height: 24, width: 24).pOnly(right: 16)],
      ),
      body: ListView(
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
              return ClipRRect(
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
          CustomCalendar(),
          const SizedBox(height: 40),
          Text('Member Insights', style: AppStyles.text18Px.poppins.w600.dark),
          const SizedBox(height: 16),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
