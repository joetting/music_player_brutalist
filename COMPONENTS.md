# Component Documentation

## Table of Contents
1. [Theme System](#theme-system)
2. [Music Components](#music-components)
3. [Control Components](#control-components)
4. [Search & Filter](#search--filter)
5. [Audio Diagnostics](#audio-diagnostics)
6. [Layout Components](#layout-components)

---

## Theme System

### RatholeTheme

The core theme system providing 7 distinct color palettes.

**Available Palettes:**

```dart
RatholeTheme.classic     // Bold yellow/pink/cyan
RatholeTheme.muted       // Beige/gray/brown
RatholeTheme.dark        // Neon green/magenta/cyan
RatholeTheme.darkPro     // Subdued dark mode
RatholeTheme.foobar      // VS Code blue/teal
RatholeTheme.synthwave   // Hot pink/cyan retro
RatholeTheme.crtGreen    // Terminal green
```

**Usage:**

```dart
// Get a palette
final palette = RatholeTheme.classic;

// Build a theme
final theme = RatholeTheme.buildTheme(palette, isDark: false);

// Access all palettes
final allPalettes = RatholeTheme.allPalettes; // Map<String, RatholePalette>
```

### RatholePalette

Color palette definition with 10 semantic colors:

```dart
class RatholePalette {
  final Color primary;      // Main actions, highlights
  final Color secondary;    // Secondary elements
  final Color tertiary;     // Tertiary elements
  final Color background;   // Page background
  final Color surface;      // Card/container background
  final Color error;        // Error states
  final Color border;       // All borders
  final Color shadow;       // All shadows
  final Color text;         // Primary text
  final Color accent;       // Interactive elements (links, buttons)
}
```

### AudioQualityColors

Utility class for color-coding audio quality:

```dart
// Color by sample rate
final color = AudioQualityColors.forSampleRate(96000); 
// Returns: Cyan for 96kHz

// Color by bitrate
final color = AudioQualityColors.forBitrate(320000);
// Returns: Mint green for 320kbps

// Color by format
final color = AudioQualityColors.forFormat('FLAC');
// Returns: Mint green for lossless

// Generate quality label
final label = AudioQualityColors.qualityLabel(96000, 24);
// Returns: "Hi-Res 96kHz/24-bit"
```

**Color Mapping:**
- **≥192kHz**: Mint Green (#00FF9F) - DSD/Hi-Res
- **≥96kHz**: Cyan (#00D4FF) - Hi-Res
- **≥48kHz**: Amber (#FFB000) - CD+
- **<48kHz**: Gray (#9CA3AF) - Standard

---

## Music Components

### NeuAlbumCard

Album grid card with neubrutalist styling.

**Properties:**

```dart
NeuAlbumCard({
  required String albumTitle,        // Album name
  required String artistName,        // Artist name
  String? artworkUrl,                // Album art URL (optional)
  required int trackCount,           // Number of tracks
  int? year,                         // Release year (optional)
  int? sampleRate,                   // Sample rate in Hz (optional)
  int? bitDepth,                     // Bit depth (optional)
  bool hasMusicBrainzId = false,     // MusicBrainz verification
  required VoidCallback onTap,       // Tap handler
  required RatholePalette palette,   // Theme palette
})
```

**Features:**
- Asymmetric border radius (top-right & bottom-left rounded)
- Quality badge overlay (when sampleRate/bitDepth provided)
- MusicBrainz verification indicator
- Hard shadow (8px offset)
- Metadata chips (year, track count, quality)

**Example:**

```dart
NeuAlbumCard(
  albumTitle: 'Bloom',
  artistName: 'Beach House',
  trackCount: 10,
  year: 2012,
  sampleRate: 96000,
  bitDepth: 24,
  hasMusicBrainzId: true,
  onTap: () => print('Album tapped'),
  palette: RatholeTheme.classic,
)
```

### NeuTrackTile

Track list row with playing state indication.

**Properties:**

```dart
NeuTrackTile({
  int? trackNumber,                  // Track number (optional)
  required String title,             // Track title
  required String artist,            // Artist name
  required Duration duration,        // Track length
  int? sampleRate,                   // Sample rate (optional)
  int? bitDepth,                     // Bit depth (optional)
  String? format,                    // File format (optional)
  bool isPlaying = false,            // Playing state
  required VoidCallback onTap,       // Tap handler
  required RatholePalette palette,   // Theme palette
})
```

**Features:**
- Animated graphic equalizer icon when playing
- Bold border when active (3px vs 2px)
- Hard shadow when playing
- Quality badge (when specs provided)
- Formatted duration display

**Example:**

```dart
NeuTrackTile(
  trackNumber: 1,
  title: 'Myth',
  artist: 'Beach House',
  duration: Duration(minutes: 4, seconds: 19),
  sampleRate: 96000,
  bitDepth: 24,
  format: 'FLAC',
  isPlaying: true,
  onTap: () => print('Track tapped'),
  palette: RatholeTheme.classic,
)
```

---

## Control Components

### NeuButton

Primary button with press animation.

**Properties:**

```dart
NeuButton({
  required Widget child,             // Button content
  required VoidCallback onPressed,   // Tap handler
  required RatholePalette palette,   // Theme palette
  Color? backgroundColor,            // Custom bg color (optional)
  Color? borderColor,                // Custom border (optional)
  double? width,                     // Fixed width (optional)
  double? height,                    // Fixed height (optional)
  EdgeInsets? padding,               // Custom padding (optional)
  bool enabled = true,               // Enabled state
})
```

**Features:**
- Shadow reduces on press (6px → 0px)
- Button translates on press (mimics shadow movement)
- Disabled state (50% opacity)
- 100ms animation duration

**Example:**

```dart
NeuButton(
  onPressed: () => print('Pressed'),
  palette: palette,
  backgroundColor: palette.primary,
  child: Text('PLAY'),
)
```

### NeuIconButton

Icon-only button variant.

**Properties:**

```dart
NeuIconButton({
  required IconData icon,            // Icon to display
  required VoidCallback onPressed,   // Tap handler
  required RatholePalette palette,   // Theme palette
  Color? backgroundColor,            // Custom bg (optional)
  Color? iconColor,                  // Custom icon color (optional)
  double size = 48,                  // Button size
  bool enabled = true,               // Enabled state
})
```

**Example:**

```dart
NeuIconButton(
  icon: Icons.play_arrow,
  onPressed: () => print('Play'),
  palette: palette,
  size: 56,
)
```

### NeuSlider

Chunky slider with custom thumb shape.

**Properties:**

```dart
NeuSlider({
  required double value,             // Current value (0.0-1.0)
  required ValueChanged<double> onChanged, // Value change handler
  required RatholePalette palette,   // Theme palette
  double min = 0.0,                  // Minimum value
  double max = 1.0,                  // Maximum value
  Color? activeColor,                // Track active color (optional)
  double height = 60,                // Slider height
})
```

**Features:**
- Custom thumb with border and shadow
- Bold track (8px height)
- Hard shadow container
- Vertical variant available (`NeuVerticalSlider`)

**Example:**

```dart
NeuSlider(
  value: volumeLevel,
  onChanged: (v) => setState(() => volumeLevel = v),
  palette: palette,
  activeColor: palette.primary,
)
```

### NeuProgressBar

Seekable progress indicator.

**Properties:**

```dart
NeuProgressBar({
  required double value,             // Progress (0.0-1.0)
  ValueChanged<double>? onChanged,   // Seek handler (optional)
  required RatholePalette palette,   // Theme palette
  Color? progressColor,              // Progress fill color (optional)
  double height = 12,                // Bar height
  bool showLabels = false,           // Show time labels
  String? leftLabel,                 // Left label (e.g., "1:23")
  String? rightLabel,                // Right label (e.g., "4:19")
})
```

**Features:**
- Click/drag to seek
- Hard-edged progress indicator
- Optional time labels
- Waveform variant available (`NeuWaveformProgress`)

**Example:**

```dart
NeuProgressBar(
  value: playbackPosition,
  onChanged: (v) => seek(v),
  palette: palette,
  showLabels: true,
  leftLabel: formatTime(currentPosition),
  rightLabel: formatTime(totalDuration),
)
```

---

## Search & Filter

### NeuSearchBar

Bold search input with clear button.

**Properties:**

```dart
NeuSearchBar({
  required TextEditingController controller, // Text controller
  String hintText = 'Search...',    // Placeholder text
  ValueChanged<String>? onChanged,  // Text change handler
  VoidCallback? onClear,            // Clear button handler
  required RatholePalette palette,  // Theme palette
  FocusNode? focusNode,             // Focus node (optional)
})
```

**Features:**
- Border changes to primary color when focused
- Shadow changes to primary color when focused
- Clear button appears when text present
- Search icon on left

**Example:**

```dart
final searchController = TextEditingController();

NeuSearchBar(
  controller: searchController,
  palette: palette,
  hintText: 'Search albums, artists...',
  onChanged: (query) => performSearch(query),
  onClear: () => clearSearch(),
)
```

### NeuFilterChip

Compact filter chip for genres, years, etc.

**Properties:**

```dart
NeuFilterChip({
  required String label,             // Chip text
  required bool isSelected,          // Selected state
  required VoidCallback onTap,       // Tap handler
  required RatholePalette palette,   // Theme palette
  IconData? icon,                    // Optional icon
})
```

**Features:**
- Bold border when selected (3px vs 2px)
- Hard shadow when selected
- Close icon appears when selected
- Rounded pill shape (16px radius)

**Example:**

```dart
NeuFilterChip(
  label: 'Electronic',
  isSelected: selectedGenres.contains('Electronic'),
  onTap: () => toggleGenre('Electronic'),
  palette: palette,
  icon: Icons.music_note,
)
```

---

## Audio Diagnostics

### NeuSpectrogram

Real-time frequency analyzer visualization.

**Properties:**

```dart
NeuSpectrogram({
  required RatholePalette palette,   // Theme palette
  double height = 200,               // Component height
  bool showGrid = true,              // Show frequency grid
  bool showLabels = true,            // Show frequency labels
  List<double>? frequencyData,       // Amplitude data (optional)
})
```

**Features:**
- 64 frequency bars (20Hz - 20kHz range)
- Color-coded by frequency:
  - Red: Bass (20Hz-200Hz)
  - Yellow: Low-mid (200Hz-2kHz)
  - Cyan: High-mid (2kHz-10kHz)
  - Green: Treble (10kHz-20kHz)
- Grid overlay with 4x4 divisions
- Frequency labels at key points
- Animated at 60fps (when using mock data)

**Example:**

```dart
// With mock data (auto-animated)
NeuSpectrogram(
  palette: palette,
  height: 250,
)

// With real FFT data
NeuSpectrogram(
  palette: palette,
  frequencyData: fftResults, // List<double> of 64 values (0.0-1.0)
  showGrid: true,
  showLabels: true,
)
```

### NeuAudioInfoBadge

Compact audio quality indicator.

**Properties:**

```dart
NeuAudioInfoBadge({
  required String format,            // File format (e.g., 'FLAC')
  required int sampleRate,           // Sample rate in Hz
  required int bitDepth,             // Bit depth
  required bool exclusiveMode,       // Exclusive mode active
  required RatholePalette palette,   // Theme palette
  VoidCallback? onTap,               // Tap handler (optional)
})
```

**Features:**
- Color-coded by quality
- Exclusive mode bolt icon
- Format displayed in uppercase
- Divider between sections

**Example:**

```dart
NeuAudioInfoBadge(
  format: 'FLAC',
  sampleRate: 96000,
  bitDepth: 24,
  exclusiveMode: true,
  palette: palette,
  onTap: () => showAudioPanel(),
)
```

### NeuAudioPanel

Detailed audio path diagnostic panel.

**Properties:**

```dart
NeuAudioPanel({
  required String sourceFormat,      // Source file format
  required int sourceSampleRate,     // Source sample rate
  required int sourceBitDepth,       // Source bit depth
  required String outputDevice,      // Output device name
  required int outputSampleRate,     // Output sample rate
  required int outputBitDepth,       // Output bit depth
  required bool exclusiveMode,       // Exclusive mode active
  required bool bitPerfect,          // Bit-perfect playback
  required RatholePalette palette,   // Theme palette
})
```

**Features:**
- Visual flow diagram (Source → Output)
- Color-coded sections
- Status chips (Exclusive Mode, Bit-Perfect)
- Success/error indicators

**Example:**

```dart
NeuAudioPanel(
  sourceFormat: 'FLAC',
  sourceSampleRate: 96000,
  sourceBitDepth: 24,
  outputDevice: 'FiiO K9 Pro USB DAC',
  outputSampleRate: 96000,
  outputBitDepth: 24,
  exclusiveMode: true,
  bitPerfect: true,
  palette: palette,
)
```

---

## Layout Components

### NeuContainer

Reusable container with neubrutalist styling.

**Properties:**

```dart
NeuContainer({
  required Widget child,             // Container content
  required RatholePalette palette,   // Theme palette
  Color? backgroundColor,            // Custom bg (optional)
  Color? borderColor,                // Custom border (optional)
  Color? shadowColor,                // Custom shadow (optional)
  double borderWidth = 3,            // Border thickness
  EdgeInsets? padding,               // Custom padding (optional)
  double? width,                     // Fixed width (optional)
  double? height,                    // Fixed height (optional)
  BorderRadius? borderRadius,        // Custom radius (optional)
  bool asymmetricCorners = false,    // Use asymmetric corners
  bool hasShadow = true,             // Enable shadow
  Offset shadowOffset = Offset(6,6), // Shadow position
})
```

**Example:**

```dart
NeuContainer(
  palette: palette,
  asymmetricCorners: true,
  padding: EdgeInsets.all(24),
  child: Text('Container content'),
)
```

### NeuCard

Card with optional title and divider.

**Properties:**

```dart
NeuCard({
  String? title,                     // Card title (optional)
  required Widget child,             // Card content
  required RatholePalette palette,   // Theme palette
  VoidCallback? onTap,               // Tap handler (optional)
  bool isSelected = false,           // Selected state
})
```

**Example:**

```dart
NeuCard(
  title: 'Settings',
  palette: palette,
  isSelected: true,
  onTap: () => openSettings(),
  child: Column(
    children: [
      Text('Option 1'),
      Text('Option 2'),
    ],
  ),
)
```

### NeuDivider

Hard-edged divider line.

**Properties:**

```dart
NeuDivider({
  required RatholePalette palette,   // Theme palette
  double thickness = 2,              // Line thickness
  double? height,                    // Container height (optional)
  Color? color,                      // Custom color (optional)
})
```

**Example:**

```dart
NeuDivider(
  palette: palette,
  thickness: 3,
)
```

---

## Best Practices

### 1. Consistent Palette Usage

Always pass the same palette throughout your widget tree:

```dart
class MyApp extends StatelessWidget {
  final palette = RatholeTheme.classic;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: RatholeTheme.buildTheme(palette),
      home: MyHomePage(palette: palette),
    );
  }
}
```

### 2. Quality Badges

Always provide sample rate and bit depth when available:

```dart
// ✅ Good
NeuTrackTile(
  sampleRate: 96000,
  bitDepth: 24,
  ...
)

// ❌ Missing quality info
NeuTrackTile(
  // No sampleRate/bitDepth
  ...
)
```

### 3. Interactive States

Handle press states for better UX:

```dart
// ✅ Good - Shows playing state
NeuTrackTile(
  isPlaying: currentTrackId == track.id,
  ...
)

// ✅ Good - Shows selected state
NeuCard(
  isSelected: selectedCardId == card.id,
  ...
)
```

### 4. Accessibility

Provide meaningful tap handlers:

```dart
// ✅ Good
NeuButton(
  onPressed: () => playTrack(),
  child: Text('PLAY'),
)

// ❌ Bad - No action
NeuButton(
  onPressed: () {},
  child: Text('PLAY'),
)
```

---

## Component Combinations

### Album Detail View

```dart
Column(
  children: [
    NeuAlbumCard(
      albumTitle: album.title,
      artistName: album.artist,
      palette: palette,
      ...
    ),
    SizedBox(height: 16),
    ...album.tracks.map((track) => NeuTrackTile(
      title: track.title,
      artist: track.artist,
      palette: palette,
      ...
    )),
  ],
)
```

### Now Playing Bar

```dart
NeuContainer(
  palette: palette,
  child: Column(
    children: [
      NeuProgressBar(
        value: progress,
        palette: palette,
        ...
      ),
      Row(
        children: [
          NeuAudioInfoBadge(
            format: currentTrack.format,
            palette: palette,
            ...
          ),
          Spacer(),
          NeuIconButton(
            icon: Icons.skip_previous,
            palette: palette,
            ...
          ),
          NeuIconButton(
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
            palette: palette,
            ...
          ),
          NeuIconButton(
            icon: Icons.skip_next,
            palette: palette,
            ...
          ),
        ],
      ),
    ],
  ),
)
```

### Search Interface

```dart
Column(
  children: [
    NeuSearchBar(
      controller: searchController,
      palette: palette,
      ...
    ),
    SizedBox(height: 12),
    Wrap(
      spacing: 8,
      children: genres.map((genre) => NeuFilterChip(
        label: genre,
        isSelected: selectedGenres.contains(genre),
        palette: palette,
        ...
      )).toList(),
    ),
  ],
)
```

---

## Performance Tips

1. **Use const constructors** when possible
2. **Avoid rebuilding entire lists** - use ListView.builder
3. **Cache TextEditingController** instances
4. **Throttle search queries** - use debouncing
5. **Optimize images** - use cached_network_image for album art

---

## Troubleshooting

### Shadows not appearing

Ensure the container has enough space for shadows:

```dart
// Add margin to account for shadow
Container(
  margin: EdgeInsets.all(8), // Space for 6px shadow + border
  child: NeuAlbumCard(...),
)
```

### Text overflowing

Use `maxLines` and `overflow`:

```dart
Text(
  longText,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

### Colors not updating

Make sure you're passing the new palette:

```dart
// ✅ Good - palette updates trigger rebuild
setState(() {
  currentPalette = RatholeTheme.dark;
});

// Widget uses: palette: currentPalette
```
