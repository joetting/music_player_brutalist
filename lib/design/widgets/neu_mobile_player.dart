import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'ascii_icons.dart';
import 'neu_spectrogram.dart';
import 'neu_audio_info_badge.dart';
import 'neu_button.dart';
import 'neu_progress_bar.dart';

/// Full-screen "Now Playing" Modal for Android.
/// 
/// Implements "Comfort Mode" with large hit targets (72dp+) and high information density.
/// Features an integrated Mel-Spectrogram and Audio Diagnostic Badge to solve the "Transparency Deficit".
class NeuMobileExpandedPlayer extends StatelessWidget {
  final String trackTitle;
  final String artistName;
  final String? albumTitle;
  final bool isPlaying;
  final bool isShuffled;
  final bool isRepeating;
  final double progress;
  final Duration position;
  final Duration duration;
  final double volume;
  final RatholePalette palette;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final Function(double) onSeek;
  final Function(double) onVolumeChange;

  const NeuMobileExpandedPlayer({
    super.key,
    required this.trackTitle,
    required this.artistName,
    this.albumTitle,
    required this.isPlaying,
    required this.isShuffled,
    required this.isRepeating,
    required this.progress,
    required this.position,
    required this.duration,
    required this.volume,
    required this.palette,
    required this.onClose,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
    required this.onRepeat,
    required this.onSeek,
    required this.onVolumeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AsciiIconButton(
          glyph: AsciiGlyph.chevronDown,
          onPressed: onClose,
          size: 32,
          color: palette.text,
        ),
        title: Text(
          'NOW PLAYING',
          style: GoogleFonts.robotoCondensed(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: palette.text.withOpacity(0.6),
          ),
        ),
        centerTitle: true,
        actions: [
          AsciiIconButton(
            glyph: AsciiGlyph.more,
            onPressed: () {}, // Context menu for technical properties
            color: palette.text,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // 1. Large Diagnostic Hero Area
            // Combines visual branding with the "Truth to Materials" Mel-Spectrogram.
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(color: palette.border, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: palette.shadow,
                      offset: const Offset(8, 8),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: AsciiIcon(
                        AsciiGlyph.album,
                        size: 160,
                        color: palette.primary.withOpacity(0.1),
                      ),
                    ),
                    // Mel-Spectrogram for signal verification
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 140,
                        child: NeuSpectrogram(
                          palette: palette,
                          height: 140,
                          showGrid: true, // Grid is essential for diagnostic utility
                          showLabels: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Metadata Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackTitle.toUpperCase(),
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              color: palette.text,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$artistName ${albumTitle != null ? '— $albumTitle' : ''}",
                            style: GoogleFonts.spaceMono(
                              fontSize: 13,
                              color: palette.text.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bit-Perfect/High-Res Indicator
                NeuAudioInfoBadge(
                  format: "FLAC",
                  sampleRate: 96000,
                  bitDepth: 24,
                  exclusiveMode: true,
                  palette: palette,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 3. Neobrutalist Progress Bar
            NeuProgressBar(
              value: progress,
              onChanged: onSeek,
              palette: palette,
              showLabels: true,
              leftLabel: _formatDuration(position),
              rightLabel: _formatDuration(duration),
              height: 12,
            ),

            const SizedBox(height: 40),

            // 4. Playback Controls (Comfort Mode: Oversized hit targets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Use integrated NeuIconButton which handles IconData to Ascii conversion
                NeuIconButton(
                  icon: isShuffled ? Icons.shuffle_on : Icons.shuffle,
                  onPressed: onShuffle,
                  palette: palette,
                  size: 48,
                  backgroundColor: isShuffled ? palette.accent.withOpacity(0.2) : null,
                ),
                Row(
                  children: [
                    NeuIconButton(
                      icon: Icons.skip_previous,
                      onPressed: onPrevious,
                      palette: palette,
                      size: 64,
                    ),
                    const SizedBox(width: 16),
                    NeuIconButton(
                      icon: isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: onPlayPause,
                      palette: palette,
                      size: 84, // Primary touch target
                      backgroundColor: palette.primary,
                    ),
                    const SizedBox(width: 16),
                    NeuIconButton(
                      icon: Icons.skip_next,
                      onPressed: onNext,
                      palette: palette,
                      size: 64,
                    ),
                  ],
                ),
                NeuIconButton(
                  icon: isRepeating ? Icons.repeat_on : Icons.repeat,
                  onPressed: onRepeat,
                  palette: palette,
                  size: 48,
                  backgroundColor: isRepeating ? palette.accent.withOpacity(0.2) : null,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 5. Volume Slider
            Row(
              children: [
                AsciiIcon(AsciiGlyph.volumeDown, size: 16, color: palette.text.withOpacity(0.5)),
                Expanded(
                  child: Slider(
                    value: volume,
                    onChanged: onVolumeChange,
                    activeColor: palette.secondary,
                    inactiveColor: palette.border.withOpacity(0.1),
                  ),
                ),
                AsciiIcon(AsciiGlyph.volumeUp, size: 16, color: palette.text.withOpacity(0.5)),
              ],
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}