import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Spectrogram/Frequency Analyzer
/// Features:
/// - Hard-edged frequency bars (brutalist style)
/// - Grid overlay with technical labels
/// - Color-coded frequency ranges
/// - Real-time animation (mockup with random data)
/// - Frequency labels (20Hz, 1kHz, 20kHz)
class NeuSpectrogram extends StatelessWidget {
  final RatholePalette palette;
  final double height;
  final bool showGrid;
  final bool showLabels;
  final List<double>? frequencyData;

  const NeuSpectrogram({
    super.key,
    required this.palette,
    this.height = 200,
    this.showGrid = true,
    this.showLabels = true,
    this.frequencyData,
  });

  @override
  Widget build(BuildContext context) {
    // Use static mock data for now to avoid animation issues
    final data = frequencyData ?? _generateStaticMockData();

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            // Spectrogram bars
            CustomPaint(
              size: Size(double.infinity, height),
              painter: _SpectrogramPainter(
                data: data,
                palette: palette,
                showGrid: showGrid,
              ),
            ),

            // Frequency labels
            if (showLabels) _buildLabels(),
          ],
        ),
      ),
    );
  }

  List<double> _generateStaticMockData() {
    // Generate static demo data (no animation)
    return List.generate(64, (i) {
      final baseLoudness = 1.0 - (i / 64);
      return (baseLoudness * 0.7 + (i % 3) * 0.1).clamp(0.0, 1.0);
    });
  }

  Widget _buildLabels() {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLabel('20Hz'),
          _buildLabel('200Hz'),
          _buildLabel('2kHz'),
          _buildLabel('20kHz'),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: palette.surface.withOpacity(0.9),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: palette.text,
        ),
      ),
    );
  }
}

class _SpectrogramPainter extends CustomPainter {
  final List<double> data;
  final RatholePalette palette;
  final bool showGrid;

  _SpectrogramPainter({
    required this.data,
    required this.palette,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barWidth = size.width / data.length;

    // Draw grid first
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // Draw frequency bars
    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth;
      final amplitude = data[i];
      final barHeight = amplitude * size.height;

      // Color code by frequency range
      final color = _getFrequencyColor(i / data.length);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Hard-edged bars (no rounded corners!)
      canvas.drawRect(
        Rect.fromLTWH(
          x + 1, // Small gap between bars
          size.height - barHeight,
          barWidth - 2,
          barHeight,
        ),
        paint,
      );

      // Border on each bar for extra brutalism
      final borderPaint = Paint()
        ..color = palette.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawRect(
        Rect.fromLTWH(
          x + 1,
          size.height - barHeight,
          barWidth - 2,
          barHeight,
        ),
        borderPaint,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = palette.border.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal lines (dB levels)
    for (int i = 1; i < 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical lines (frequency markers)
    for (int i = 1; i < 4; i++) {
      final x = (size.width / 4) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  Color _getFrequencyColor(double position) {
    // Color code frequency ranges
    if (position < 0.25) {
      // Bass (20Hz-200Hz) - Red
      return const Color(0xFFFF006E);
    } else if (position < 0.5) {
      // Low-mid (200Hz-2kHz) - Yellow
      return const Color(0xFFFFDB00);
    } else if (position < 0.75) {
      // High-mid (2kHz-10kHz) - Cyan
      return const Color(0xFF00D4FF);
    } else {
      // Treble (10kHz-20kHz) - Green
      return const Color(0xFF00FF9F);
    }
  }

  @override
  bool shouldRepaint(_SpectrogramPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// Compact audio info badge
class NeuAudioInfoBadge extends StatelessWidget {
  final String format;
  final int sampleRate;
  final int bitDepth;
  final bool exclusiveMode;
  final RatholePalette palette;
  final VoidCallback? onTap;

  const NeuAudioInfoBadge({
    super.key,
    required this.format,
    required this.sampleRate,
    required this.bitDepth,
    required this.exclusiveMode,
    required this.palette,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final qualityColor = AudioQualityColors.forSampleRate(sampleRate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: qualityColor.withOpacity(0.2),
          border: Border.all(color: palette.border, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Format
            Text(
              format.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
            const SizedBox(width: 6),

            // Divider
            Container(
              width: 1,
              height: 12,
              color: palette.border,
            ),
            const SizedBox(width: 6),

            // Sample rate / bit depth
            Text(
              '${sampleRate ~/ 1000}kHz/$bitDepth-bit',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            ),
            const SizedBox(width: 6),

            // Exclusive mode indicator
            if (exclusiveMode)
              Icon(
                Icons.bolt,
                size: 14,
                color: palette.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Expandable audio path diagnostic panel
class NeuAudioPanel extends StatelessWidget {
  final String sourceFormat;
  final int sourceSampleRate;
  final int sourceBitDepth;
  final String outputDevice;
  final int outputSampleRate;
  final int outputBitDepth;
  final bool exclusiveMode;
  final bool bitPerfect;
  final RatholePalette palette;

  const NeuAudioPanel({
    super.key,
    required this.sourceFormat,
    required this.sourceSampleRate,
    required this.sourceBitDepth,
    required this.outputDevice,
    required this.outputSampleRate,
    required this.outputBitDepth,
    required this.exclusiveMode,
    required this.bitPerfect,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'AUDIO PATH',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 12),

          // Source
          _buildInfoRow(
            'Source',
            '$sourceFormat • ${sourceSampleRate ~/ 1000}kHz/$sourceBitDepth-bit',
            palette.primary,
          ),
          const SizedBox(height: 8),

          // Arrow
          Center(
            child: Icon(
              Icons.arrow_downward,
              color: palette.text.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(height: 8),

          // Output
          _buildInfoRow(
            'Output',
            '$outputDevice • ${outputSampleRate ~/ 1000}kHz/$outputBitDepth-bit',
            palette.secondary,
          ),
          const SizedBox(height: 12),

          // Status indicators
          Row(
            children: [
              _buildStatusChip(
                exclusiveMode ? 'Exclusive Mode' : 'Shared Mode',
                exclusiveMode,
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                bitPerfect ? 'Bit-Perfect' : 'Resampled',
                bitPerfect,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.robotoCondensed(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? palette.primary.withOpacity(0.2)
            : palette.error.withOpacity(0.1),
        border: Border.all(
          color: isActive ? palette.primary : palette.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isActive ? palette.primary : palette.error,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
          ),
        ],
      ),
    );
  }
}
