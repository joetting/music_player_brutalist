import 'package:flutter/material.dart';
import 'design/theme/app_theme.dart';
import 'design/widgets/neu_album_card.dart';
import 'design/widgets/neu_track_tile.dart';
import 'design/widgets/neu_button.dart';
import 'design/widgets/neu_slider.dart';
import 'design/widgets/neu_progress_bar.dart';
import 'design/widgets/neu_search_bar.dart';
import 'design/widgets/neu_spectrogram.dart';
import 'design/widgets/neu_container.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatefulWidget {
  const MusicPlayerApp({super.key});

  @override
  State<MusicPlayerApp> createState() => _MusicPlayerAppState();
}

class _MusicPlayerAppState extends State<MusicPlayerApp> {
  String _selectedPalette = 'Classic';
  RatholePalette _currentPalette = RatholeTheme.classic;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brutalist Music Player',
      debugShowCheckedModeBanner: false,
      theme: RatholeTheme.buildTheme(_currentPalette),
      home: ComponentShowcase(
        palette: _currentPalette,
        onPaletteChanged: (name, palette) {
          setState(() {
            _selectedPalette = name;
            _currentPalette = palette;
          });
        },
        currentPaletteName: _selectedPalette,
      ),
    );
  }
}

class ComponentShowcase extends StatefulWidget {
  final RatholePalette palette;
  final Function(String, RatholePalette) onPaletteChanged;
  final String currentPaletteName;

  const ComponentShowcase({
    super.key,
    required this.palette,
    required this.onPaletteChanged,
    required this.currentPaletteName,
  });

  @override
  State<ComponentShowcase> createState() => _ComponentShowcaseState();
}

