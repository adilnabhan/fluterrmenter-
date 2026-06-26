import 'package:mentor_mobile_app/imports_bindings.dart';

///
class ProductShimmer extends StatelessWidget {
  ///
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: KShimmer()),
        12.verticalSpace,
        KShimmer.text(height: 12.r, width: double.maxFinite).pOnly(bottom: 4.r),
        KShimmer.text(height: 12.r, width: double.maxFinite),
        18.verticalSpace,
        KShimmer.text(height: 10.r, width: double.maxFinite),
        16.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: Column(children: [KShimmer.text(height: 12.r, width: double.maxFinite).pOnly(bottom: 8.r), KShimmer.text(height: 12.r, width: double.maxFinite)])),
            8.horizontalSpace,
            Flexible(child: KShimmer(height: 32.r, radius: 4.r)),
          ],
        ),
      ],
    );
  }
}
