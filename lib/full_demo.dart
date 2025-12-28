import 'package:flutter/material.dart';
import 'design/theme/app_theme.dart';
import 'design/widgets/neu_adaptive_scaffold.dart';
import 'design/widgets/neu_folder_tree.dart';
import 'design/widgets/neu_data_grid.dart';
import 'design/widgets/neu_playlist.dart';
import 'design/widgets/neu_search_bar.dart';
import 'design/widgets/neu_spectrogram.dart';
import 'design/widgets/neu_progress_bar.dart';
import 'design/widgets/neu_button.dart';

void main() {
  runApp(const FullMusicPlayerDemo());
}

class FullMusicPlayerDemo extends StatefulWidget {
  const FullMusicPlayerDemo({super.key});

  @override
  State<FullMusicPlayerDemo> createState() => _FullMusicPlayerDemoState();
}

class _FullMusicPlayerDemoState extends State<FullMusicPlayerDemo> {
  RatholePalette _palette = RatholeTheme.classic;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brutalist Music Player - Full Demo',
      debugShowCheckedModeBanner: false,
      theme: RatholeTheme.buildTheme(_palette),
      home: MusicPlayerHome(
        palette: _palette,
        onPaletteChanged: (palette) => setState(() => _palette = palette),
      ),
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  final RatholePalette palette;
  final Function(RatholePalette) onPaletteChanged;

  const MusicPlayerHome({
    super.key,
    required this.palette,
    required this.onPaletteChanged,
  });

  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  int _selectedNavIndex = 0;
  ViewMode _currentViewMode = ViewMode.folders;
  final TextEditingController _searchController = TextEditingController();

  // Mock data
  final List<FolderNode> _folderTree = [
    FolderNode(
      path: '/Music/Electronic',
      name: 'Electronic',
      trackCount: 150,
      children: [
        FolderNode(
          path: '/Music/Electronic/Boards of Canada',
          name: 'Boards of Canada',
          trackCount: 45,
          children: [
            FolderNode(
              path: '/Music/Electronic/Boards of Canada/Geogaddi',
              name: 'Geogaddi',
              trackCount: 23,
              isAlbum: true,
            ),
          ],
        ),
      ],
    ),
    FolderNode(
      path: '/Music/Rock',
      name: 'Rock',
      trackCount: 280,
      children: [
        FolderNode(
          path: '/Music/Rock/Radiohead',
          name: 'Radiohead',
          trackCount: 87,
          isAlbum: false,
        ),
      ],
    ),
  ];

  final List<Map<String, dynamic>> _tracks = [
    {
      'track': 1,
      'title': 'Music Is Math',
      'artist': 'Boards of Canada',
      'album': 'Geogaddi',
      'year': 2002,
      'genre': 'IDM',
      'format': 'FLAC',
      'bitrate': '1411 kbps',
      'sampleRate': '96kHz/24-bit',
      'duration': '5:21',
      'path': '/Music/Electronic/Boards of Canada/Geogaddi/02.flac',
    },
    {
      'track': 2,
      'title': 'Gyroscope',
      'artist': 'Boards of Canada',
      'album': 'Geogaddi',
      'year': 2002,
      'genre': 'IDM',
      'format': 'FLAC',
      'bitrate': '1411 kbps',
      'sampleRate': '96kHz/24-bit',
      'duration': '3:26',
      'path': '/Music/Electronic/Boards of Canada/Geogaddi/04.flac',
    },
  ];

