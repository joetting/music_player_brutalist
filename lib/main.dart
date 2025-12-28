import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design/theme/app_theme.dart';
import 'design/widgets/neu_adaptive_scaffold.dart';
import 'design/widgets/neu_playlist_tabs.dart';
import 'design/widgets/neu_playlist_manager.dart';
import 'design/widgets/neu_folder_tree.dart';
import 'design/widgets/neu_data_grid.dart';
import 'design/widgets/neu_track_tile.dart';
import 'design/widgets/neu_button.dart';
import 'design/widgets/neu_progress_bar.dart';
import 'design/widgets/neu_mobile_player.dart';
import 'design/widgets/neu_spectrogram.dart';
import 'design/widgets/neu_search_bar.dart';
import 'design/widgets/neu_audio_info_badge.dart';
import 'design/widgets/neu_container.dart';
import 'design/widgets/neu_scrobble_dialogs.dart';
import 'design/widgets/neu_playlist.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BrutalistMusicPlayerApp());
}

class BrutalistMusicPlayerApp extends StatefulWidget {
  const BrutalistMusicPlayerApp({super.key});

  @override
  State<BrutalistMusicPlayerApp> createState() => _BrutalistMusicPlayerAppState();
}

class _BrutalistMusicPlayerAppState extends State<BrutalistMusicPlayerApp> {
  RatholePalette _palette = RatholeTheme.darkPro;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brutalist Music Player',
      debugShowCheckedModeBanner: false,
      theme: RatholeTheme.buildTheme(_palette, isDark: true),
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
  // Navigation State
  int _selectedNavIndex = 0;
  ViewMode _currentViewMode = ViewMode.folders;

  // Playlist State
  List<PlaylistTab> _playlists = [];
  List<PlaylistFolder> _folders = [];
  int _activePlaylistIndex = 0;

