import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Custom Neubrutalist Track Tile
/// Features:
/// - Shows playing state with animated icon
/// - Quality badges for audio specs
/// - Bold borders when active
/// - Hard shadows for playing tracks
class NeuTrackTile extends StatelessWidget {
  final int? trackNumber;
  final String title;
  final String artist;
  final Duration duration;
  final int? sampleRate;
  final int? bitDepth;
  final String? format;
  final bool isPlaying;
  final VoidCallback onTap;
  final RatholePalette palette;

  const NeuTrackTile({
    super.key,
    this.trackNumber,
    required this.title,
    required this.artist,
    required this.duration,
    this.sampleRate,
    this.bitDepth,
    this.format,
    this.isPlaying = false,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final qualityColor = sampleRate != null
        ? AudioQualityColors.forSampleRate(sampleRate!)
        : palette.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaying
              ? palette.primary.withOpacity(0.2)
              : palette.surface,
          border: Border.all(
            color: isPlaying ? palette.primary : palette.border,
            width: isPlaying ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: palette.shadow,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Track number or playing indicator
            SizedBox(
              width: 40,
              child: isPlaying
                  ? Icon(
                      Icons.graphic_eq,
                      color: palette.primary,
                      size: 24,
                    )
                  : Text(
                      trackNumber?.toString() ?? '—',
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.text.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),

            // Title and Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: palette.text.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Quality badge
            if (sampleRate != null && bitDepth != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.3),
                  border: Border.all(color: palette.border, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${sampleRate! ~/ 1000}k/${bitDepth}b',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // Duration
            Text(
              _formatDuration(duration),
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                color: palette.text.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
