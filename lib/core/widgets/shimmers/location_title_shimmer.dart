import 'package:mentor_mobile_app/imports_bindings.dart';

///
class LocationTextShimmer extends StatelessWidget {
  // ignore: public_member_api_docs
  const LocationTextShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KShimmer(height: 18, width: 200, radius: 4),
        8.verticalSpace,
        const KShimmer(height: 16, width: 250, radius: 4),
        5.verticalSpace,
        const KShimmer(height: 16, width: 210, radius: 4),
      ],
    );
  }
}
