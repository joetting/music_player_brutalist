import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Mel-Spectrogram Diagnostic Tool
/// 
/// Visualizes high-frequency audio data in real-time. [cite: 1]
/// Rejects standard "screensaver" aesthetics for a "measurement tool" look. [cite: 3, 5]
class NeuSpectrogram extends StatefulWidget {
  final RatholePalette palette;
  final double height;
  final bool showGrid;
  final bool showLabels;
  final List<double>? frequencyData; // Real-time FFT magnitudes

  const NeuSpectrogram({
    super.key,
    required this.palette,
    this.height = 200,
    this.showGrid = true,
    this.showLabels = true,
    this.frequencyData,
  });

  @override
  State<NeuSpectrogram> createState() => _NeuSpectrogramState();
}

class _NeuSpectrogramState extends State<NeuSpectrogram>
    with SingleTickerProviderStateMixin {
  late AnimationController _mockController;
  final math.Random _random = math.Random();
  List<double>? _cachedData;

  @override
  void initState() {
    super.initState();
    // Animation for mock data when real FFT stream is absent [cite: 5]
    _mockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    // Only animate if we don't have real data
    if (widget.frequencyData == null) {
      _mockController.addListener(_updateMockData);
      _mockController.repeat();
    }
  }

  void _updateMockData() {
    if (mounted) {
      setState(() {
        _cachedData = List.generate(64, (i) => _random.nextDouble());
      });
    }
  }

  @override
  void dispose() {
    _mockController.removeListener(_updateMockData);
    _mockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black, // Stark background for structural visibility [cite: 1, 3]
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: _SpectrogramPainter(
          palette: widget.palette,
          // Use provided data or cached mock data [cite: 5]
          data: widget.frequencyData ?? _cachedData ?? List.generate(64, (i) => 0.5),
          showGrid: widget.showGrid,
          showLabels: widget.showLabels,
        ),
      ),
    );
  }
}

class _SpectrogramPainter extends CustomPainter {
  final RatholePalette palette;
  final List<double> data;
  final bool showGrid;
  final bool showLabels;

  _SpectrogramPainter({
    required this.palette,
    required this.data,
    required this.showGrid,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBars(canvas, size);
    if (showGrid) _drawDiagnosticOverlay(canvas, size);
  }

  void _drawBars(Canvas canvas, Size size) {
    final barWidth = size.width / data.length;
    final paint = Paint()..style = PaintingStyle.fill;

  for (int i = 0; i < data.length; i++) {
      final barHeight = data[i] * size.height;
      
      // Neobrutalist sharp rectangular bars (no rounded corners) [cite: 1, 5]
      // Color coding by frequency range: Bass (Red) -> Treble (Green) [cite: 5]
      if (i < data.length * 0.2) {
        paint.color = palette.error; // Bass
      } else if (i < data.length * 0.5) {
        paint.color = Colors.amber; // Low-mid
      } else if (i < data.length * 0.8) {
        paint.color = palette.primary; // High-mid
      } else {
        paint.color = Colors.lightGreenAccent; // Treble
      }

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - barHeight,
          barWidth - 1, // 1px gap for structural visibility [cite: 3]
          barHeight,
        ),
        paint,
      );
    }
  }

  /// Draws the diagnostic grid and labels using monospace typography [cite: 3, 5]
  void _drawDiagnosticOverlay(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = palette.border.withValues(alpha: 0.1) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Frequency Grid (Hz markers)
    final frequencies = ['20Hz', '1kHz', '5kHz', '20kHz'];
    for (int i = 0; i < frequencies.length; i++) {
      double x = (size.width / (frequencies.length - 1)) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      
      if (showLabels) {
        _drawMonospaceText(canvas, frequencies[i], Offset(x + 4, size.height - 15));
      }
    }

    // 2. Amplitude Grid (dB markers)
    final dbLevels = ['0dB', '-24dB', '-48dB', '-96dB'];
    for (int i = 0; i < dbLevels.length; i++) {
      double y = (size.height / (dbLevels.length - 1)) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      
      if (showLabels) {
        _drawMonospaceText(canvas, dbLevels[i], Offset(5, y + 2));
      }
    }
  }

  void _drawMonospaceText(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: palette.text.withValues(alpha: 0.5),
          fontFamily: 'JetBrains Mono', // Monospace font as per research [cite: 3, 5]
          fontSize: 9,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _SpectrogramPainter oldDelegate) => true;
}