import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Slider
/// Features:
/// - Chunky track with hard borders
/// - Bold thumb with shadow
/// - Color-coded value display
class NeuSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final RatholePalette palette;
  final double min;
  final double max;
  final Color? activeColor;
  final double height;

  const NeuSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.palette,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final acColor = activeColor ?? palette.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: acColor,
          inactiveTrackColor: palette.border.withOpacity(0.2),
          thumbColor: acColor,
          overlayColor: acColor.withOpacity(0.2),
          trackHeight: 8,
          thumbShape: const _NeuThumbShape(
            enabledThumbRadius: 16,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Custom thumb shape with border
class _NeuThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;

  const _NeuThumbShape({
    required this.enabledThumbRadius,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Inner fill
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center + const Offset(3, 3),
      enabledThumbRadius,
      shadowPaint,
    );

    // Draw thumb
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);
  }
}

/// Vertical slider variant for EQ
class NeuVerticalSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final RatholePalette palette;
  final double min;
  final double max;
  final Color? activeColor;
  final double width;

  const NeuVerticalSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.palette,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor,
    this.width = 60,
  });

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: NeuSlider(
        value: value,
        onChanged: onChanged,
        palette: palette,
        min: min,
        max: max,
        activeColor: activeColor,
        height: width,
      ),
    );
  }
}
