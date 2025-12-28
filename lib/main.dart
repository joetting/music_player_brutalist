import 'package:flutter/material.dart';
import 'design/theme/app_theme.dart';
import 'design/widgets/neu_adaptive_scaffold.dart';
import 'design/widgets/neu_playlist_tabs.dart';
import 'design/widgets/neu_playlist_manager.dart';
import 'design/widgets/neu_track_tile.dart';
import 'design/widgets/neu_button.dart';
import 'design/widgets/neu_progress_bar.dart';
import 'design/widgets/neu_mobile_player.dart';
import 'design/widgets/neu_platform_controls.dart';
import 'design/widgets/neu_scrobble_dialogs.dart';
import 'design/widgets/neu_spectrogram.dart';
import 'design/widgets/neu_search_bar.dart';

void main() {
  runApp(const CompleteMusicPlayerDemo());
}

class CompleteMusicPlayerDemo extends StatefulWidget {
  const CompleteMusicPlayerDemo({super.key});

  @override
  State<CompleteMusicPlayerDemo> createState() => _CompleteMusicPlayerDemoState();
}

class _CompleteMusicPlayerDemoState extends State<CompleteMusicPlayerDemo> {
  RatholePalette _palette = RatholeTheme.darkPro;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brutalist Music Player - Complete Demo',
      debugShowCheckedModeBanner: false,
      theme: RatholeTheme.buildTheme(_palette, isDark: true),
      home: CompleteMusicPlayer(
        palette: _palette,
        onPaletteChanged: (palette) => setState(() => _palette = palette),
      ),
    );
  }
}

class CompleteMusicPlayer extends StatefulWidget {
  final RatholePalette palette;
  final Function(RatholePalette) onPaletteChanged;

  const CompleteMusicPlayer({
    super.key,
    required this.palette,
    required this.onPaletteChanged,
  });

  @override
  State<CompleteMusicPlayer> createState() => _CompleteMusicPlayerState();
}

class _CompleteMusicPlayerState extends State<CompleteMusicPlayer> {
  // Playlist state
  List<PlaylistTab> _playlists = [];
  List<PlaylistFolder> _folders = [];
  int _activePlaylistIndex = 0;

  // Playback state
  bool _isPlaying = false;
  int? _currentTrackIndex;
  double _progress = 0.35;
  double _volume = 0.7;

  // UI state
  final TextEditingController _searchController = TextEditingController();
  bool _showMobilePlayer = false;

  @override
  void initState() {
    super.initState();
    _initializePlaylists();
  }

  void _initializePlaylists() {
    // Create folders
    _folders = [
      const PlaylistFolder(id: 'electronic', name: 'Electronic'),
      const PlaylistFolder(id: 'rock', name: 'Rock'),
      const PlaylistFolder(id: 'classical', name: 'Classical'),
    ];

    // Create playlists
    _playlists = [
      const PlaylistTab(
        id: 'default',
        name: 'Default',
        trackCount: 45,
        isDefault: true,
      ),
      const PlaylistTab(
        id: 'favorites',
        name: 'Favorites',
        trackCount: 67,
      ),
      const PlaylistTab(
        id: 'hires',
        name: 'Hi-Res Only',
        trackCount: 123,
        isAutoPlaylist: true,
      ),
      const PlaylistTab(
        id: 'recent',
        name: 'Recently Added',
        trackCount: 34,
        isAutoPlaylist: true,
      ),
      const PlaylistTab(
        id: 'chill',
        name: 'Chill Vibes',
        trackCount: 89,
      ),
      const PlaylistTab(
        id: 'workout',
        name: 'Workout Mix',
        trackCount: 56,
      ),
      const PlaylistTab(
        id: 'dnb',
        name: 'Drum & Bass',
        trackCount: 156,
      ),
      const PlaylistTab(
        id: 'ambient',
        name: 'Ambient',
        trackCount: 78,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: widget.palette.background,
      body: Column(
        children: [
          // Top bar with theme selector
          _buildTopBar(),

          // Playlist tabs
          NeuPlaylistTabs(
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
              setState(() {
                _playlists.removeAt(index);
                if (_activePlaylistIndex >= _playlists.length) {
                  _activePlaylistIndex = _playlists.length - 1;
                }
              });
            },
            onReorderPlaylists: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _playlists.removeAt(oldIndex);
                _playlists.insert(newIndex, item);
              });
            },
            palette: widget.palette,
          ),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Playlist Manager Sidebar
                SizedBox(
                  width: 250,
                  child: NeuPlaylistManager(
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
                      // Implement folder assignment
                    },
                    onDeletePlaylist: (index) {
                      setState(() {
                        if (!_playlists[index].isDefault) {
                          _playlists.removeAt(index);
                          if (_activePlaylistIndex >= _playlists.length) {
                            _activePlaylistIndex = _playlists.length - 1;
                          }
                        }
                      });
                    },
                    onDeleteFolder: (folderId) {
                      setState(() {
                        _folders.removeWhere((f) => f.id == folderId);
                      });
                    },
                    palette: widget.palette,
                  ),
                ),

                // Active Playlist Content
                Expanded(
                  child: _buildPlaylistContent(),
                ),

