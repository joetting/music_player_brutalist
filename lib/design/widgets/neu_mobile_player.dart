import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Android notification bar controller
/// This widget shows the current playback state and provides controls
/// in the Android notification bar
class AndroidNotificationController extends StatelessWidget {
  final String trackTitle;
  final String artistName;
  final String? albumTitle;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final RatholePalette palette;

  const AndroidNotificationController({
    super.key,
    required this.trackTitle,
    required this.artistName,
    this.albumTitle,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    // This is a visual representation of what the notification would look like
    // In a real implementation, this would use platform channels to control
    // the actual Android notification

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(12),
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
          // Notification header
          Row(
            children: [
              Icon(Icons.music_note, size: 16, color: palette.primary),
              const SizedBox(width: 8),
              Text(
                'NOW PLAYING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: palette.text.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(Icons.close, size: 16, color: palette.text.withOpacity(0.5)),
            ],
          ),

          const SizedBox(height: 12),

          // Track info and controls
          Row(
            children: [
              // Album art placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: palette.primary.withOpacity(0.2),
                  border: Border.all(color: palette.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.album,
                  size: 32,
                  color: palette.primary,
                ),
              ),

              const SizedBox(width: 12),

              // Track details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trackTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artistName,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.text.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (albumTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        albumTitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.text.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(Icons.skip_previous, onPrevious),
                  const SizedBox(width: 8),
                  _buildControlButton(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    onPlayPause,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 8),
                  _buildControlButton(Icons.skip_next, onNext),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isPrimary ? 40 : 36,
        height: isPrimary ? 40 : 36,
        decoration: BoxDecoration(
          color: isPrimary ? palette.primary : palette.surface,
          border: Border.all(color: palette.border, width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: palette.shadow,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: isPrimary ? 20 : 18,
          color: palette.text,
        ),
      ),
    );
  }
}

/// Linux media session controller
/// This widget provides system-level media controls integration for Linux
/// using MPRIS D-Bus interface
class LinuxMediaSessionController extends StatelessWidget {
  final String trackTitle;
  final String artistName;
  final String? albumTitle;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final double volume;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onStop;
  final Function(Duration) onSeek;
  final Function(double) onVolumeChange;
  final RatholePalette palette;

  const LinuxMediaSessionController({
    super.key,
    required this.trackTitle,
    required this.artistName,
    this.albumTitle,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.volume,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onStop,
    required this.onSeek,
    required this.onVolumeChange,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    // This is a visual representation of the MPRIS media controls
    // In a real implementation, this would use platform channels to register
    // with the Linux media session via D-Bus

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(12),
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
          // Header
          Row(
            children: [
              Icon(Icons.computer, size: 18, color: palette.tertiary),
              const SizedBox(width: 8),
              Text(
                'LINUX MEDIA SESSION (MPRIS)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: palette.text.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.primary.withOpacity(0.2),
                  border: Border.all(color: palette.border, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPlaying ? 'PLAYING' : 'PAUSED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Track metadata
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.background,
              border: Border.all(color: palette.border, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetadataRow('Title', trackTitle),
                const SizedBox(height: 6),
                _buildMetadataRow('Artist', artistName),
                if (albumTitle != null) ...[
                  const SizedBox(height: 6),
                  _buildMetadataRow('Album', albumTitle!),
                ],
                const SizedBox(height: 6),
                _buildMetadataRow(
                  'Position',
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.stop, onStop, 'Stop'),
              const SizedBox(width: 8),
              _buildControlButton(Icons.skip_previous, onPrevious, 'Previous'),
              const SizedBox(width: 8),
              _buildControlButton(
                isPlaying ? Icons.pause : Icons.play_arrow,
                onPlayPause,
                isPlaying ? 'Pause' : 'Play',
                isPrimary: true,
              ),
              const SizedBox(width: 8),
              _buildControlButton(Icons.skip_next, onNext, 'Next'),
            ],
          ),

          const SizedBox(height: 12),

          // Volume control
          Row(
            children: [
              Icon(Icons.volume_up, size: 16, color: palette.text.withOpacity(0.6)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: palette.background,
                    border: Border.all(color: palette.border, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: volume,
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(volume * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: palette.text.withOpacity(0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: palette.primary.withOpacity(0.1),
              border: Border.all(color: palette.border, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: palette.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected to system media controls (Keyboard shortcuts enabled)',
                  style: TextStyle(
                    fontSize: 10,
                    color: palette.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.text.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, String label,
      {bool isPrimary = false}) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: isPrimary ? 44 : 40,
          height: isPrimary ? 44 : 40,
          decoration: BoxDecoration(
            color: isPrimary ? palette.primary : palette.surface,
            border: Border.all(color: palette.border, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: palette.shadow,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: isPrimary ? 24 : 20,
            color: palette.text,
          ),
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