  final List<Playlist> _playlists = [
    Playlist(
      id: '1',
      name: 'Favorites',
      trackCount: 145,
      isDefault: true,
    ),
    Playlist(
      id: '2',
      name: 'Chill Vibes',
      trackCount: 67,
    ),
    Playlist(
      id: '3',
      name: 'High-Res Only',
      trackCount: 234,
      isSmartPlaylist: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return NeuAdaptiveScaffold(
      title: 'BRUTALIST PLAYER',
      palette: widget.palette,
      isDesktop: isDesktop,
      navItems: MusicNavItems.standard,
      selectedNavIndex: _selectedNavIndex,
      onNavSelected: (index) => setState(() => _selectedNavIndex = index),

      // Left sidebar (folder tree or playlists)
      sidebar: _selectedNavIndex == 0
          ? _buildLibraryPanel()
          : _selectedNavIndex == 1
              ? _buildPlaylistPanel()
              : null,

      // Main content area
      body: _buildMainContent(),

      // Right panel (queue or audio info)
      rightPanel: isDesktop ? _buildRightPanel() : null,
    );
  }

  Widget _buildLibraryPanel() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // View mode selector
          NeuViewModeSelector(
            currentMode: _currentViewMode,
            onModeChanged: (mode) => setState(() => _currentViewMode = mode),
            palette: widget.palette,
          ),

          const SizedBox(height: 12),

          // Folder tree
          Expanded(
            child: NeuFolderTree(
              rootNodes: _folderTree,
              onFolderSelected: (node) {
                // Handle folder selection
              },
              palette: widget.palette,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistPanel() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: NeuPlaylistSidebar(
        playlists: _playlists,
        onPlaylistSelected: (playlist) {
          // Handle playlist selection
        },
        onCreatePlaylist: () {
          // Show create playlist dialog
        },
        palette: widget.palette,
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar + theme selector
          Row(
            children: [
              Expanded(
                child: NeuSearchBar(
                  controller: _searchController,
                  palette: widget.palette,
                  hintText: 'Search library...',
                ),
              ),
              const SizedBox(width: 12),
              _buildThemeSelector(),
            ],
          ),

          const SizedBox(height: 12),

          // Track grid
          Expanded(
            child: NeuDataGrid(
              columns: MusicGridColumns.audiophile,
              rows: _tracks,
              palette: widget.palette,
              rowHeight: 28,
              onRowTap: (index) {
                // Play track
              },
              onSort: (column, ascending) {
                // Sort tracks
              },
            ),
          ),

          const SizedBox(height: 8),

          // Now playing bar
          _buildNowPlayingBar(),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Audio info
          NeuAudioInfoBadge(
            format: 'FLAC',
            sampleRate: 96000,
            bitDepth: 24,
            exclusiveMode: true,
            palette: widget.palette,
          ),

          const SizedBox(height: 12),

          // Spectrogram
          NeuSpectrogram(
            palette: widget.palette,
            height: 180,
          ),

          const SizedBox(height: 12),

          // Queue
          Expanded(
            child: NeuQueueView(
              queue: [
                QueueTrack(
                  id: '1',
                  title: 'Music Is Math',
                  artist: 'Boards of Canada',
                  duration: '5:21',
                ),
                QueueTrack(
                  id: '2',
                  title: 'Gyroscope',
                  artist: 'Boards of Canada',
                  duration: '3:26',
                ),
              ],
              currentTrackIndex: 0,
              onTrackTap: (index) {},
              onReorder: (oldIndex, newIndex) {},
              palette: widget.palette,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          NeuProgressBar(
            value: 0.35,
            onChanged: (value) {},
            palette: widget.palette,
            showLabels: true,
            leftLabel: '1:52',
            rightLabel: '5:21',
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music Is Math',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.palette.text,
                      ),
                    ),
                    Text(
                      'Boards of Canada • Geogaddi',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.palette.text.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Playback controls
              NeuIconButton(
                icon: Icons.skip_previous,
                onPressed: () {},
                palette: widget.palette,
                size: 40,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: Icons.play_arrow,
                onPressed: () {},
                palette: widget.palette,
                size: 48,
                backgroundColor: widget.palette.primary,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: Icons.skip_next,
                onPressed: () {},
                palette: widget.palette,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.palette.primary,
          border: Border.all(color: widget.palette.border, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette, size: 16, color: widget.palette.text),
            const SizedBox(width: 8),
            Text(
              'Theme',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.palette.text,
              ),
            ),
          ],
        ),
      ),
      onSelected: (name) {
        widget.onPaletteChanged(RatholeTheme.allPalettes[name]!);
      },
      itemBuilder: (context) {
        return RatholeTheme.allPalettes.keys.map((name) {
          return PopupMenuItem(
            value: name,
            child: Text(name),
          );
        }).toList();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
