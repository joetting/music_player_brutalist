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
    final qualityColor = widget.sampleRate != null
        ? AudioQualityColors.forSampleRate(widget.sampleRate!)
        : widget.palette.secondary;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isPlaying
                ? widget.palette.primary.withOpacity(0.2)
                : widget.palette.surface,
            border: Border.all(
              color: widget.isPlaying ? widget.palette.primary : widget.palette.border,
              width: widget.isPlaying ? 3 : (_isHovered ? 3 : 2),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.isPlaying
                ? [
                    BoxShadow(
                      color: widget.palette.shadow,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ]
                : _isHovered
                    ? [
                        BoxShadow(
                          color: widget.palette.shadow,
                          offset: const Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
          ),
          transform: Matrix4.translationValues(
            _isHovered && !widget.isPlaying ? -2 : 0,
            _isHovered && !widget.isPlaying ? -2 : 0,
            0,
          ),
          child: Row(
            children: [
              // Track number or playing indicator
              SizedBox(
                width: 40,
                child: widget.isPlaying
                    ? Icon(
                        Icons.graphic_eq,
                        color: widget.palette.primary,
                        size: 24,
                      )
                    : Text(
                        widget.trackNumber?.toString() ?? '—',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.palette.text.withOpacity(0.5),
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
                      widget.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: widget.palette.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.artist,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: widget.palette.text.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Quality badge
              if (widget.sampleRate != null && widget.bitDepth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: qualityColor.withOpacity(0.3),
                    border: Border.all(color: widget.palette.border, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.sampleRate! ~/ 1000}k/${widget.bitDepth}b',
                    style: textTheme.labelSmall?.copyWith(
                      color: widget.palette.text,
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // Duration
              Text(
                _formatDuration(widget.duration),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: widget.palette.text.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    IconData icon,
    Color color,
    Alignment alignment,
    String label,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.palette.border, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: widget.palette.text),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontSize: 14,
              color: widget.palette.text,
            ),
          ),
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