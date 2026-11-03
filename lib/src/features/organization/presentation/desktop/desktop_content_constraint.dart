import 'package:flutter/material.dart';

/// Breakpoints and responsive utility for the Desktop FitnessCenter module.
class DesktopBreakpoints {
  const DesktopBreakpoints._();

  static const double compactMax = 1024;
  static const double mediumMax = 1440;
  static const double defaultMaxContentWidth = 1380;

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < compactMax;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= compactMax && w < mediumMax;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= mediumMax;

  /// Returns recommended column count for metric cards or grids.
  static int getCardGridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 800) return 1;
    if (w < 1100) return 2;
    if (w < 1500) return 3;
    return 4;
  }

  /// Returns recommended column count for stats cards (e.g. 7 dashboard metrics).
  static int getStatGridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 850) return 2;
    if (w < 1280) return 3;
    if (w < 1650) return 4;
    return 4;
  }
}

/// A wrapper widget that constrains content to a maximum width on desktop
/// and centers it horizontally, preventing excessive stretching on ultra-wide screens.
/// On mobile screen widths (< 900px), it seamlessly returns the child untouched.
class DesktopContentConstraint extends StatelessWidget {
  const DesktopContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = DesktopBreakpoints.defaultMaxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 900) {
      return child;
    }

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
