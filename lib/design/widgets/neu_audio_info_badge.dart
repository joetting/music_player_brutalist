import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Compact audio quality indicator.
/// Color-coded by sample rate/bitrate to provide instant quality feedback.
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
    // Get quality color based on sample rate
    final qualityColor = AudioQualityColors.forSampleRate(sampleRate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: qualityColor.withValues(alpha: 0.2),
          border: Border.all(color: palette.border, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Exclusive mode bolt icon
            if (exclusiveMode)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.bolt, size: 14, color: palette.primary),
              ),
            Text(
              format.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
            const SizedBox(width: 4),
            Container(width: 1, height: 10, color: palette.border.withValues(alpha: 0.3)),
            const SizedBox(width: 4),
            Text(
              '${sampleRate ~/ 1000}kHz / $bitDepth-bit',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w700,
                color: palette.text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}