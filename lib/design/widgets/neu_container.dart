import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Container
/// Features:
/// - Customizable borders
/// - Hard shadows
/// - Asymmetric corner options
/// - Background color variants
class NeuContainer extends StatelessWidget {
  final Widget child;
  final RatholePalette palette;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool asymmetricCorners;
  final bool hasShadow;
  final Offset shadowOffset;

  const NeuContainer({
    super.key,
    required this.child,
    required this.palette,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.borderWidth = 3,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.asymmetricCorners = false,
    this.hasShadow = true,
    this.shadowOffset = const Offset(6, 6),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? palette.surface;
    final bColor = borderColor ?? palette.border;
    final sColor = shadowColor ?? palette.shadow;

    final radius = borderRadius ??
        (asymmetricCorners
            ? const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(0),
              )
            : BorderRadius.circular(8));

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: bColor,
          width: borderWidth,
        ),
        borderRadius: radius,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: sColor,
                  offset: shadowOffset,
                  blurRadius: 0, // Hard shadow!
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Divider with brutalist styling
class NeuDivider extends StatelessWidget {
  final RatholePalette palette;
  final double thickness;
  final double? height;
  final Color? color;

  const NeuDivider({
    super.key,
    required this.palette,
    this.thickness = 2,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? thickness,
      color: color ?? palette.border,
    );
  }
}

/// Brutalist card with title
class NeuCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final RatholePalette palette;
  final VoidCallback? onTap;
  final bool isSelected;

  const NeuCard({
    super.key,
    this.title,
    required this.child,
    required this.palette,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuContainer(
        palette: palette,
        borderColor: isSelected ? palette.primary : palette.border,
        backgroundColor: isSelected
            ? palette.primary.withOpacity(0.1)
            : palette.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 12),
              NeuDivider(palette: palette),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
