// ignore_for_file: public_member_api_docs

import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
class ErrorUi extends StatefulWidget {
  ///* For using 404 Client Error Widget
  factory ErrorUi.notFound({CallVoid? onTap}) {
    return ErrorUi._(
      subtitle: "We're sorry, but something went wrong.",
      img: 'assets/images/png/vectors/404.png',
      title: 'PAGE NOT FOUND !',
      buttonTitle: 'Back home',
      imageHeight: 328.h,
      imageWidth: 328.w,
      onTap: onTap,
    );
  }

  ///* For using 500 Server Error Widget
  factory ErrorUi.server({CallVoid? onTap}) {
    return ErrorUi._(
      subtitle: "Oops! Something went wrong. We're on it. Please try again later..",
      img: 'assets/images/png/vectors/500.png',
      title: 'Internal server error !'.toUpperCase(),
      buttonTitle: 'Retry',
      imageHeight: 328.h,
      imageWidth: 328.w,
      onTap: onTap,
    );
  }

  ///* For using Network Error Widget
  factory ErrorUi.network({CallVoid? onTap}) {
    return ErrorUi._(
      title: 'No internet !'.toUpperCase(),
      subtitle: 'Could not connect to the network. Please check your internet.',
      img: 'assets/images/png/vectors/network.png',
      buttonTitle: 'Retry',
      imageHeight: 297.h,
      imageWidth: 200.w,
      onTap: onTap,
    );
  }

  ///* For using Network Error Widget
  factory ErrorUi.empty({CallVoid? onTap}) {
    return ErrorUi._(
      title: 'Empty Data !'.toUpperCase(),
      subtitle: 'No data found. Please add some data.',
      img: 'assets/images/png/vectors/empty.png',
      buttonTitle: onTap != null ? 'Retry' : null,
      imageHeight: 297.h,
      imageWidth: 200.w,
      onTap: onTap,
    );
  }

  const ErrorUi._({this.title, this.subtitle, this.img, this.buttonTitle, this.onTap, this.imageHeight, this.imageWidth});
  final String? title;
  final String? subtitle;
  final String? img;
  final String? buttonTitle;
  final CallVoid? onTap;
  final double? imageHeight;
  final double? imageWidth;

  @override
  State<ErrorUi> createState() => _ErrorUiState();
}

class _ErrorUiState extends State<ErrorUi> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = MediaQuery.sizeOf(context).width >= 650;
        final double? effectiveHeight;
        final double? effectiveWidth;
        if (isDesktop) {
          effectiveHeight = (widget.imageHeight != null && widget.imageHeight! < 180.0)
              ? widget.imageHeight!
              : 160.0;
          effectiveWidth = (widget.imageWidth != null && widget.imageWidth! < 180.0)
              ? widget.imageWidth!
              : 160.0;
        } else {
          effectiveHeight = widget.imageHeight ?? (constraints.maxHeight.isFinite ? constraints.maxHeight * 0.4 : null);
          effectiveWidth = widget.imageWidth ?? (constraints.maxWidth.isFinite ? constraints.maxWidth * 0.4 : null);
        }

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 480 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    widget.img ?? '',
                    fit: isDesktop ? BoxFit.contain : BoxFit.cover,
                    height: effectiveHeight,
                    width: effectiveWidth,
                  ),
                  (isDesktop ? 16.0 : 20.0).verticalSpace,
                  if (widget.title != null)
                    Text(
                      widget.title ?? '',
                      textAlign: TextAlign.center,
                      style: (isDesktop ? AppStyles.text16Px : AppStyles.text20Px).w600.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  if (widget.title != null) (isDesktop ? 6.0 : 10.0).verticalSpace,
                  Text(
                    widget.subtitle ?? '',
                    textAlign: TextAlign.center,
                    style: AppStyles.text14Px.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ).pxy(x: isDesktop ? 20.0 : constraints.maxWidth * 0.1),
                  (isDesktop ? 18.0 : 28.0).verticalSpace,
                  if (widget.buttonTitle?.isNotEmpty ?? false)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4000000.r),
                      child: InkWell(
                        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                        onTap: widget.onTap,
                        child: ColoredBox(
                          color: AppColors.primary,
                          child: Text(
                            widget.buttonTitle ?? '',
                            style: AppStyles.text14Px.w600.copyWith(color: AppColors.light),
                          ).pxy(x: 24.r, y: 10.r),
                        ),
                      ),
                    ).center,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