                // Right Panel (Queue + Audio Info)
                SizedBox(
                  width: 320,
                  child: _buildRightPanel(),
                ),
              ],
            ),
          ),

          // Now Playing Bar
          _buildNowPlayingBar(),
        ],
      ),
    );
  }

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
            setState(() {
              if (!_playlists[index].isDefault) {
                _playlists.removeAt(index);
              }
            });
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
                  '${_playlists[_activePlaylistIndex].trackCount} tracks',
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
            child: _buildMobileTrackList(),
          ),
        ],
      ),
      floatingActionButton: NeuMobileMiniPlayer(
        trackTitle: 'Music Is Math',
        artistName: 'Boards of Canada',
        isPlaying: _isPlaying,
        progress: _progress,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NeuMobileExpandedPlayer(
                trackTitle: 'Music Is Math',
                artistName: 'Boards of Canada',
                albumTitle: 'Geogaddi',
                isPlaying: _isPlaying,
                isShuffled: false,
                isRepeating: false,
                progress: _progress,
                position: const Duration(minutes: 1, seconds: 52),
                duration: const Duration(minutes: 5, seconds: 21),
                volume: _volume,
                onClose: () => Navigator.pop(context),
                onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                onNext: () {},
                onPrevious: () {},
                onShuffle: () {},
                onRepeat: () {},
                onSeek: (value) => setState(() => _progress = value),
                onVolumeChange: (value) => setState(() => _volume = value),
                palette: widget.palette,
              ),
            ),
          );
        },
        onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
        onNext: () {},
        palette: widget.palette,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          // Settings menu
          PopupMenuButton(
            icon: Icon(Icons.settings, color: widget.palette.text),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.music_note, size: 16),
                    SizedBox(width: 8),
                    Text('Last.fm Settings'),
                  ],
                ),
                onTap: () => _showLastFmDialog(),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.headphones, size: 16),
                    SizedBox(width: 8),
                    Text('ListenBrainz Settings'),
                  ],
                ),
                onTap: () => _showListenBrainzDialog(),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _buildThemeSelector(),
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

  Widget _buildPlaylistContent() {
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
                        '${_playlists[_activePlaylistIndex].trackCount} tracks',
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
                  onPressed: () {},
                  palette: widget.palette,
                  size: 40,
                ),
                const SizedBox(width: 8),
                NeuIconButton(
                  icon: Icons.play_arrow,
                  onPressed: () => setState(() => _isPlaying = true),
                  palette: widget.palette,
                  backgroundColor: widget.palette.primary,
                  size: 40,
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: NeuSearchBar(
              controller: _searchController,
              palette: widget.palette,
              hintText: 'Search tracks...',
            ),
          ),

          // Track list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return NeuTrackTile(
                  trackNumber: index + 1,
                  title: _getMockTrack(index)['title'],
                  artist: _getMockTrack(index)['artist'],
                  duration: Duration(minutes: 4, seconds: 20 + index * 10),
                  sampleRate: 96000,
                  bitDepth: 24,
                  format: 'FLAC',
                  isPlaying: _currentTrackIndex == index,
                  onTap: () => setState(() => _currentTrackIndex = index),
                  onQueue: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to queue: ${_getMockTrack(index)['title']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onDelete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed: ${_getMockTrack(index)['title']}'),
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

  Widget _buildMobileTrackList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return NeuTrackTile(
          trackNumber: index + 1,
          title: _getMockTrack(index)['title'],
          artist: _getMockTrack(index)['artist'],
          duration: Duration(minutes: 4, seconds: 20 + index * 10),
          sampleRate: 96000,
          bitDepth: 24,
          format: 'FLAC',
          isPlaying: _currentTrackIndex == index,
          onTap: () => setState(() => _currentTrackIndex = index),
          onQueue: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added to queue: ${_getMockTrack(index)['title']}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onDelete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed: ${_getMockTrack(index)['title']}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          palette: widget.palette,
        );
      },
    );
  }

  Widget _buildRightPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Platform controls info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.palette.surface,
              border: Border.all(color: widget.palette.border, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.computer, size: 16, color: widget.palette.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM CONTROLS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: widget.palette.text.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 12, color: widget.palette.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'MPRIS enabled (Linux)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              color: widget.palette.text.withOpacity(0.7),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Spectrogram
          NeuSpectrogram(
            palette: widget.palette,
            height: 160,
          ),

          const SizedBox(height: 12),

          // Queue placeholder
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.palette.surface,
                border: Border.all(color: widget.palette.border, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.queue_music, size: 16, color: widget.palette.primary),
                      const SizedBox(width: 8),
                      Text(
                        'QUEUE',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              color: widget.palette.text,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '3 tracks',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: widget.palette.text.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Queue visualization here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.palette.text.withOpacity(0.4),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingBar() {
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
            onChanged: (value) => setState(() => _progress = value),
            palette: widget.palette,
            showLabels: true,
            leftLabel: '1:52',
            rightLabel: '5:21',
            height: 12,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Album art
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

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music Is Math',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: widget.palette.text,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Boards of Canada • Geogaddi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
                palette: widget.palette,
                backgroundColor: widget.palette.primary,
                size: 48,
              ),
              const SizedBox(width: 8),
              NeuIconButton(
                icon: Icons.skip_next,
                onPressed: () {},
                palette: widget.palette,
                size: 40,
              ),

              const SizedBox(width: 16),

              // Volume
              Icon(Icons.volume_up, size: 20, color: widget.palette.text.withOpacity(0.6)),
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

  Map<String, String> _getMockTrack(int index) {
    final tracks = [
      {'title': 'Music Is Math', 'artist': 'Boards of Canada'},
      {'title': 'Gyroscope', 'artist': 'Boards of Canada'},
      {'title': 'In the Annexe', 'artist': 'Boards of Canada'},
      {'title': 'Julie and Candy', 'artist': 'Boards of Canada'},
      {'title': 'The Smallest Weird Number', 'artist': 'Boards of Canada'},
    ];
    return tracks[index % tracks.length];
  }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}