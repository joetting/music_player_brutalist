import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'neu_playlist_tabs.dart';

/// Foobar2000-style playlist manager sidebar
/// Shows all playlists in a tree/list view for quick navigation
/// when you have dozens or hundreds of playlists
class NeuPlaylistManager extends StatefulWidget {
  final List<PlaylistTab> playlists;
  final List<PlaylistFolder> folders;
  final int? selectedPlaylistIndex;
  final Function(int) onPlaylistSelected;
  final Function(String) onCreatePlaylist;
  final Function(String) onCreateFolder;
  final Function(int, String?) onMovePlaylist; // index, folderID
  final Function(int) onDeletePlaylist;
  final Function(String) onDeleteFolder;
  final RatholePalette palette;

  const NeuPlaylistManager({
    super.key,
    required this.playlists,
    required this.folders,
    this.selectedPlaylistIndex,
    required this.onPlaylistSelected,
    required this.onCreatePlaylist,
    required this.onCreateFolder,
    required this.onMovePlaylist,
    required this.onDeletePlaylist,
    required this.onDeleteFolder,
    required this.palette,
  });

  @override
  State<NeuPlaylistManager> createState() => _NeuPlaylistManagerState();
}

class _NeuPlaylistManagerState extends State<NeuPlaylistManager> {
  final Set<String> _expandedFolders = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.palette.background,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(textTheme),

          // Search bar
          _buildSearchBar(textTheme),

          // Playlist tree
          Expanded(
            child: _buildPlaylistTree(textTheme),
          ),

          // Stats footer
          _buildStatsFooter(textTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_special, size: 18, color: widget.palette.primary),
          const SizedBox(width: 8),
          Text(
            'PLAYLISTS',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 14,
              letterSpacing: 1.2,
              color: widget.palette.text,
            ),
          ),
          const Spacer(),
          PopupMenuButton(
            icon: Icon(Icons.add, size: 18, color: widget.palette.primary),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.playlist_add, size: 16, color: widget.palette.text),
                    const SizedBox(width: 8),
                    Text('New Playlist'),
                  ],
                ),
                onTap: () => _showCreatePlaylistDialog(),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder, size: 16, color: widget.palette.text),
                    const SizedBox(width: 8),
                    Text('New Folder'),
                  ],
                ),
                onTap: () => _showCreateFolderDialog(),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: widget.palette.accent),
                    const SizedBox(width: 8),
                    Text('New Auto Playlist'),
                  ],
                ),
                onTap: () {
                  // Show auto playlist builder
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: widget.palette.surface,
          border: Border.all(color: widget.palette.border, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 16, color: widget.palette.text.withOpacity(0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Filter playlists...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: widget.palette.text.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Icon(Icons.close, size: 16, color: widget.palette.text.withOpacity(0.5)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTree(TextTheme textTheme) {
    final filteredPlaylists = _searchQuery.isEmpty
        ? widget.playlists
        : widget.playlists
            .where((p) => p.name.toLowerCase().contains(_searchQuery))
            .toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Uncategorized playlists
        ...filteredPlaylists
            .asMap()
            .entries
            .where((e) => _getPlaylistFolder(e.value) == null)
            .map((e) => _buildPlaylistItem(e.value, e.key, textTheme)),

        // Folders with playlists
        ...widget.folders.map((folder) => _buildFolderItem(folder, textTheme)),
      ],
    );
  }

  Widget _buildPlaylistItem(PlaylistTab playlist, int index, TextTheme textTheme) {
    final isSelected = index == widget.selectedPlaylistIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onPlaylistSelected(index);
          },
          onSecondaryTap: () => _showPlaylistContextMenu(context, index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.palette.primary.withOpacity(0.2)
                  : null,
              border: isSelected
                  ? Border.all(color: widget.palette.primary, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  playlist.isAutoPlaylist
                      ? Icons.auto_awesome
                      : Icons.playlist_play,
                  size: 14,
                  color: playlist.isAutoPlaylist
                      ? widget.palette.accent
                      : widget.palette.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    playlist.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.palette.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.palette.border.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${playlist.trackCount}',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: widget.palette.text.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderItem(PlaylistFolder folder, TextTheme textTheme) {
    final isExpanded = _expandedFolders.contains(folder.id);
    final playlistsInFolder = widget.playlists
        .asMap()
        .entries
        .where((e) => _getPlaylistFolder(e.value) == folder.id)
        .toList();

    if (_searchQuery.isNotEmpty && playlistsInFolder.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Folder header
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedFolders.remove(folder.id);
                  } else {
                    _expandedFolders.add(folder.id);
                  }
                });
              },
              onSecondaryTap: () => _showFolderContextMenu(context, folder),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.palette.surface.withOpacity(0.5),
                  border: Border.all(
                    color: widget.palette.border.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 16,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.folder_open : Icons.folder,
                      size: 14,
                      color: widget.palette.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        folder.name,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.palette.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${playlistsInFolder.length}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: widget.palette.text.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Playlists in folder
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: playlistsInFolder
                  .map((e) => _buildPlaylistItem(e.value, e.key, textTheme))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsFooter(TextTheme textTheme) {
    final totalTracks = widget.playlists.fold<int>(
      0,
      (sum, playlist) => sum + playlist.trackCount,
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          top: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 12, color: widget.palette.text.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(
            '${widget.playlists.length} playlists • $totalTracks tracks',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: widget.palette.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String? _getPlaylistFolder(PlaylistTab playlist) {
    // In a real implementation, playlists would have a folderID property
    // For now, return null (uncategorized)
    return null;
  }

  void _showPlaylistContextMenu(BuildContext context, int index) {
    final playlist = widget.playlists[index];

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.play_arrow, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              const Text('Play'),
            ],
          ),
          onTap: () => widget.onPlaylistSelected(index),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              const Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.copy, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              const Text('Duplicate'),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.folder, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              const Text('Move to Folder'),
            ],
          ),
        ),
        if (!playlist.isDefault)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.delete, size: 16, color: widget.palette.error),
                const SizedBox(width: 8),
                const Text('Delete'),
              ],
            ),
            onTap: () => widget.onDeletePlaylist(index),
          ),
      ],
    );
  }

  void _showFolderContextMenu(BuildContext context, PlaylistFolder folder) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: widget.palette.text),
              const SizedBox(width: 8),
              const Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: widget.palette.error),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
          onTap: () => widget.onDeleteFolder(folder.id),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog() {
    Future.delayed(Duration.zero, () {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (_) => _buildCreateDialog(
          'New Playlist',
          controller,
          () => widget.onCreatePlaylist(controller.text),
        ),
      );
    });
  }

  void _showCreateFolderDialog() {
    Future.delayed(Duration.zero, () {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (_) => _buildCreateDialog(
          'New Folder',
          controller,
          () => widget.onCreateFolder(controller.text),
        ),
      );
    });
  }

  Widget _buildCreateDialog(String title, TextEditingController controller, VoidCallback onCreate) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.palette.background,
          border: Border.all(color: widget.palette.border, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: widget.palette.shadow,
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title.toUpperCase(),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: widget.palette.text,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Enter name',
                filled: true,
                fillColor: widget.palette.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: widget.palette.border, width: 2),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  onCreate();
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onCreate();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Playlist folder model for organizing playlists
class PlaylistFolder {
  final String id;
  final String name;
  final String? parentFolderId;

  const PlaylistFolder({
    required this.id,
    required this.name,
    this.parentFolderId,
  });
}