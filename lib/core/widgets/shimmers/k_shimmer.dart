import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

///
class KShimmer extends StatelessWidget {
  ///
  const KShimmer({this.width, this.height, this.radius = 8, super.key});

  ///
  factory KShimmer.text({double? width, double? height, double radius = 0}) {
    return KShimmer(height: height ?? 12.r, width: width ?? Feggy.navKey.currentContext!.width * 0.4, radius: radius);
  }

  ///
  final double? width;

  ///
  final double? height;

  ///
  final double radius;
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF242424) : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF383838) : Colors.grey.shade100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: isDark ? const Color(0xFF242424) : Colors.grey,
          child: SizedBox(
            width: width ?? double.maxFinite,
            height: height ?? double.maxFinite,
          ),
        ),
      ),
    );
  }
}
