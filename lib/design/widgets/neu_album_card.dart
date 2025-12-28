import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Custom Neubrutalist Album Card
/// Features:
/// - Asymmetric border radius (brutalist principle)
/// - Hard shadows with no blur
/// - Bold typography
/// - Quality badges for audio specs
/// - MusicBrainz verification indicator
class NeuAlbumCard extends StatelessWidget {
  final String albumTitle;
  final String artistName;
  final String? artworkUrl;
  final int trackCount;
  final int? year;
  final int? sampleRate;
  final int? bitDepth;
  final bool hasMusicBrainzId;
  final VoidCallback onTap;
  final RatholePalette palette;

  const NeuAlbumCard({
    super.key,
    required this.albumTitle,
    required this.artistName,
    this.artworkUrl,
    required this.trackCount,
    this.year,
    this.sampleRate,
    this.bitDepth,
    this.hasMusicBrainzId = false,
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
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.border, width: 3),
          // Asymmetric corners - classic neubrutalist touch
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              offset: const Offset(8, 8),
              blurRadius: 0, // Hard shadow - no blur!
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Art
            _buildAlbumArt(qualityColor),

            // Metadata Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album Title
                  Text(
                    albumTitle,
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Artist Name
                  Text(
                    artistName,
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: palette.text.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Metadata Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (year != null)
                        _buildChip(year.toString(), palette.tertiary),
                      _buildChip('$trackCount tracks', palette.secondary),
                      if (sampleRate != null && bitDepth != null)
                        _buildChip(
                          '${sampleRate! ~/ 1000}k/$bitDepth-bit',
                          qualityColor,
                        ),
                      if (hasMusicBrainzId)
                        _buildChip('MB✓', palette.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(Color qualityColor) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: palette.border, width: 3),
          ),
          color: qualityColor.withOpacity(0.2),
        ),
        child: Stack(
          children: [
            // Album artwork or placeholder
            if (artworkUrl != null)
              Image.network(
                artworkUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // Quality badge overlay
            if (sampleRate != null && bitDepth != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: qualityColor,
                    border: Border.all(color: palette.border, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AudioQualityColors.qualityLabel(sampleRate!, bitDepth!),
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: palette.surface,
      child: Center(
        child: Icon(
          Icons.album,
          size: 64,
          color: palette.text.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        border: Border.all(color: palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: palette.text,
        ),
      ),
    );
  }
}
