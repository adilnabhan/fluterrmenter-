import 'package:mentor_mobile_app/imports_bindings.dart';
//
// ///
// class ImageNetwork extends StatelessWidget {
//   ///
//   const ImageNetwork(
//     this.imageUrl, {
//     super.key,
//     this.placeholderWidget,
//     this.errorWidget,
//     this.width,
//     this.height,
//     this.fit = BoxFit.cover,
//   });
//
//   ///image url to load image
//   final String? imageUrl;
//
//   ///loading widget while image is loading
//   final Widget? placeholderWidget;
//
//   ///error widget to show error when image loading failed or invalid image url
//   final Widget? errorWidget;
//
//   ///
//   final double? width;
//
//   ///
//   final double? height;
//
//   ///
//   final BoxFit fit;
//
//   @override
//   Widget build(BuildContext context) {
//     if (imageUrl?.isEmpty ?? true) {
//       return errorWidget ?? empty;
//     }
//     return CachedNetworkImage(
//       imageUrl: imageUrl!,
//       width: width,
//       height: height,
//       fit: fit,
//       placeholder: (_, __) {
//         return placeholderWidget ??
//             Shimmer.fromColors(
//               baseColor: Colors.white,
//               highlightColor: Colors.grey[300]!,
//               child: Container(
//                 width: width,
//                 height: height,
//                 color: Colors.grey[300],
//               ),
//
//               // ColoredBox(
//               //   color: Colors.grey[300]!,
//               //   child: SizedBox(width: width, height: height),
//               // ),
//             );
//       },
//       errorWidget: (_, __, error) {
//         return errorWidget ?? Center(child: empty);
//       },
//     );
//   }
//
//   ///
//   Widget get empty => Container(
//     alignment: Alignment.center,
//     height: height,
//     width: width,
//     color: Colors.grey.shade400,
//     child: Icon(
//       Icons.image,
//       color: Colors.white,
//       size: height ?? 50,
//       semanticLabel: 'Image not found',
//     ),
//   );
// }



///
class ImageNetwork extends StatelessWidget {
  ///
  const ImageNetwork(
      this.imageUrl, {
        super.key,
        this.placeholderWidget,
        this.errorWidget,
        this.width,
        this.height,
        this.fit = BoxFit.cover,
      });

  /// image url
  final String? imageUrl;

  /// shimmer or custom placeholder
  final Widget? placeholderWidget;

  /// error widget
  final Widget? errorWidget;

  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? empty;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,

      // ❌ NO resizing → keeps full clarity
      // memCacheWidth / memCacheHeight REMOVED

      // Faster appearance
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,

      // Keep shimmer
      placeholder: (_, __) {
        return placeholderWidget ??
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: width,
                height: height,
                color: Colors.grey.shade300,
              ),
            );
      },

      errorWidget: (_, __, ___) => errorWidget ?? empty,
    );
  }

  ///
  Widget get empty => Container(
    alignment: Alignment.center,
    height: height,
    width: width,
    color: Colors.grey.shade400,
    child: Icon(
      Icons.image,
      color: Colors.white,
      size: height ?? 50,
      semanticLabel: 'Image not found',
    ),
  );
}