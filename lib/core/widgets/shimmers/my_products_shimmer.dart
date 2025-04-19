import 'package:mentor_mobile_app/imports_bindings.dart';

///
class MyProductShimmer extends StatelessWidget {
  // ignore: public_member_api_docs
  const MyProductShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Flexible(child: KShimmer(height: 120, width: context.width, radius: 10)), 8.horizontalSpace, Flexible(child: KShimmer(height: 120, width: context.width, radius: 10))]),
        15.verticalSpace,
        ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, index) => KShimmer(height: 100, width: context.width, radius: 10),
          separatorBuilder: (context, index) => 12.verticalSpace,
          itemCount: 5,
        ),
      ],
    );
  }
}
