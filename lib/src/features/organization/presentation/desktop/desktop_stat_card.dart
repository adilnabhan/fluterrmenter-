import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/core/extensions/typography_extension.dart';
import 'package:mentor_mobile_app/core/themes/app_colors.dart';
import 'package:mentor_mobile_app/core/themes/app_styles.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';

/// Interactive desktop statistic/metric card with smooth hover elevation,
/// cursor feedback, and clean typography.
class DesktopStatCard extends StatefulWidget {
  const DesktopStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.gradient,
    this.prefix,
  });

  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final Widget? icon;
  final String? subtitle;
  final Gradient? gradient;
  final String? prefix;

  @override
  State<DesktopStatCard> createState() => _DesktopStatCardState();
}

class _DesktopStatCardState extends State<DesktopStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final effectiveGradient = isDark
        ? (widget.gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(widget.color.withValues(alpha: 0.25), const Color(0xFF1E1E1E)),
                  Color.alphaBlend(widget.color.withValues(alpha: 0.15), const Color(0xFF181818)),
                ],
              )
            : null)
        : widget.gradient;

    final cardBg = isDark
        ? Color.alphaBlend(widget.color.withValues(alpha: 0.12), context.colors.card)
        : Colors.white;

    final pillBg = widget.gradient != null
        ? (isDark
            ? widget.color.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.85))
        : widget.color.withValues(alpha: 0.12);

    final titleColor = widget.gradient != null
        ? (isDark ? Colors.white : widget.color)
        : (isDark ? Colors.white : const Color(0xFF222222));

    final iconContainerBg = widget.gradient != null
        ? widget.color
        : (_isHovered ? widget.color : widget.color.withValues(alpha: 0.15));

    final arrowIconColor = widget.gradient != null
        ? Colors.white
        : (_isHovered ? Colors.white : widget.color);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: effectiveGradient == null ? cardBg : null,
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.7)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : (widget.gradient != null
                        ? widget.color.withValues(alpha: 0.3)
                        : widget.color.withValues(alpha: 0.15))),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.06),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            hoverColor: widget.color.withValues(alpha: 0.04),
            splashColor: widget.color.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.prefix ?? ""}${widget.count}',
                          style: AppStyles.text22Px.poppins.w700.copyWith(
                            color: widget.color,
                            height: 1.1,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconContainerBg,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: arrowIconColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: titleColor,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

