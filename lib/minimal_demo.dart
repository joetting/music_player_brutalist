import 'package:flutter/material.dart';
import 'design/theme/app_theme.dart';
import 'design/widgets/neu_album_card.dart';
import 'design/widgets/neu_track_tile.dart';
import 'design/widgets/neu_button.dart';
import 'design/widgets/neu_container.dart';

void main() {
  runApp(const MinimalDemo());
}

class MinimalDemo extends StatelessWidget {
  const MinimalDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = RatholeTheme.classic;
    
    return MaterialApp(
      title: 'Brutalist Music Player - Minimal Demo',
      debugShowCheckedModeBanner: false,
      theme: RatholeTheme.buildTheme(palette),
      home: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          title: const Text('BRUTALIST MUSIC PLAYER'),
          backgroundColor: palette.surface,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                NeuContainer(
                  palette: palette,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Component Library',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Minimal demo - no animations',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.text.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Text(
                  'BUTTONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: palette.text.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    NeuButton(
                      onPressed: () {},
                      palette: palette,
                      child: const Text('Play'),
                    ),
                    NeuButton(
                      onPressed: () {},
                      palette: palette,
                      backgroundColor: palette.secondary,
                      child: const Text('Pause'),
                    ),
                    NeuIconButton(
                      icon: Icons.skip_next,
                      onPressed: () {},
                      palette: palette,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Album Card
                Text(
                  'ALBUM CARD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: palette.text.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  child: NeuAlbumCard(
                    albumTitle: 'Geogaddi',
                    artistName: 'Boards of Canada',
                    trackCount: 23,
                    year: 2002,
                    sampleRate: 96000,
                    bitDepth: 24,
                    hasMusicBrainzId: true,
                    onTap: () {},
                    palette: palette,
                  ),
                ),

                const SizedBox(height: 24),

                // Track Tiles
                Text(
                  'TRACK LIST',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: palette.text.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                NeuTrackTile(
                  trackNumber: 1,
                  title: 'Music Is Math',
                  artist: 'Boards of Canada',
                  duration: const Duration(minutes: 5, seconds: 21),
                  sampleRate: 96000,
                  bitDepth: 24,
                  format: 'FLAC',
                  isPlaying: true,
                  onTap: () {},
                  palette: palette,
                ),
                NeuTrackTile(
                  trackNumber: 2,
                  title: 'Gyroscope',
                  artist: 'Boards of Canada',
                  duration: const Duration(minutes: 3, seconds: 26),
                  sampleRate: 96000,
                  bitDepth: 24,
                  format: 'FLAC',
                  onTap: () {},
                  palette: palette,
                ),

                const SizedBox(height: 24),

                // Info
                NeuContainer(
                  palette: palette,
                  backgroundColor: palette.primary.withOpacity(0.1),
                  child: Text(
                    'All components working! Check main.dart and full_demo.dart for complete examples.',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.text.withOpacity(0.8),
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
}
