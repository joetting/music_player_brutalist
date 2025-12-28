import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neubrutalist Theme System for Music Player
/// Based on neubrutalism_ui 2.0.2 principles:
/// - Bold, contrasting colors
/// - Thick borders (2-5px)
/// - Hard shadows (5-15px offset)
/// - Flat design with depth via shadows
/// - Asymmetric layouts
/// - Oversized typography

class RatholeTheme {
  // --- COLOR PALETTES ---

  /// Classic Brutalist (Bold Primary Colors)
  static const classic = RatholePalette(
    primary: Color(0xFFFFDB00), // Bold Yellow
    secondary: Color(0xFFEC87C0), // Hot Pink
    tertiary: Color(0xFF00D4FF), // Electric Blue
    background: Color(0xFFFAFAFA), // Off-white
    surface: Color(0xFFFFFFFF), // Pure white
    error: Color(0xFFFF006E), // Vibrant red
    border: Color(0xFF000000), // Always black
    shadow: Color(0xFF000000), // Always black
    text: Color(0xFF000000), // Black text
    accent: Color(0xFF00D4FF), // Electric Blue for clickable items
  );

  /// Muted Professional (Beige/Gray/Brown)
  static const muted = RatholePalette(
    primary: Color(0xFFD4A574), // Warm beige
    secondary: Color(0xFF9CA3AF), // Cool gray
    tertiary: Color(0xFF8B7355), // Muted brown
    background: Color(0xFFF5F5F0), // Cream
    surface: Color(0xFFFFFFFF), // White
    error: Color(0xFFDC2626), // Subdued red
    border: Color(0xFF1F2937), // Dark gray
    shadow: Color(0xFF1F2937), // Dark gray
    text: Color(0xFF1F2937), // Dark gray text
    accent: Color(0xFF8B7355), // Brown for clickable items
  );

  /// Dark Mode (Neon on Black) - IMPROVED READABILITY
  static const dark = RatholePalette(
    primary: Color(0xFF00FF9F), // Neon green (primary actions)
    secondary: Color(0xFFFF00FF), // Neon magenta (secondary highlights)
    tertiary: Color(0xFF00E5FF), // Neon cyan (tertiary elements)
    background: Color(0xFF0A0A0A), // Near black
    surface: Color(0xFF1A1A1A), // Dark gray
    error: Color(0xFFFF3366), // Bright red
    border: Color(0xFF00FF9F), // Neon green borders
    shadow: Color(0xFF00FF9F), // Neon green shadows
    text: Color(0xFFFFFFFF), // White text
    accent: Color(0xFF00E5FF), // Cyan for clickable/interactive items
  );

  /// Dark Professional (Subdued Dark Mode)
  /// Better for long listening sessions - less neon, easier on eyes
  static const darkPro = RatholePalette(
    primary: Color(0xFF00D9FF), // Cyan (easier to read than yellow)
    secondary: Color(0xFFEC87C0), // Soft pink
    tertiary: Color(0xFF9CA3AF), // Gray
    background: Color(0xFF0A0A0A), // Near black
    surface: Color(0xFF1A1A1A), // Dark gray
    error: Color(0xFFFF3366), // Bright red
    border: Color(0xFF2A2A2A), // Subtle gray border
    shadow: Color(0xFF000000), // Black shadow
    text: Color(0xFFE0E0E0), // Light gray (softer than pure white)
    accent: Color(0xFF00FF9F), // Mint green for interactive elements
  );

  
  /// Synthwave (Retro Futurism)
  static const synthwave = RatholePalette(
    primary: Color(0xFFFF006E), // Hot pink
    secondary: Color(0xFF00F0FF), // Electric cyan
    tertiary: Color(0xFFFFDB00), // Yellow
    background: Color(0xFF0A0014), // Deep purple-black
    surface: Color(0xFF1A0A2E), // Dark purple
    error: Color(0xFFFF3B30), // Red
    border: Color(0xFF3F0071), // Purple border
    shadow: Color(0xFF000000), // Black shadow
    text: Color(0xFFE0E0E0), // Light gray
    accent: Color(0xFF00F0FF), // Cyan for interactive
  );

  /// CRT Green (Retro terminal)
  static const crtGreen = RatholePalette(
    primary: Color(0xFF00FF00), // Terminal green
    secondary: Color(0xFF00DD00), // Lighter green
    tertiary: Color(0xFF008800), // Darker green
    background: Color(0xFF0D1B0D), // Very dark green
    surface: Color(0xFF152015), // Dark green
    error: Color(0xFFFF0000), // Red
    border: Color(0xFF00AA00), // Green border
    shadow: Color(0xFF001100), // Very dark green shadow
    text: Color(0xFF00FF00), // Green text
    accent: Color(0xFF00DD00), // Lighter green for interactive
  );
  static const RatholePalette midnight = RatholePalette(
      primary: const Color(0xFF00FF9F),   // Mint Green for high-visibility highlights
      secondary: const Color(0xFF00D4FF), // Cyan
      tertiary: const Color(0xFF9CA3AF),  // Subdued Gray
      background: const Color(0xFF000000), // Pure Black for OLED 
      surface: const Color(0xFF121212),    // Very dark grey for cards
      error: const Color(0xFFFF003C),      // Vibrant Red
      border: const Color(0xFF262626),     // Lowered border contrast 
      shadow: Colors.transparent,          // Removed offset shadows for OLED 
      text: const Color(0xFFE0E0E0),       // Off-white for reduced strain
      accent: const Color(0xFF00FF9F),
    );
  // --- THEME DATA BUILDERS ---

