import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ascii_icons.dart';

/// Detailed audio path diagnostic panel.
/// Visualizes the flow from file source to hardware output.
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: palette.shadow, 
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIO_SIGNAL_PATH_DIAGNOSTICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: palette.text.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          
          // Path Flow Diagram
          _buildStage(
            'SOURCE_FILE',
            '$sourceFormat • ${sourceSampleRate ~/ 1000}kHz / $sourceBitDepth-bit',
            AsciiGlyph.file,
            AudioQualityColors.forSampleRate(sourceSampleRate),
          ),
          
          _buildConnector(),
          
          _buildStage(
            'HARDWARE_OUTPUT',
            '$outputDevice • ${outputSampleRate ~/ 1000}kHz / $outputBitDepth-bit',
            AsciiGlyph.speaker,
            AudioQualityColors.forSampleRate(outputSampleRate),
          ),
          
          const SizedBox(height: 24),
          
          // Status Chips (Exclusive Mode, Bit-Perfect)
          Row(
            children: [
              _buildStatusChip('EXCLUSIVE_MODE', exclusiveMode),
              const SizedBox(width: 8),
              _buildStatusChip('BIT_PERFECT', bitPerfect),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStage(String label, String details, AsciiGlyph glyph, Color qualityColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          AsciiIcon(glyph, color: qualityColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
                Text(
                  details,
                  style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: Container(
        width: 3,
        height: 20,
        color: palette.border,
      ),
    );
  }

  Widget _buildStatusChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? palette.primary.withOpacity(0.2) : palette.error.withOpacity(0.2),
        border: Border.all(color: active ? palette.primary : palette.error, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AsciiIcon(
            active ? AsciiGlyph.check : AsciiGlyph.error,
            size: 14,
            color: active ? palette.primary : palette.error,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}