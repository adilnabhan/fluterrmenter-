import 'package:mentor_mobile_app/imports_bindings.dart';

///
class GloablProductShimmer extends StatelessWidget {
  // ignore: public_member_api_docs
  const GloablProductShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) => KShimmer(height: 90, width: context.width, radius: 10),
      separatorBuilder: (context, index) => 12.verticalSpace,
      itemCount: 7,
    );
  }
}
