import 'dart:ui' as ui;
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';

/// A custom tab bar featuring a connected, curved folder-tab design with
/// smooth concave/convex transitions that seamlessly integrate with the
/// content container below it.
class CurvedTabBar extends StatefulWidget {
  const CurvedTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
    this.height = 50.0,
    this.borderWidth = 1.8,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;
  final double height;
  final double borderWidth;

  @override
  State<CurvedTabBar> createState() => _CurvedTabBarState();
}

class _CurvedTabBarState extends State<CurvedTabBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.selectedIndex.toDouble(),
    );
    _anim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant CurvedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animController.animateTo(
        widget.selectedIndex.toDouble(),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final animVal = _anim.value;
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: CurvedTabBarPainter(
            animationValue: animVal,
            surfaceColor: context.colors.surface,
            borderColor: context.colors.border,
            backgroundColor: context.colors.background,
            borderWidth: widget.borderWidth,
          ),
          child: SizedBox(
            height: widget.height,
            child: Row(
              children: List.generate(widget.tabs.length, (index) {
                final isSelected = widget.selectedIndex == index;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: '${widget.tabs[index]} tab',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onTabChanged(index),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.tabs[index],
                          textAlign: TextAlign.center,
                          style: AppStyles.text14Px.poppins.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? context.colors.textPrimary
                                : context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class CurvedTabBarPainter extends CustomPainter {
  const CurvedTabBarPainter({
    required this.animationValue,
    required this.surfaceColor,
    required this.borderColor,
    required this.backgroundColor,
    this.borderWidth = 1.8,
  });

  final double animationValue; // 0.0 for tab 0, 1.0 for tab 1
  final Color surfaceColor;
  final Color borderColor;
  final Color backgroundColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final containerTop = H;
    const tabTop = 8.0;
    const tabRadius = 14.0;
    const filletRadius = 14.0;
    const outerRadius = 20.0;

    final halfWidth = W / 2;

    // Tab margin from screen edges
    const tabMargin = outerRadius + filletRadius;
    const centerGap = 10.0;

    // Tab 0 boundaries (left half)
    const tab0Left = tabMargin;
    final tab0Right = halfWidth - centerGap;

    // Tab 1 boundaries (right half)
    final tab1Left = halfWidth + centerGap;
    final tab1Right = W - tabMargin;

    final tabLeft = ui.lerpDouble(tab0Left, tab1Left, animationValue)!;
    final tabRight = ui.lerpDouble(tab0Right, tab1Right, animationValue)!;

    // 1. Draw pure background color for the screen header
    canvas.drawRect(
      Rect.fromLTWH(0, 0, W, H),
      Paint()..color = backgroundColor,
    );

    final path = Path();
    final contourPath = Path();

    // Start at left outer edge
    final startY = containerTop + outerRadius;
    path.moveTo(0, H + 20.0);
    path.lineTo(0, startY);
    contourPath.moveTo(0, startY);

    // Outer top-left corner
    path.arcToPoint(
      Offset(outerRadius, containerTop),
      radius: const Radius.circular(outerRadius),
      clockwise: true,
    );
    contourPath.arcToPoint(
      Offset(outerRadius, containerTop),
      radius: const Radius.circular(outerRadius),
      clockwise: true,
    );

    // Left shoulder line (if any space between outer corner and fillet)
    final leftShoulderEnd = tabLeft - filletRadius;
    if (leftShoulderEnd > outerRadius) {
      path.lineTo(leftShoulderEnd, containerTop);
      contourPath.lineTo(leftShoulderEnd, containerTop);
    }

    // Bottom-left concave fillet (curves UP into tab)
    path.arcToPoint(
      Offset(tabLeft, containerTop - filletRadius),
      radius: const Radius.circular(filletRadius),
      clockwise: false,
    );
    contourPath.arcToPoint(
      Offset(tabLeft, containerTop - filletRadius),
      radius: const Radius.circular(filletRadius),
      clockwise: false,
    );

    // Left vertical edge of tab
    path.lineTo(tabLeft, tabTop + tabRadius);
    contourPath.lineTo(tabLeft, tabTop + tabRadius);

    // Top-left convex corner of tab
    path.arcToPoint(
      Offset(tabLeft + tabRadius, tabTop),
      radius: const Radius.circular(tabRadius),
      clockwise: true,
    );
    contourPath.arcToPoint(
      Offset(tabLeft + tabRadius, tabTop),
      radius: const Radius.circular(tabRadius),
      clockwise: true,
    );

    // Top horizontal edge of tab
    path.lineTo(tabRight - tabRadius, tabTop);
    contourPath.lineTo(tabRight - tabRadius, tabTop);

    // Top-right convex corner of tab
    path.arcToPoint(
      Offset(tabRight, tabTop + tabRadius),
      radius: const Radius.circular(tabRadius),
      clockwise: true,
    );
    contourPath.arcToPoint(
      Offset(tabRight, tabTop + tabRadius),
      radius: const Radius.circular(tabRadius),
      clockwise: true,
    );

    // Right vertical edge of tab
    path.lineTo(tabRight, containerTop - filletRadius);
    contourPath.lineTo(tabRight, containerTop - filletRadius);

    // Bottom-right concave fillet (curves DOWN to containerTop)
    final rightShoulderStart = tabRight + filletRadius;
    path.arcToPoint(
      Offset(rightShoulderStart, containerTop),
      radius: const Radius.circular(filletRadius),
      clockwise: false,
    );
    contourPath.arcToPoint(
      Offset(rightShoulderStart, containerTop),
      radius: const Radius.circular(filletRadius),
      clockwise: false,
    );

    // Right shoulder line (runs along containerTop to outer right corner)
    final rightShoulderEnd = W - outerRadius;
    if (rightShoulderEnd > rightShoulderStart) {
      path.lineTo(rightShoulderEnd, containerTop);
      contourPath.lineTo(rightShoulderEnd, containerTop);
    }

    // Outer top-right corner
    final endY = containerTop + outerRadius;
    path.arcToPoint(
      Offset(W, endY),
      radius: const Radius.circular(outerRadius),
      clockwise: true,
    );
    contourPath.arcToPoint(
      Offset(W, endY),
      radius: const Radius.circular(outerRadius),
      clockwise: true,
    );

    // Close path along the bottom
    path.lineTo(W, H + 20.0);
    path.lineTo(0, H + 20.0);
    path.close();

    // 2. Fill the connected tab & container shape with light grey surface color
    canvas.drawPath(
      path,
      Paint()
        ..color = surfaceColor
        ..style = PaintingStyle.fill,
    );

    // 3. Stroke the continuous top contour with the border
    canvas.drawPath(
      contourPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CurvedTabBarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
