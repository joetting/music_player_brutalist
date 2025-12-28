import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Custom Neubrutalist Track Tile
/// Features:
/// - Shows playing state with animated icon
/// - Quality badges for audio specs
/// - Bold borders when active
/// - Hard shadows for playing tracks
/// - Swipe gestures on mobile
/// - Hover states on desktop
class NeuTrackTile extends StatefulWidget {
  final int? trackNumber;
  final String title;
  final String artist;
  final Duration duration;
  final int? sampleRate;
  final int? bitDepth;
  final String? format;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onQueue;
  final VoidCallback? onDelete;
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
    this.onQueue,
    this.onDelete,
    required this.palette,
  });

  @override
  State<NeuTrackTile> createState() => _NeuTrackTileState();
}

class _NeuTrackTileState extends State<NeuTrackTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final content = _buildTileContent(context);
    final textTheme = Theme.of(context).textTheme;

    // If on mobile, add swipe gestures
    if (MediaQuery.of(context).size.width <= 800) {
      return Dismissible(
        key: Key(widget.title + widget.artist),
        direction: DismissDirection.horizontal,
        background: _buildSwipeBackground(
          Icons.queue_music,
          widget.palette.primary,
          Alignment.centerLeft,
          'Queue',
          textTheme,
        ),
        secondaryBackground: _buildSwipeBackground(
          Icons.delete_outline,
          widget.palette.error,
          Alignment.centerRight,
          'Delete',
          textTheme,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            widget.onQueue?.call();
          } else {
            widget.onDelete?.call();
          }
          return false; // Don't actually dismiss
        },
        child: content,
      );
    }
    return content;
  }

  Widget _buildTileContent(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width <= 800;
  // Increase height to 72dp for Android "Comfort Mode" 
  final double tileHeight = isMobile ? 72.0 : 48.0; 
  
  return MouseRegion(
    // ... existing hover logic ...
    child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Essential for Android tactile feedback
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isMobile ? 16 : 12), // Larger padding for touch 
        height: tileHeight,
        decoration: BoxDecoration(
          color: widget.isPlaying
              ? widget.palette.primary.withValues(alpha: 0.2)
              : widget.palette.surface,
          border: Border.all(
            color: widget.isPlaying ? widget.palette.primary : widget.palette.border,
            width: widget.isPlaying ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (widget.isPlaying || _isHovered)
              BoxShadow(
                color: widget.palette.shadow,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
          ],
        ),
        child: Row(
          children: [
            // Track thumbnails or large icons for touch 
            Container(
              width: isMobile ? 40 : 32,
              height: isMobile ? 40 : 32,
              decoration: BoxDecoration(
                color: widget.palette.background,
                border: Border.all(color: widget.palette.border, width: 2),
              ),
              child: Icon(
                widget.isPlaying ? Icons.graphic_eq : Icons.music_note,
                size: 20,
                color: widget.palette.primary,
              ),
            ),
            const SizedBox(width: 12),
            // ... existing metadata logic ...
          ],
        ),
      ),
    ),
  );
}

// Updated swipe backgrounds with stark colors 
Widget _buildSwipeBackground(
  IconData icon,
  Color color, // Pass palette.error (Red) or Colors.green (Green)
  Alignment alignment,
  String label,
  TextTheme textTheme,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    alignment: alignment,
    decoration: BoxDecoration(
      color: color, // Stark red/green backgrounds 
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black, width: 3),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (alignment == Alignment.centerLeft) ...[
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
        ],
        Text(
          label.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (alignment == Alignment.centerRight) ...[
          const SizedBox(width: 12),
          Icon(icon, color: Colors.white),
        ],
      ],
    ),
  );
}

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}