  static ThemeData buildTheme(RatholePalette palette, {bool isDark = false}) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,

      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: palette.primary,
        onPrimary: palette.text,
        secondary: palette.secondary,
        onSecondary: palette.text,
        tertiary: palette.tertiary,
        onTertiary: palette.text,
        error: palette.error,
        onError: Colors.white,
        surface: palette.surface,
        onSurface: palette.text,
      ),

      scaffoldBackgroundColor: palette.background,

      // Typography
      textTheme: _buildTextTheme(palette),

      // Component Themes
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border, width: 3),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.text,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: palette.border, width: 3),
          ),
          shadowColor: palette.shadow,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.primary, width: 3),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(RatholePalette palette) {
    return TextTheme(
      // Display - For large album titles
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        color: palette.text,
        height: 1.0,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: palette.text,
        height: 1.0,
      ),

      // Headline - For screen titles
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),

      // Title - For card headers
      titleLarge: GoogleFonts.robotoCondensed(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      titleMedium: GoogleFonts.robotoCondensed(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      titleSmall: GoogleFonts.robotoCondensed(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),

      // Body - For metadata, track lists
      bodyLarge: GoogleFonts.spaceMono(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: palette.text,
      ),
      bodyMedium: GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: palette.text,
      ),

      // Label - For buttons, chips
      labelLarge: GoogleFonts.robotoCondensed(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: palette.text,
        letterSpacing: 1.2,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: palette.text.withOpacity(0.7),
      ),
    );
  }

  /// Helper: Get all available palettes
  static Map<String, RatholePalette> get allPalettes => {
        'Classic': classic,
        'Muted': muted,
        'Dark': dark,
        'Dark Pro': darkPro,
        'Synthwave': synthwave,
        'CRT Green': crtGreen,
        'Midnight': midnight,
      };
}

/// Color palette definition
class RatholePalette {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color error;
  final Color border;
  final Color shadow;
  final Color text;
  final Color accent;

  const RatholePalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.error,
    required this.border,
    required this.shadow,
    required this.text,
    required this.accent,
  });
}

/// Extension for shadow creation
extension NeubrutalistShadow on Widget {
  Widget withNeuShadow({
    required Color shadowColor,
    double offsetX = 6,
    double offsetY = 6,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(offsetX, offsetY),
            blurRadius: 0, // Hard shadow, no blur
          ),
        ],
      ),
      child: this,
    );
  }
}

/// Audio quality color coding
class AudioQualityColors {
  static Color forSampleRate(int sampleRate) {
    if (sampleRate >= 192000) {
      return const Color(0xFF00FF9F); // DSD/Hi-Res - Mint green
    }
    if (sampleRate >= 96000) {
      return const Color(0xFF00D4FF); // Hi-Res - Cyan
    }
    if (sampleRate >= 48000) {
      return const Color(0xFFFFB000); // CD+ - Amber
    }
    return const Color(0xFF9CA3AF); // Standard/Lossy - Gray
  }

  static Color forBitrate(int bitrate) {
    if (bitrate >= 320000) return const Color(0xFF00FF9F); // High quality
    if (bitrate >= 192000) return const Color(0xFF00D4FF); // Medium-high
    if (bitrate >= 128000) return const Color(0xFFFFB000); // Medium
    return const Color(0xFF9CA3AF); // Low
  }

  static Color forFormat(String format) {
    final lowerFormat = format.toLowerCase();
    if (lowerFormat.contains('flac') || lowerFormat.contains('wav')) {
      return const Color(0xFF00FF9F); // Lossless
    } else if (lowerFormat.contains('alac') || lowerFormat.contains('ape')) {
      return const Color(0xFF00D4FF); // Lossless compressed
    } else if (lowerFormat.contains('mp3') || lowerFormat.contains('aac')) {
      return const Color(0xFFFFB000); // Lossy
    }
    return const Color(0xFF9CA3AF); // Unknown
  }

  static String qualityLabel(int sampleRate, int bitDepth) {
    if (sampleRate >= 192000) {
      return "Hi-Res ${sampleRate ~/ 1000}kHz/$bitDepth-bit";
    }
    if (sampleRate >= 96000) {
      return "Hi-Res ${sampleRate ~/ 1000}kHz/$bitDepth-bit";
    }
    if (sampleRate >= 48000) {
      return "CD+ ${sampleRate ~/ 1000}kHz/$bitDepth-bit";
    }
    return "${sampleRate ~/ 1000}kHz/$bitDepth-bit";
  }
}