  // Playback State
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  int? _currentTrackIndex;
  double _progress = 0.0;
  double _volume = 0.7;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5, seconds: 21);

  // UI State
  final TextEditingController _searchController = TextEditingController();
  FolderNode? _selectedFolder;
  int? _selectedGridRow;

  // Mock Data
  late List<FolderNode> _folderTree;
  late List<Map<String, dynamic>> _tracks;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _initializePlaylists();
    _startPlaybackSimulation();
  }

  void _initializeMockData() {
    _folderTree = [
      FolderNode(
        path: '/Music/Electronic',
        name: 'Electronic',
        trackCount: 234,
        children: [
          FolderNode(
            path: '/Music/Electronic/Boards of Canada',
            name: 'Boards of Canada',
            trackCount: 87,
            children: [
              const FolderNode(
                path: '/Music/Electronic/Boards of Canada/Geogaddi',
                name: 'Geogaddi (2002)',
                trackCount: 23,
                isAlbum: true,
              ),
              const FolderNode(
                path: '/Music/Electronic/Boards of Canada/Music Has The Right',
                name: 'Music Has The Right (2005)',
                trackCount: 17,
                isAlbum: true,
              ),
            ],
          ),
          FolderNode(
            path: '/Music/Electronic/Aphex Twin',
            name: 'Aphex Twin',
            trackCount: 156,
            children: [
              const FolderNode(
                path: '/Music/Electronic/Aphex Twin/Selected Ambient Works',
                name: 'Selected Ambient Works 85-92',
                trackCount: 13,
                isAlbum: true,
              ),
            ],
          ),
        ],
      ),
      FolderNode(
        path: '/Music/Rock',
        name: 'Rock',
        trackCount: 412,
        children: [
          FolderNode(
            path: '/Music/Rock/Radiohead',
            name: 'Radiohead',
            trackCount: 143,
            children: [
              const FolderNode(
                path: '/Music/Rock/Radiohead/OK Computer',
                name: 'OK Computer (1997)',
                trackCount: 12,
                isAlbum: true,
              ),
              const FolderNode(
                path: '/Music/Rock/Radiohead/In Rainbows',
                name: 'In Rainbows (2007)',
                trackCount: 10,
                isAlbum: true,
              ),
            ],
          ),
        ],
      ),
      FolderNode(
        path: '/Music/Jazz',
        name: 'Jazz',
        trackCount: 187,
        children: [
          const FolderNode(
            path: '/Music/Jazz/Miles Davis',
            name: 'Miles Davis',
            trackCount: 78,
          ),
        ],
      ),
    ];

    _tracks = [
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
      {
        'track': 3,
        'title': 'In the Annexe',
        'artist': 'Boards of Canada',
        'album': 'Geogaddi',
        'year': 2002,
        'genre': 'IDM',
        'format': 'FLAC',
        'bitrate': '1411 kbps',
        'sampleRate': '96kHz/24-bit',
        'duration': '2:33',
        'path': '/Music/Electronic/Boards of Canada/Geogaddi/05.flac',
      },
      {
        'track': 4,
        'title': 'Julie and Candy',
        'artist': 'Boards of Canada',
        'album': 'Geogaddi',
        'year': 2002,
        'genre': 'IDM',
        'format': 'FLAC',
        'bitrate': '1411 kbps',
        'sampleRate': '96kHz/24-bit',
        'duration': '5:30',
        'path': '/Music/Electronic/Boards of Canada/Geogaddi/06.flac',
      },
      {
        'track': 5,
        'title': 'The Smallest Weird Number',
        'artist': 'Boards of Canada',
        'album': 'Geogaddi',
        'year': 2002,
        'genre': 'IDM',
        'format': 'FLAC',
        'bitrate': '1411 kbps',
        'sampleRate': '96kHz/24-bit',
        'duration': '0:42',
        'path': '/Music/Electronic/Boards of Canada/Geogaddi/07.flac',
      },
      {
        'track': 6,
        'title': '1969',
        'artist': 'Boards of Canada',
        'album': 'Geogaddi',
        'year': 2002,
        'genre': 'IDM',
        'format': 'FLAC',
        'bitrate': '1411 kbps',
        'sampleRate': '96kHz/24-bit',
        'duration': '4:19',
        'path': '/Music/Electronic/Boards of Canada/Geogaddi/08.flac',
      },
      {
        'track': 7,
        'title': 'Energy Warning',
        'artist': 'Boards of Canada',
        'album': 'Geogaddi',
        'year': 2002,
        'genre': 'IDM',
        'format': 'FLAC',
        'bitrate': '1411 kbps',
        'sampleRate': '96kHz/24-bit',
        'duration': '0:24',
        'path': '/Music/Electronic/Boards of Canada/Geogaddi/09.flac',
      },
      {
        'track': 8,
        'title': 'The Beach at Redpoint',
        'artist': 'Boards of Canada',
        'album': 'Geogaddi',
        'year': 2002,
        'genre': 'IDM',
        'format': 'FLAC',
        'bitrate': '1411 kbps',
        'sampleRate': '96kHz/24-bit',
        'duration': '3:48',
        'path': '/Music/Electronic/Boards of Canada/Geogaddi/10.flac',
      },
    ];
  }

  void _initializePlaylists() {
    _folders = [
      const PlaylistFolder(id: 'electronic', name: 'Electronic Music'),
      const PlaylistFolder(id: 'ambient', name: 'Ambient & Chill'),
      const PlaylistFolder(id: 'workout', name: 'Workout Mixes'),
    ];

    _playlists = [
      const PlaylistTab(
        id: 'default',
        name: 'Default',
        trackCount: 8,
        isDefault: true,
      ),
      const PlaylistTab(
        id: 'favorites',
        name: 'Favorites',
        trackCount: 145,
      ),
      const PlaylistTab(
        id: 'hires',
        name: 'Hi-Res Only',
        trackCount: 234,
        isAutoPlaylist: true,
      ),
      const PlaylistTab(
        id: 'recent',
        name: 'Recently Added',
        trackCount: 67,
        isAutoPlaylist: true,
      ),
      const PlaylistTab(
        id: 'chill',
        name: 'Chill Vibes',
        trackCount: 89,
      ),
      const PlaylistTab(
        id: 'dnb',
        name: 'Drum & Bass',
        trackCount: 156,
      ),
      const PlaylistTab(
        id: 'ambient',
        name: 'Ambient Sessions',
        trackCount: 78,
      ),
    ];
  }

  void _startPlaybackSimulation() {
    // Simulate playback progress
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isPlaying && mounted) {
        setState(() {
          _progress += 0.001;
          if (_progress >= 1.0) {
            _progress = 0.0;
            _skipToNext();
          }
          _position = Duration(
            milliseconds: (_progress * _duration.inMilliseconds).round(),
          );
        });
      }
      return mounted;
    });
  }

  void _playTrack(int index) {
    setState(() {
      _currentTrackIndex = index;
      _isPlaying = true;
      _progress = 0.0;
      _position = Duration.zero;
      // Set duration from track data
      final durationStr = _tracks[index]['duration'] as String;
      final parts = durationStr.split(':');
      _duration = Duration(
        minutes: int.parse(parts[0]),
        seconds: int.parse(parts[1]),
      );
    });
    HapticFeedback.mediumImpact();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    HapticFeedback.lightImpact();
  }

  void _skipToNext() {
    if (_currentTrackIndex != null && _currentTrackIndex! < _tracks.length - 1) {
      _playTrack(_currentTrackIndex! + 1);
    }
  }

  void _skipToPrevious() {
    if (_currentTrackIndex != null) {
      if (_progress > 0.1) {
        // Restart current track if more than 10% played
        setState(() {
          _progress = 0.0;
          _position = Duration.zero;
        });
      } else if (_currentTrackIndex! > 0) {
        _playTrack(_currentTrackIndex! - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  // ==================== DESKTOP LAYOUT ====================

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: widget.palette.background,
      body: Column(
        children: [
          _buildTopBar(),
          _buildPlaylistTabs(),
          Expanded(
            child: Row(
              children: [
                // Left Panel: Playlist Manager
                SizedBox(
                  width: 240,
                  child: _buildPlaylistManagerPanel(),
                ),
                // Center: Main Content
                Expanded(
                  child: _selectedNavIndex == 0
                      ? _buildLibraryView()
                      : _selectedNavIndex == 1
                          ? _buildPlaylistView()
                          : _buildAlbumsView(),
                ),
                // Right Panel: Audio Info & Queue
                SizedBox(
                  width: 300,
                  child: _buildRightPanel(),
                ),
              ],
            ),
          ),
          _buildDesktopNowPlayingBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.music_note, color: widget.palette.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            'BRUTALIST PLAYER',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: widget.palette.text,
                ),
          ),
          const Spacer(),
          _buildSettingsMenu(),
          const SizedBox(width: 12),
          _buildThemeSelector(),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.settings, color: widget.palette.text),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.music_note, size: 16, color: widget.palette.error),
              const SizedBox(width: 8),
              const Text('Last.fm Settings'),
            ],
          ),
          onTap: () => _showLastFmDialog(),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.headphones, size: 16, color: widget.palette.secondary),
              const SizedBox(width: 8),
              const Text('ListenBrainz Settings'),
            ],
          ),
          onTap: () => _showListenBrainzDialog(),
        ),
        const PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.library_music, size: 16),
              SizedBox(width: 8),
              Text('Rescan Library'),
            ],
          ),
        ),
        const PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16),
              SizedBox(width: 8),
              Text('About'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.palette.primary,
          border: Border.all(color: widget.palette.border, width: 2),
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

  Widget _buildPlaylistTabs() {
    return NeuPlaylistTabs(
      playlists: _playlists,
      activePlaylistIndex: _activePlaylistIndex,
      onPlaylistSelected: (index) {
        setState(() => _activePlaylistIndex = index);
      },
      onCreatePlaylist: (name) {
        setState(() {
          _playlists.add(PlaylistTab(
            id: DateTime.now().toString(),
            name: name,
            trackCount: 0,
          ));
          _activePlaylistIndex = _playlists.length - 1;
        });
      },
      onClosePlaylist: (index) {
        if (!_playlists[index].isDefault) {
          setState(() {
            _playlists.removeAt(index);
            if (_activePlaylistIndex >= _playlists.length) {
              _activePlaylistIndex = _playlists.length - 1;
            }
          });
        }
      },
      onReorderPlaylists: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _playlists.removeAt(oldIndex);
          _playlists.insert(newIndex, item);
        });
      },
      palette: widget.palette,
    );
  }

  Widget _buildPlaylistManagerPanel() {
    return NeuPlaylistManager(
      playlists: _playlists,
      folders: _folders,
      selectedPlaylistIndex: _activePlaylistIndex,
      onPlaylistSelected: (index) {
        setState(() => _activePlaylistIndex = index);
      },
      onCreatePlaylist: (name) {
        setState(() {
          _playlists.add(PlaylistTab(
            id: DateTime.now().toString(),
            name: name,
            trackCount: 0,
          ));
        });
      },
      onCreateFolder: (name) {
        setState(() {
          _folders.add(PlaylistFolder(
            id: DateTime.now().toString(),
            name: name,
          ));
        });
      },
      onMovePlaylist: (index, folderId) {
        // Implement folder assignment logic
      },
      onDeletePlaylist: (index) {
        if (!_playlists[index].isDefault) {
          setState(() {
            _playlists.removeAt(index);
            if (_activePlaylistIndex >= _playlists.length) {
              _activePlaylistIndex = _playlists.length - 1;
            }
          });
        }
      },
      onDeleteFolder: (folderId) {
        setState(() {
          _folders.removeWhere((f) => f.id == folderId);
        });
      },
      palette: widget.palette,
    );
  }

  Widget _buildLibraryView() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Folder Tree
          SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NeuViewModeSelector(
                  currentMode: _currentViewMode,
                  onModeChanged: (mode) {
                    setState(() => _currentViewMode = mode);
                  },
                  palette: widget.palette,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: NeuFolderTree(
                    rootNodes: _folderTree,
                    selectedNode: _selectedFolder,
                    onFolderSelected: (node) {
                      setState(() => _selectedFolder = node);
                    },
                    palette: widget.palette,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Track Grid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NeuSearchBar(
                  controller: _searchController,
                  palette: widget.palette,
                  hintText: 'Search library...',
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: NeuDataGrid(
                    columns: MusicGridColumns.audiophile,
                    rows: _tracks,
                    selectedRowIndex: _selectedGridRow,
                    palette: widget.palette,
                    onRowTap: (index) {
                      setState(() => _selectedGridRow = index);
                    },
                    onRowDoubleTap: (index) {
                      _playTrack(index);
                    },
                    onSort: (column, ascending) {
                      // Implement sorting
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistView() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Playlist Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: widget.palette.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _playlists[_activePlaylistIndex].isAutoPlaylist
                      ? Icons.auto_awesome
                      : Icons.playlist_play,
                  size: 32,
                  color: _playlists[_activePlaylistIndex].isAutoPlaylist
                      ? widget.palette.accent
                      : widget.palette.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _playlists[_activePlaylistIndex].name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              color: widget.palette.text,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_tracks.length} tracks',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: widget.palette.text.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                NeuIconButton(
                  icon: Icons.shuffle,
                  onPressed: () {
                    setState(() => _isShuffled = !_isShuffled);
                    HapticFeedback.lightImpact();
                  },
                  palette: widget.palette,
                  backgroundColor: _isShuffled
                      ? widget.palette.accent.withOpacity(0.3)
                      : null,
                  size: 40,
                ),
                const SizedBox(width: 8),
                NeuIconButton(
                  icon: Icons.play_arrow,
                  onPressed: () {
                    if (_tracks.isNotEmpty) {
                      _playTrack(0);
                    }
                  },
                  palette: widget.palette,
                  backgroundColor: widget.palette.primary,
                  size: 40,
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: NeuSearchBar(
              controller: _searchController,
              palette: widget.palette,
              hintText: 'Search tracks...',
            ),
          ),
          // Track List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                return NeuTrackTile(
                  trackNumber: track['track'] as int,
                  title: track['title'] as String,
                  artist: track['artist'] as String,
                  duration: _parseDuration(track['duration'] as String),
                  sampleRate: 96000,
                  bitDepth: 24,
                  format: track['format'] as String,
                  isPlaying: _currentTrackIndex == index && _isPlaying,
                  onTap: () => _playTrack(index),
                  onQueue: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to queue: ${track['title']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  palette: widget.palette,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsView() {
    return Center(
      child: Text(
        'Albums View - Coming Soon',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: widget.palette.text.withOpacity(0.5),
            ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Audio Info Badge
          if (_currentTrackIndex != null)
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
            height: 160,
            showGrid: true,
            showLabels: true,
          ),
          const SizedBox(height: 12),
          // Queue
          Expanded(
            child: NeuQueueView(
              queue: _tracks
                  .asMap()
                  .entries
                  .map((e) => QueueTrack(
                        id: e.key.toString(),
                        title: e.value['title'] as String,
                        artist: e.value['artist'] as String,
                        duration: e.value['duration'] as String,
                      ))
                  .toList(),
              currentTrackIndex: _currentTrackIndex,
              onTrackTap: (index) => _playTrack(index),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _tracks.removeAt(oldIndex);
                  _tracks.insert(newIndex, item);
                });
              },
              palette: widget.palette,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNowPlayingBar() {
    if (_currentTrackIndex == null) {
      return const SizedBox.shrink();
    }

    final track = _tracks[_currentTrackIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          top: BorderSide(color: widget.palette.border, width: 3),
        ),
      ),
      child: Column(
        children: [
          NeuProgressBar(
            value: _progress,
            onChanged: (value) {
              setState(() {
                _progress = value;
                _position = Duration(
                  milliseconds: (value * _duration.inMilliseconds).round(),
                );
              });
            },
            palette: widget.palette,
            showLabels: true,
            leftLabel: _formatDuration(_position),
            rightLabel: _formatDuration(_duration),
            height: 12,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Album Art
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.palette.primary.withOpacity(0.2),
                  border: Border.all(color: widget.palette.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.album,
                  size: 32,
                  color: widget.palette.primary,
                ),
              ),
              const SizedBox(width: 16),
              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: widget.palette.text,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${track['artist']} • ${track['album']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: widget.palette.text.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              // Playback Controls
              NeuIconButton(
                icon: _isShuffled ? Icons.shuffle_on : Icons.shuffle,
                onPressed: () {
                  setState(() => _isShuffled = !_isShuffled);
                  HapticFeedback.lightImpact();
                },
                palette: widget.palette,
                backgroundColor: _isShuffled
                    ? widget.palette.accent.withOpacity(0.2)
                    : null,
                size: 40,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: Icons.skip_previous,
                onPressed: _skipToPrevious,
                palette: widget.palette,
                size: 40,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                onPressed: _togglePlayPause,
                palette: widget.palette,
                backgroundColor: widget.palette.primary,
                size: 48,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: Icons.skip_next,
                onPressed: _skipToNext,
                palette: widget.palette,
                size: 40,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: _isRepeating ? Icons.repeat_on : Icons.repeat,
                onPressed: () {
                  setState(() => _isRepeating = !_isRepeating);
                  HapticFeedback.lightImpact();
                },
                palette: widget.palette,
                backgroundColor: _isRepeating
                    ? widget.palette.accent.withOpacity(0.2)
                    : null,
                size: 40,
              ),
              const SizedBox(width: 16),
              // Volume
              Icon(Icons.volume_up,
                  size: 20, color: widget.palette.text.withOpacity(0.6)),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Slider(
                  value: _volume,
                  onChanged: (value) => setState(() => _volume = value),
                  activeColor: widget.palette.secondary,
                  inactiveColor: widget.palette.border.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: widget.palette.background,
      appBar: AppBar(
        title: Text(
          'BRUTALIST PLAYER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: widget.palette.text,
              ),
        ),
        backgroundColor: widget.palette.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: widget.palette.text),
            onPressed: () {},
          ),
          _buildThemeSelector(),
        ],
      ),
      drawer: Drawer(
        child: NeuPlaylistManager(
          playlists: _playlists,
          folders: _folders,
          selectedPlaylistIndex: _activePlaylistIndex,
          onPlaylistSelected: (index) {
            setState(() => _activePlaylistIndex = index);
            Navigator.pop(context);
          },
          onCreatePlaylist: (name) {
            setState(() {
              _playlists.add(PlaylistTab(
                id: DateTime.now().toString(),
                name: name,
                trackCount: 0,
              ));
            });
          },
          onCreateFolder: (name) {
            setState(() {
              _folders.add(PlaylistFolder(
                id: DateTime.now().toString(),
                name: name,
              ));
            });
          },
          onMovePlaylist: (index, folderId) {},
          onDeletePlaylist: (index) {
            if (!_playlists[index].isDefault) {
              setState(() {
                _playlists.removeAt(index);
              });
            }
          },
          onDeleteFolder: (folderId) {
            setState(() {
              _folders.removeWhere((f) => f.id == folderId);
            });
          },
          palette: widget.palette,
        ),
      ),
      body: Column(
        children: [
          // Current Playlist Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.palette.surface,
              border: Border(
                bottom: BorderSide(color: widget.palette.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _playlists[_activePlaylistIndex].isAutoPlaylist
                      ? Icons.auto_awesome
                      : Icons.playlist_play,
                  color: widget.palette.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _playlists[_activePlaylistIndex].name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          color: widget.palette.text,
                        ),
                  ),
                ),
                Text(
                  '${_tracks.length} tracks',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: widget.palette.text.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          // Track List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                return NeuTrackTile(
                  trackNumber: track['track'] as int,
                  title: track['title'] as String,
                  artist: track['artist'] as String,
                  duration: _parseDuration(track['duration'] as String),
                  sampleRate: 96000,
                  bitDepth: 24,
                  format: track['format'] as String,
                  isPlaying: _currentTrackIndex == index && _isPlaying,
                  onTap: () => _playTrack(index),
                  onQueue: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to queue: ${track['title']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  palette: widget.palette,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _currentTrackIndex != null
          ? NeuMobileMiniPlayer(
              trackTitle: _tracks[_currentTrackIndex!]['title'] as String,
              artistName: _tracks[_currentTrackIndex!]['artist'] as String,
              isPlaying: _isPlaying,
              progress: _progress,
              onTap: () => _showMobileExpandedPlayer(),
              onPlayPause: _togglePlayPause,
              onNext: _skipToNext,
              palette: widget.palette,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showMobileExpandedPlayer() {
    if (_currentTrackIndex == null) return;

    final track = _tracks[_currentTrackIndex!];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NeuMobileExpandedPlayer(
          trackTitle: track['title'] as String,
          artistName: track['artist'] as String,
          albumTitle: track['album'] as String,
          isPlaying: _isPlaying,
          isShuffled: _isShuffled,
          isRepeating: _isRepeating,
          progress: _progress,
          position: _position,
          duration: _duration,
          volume: _volume,
          onClose: () => Navigator.pop(context),
          onPlayPause: _togglePlayPause,
          onNext: _skipToNext,
          onPrevious: _skipToPrevious,
          onShuffle: () {
            setState(() => _isShuffled = !_isShuffled);
          },
          onRepeat: () {
            setState(() => _isRepeating = !_isRepeating);
          },
          onSeek: (value) {
            setState(() {
              _progress = value;
              _position = Duration(
                milliseconds: (value * _duration.inMilliseconds).round(),
              );
            });
          },
          onVolumeChange: (value) {
            setState(() => _volume = value);
          },
          palette: widget.palette,
        ),
      ),
    );
  }

  // ==================== DIALOGS ====================

  void _showLastFmDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => LastFmScrobbleDialog(
          palette: widget.palette,
          isEnabled: false,
          onSave: (enabled, username, password) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  enabled
                      ? 'Last.fm scrobbling enabled for $username'
                      : 'Last.fm scrobbling disabled',
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _showListenBrainzDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => ListenBrainzScrobbleDialog(
          palette: widget.palette,
          isEnabled: false,
          onSave: (enabled, token) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  enabled
                      ? 'ListenBrainz scrobbling enabled'
                      : 'ListenBrainz scrobbling disabled',
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ==================== UTILITIES ====================

  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    return Duration(
      minutes: int.parse(parts[0]),
      seconds: int.parse(parts[1]),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ==================== MOBILE MINI PLAYER ====================

class NeuMobileMiniPlayer extends StatelessWidget {
  final String trackTitle;
  final String artistName;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final RatholePalette palette;

  const NeuMobileMiniPlayer({
    super.key,
    required this.trackTitle,
    required this.artistName,
    required this.isPlaying,
    required this.progress,
    required this.onTap,
    required this.onPlayPause,
    required this.onNext,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Album Art
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: palette.primary.withOpacity(0.2),
                    border: Border.all(color: palette.border, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.album,
                    size: 28,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(width: 12),
                // Track Info
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
                      const SizedBox(height: 2),
                      Text(
                        artistName,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.text.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Controls
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: palette.text,
                  ),
                  onPressed: onPlayPause,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: palette.text),
                  onPressed: onNext,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: palette.background,
                border: Border.all(color: palette.border, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}