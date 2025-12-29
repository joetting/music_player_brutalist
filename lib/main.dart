import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design/theme/app_theme.dart';
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
import 'design/widgets/neu_playlist.dart';
import 'design/widgets/ascii_icons.dart';
import 'design/widgets/neu_lyrics_panel.dart';
import 'design/widgets/neu_keyboard_shortcuts.dart';
import 'design/widgets/neu_theme_customizer.dart';
import 'design/widgets/neu_column_editor.dart';
import 'keyboard_shortcuts.dart';

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
  // Keyboard Shortcuts Manager
  late final KeyboardShortcutManager _shortcutManager;

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
  bool _isMuted = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5, seconds: 21);

  // UI State
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  FolderNode? _selectedFolder;
  int? _selectedGridRow;
  
  // Lyrics State
  int _rightPanelTab = 0; // 0 = Queue, 1 = Lyrics
  List<LyricLine> _currentLyrics = [];
  bool _lyricsAutoScroll = true;

  // Column Customization State
  List<GridColumn> _gridColumns = MusicGridColumns.audiophile;

  // Mock Data
  late List<FolderNode> _folderTree;
  late List<Map<String, dynamic>> _tracks;

  @override
  void initState() {
    super.initState();
    _initializeKeyboardShortcuts();
    _initializeMockData();
    _initializePlaylists();
    _loadMockLyrics();
    _startPlaybackSimulation();
  }

  void _initializeKeyboardShortcuts() {
    _shortcutManager = KeyboardShortcutManager();
    
    MusicPlayerShortcuts.registerDefaults(
      _shortcutManager,
      onPlayPause: _togglePlayPause,
      onNext: _skipToNext,
      onPrevious: _skipToPrevious,
      onVolumeUp: () {
        setState(() {
          _volume = (_volume + 0.1).clamp(0.0, 1.0);
        });
        _showVolumeToast();
      },
      onVolumeDown: () {
        setState(() {
          _volume = (_volume - 0.1).clamp(0.0, 1.0);
        });
        _showVolumeToast();
      },
      onMute: () {
        setState(() {
          if (_isMuted) {
            _isMuted = false;
          } else {
            _isMuted = true;
          }
        });
      },
      onShuffle: () {
        setState(() => _isShuffled = !_isShuffled);
        HapticFeedback.lightImpact();
      },
      onRepeat: () {
        setState(() => _isRepeating = !_isRepeating);
        HapticFeedback.lightImpact();
      },
      onSearch: () {
        _searchFocusNode.requestFocus();
      },
      onQueue: () {
        setState(() => _rightPanelTab = 0);
      },
      onDiagnostics: () {
        _showDiagnosticsDialog();
      },
      onSettings: () {
        _showSettingsDialog();
      },
    );
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
            ],
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
    ];
  }

  void _initializePlaylists() {
    _playlists = [
      const PlaylistTab(id: 'default', name: 'Default', trackCount: 8, isDefault: true),
      const PlaylistTab(id: 'favorites', name: 'Favorites', trackCount: 145),
    ];
    _folders = [const PlaylistFolder(id: 'electronic', name: 'Electronic Music')];
  }

  void _loadMockLyrics() {
    _currentLyrics = [
      const LyricLine(
        timestamp: Duration(seconds: 0),
        text: 'The sunlight on the garden',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 15),
        text: 'Hardens and grows cold',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 30),
        text: 'We cannot cage the minute',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 45),
        text: 'Within its nets of gold',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 60),
        text: 'When all is told',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 75),
        text: 'We cannot beg for pardon',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 90),
        text: 'The beauty that we travel',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 105),
        text: 'For is its own excuse for being',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 120),
        text: 'Mathematics, geometry',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 135),
        text: 'The architecture in the trees',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 150),
        text: 'Music is math',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 165),
        text: 'The one thing that keeps us in line',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 180),
        text: 'Patterns repeat',
        isSynced: true,
      ),
      const LyricLine(
        timestamp: Duration(seconds: 195),
        text: 'Time signatures divine',
        isSynced: true,
      ),
    ];
  }

  void _startPlaybackSimulation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isPlaying && mounted) {
        setState(() {
          _progress = (_progress + 0.001).clamp(0.0, 1.0);
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
      final parts = (_tracks[index]['duration'] as String).split(':');
      _duration = Duration(minutes: int.parse(parts[0]), seconds: int.parse(parts[1]));
    });
    HapticFeedback.mediumImpact();
  }

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    HapticFeedback.lightImpact();
  }

  void _skipToNext() {
    if (_currentTrackIndex != null && _currentTrackIndex! < _tracks.length - 1) {
      _playTrack(_currentTrackIndex! + 1);
    }
  }

  void _skipToPrevious() {
    if (_currentTrackIndex != null && _currentTrackIndex! > 0) {
      _playTrack(_currentTrackIndex! - 1);
    }
  }

  void _showVolumeToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Volume: ${(_volume * 100).round()}%',
          style: GoogleFonts.spaceMono(fontSize: 12),
        ),
        backgroundColor: widget.palette.primary,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showDiagnosticsDialog() {
    // Show audio diagnostics panel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Audio Diagnostics Panel (Coming Soon)',
          style: GoogleFonts.spaceMono(fontSize: 12),
        ),
        backgroundColor: widget.palette.accent,
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildSettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutHandler(
      manager: _shortcutManager,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
        },
      ),
    );
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
                SizedBox(width: 240, child: _buildPlaylistManagerPanel()),
                Expanded(child: _buildLibraryView()),
                SizedBox(width: 300, child: _buildRightPanel()),
              ],
            ),
          ),
          if (_currentTrackIndex != null) _buildDesktopNowPlayingBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(bottom: BorderSide(color: widget.palette.border, width: 3)),
      ),
      child: Row(
        children: [
          AsciiIcon(AsciiGlyph.musicNote, color: widget.palette.primary, size: 28),
          const SizedBox(width: 12),
          Text('BRUTALIST PLAYER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: widget.palette.text)),
          const Spacer(),
          _buildToolbarButtons(),
        ],
      ),
    );
  }

  Widget _buildToolbarButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Keyboard shortcuts button
        _buildToolbarButton(
          AsciiGlyph.key,
          'SHORTCUTS',
          () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: NeuKeyboardShortcutsPanel(
                  manager: _shortcutManager,
                  palette: widget.palette,
                  onEdit: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => NeuKeyboardShortcutEditor(
                        manager: _shortcutManager,
                        palette: widget.palette,
                        onSave: (manager) {
                          // TODO: Save to persistent storage
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Shortcuts saved!',
                                style: GoogleFonts.spaceMono(fontSize: 12),
                              ),
                              backgroundColor: widget.palette.primary,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        
        // Theme customizer button
        _buildToolbarButton(
          AsciiGlyph.settings,
          'THEME',
          () {
            showDialog(
              context: context,
              builder: (_) => NeuThemeCustomizer(
                initialPalette: widget.palette,
                onThemeChanged: (newPalette) {
                  widget.onPaletteChanged(newPalette);
                },
                onSave: (palette) {
                  // TODO: Save to persistent storage
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Theme saved!',
                        style: GoogleFonts.spaceMono(fontSize: 12),
                      ),
                      backgroundColor: widget.palette.primary,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolbarButton(AsciiGlyph glyph, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.palette.primary.withValues(alpha: 0.2),
          border: Border.all(color: widget.palette.border, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AsciiIcon(glyph, size: 16, color: widget.palette.text),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.palette.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTabs() {
    return NeuPlaylistTabs(
      playlists: _playlists,
      activePlaylistIndex: _activePlaylistIndex,
      onPlaylistSelected: (i) => setState(() => _activePlaylistIndex = i),
      onCreatePlaylist: (n) {},
      onClosePlaylist: (i) {},
      onReorderPlaylists: (o, n) {},
      palette: widget.palette,
    );
  }

  Widget _buildPlaylistManagerPanel() {
    return NeuPlaylistManager(
      playlists: _playlists,
      folders: _folders,
      selectedPlaylistIndex: _activePlaylistIndex,
      onPlaylistSelected: (i) => setState(() => _activePlaylistIndex = i),
      onCreatePlaylist: (n) {},
      onCreateFolder: (n) {},
      onMovePlaylist: (i, f) {},
      onDeletePlaylist: (i) {},
      onDeleteFolder: (f) {},
      palette: widget.palette,
    );
  }

  Widget _buildLibraryView() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          SizedBox(
            width: 250,
            child: NeuFolderTree(
              rootNodes: _folderTree,
              onFolderSelected: (n) => setState(() => _selectedFolder = n),
              palette: widget.palette,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar + Column editor
                Row(
                  children: [
                    Expanded(
                      child: NeuSearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        palette: widget.palette,
                        hintText: 'Search library... (Ctrl+F)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    NeuColumnEditorButton(
                      currentColumns: _gridColumns,
                      palette: widget.palette,
                      onColumnsChanged: (newColumns) {
                        setState(() => _gridColumns = newColumns);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Data grid
                Expanded(
                  child: NeuDataGrid(
                    columns: _gridColumns,
                    rows: _tracks,
                    selectedRowIndex: _selectedGridRow,
                    onRowTap: (i) => setState(() => _selectedGridRow = i),
                    onRowDoubleTap: _playTrack,
                    palette: widget.palette,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildRightPanelTabs(),
          const SizedBox(height: 8),
          
          if (_currentTrackIndex != null)
            NeuAudioInfoBadge(
              format: 'FLAC',
              sampleRate: 96000,
              bitDepth: 24,
              exclusiveMode: true,
              palette: widget.palette,
            ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _rightPanelTab == 0 ? _buildQueueTab() : _buildLyricsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanelTabs() {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(color: widget.palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildTab('QUEUE', 0, AsciiGlyph.queueMusic),
          _buildTab('LYRICS', 1, AsciiGlyph.music),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, AsciiGlyph glyph) {
    final isSelected = _rightPanelTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _rightPanelTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? widget.palette.primary.withValues(alpha: 0.2) 
                : Colors.transparent,
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: widget.palette.primary, width: 3),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AsciiIcon(glyph, size: 14, color: widget.palette.text),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.robotoCondensed(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: widget.palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueTab() {
    return Column(
      children: [
        NeuSpectrogram(
          palette: widget.palette,
          height: 160,
          showGrid: true,
          showLabels: false,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: NeuQueueView(
            queue: _tracks.asMap().entries.map((e) => 
              QueueTrack(
                id: e.key.toString(),
                title: e.value['title'],
                artist: e.value['artist'],
                duration: e.value['duration'],
              )
            ).toList(),
            currentTrackIndex: _currentTrackIndex,
            onTrackTap: _playTrack,
            onReorder: (o, n) {},
            palette: widget.palette,
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsTab() {
    return NeuLyricsPanel(
      lyrics: _currentLyrics,
      currentPosition: _position,
      palette: widget.palette,
      autoScroll: _lyricsAutoScroll,
      onAutoScrollToggle: (value) => setState(() => _lyricsAutoScroll = value),
      source: LyricsSource.lrc,
    );
  }

  Widget _buildDesktopNowPlayingBar() {
    final track = _tracks[_currentTrackIndex!];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(top: BorderSide(color: widget.palette.border, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuProgressBar(
            value: _progress,
            palette: widget.palette,
            showLabels: true,
            leftLabel: _formatDuration(_position),
            rightLabel: _formatDuration(_duration),
            onChanged: (v) => setState(() => _progress = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.palette.primary.withValues(alpha: 0.2),
                  border: Border.all(color: widget.palette.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AsciiIcon(AsciiGlyph.album, size: 32, color: widget.palette.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(track['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${track['artist']} • ${track['album']}', style: TextStyle(fontSize: 12, color: widget.palette.text.withValues(alpha: 0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              NeuIconButton(icon: Icons.skip_previous, onPressed: _skipToPrevious, palette: widget.palette, size: 40),
              const SizedBox(width: 8),
              NeuIconButton(icon: _isPlaying ? Icons.pause : Icons.play_arrow, onPressed: _togglePlayPause, palette: widget.palette, backgroundColor: widget.palette.primary, size: 48),
              const SizedBox(width: 8),
              NeuIconButton(icon: Icons.skip_next, onPressed: _skipToNext, palette: widget.palette, size: 40),
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
        title: const Text('BRUTALIST PLAYER', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: widget.palette.surface,
        actions: [
          IconButton(
            icon: AsciiIcon(AsciiGlyph.settings, size: 20, color: widget.palette.text),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _tracks.length,
        itemBuilder: (context, index) => NeuTrackTile(
          trackNumber: _tracks[index]['track'],
          title: _tracks[index]['title'],
          artist: _tracks[index]['artist'],
          duration: const Duration(minutes: 5),
          isPlaying: _currentTrackIndex == index && _isPlaying,
          onTap: () => _playTrack(index),
          palette: widget.palette,
        ),
      ),
      floatingActionButton: _currentTrackIndex != null
          ? NeuMobileMiniPlayer(
              trackTitle: _tracks[_currentTrackIndex!]['title'],
              artistName: _tracks[_currentTrackIndex!]['artist'],
              isPlaying: _isPlaying,
              progress: _progress,
              onTap: _showMobileExpandedPlayer,
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => NeuMobileExpandedPlayer(
      trackTitle: track['title'], artistName: track['artist'], albumTitle: track['album'],
      isPlaying: _isPlaying, isShuffled: _isShuffled, isRepeating: _isRepeating,
      progress: _progress, position: _position, duration: _duration, volume: _volume,
      onClose: () => Navigator.pop(context), onPlayPause: _togglePlayPause, onNext: _skipToNext, onPrevious: _skipToPrevious,
      onShuffle: () => setState(() => _isShuffled = !_isShuffled),
      onRepeat: () => setState(() => _isRepeating = !_isRepeating),
      onSeek: (v) => setState(() => _progress = v),
      onVolumeChange: (v) => setState(() => _volume = v),
      palette: widget.palette,
    )));
  }

  // ==================== SETTINGS DIALOG ====================

  Widget _buildSettingsDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
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
            // Header
            Row(
              children: [
                AsciiIcon(AsciiGlyph.settings, size: 20, color: widget.palette.primary),
                const SizedBox(width: 12),
                Text(
                  'SETTINGS',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: widget.palette.text,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: AsciiIcon(AsciiGlyph.close, size: 18, color: widget.palette.text),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Settings options
            _buildSettingsButton(
              'Keyboard Shortcuts',
              AsciiGlyph.key,
              () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: NeuKeyboardShortcutsPanel(
                      manager: _shortcutManager,
                      palette: widget.palette,
                      onEdit: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => NeuKeyboardShortcutEditor(
                            manager: _shortcutManager,
                            palette: widget.palette,
                            onSave: (manager) {},
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildSettingsButton(
              'Theme Customizer',
              AsciiGlyph.settings,
              () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => NeuThemeCustomizer(
                    initialPalette: widget.palette,
                    onThemeChanged: widget.onPaletteChanged,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildSettingsButton(
              'Column Editor',
              AsciiGlyph.gridView,
              () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => NeuColumnEditor(
                    initialColumns: _gridColumns,
                    palette: widget.palette,
                    onSave: (cols) => setState(() => _gridColumns = cols),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(String label, AsciiGlyph glyph, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.palette.surface,
          border: Border.all(color: widget.palette.border, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            AsciiIcon(glyph, size: 20, color: widget.palette.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.robotoCondensed(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.palette.text,
              ),
            ),
            const Spacer(),
            AsciiIcon(AsciiGlyph.chevronRight, size: 16, color: widget.palette.text),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
          boxShadow: [BoxShadow(color: palette.shadow, offset: const Offset(6, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: palette.primary.withValues(alpha: 0.2), border: Border.all(color: palette.border, width: 2), borderRadius: BorderRadius.circular(8)), child: AsciiIcon(AsciiGlyph.album, size: 28, color: palette.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(trackTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text(artistName, style: TextStyle(fontSize: 12, color: palette.text.withValues(alpha: 0.7)), maxLines: 1, overflow: TextOverflow.ellipsis)])),
                AsciiIconButton(glyph: isPlaying ? AsciiGlyph.pause : AsciiGlyph.play, onPressed: onPlayPause, size: 24, color: palette.text),
                AsciiIconButton(glyph: AsciiGlyph.skipNext, onPressed: onNext, size: 24, color: palette.text),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(color: palette.background, border: Border.all(color: palette.border, width: 1), borderRadius: BorderRadius.circular(2)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(decoration: BoxDecoration(color: palette.primary, borderRadius: BorderRadius.circular(1))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}