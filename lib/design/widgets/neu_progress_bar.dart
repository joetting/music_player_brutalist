import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Progress Bar
/// Features:
/// - Chunky track with hard edges
/// - Bold progress indicator
/// - Optional time labels
/// - Seekable functionality
class NeuProgressBar extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final RatholePalette palette;
  final Color? progressColor;
  final double height;
  final bool showLabels;
  final String? leftLabel;
  final String? rightLabel;

  const NeuProgressBar({
    super.key,
    required this.value,
    this.onChanged,
    required this.palette,
    this.progressColor,
    this.height = 12,
    this.showLabels = false,
    this.leftLabel,
    this.rightLabel,
  });

  @override
  State<NeuProgressBar> createState() => _NeuProgressBarState();
}

class _NeuProgressBarState extends State<NeuProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final progColor = widget.progressColor ?? widget.palette.primary;
    final currentValue = _dragValue ?? widget.value.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        GestureDetector(
          onHorizontalDragUpdate: widget.onChanged != null
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);
                  final value = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                  setState(() => _dragValue = value);
                }
              : null,
          onHorizontalDragEnd: widget.onChanged != null
              ? (details) {
                  if (_dragValue != null) {
                    widget.onChanged!(_dragValue!);
                    setState(() => _dragValue = null);
                  }
                }
              : null,
          onTapDown: widget.onChanged != null
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);
                  final value = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                  widget.onChanged!(value);
                }
              : null,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.palette.surface,
              border: Border.all(color: widget.palette.border, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Progress fill
                FractionallySizedBox(
                  widthFactor: currentValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Hard edge marker at current position
                Positioned(
                  left: currentValue * MediaQuery.of(context).size.width - 2,
                  child: Container(
                    width: 4,
                    height: widget.height,
                    color: widget.palette.border,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Labels
        if (widget.showLabels) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.leftLabel ?? '',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: widget.palette.text.withOpacity(0.7),
                ),
              ),
              Text(
                widget.rightLabel ?? '',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: widget.palette.text.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Waveform-style progress bar (future enhancement)
/// Shows song structure visually
class NeuWaveformProgress extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final RatholePalette palette;
  final List<double> waveformData; // 0.0 to 1.0 amplitude values
  final double height;

  const NeuWaveformProgress({
    super.key,
    required this.value,
    this.onChanged,
    required this.palette,
    required this.waveformData,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onChanged != null
          ? (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final value = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
              onChanged!(value);
            }
          : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.border, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: _WaveformPainter(
            waveformData: waveformData,
            progress: value,
            palette: palette,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final RatholePalette palette;

  _WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final amplitude = waveformData[i];
      final barHeight = amplitude * size.height * 0.8;

      final paint = Paint()
        ..color = (i / waveformData.length) < progress
            ? palette.primary
            : palette.border.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Draw hard-edged bar
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          centerY - barHeight / 2,
          barWidth - 1, // Gap between bars
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveformData != waveformData;
  }
}
