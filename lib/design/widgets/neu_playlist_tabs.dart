import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Foobar2000-style playlist tabs manager
/// Features:
/// - Multiple playlist tabs (like browser tabs)
/// - Drag-to-reorder tabs
/// - Right-click context menu
/// - Quick add/close buttons
/// - Active playlist highlighting
/// - Overflow scrolling for many playlists
class NeuPlaylistTabs extends StatefulWidget {
  final List<PlaylistTab> playlists;
  final int activePlaylistIndex;
  final Function(int) onPlaylistSelected;
  final Function(String name) onCreatePlaylist;
  final Function(int) onClosePlaylist;
  final Function(int, int) onReorderPlaylists;
  final Function(int)? onRenamePlaylist;
  final Function(int)? onDuplicatePlaylist;
  final RatholePalette palette;

  const NeuPlaylistTabs({
    super.key,
    required this.playlists,
    required this.activePlaylistIndex,
    required this.onPlaylistSelected,
    required this.onCreatePlaylist,
    required this.onClosePlaylist,
    required this.onReorderPlaylists,
    this.onRenamePlaylist,
    this.onDuplicatePlaylist,
    required this.palette,
  });

  @override
  State<NeuPlaylistTabs> createState() => _NeuPlaylistTabsState();
}

class _NeuPlaylistTabsState extends State<NeuPlaylistTabs> {
  final ScrollController _scrollController = ScrollController();
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          // Scrollable tab area
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scrollController,
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: widget.playlists.length,
              onReorder: widget.onReorderPlaylists,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final playlist = widget.playlists[index];
                final isActive = index == widget.activePlaylistIndex;
                final isHovered = index == _hoveredIndex;

