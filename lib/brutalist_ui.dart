/// Brutalist Music Player Component Library
/// 
/// A complete neubrutalist UI component library for Flutter music players.
/// Features bold borders, hard shadows, and uncompromising visual design.
/// 
/// Usage:
/// ```dart
/// import 'package:music_player_brutalist/brutalist_ui.dart';
/// 
/// final palette = RatholeTheme.classic;
/// NeuAlbumCard(palette: palette, ...);
/// ```

library brutalist_ui;

// Theme System
export 'design/theme/app_theme.dart';

// Music Components
export 'design/widgets/neu_album_card.dart';
export 'design/widgets/neu_track_tile.dart';

// Controls
export 'design/widgets/neu_button.dart';
export 'design/widgets/neu_slider.dart';
export 'design/widgets/neu_progress_bar.dart';

// Search & Filters
export 'design/widgets/neu_search_bar.dart';

// Audio Diagnostics
export 'design/widgets/neu_spectrogram.dart';

// Layout Components
export 'design/widgets/neu_container.dart';
