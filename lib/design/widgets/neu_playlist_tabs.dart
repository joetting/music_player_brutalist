import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Foobar2000-style playlist tabs manager with ASCII icons
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
          // Scrollable tab area - FIXED: Use ListView instead of ReorderableListView
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.playlists.length,
              itemBuilder: (context, index) {
                final playlist = widget.playlists[index];
                final isActive = index == widget.activePlaylistIndex;
                final isHovered = index == _hoveredIndex;

                return MouseRegion(
                  onEnter: (_) {
                    if (mounted) setState(() => _hoveredIndex = index);
                  },
                  onExit: (_) {
                    if (mounted) setState(() => _hoveredIndex = null);
                  },
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onPlaylistSelected(index);
                    },
                    onSecondaryTapUp: (details) {
                      _showContextMenu(context, index, details.globalPosition);
                    },
                    child: _buildTab(
                      playlist,
                      isActive,
                      isHovered,
                      index,
                    ),
                  ),
                );
              },
            ),
          ),

          // Add new playlist button
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildTab(
    PlaylistTab playlist,
    bool isActive,
    bool isHovered,
    int index,
  ) {
    final textTheme = Theme.of(context).textTheme;

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
          // Playlist icon (ASCII)
          Text(
            playlist.isAutoPlaylist ? '✦' : '≡',
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: playlist.isAutoPlaylist
                  ? widget.palette.accent
                  : widget.palette.text.withOpacity(0.6),
              height: 1.0,
            ),
          ),
          const SizedBox(width: 8),

          // Playlist name
          Flexible(
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

          // Close button (ASCII × instead of Icon)
          if ((isHovered || isActive) && !playlist.isDefault) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onClosePlaylist(index);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    '×',
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.text.withOpacity(0.5),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton() {
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
          child: Center(
            child: Text(
              '+',
              style: GoogleFonts.spaceMono(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: widget.palette.primary,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, int index, Offset globalPosition) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Text(
                '[✎]',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text('Rename', style: TextStyle(color: widget.palette.text)),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              widget.onRenamePlaylist?.call(index);
            });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Text(
                '[⊕]',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text('Duplicate', style: TextStyle(color: widget.palette.text)),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              widget.onDuplicatePlaylist?.call(index);
            });
          },
        ),
        if (!widget.playlists[index].isDefault)
          PopupMenuItem(
            child: Row(
              children: [
                Text(
                  '[⌦]',
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: widget.palette.error,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: widget.palette.error)),
              ],
            ),
            onTap: () {
              Future.delayed(Duration.zero, () {
                widget.onClosePlaylist(index);
              });
            },
          ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final textTheme = Theme.of(dialogContext).textTheme;

        return Dialog(
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
                      Navigator.pop(dialogContext);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildDialogButton(
                      'Cancel',
                      () => Navigator.pop(dialogContext),
                      false,
                      textTheme,
                    ),
                    const SizedBox(width: 8),
                    _buildDialogButton(
                      'Create',
                      () {
                        if (controller.text.isNotEmpty) {
                          widget.onCreatePlaylist(controller.text);
                          Navigator.pop(dialogContext);
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
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  Widget _buildDialogButton(
    String label,
    VoidCallback onPressed,
    bool isPrimary,
    TextTheme textTheme,
  ) {
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
  final bool isDefault;
  final bool isAutoPlaylist;
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