                return ReorderableDragStartListener(
                  key: ValueKey(playlist.id),
                  index: index,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onPlaylistSelected(index);
                      },
                      onSecondaryTap: () => _showContextMenu(context, index),
                      child: _buildTab(
                        playlist,
                        isActive,
                        isHovered,
                        index,
                        textTheme,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Add new playlist button
          _buildAddButton(textTheme),
        ],
      ),
    );
  }

  Widget _buildTab(
    PlaylistTab playlist,
    bool isActive,
    bool isHovered,
    int index,
    TextTheme textTheme,
  ) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 200,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? widget.palette.primary.withOpacity(0.3)
            : (isHovered ? widget.palette.surface : widget.palette.background),
        border: Border(
          right: BorderSide(color: widget.palette.border, width: 2),
          bottom: isActive
              ? BorderSide(color: widget.palette.primary, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Playlist icon
          Icon(
            playlist.isAutoPlaylist ? Icons.auto_awesome : Icons.playlist_play,
            size: 14,
            color: playlist.isAutoPlaylist
                ? widget.palette.accent
                : widget.palette.text.withOpacity(0.6),
          ),
          const SizedBox(width: 8),

          // Playlist name
          Expanded(
            child: Text(
              playlist.name,
              style: textTheme.titleSmall?.copyWith(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: widget.palette.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 4),

          // Track count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: widget.palette.border.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${playlist.trackCount}',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: widget.palette.text.withOpacity(0.6),
              ),
            ),
          ),

          // Close button (only show on hover or active, not for default playlists)
          if ((isHovered || isActive) && !playlist.isDefault) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onClosePlaylist(index);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: widget.palette.text.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton(TextTheme textTheme) {
    return GestureDetector(
      onTap: () => _showCreatePlaylistDialog(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.palette.background,
            border: Border(
              left: BorderSide(color: widget.palette.border, width: 2),
            ),
          ),
          child: Icon(
            Icons.add,
            size: 20,
            color: widget.palette.primary,
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, int index) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + box.size.height,
        position.dx + box.size.width,
        position.dy + box.size.height,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              Text('Rename', style: TextStyle(color: widget.palette.text)),
            ],
          ),
          onTap: () => widget.onRenamePlaylist?.call(index),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.copy, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              Text('Duplicate', style: TextStyle(color: widget.palette.text)),
            ],
          ),
          onTap: () => widget.onDuplicatePlaylist?.call(index),
        ),
        if (!widget.playlists[index].isDefault)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.delete, size: 16, color: widget.palette.error),
                const SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: widget.palette.error)),
              ],
            ),
            onTap: () => widget.onClosePlaylist(index),
          ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.palette.background,
            border: Border.all(color: widget.palette.border, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.palette.shadow,
                offset: const Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'NEW PLAYLIST',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: widget.palette.text,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Enter playlist name',
                  filled: true,
                  fillColor: widget.palette.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.palette.border, width: 2),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.onCreatePlaylist(value);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildDialogButton('Cancel', () => Navigator.pop(context), false, textTheme),
                  const SizedBox(width: 8),
                  _buildDialogButton(
                    'Create',
                    () {
                      if (controller.text.isNotEmpty) {
                        widget.onCreatePlaylist(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    true,
                    textTheme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String label, VoidCallback onPressed, bool isPrimary, TextTheme textTheme) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? widget.palette.primary : widget.palette.surface,
          border: Border.all(color: widget.palette.border, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: widget.palette.shadow,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 12,
            color: widget.palette.text,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Playlist tab model
class PlaylistTab {
  final String id;
  final String name;
  final int trackCount;
  final bool isDefault; // Can't be closed (e.g., "Default" playlist)
  final bool isAutoPlaylist; // Smart/auto playlist
  final DateTime? lastModified;

  const PlaylistTab({
    required this.id,
    required this.name,
    required this.trackCount,
    this.isDefault = false,
    this.isAutoPlaylist = false,
    this.lastModified,
  });

  PlaylistTab copyWith({
    String? name,
    int? trackCount,
    bool? isDefault,
    bool? isAutoPlaylist,
    DateTime? lastModified,
  }) {
    return PlaylistTab(
      id: id,
      name: name ?? this.name,
      trackCount: trackCount ?? this.trackCount,
      isDefault: isDefault ?? this.isDefault,
      isAutoPlaylist: isAutoPlaylist ?? this.isAutoPlaylist,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

/// Playlist content view (the track list for active playlist)
class NeuPlaylistContentView extends StatelessWidget {
  final PlaylistTab playlist;
  final List<Map<String, dynamic>> tracks;
  final int? currentlyPlayingIndex;
  final Function(int) onTrackTap;
  final Function(int) onTrackDoubleTap;
  final Function(int, int)? onReorderTracks;
  final Function(List<int>)? onRemoveTracks;
  final RatholePalette palette;

  const NeuPlaylistContentView({
    super.key,
    required this.playlist,
    required this.tracks,
    this.currentlyPlayingIndex,
    required this.onTrackTap,
    required this.onTrackDoubleTap,
    this.onReorderTracks,
    this.onRemoveTracks,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Playlist header
        _buildPlaylistHeader(context),

        // Track list
        Expanded(
          child: tracks.isEmpty
              ? _buildEmptyState(context)
              : ReorderableListView.builder(
                  itemCount: tracks.length,
                  onReorder: (oldIndex, newIndex) {
                    if (onReorderTracks != null) {
                      onReorderTracks!(oldIndex, newIndex);
                    }
                  },
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final isPlaying = index == currentlyPlayingIndex;

                    return _buildTrackItem(
                      context,
                      track,
                      index,
                      isPlaying,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlaylistHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(color: palette.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            playlist.isAutoPlaylist ? Icons.auto_awesome : Icons.playlist_play,
            size: 32,
            color: playlist.isAutoPlaylist ? palette.accent : palette.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${playlist.trackCount} tracks',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: palette.text.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Playlist actions
          _buildActionButton(Icons.shuffle, 'Shuffle', () {}),
          const SizedBox(width: 8),
          _buildActionButton(Icons.play_arrow, 'Play All', () {}),
          const SizedBox(width: 8),
          _buildActionButton(Icons.more_vert, 'More', () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border.all(color: palette.border, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: palette.text),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: palette.text.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tracks in this playlist',
            style: textTheme.titleMedium?.copyWith(
              color: palette.text.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag and drop files or add from library',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: palette.text.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(
    BuildContext context,
    Map<String, dynamic> track,
    int index,
    bool isPlaying,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return ReorderableDragStartListener(
      key: ValueKey(track['id'] ?? index),
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPlaying
              ? palette.primary.withOpacity(0.2)
              : palette.surface,
          border: Border.all(
            color: isPlaying ? palette.primary : palette.border,
            width: isPlaying ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: GestureDetector(
          onTap: () => onTrackTap(index),
          onDoubleTap: () => onTrackDoubleTap(index),
          child: Row(
            children: [
              // Drag handle
              Icon(
                Icons.drag_handle,
                size: 16,
                color: palette.text.withOpacity(0.3),
              ),
              const SizedBox(width: 8),

              // Track number or playing indicator
              SizedBox(
                width: 40,
                child: isPlaying
                    ? Icon(Icons.graphic_eq, color: palette.primary, size: 16)
                    : Text(
                        '${index + 1}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: palette.text.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),

              // Track info
              Expanded(
                flex: 3,
                child: Text(
                  track['title'] ?? 'Unknown',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    color: palette.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  track['artist'] ?? 'Unknown Artist',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: palette.text.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  track['album'] ?? 'Unknown Album',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: palette.text.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(
                width: 60,
                child: Text(
                  track['duration'] ?? '0:00',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: palette.text.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}