class _ComponentShowcaseState extends State<ComponentShowcase> {
  final TextEditingController _searchController = TextEditingController();
  double _volumeValue = 0.7;
  double _progressValue = 0.3;
  int _selectedTrack = 0;
  bool _showAudioPanel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with theme selector
            _buildTopBar(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Search bar section
                    _buildSection('Search Bar', _buildSearchDemo()),
                    const SizedBox(height: 24),

                    // Album cards section
                    _buildSection('Album Cards', _buildAlbumCardsDemo()),
                    const SizedBox(height: 24),

                    // Track tiles section
                    _buildSection('Track List', _buildTrackListDemo()),
                    const SizedBox(height: 24),

                    // Spectrogram section
                    _buildSection('Spectrogram', _buildSpectrogramDemo()),
                    const SizedBox(height: 24),

                    // Audio info section
                    _buildSection('Audio Info', _buildAudioInfoDemo()),
                    const SizedBox(height: 24),

                    // Controls section
                    _buildSection('Controls', _buildControlsDemo()),
                    const SizedBox(height: 24),

                    // Buttons section
                    _buildSection('Buttons', _buildButtonsDemo()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(
            color: widget.palette.border,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.music_note, color: widget.palette.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            'Component Library',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: widget.palette.text,
            ),
          ),
          const Spacer(),
          _buildThemeSelector(),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return PopupMenuButton<String>(
      child: NeuContainer(
        palette: widget.palette,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hasShadow: false,
        borderWidth: 2,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.currentPaletteName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.palette.text,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.palette, size: 16, color: widget.palette.primary),
          ],
        ),
      ),
      onSelected: (name) {
        widget.onPaletteChanged(name, RatholeTheme.allPalettes[name]!);
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

  Widget _buildHeader() {
    return NeuContainer(
      palette: widget.palette,
      asymmetricCorners: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BRUTALIST UI',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: widget.palette.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hard shadows • Bold borders • No compromises',
            style: TextStyle(
              fontSize: 14,
              color: widget.palette.text.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: widget.palette.text.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSearchDemo() {
    return NeuSearchBar(
      controller: _searchController,
      palette: widget.palette,
      hintText: 'Search albums, artists, tracks...',
      onChanged: (value) {},
    );
  }

  Widget _buildAlbumCardsDemo() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: NeuAlbumCard(
              albumTitle: 'Bloom',
              artistName: 'Beach House',
              trackCount: 10,
              year: 2012,
              sampleRate: 96000,
              bitDepth: 24,
              hasMusicBrainzId: true,
              onTap: () {},
              palette: widget.palette,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: NeuAlbumCard(
              albumTitle: 'In Rainbows',
              artistName: 'Radiohead',
              trackCount: 10,
              year: 2007,
              sampleRate: 44100,
              bitDepth: 16,
              onTap: () {},
              palette: widget.palette,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: NeuAlbumCard(
              albumTitle: 'Homogenic',
              artistName: 'Björk',
              trackCount: 9,
              year: 1997,
              sampleRate: 192000,
              bitDepth: 24,
              hasMusicBrainzId: true,
              onTap: () {},
              palette: widget.palette,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackListDemo() {
    return Column(
      children: [
        NeuTrackTile(
          trackNumber: 1,
          title: 'Myth',
          artist: 'Beach House',
          duration: const Duration(minutes: 4, seconds: 19),
          sampleRate: 96000,
          bitDepth: 24,
          format: 'FLAC',
          isPlaying: _selectedTrack == 0,
          onTap: () => setState(() => _selectedTrack = 0),
          palette: widget.palette,
        ),
        NeuTrackTile(
          trackNumber: 2,
          title: 'Wild',
          artist: 'Beach House',
          duration: const Duration(minutes: 5, seconds: 14),
          sampleRate: 96000,
          bitDepth: 24,
          format: 'FLAC',
          isPlaying: _selectedTrack == 1,
          onTap: () => setState(() => _selectedTrack = 1),
          palette: widget.palette,
        ),
        NeuTrackTile(
          trackNumber: 3,
          title: 'Lazuli',
          artist: 'Beach House',
          duration: const Duration(minutes: 5, seconds: 20),
          sampleRate: 96000,
          bitDepth: 24,
          format: 'FLAC',
          isPlaying: _selectedTrack == 2,
          onTap: () => setState(() => _selectedTrack = 2),
          palette: widget.palette,
        ),
      ],
    );
  }

  Widget _buildSpectrogramDemo() {
    return Column(
      children: [
        NeuSpectrogram(
          palette: widget.palette,
          height: 200,
        ),
      ],
    );
  }

  Widget _buildAudioInfoDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeuAudioInfoBadge(
          format: 'FLAC',
          sampleRate: 96000,
          bitDepth: 24,
          exclusiveMode: true,
          palette: widget.palette,
          onTap: () => setState(() => _showAudioPanel = !_showAudioPanel),
        ),
        if (_showAudioPanel) ...[
          const SizedBox(height: 12),
          NeuAudioPanel(
            sourceFormat: 'FLAC',
            sourceSampleRate: 96000,
            sourceBitDepth: 24,
            outputDevice: 'USB DAC',
            outputSampleRate: 96000,
            outputBitDepth: 24,
            exclusiveMode: true,
            bitPerfect: true,
            palette: widget.palette,
          ),
        ],
      ],
    );
  }

  Widget _buildControlsDemo() {
    return Column(
      children: [
        // Volume slider
        NeuSlider(
          value: _volumeValue,
          onChanged: (v) => setState(() => _volumeValue = v),
          palette: widget.palette,
        ),
        const SizedBox(height: 16),

        // Progress bar
        NeuProgressBar(
          value: _progressValue,
          onChanged: (v) => setState(() => _progressValue = v),
          palette: widget.palette,
          showLabels: true,
          leftLabel: '1:23',
          rightLabel: '4:19',
          height: 16,
        ),
      ],
    );
  }

  Widget _buildButtonsDemo() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        NeuButton(
          onPressed: () {},
          palette: widget.palette,
          child: const Text('Play'),
        ),
        NeuButton(
          onPressed: () {},
          palette: widget.palette,
          backgroundColor: widget.palette.secondary,
          child: const Text('Shuffle'),
        ),
        NeuIconButton(
          icon: Icons.play_arrow,
          onPressed: () {},
          palette: widget.palette,
        ),
        NeuIconButton(
          icon: Icons.skip_next,
          onPressed: () {},
          palette: widget.palette,
          backgroundColor: widget.palette.tertiary,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
