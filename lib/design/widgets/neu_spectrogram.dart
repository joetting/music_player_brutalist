import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Simplified Neubrutalist Spectrogram
/// Restores showGrid and showLabels to resolve compilation errors in mobile_player and main.dart.
class NeuSpectrogram extends StatelessWidget {
  final RatholePalette palette;
  final double height;
  final bool showGrid; // Added to fix compilation error
  final bool showLabels; // Added to fix compilation error
  final List<double>? frequencyData;

  const NeuSpectrogram({
    super.key,
    required this.palette,
    this.height = 140,
    this.showGrid = true,
    this.showLabels = true,
    this.frequencyData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: palette.border, width: 3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(
            painter: _SimpleSpectrogramPainter(
              palette: palette,
              // Fallback to static data if no FFT stream is provided
              data: frequencyData ?? List.generate(32, (i) => 0.2 + (i % 3) * 0.1),
              showGrid: showGrid,
            ),
          ),
        );
      },
    );
  }
}

class _SimpleSpectrogramPainter extends CustomPainter {
  final RatholePalette palette;
  final List<double> data;
  final bool showGrid;

  _SimpleSpectrogramPainter({
    required this.palette,
    required this.data,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0) return;

    final barWidth = size.width / data.length;
    final paint = Paint()..style = PaintingStyle.fill;

    // Optional simple grid line for diagnostic feel
    if (showGrid) {
      final gridPaint = Paint()
        ..color = palette.border.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), gridPaint);
    }

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] * size.height).clamp(0.0, size.height);
      
      // Simplified color mapping
      if (i < data.length * 0.3) {
        paint.color = palette.error;
      } else if (i < data.length * 0.7) {
        paint.color = palette.primary;
      } else {
        paint.color = palette.accent;
      }

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - barHeight,
          (barWidth - 1).clamp(1.0, double.infinity),
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleSpectrogramPainter oldDelegate) => true;
}