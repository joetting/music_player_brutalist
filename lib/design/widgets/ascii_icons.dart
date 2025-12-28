import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ASCII-based icon replacement for Neobrutalist aesthetic
/// Uses monospace glyphs instead of Material Icons for "measurement tool" look
class AsciiIcon extends StatelessWidget {
  final AsciiGlyph glyph;
  final double size;
  final Color? color;
  final FontWeight fontWeight;

  const AsciiIcon(
    this.glyph, {
    super.key,
    this.size = 16,
    this.color,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      glyph.char,
      style: GoogleFonts.spaceMono(
        fontSize: size,
        color: color ?? Theme.of(context).iconTheme.color,
        fontWeight: fontWeight,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// ASCII glyphs for all common music player icons
enum AsciiGlyph {
  // Playback controls
  play('▶'),
  pause('||'),
  stop('■'),
  skipNext('>>'),
  skipPrevious('<<'),
  fastForward('>>>'),
  rewind('<<<'),
  
  // Media library
  album('◉'),
  music('♪'),
  musicNote('♫'),
  folder('[/]'),
  folderOpen('[-]'),
  folderClosed('[+]'),
  file('⎕'),
  playlist('≡'),
  
  // Actions
  add('[+]'),
  remove('[-]'),
  close('[×]'),
  check('[✓]'),
  error('[!]'),
  info('[i]'),
  
  // Navigation
  home('⌂'),
  search('[?]'),
  settings('⚙'),
  menu('≡'),
  more('···'),
  chevronRight('>'),
  chevronLeft('<'),
  chevronDown('v'),
  chevronUp('^'),
  arrowRight('→'),
  arrowLeft('←'),
  arrowDown('↓'),
  arrowUp('↑'),
  
  // Playback states
  shuffle('⇄'),
  shuffleOn('[⇄]'),
  repeat('↻'),
  repeatOn('[↻]'),
  repeatOne('[1]'),
  
  // Volume
  volumeUp('♪+'),
  volumeDown('♪-'),
  volumeMute('[♪]'),
  
  // Window controls
  minimize('_'),
  maximize('□'),
  restore('⊡'),
  
  // Media types
  headphones('⊗'),
  speaker('♪♪'),
  microphone('Ɨ'),
  
  // Queue/List
  queueMusic('≣'),
  listView('≡'),
  gridView('⊞'),
  
  // Social/Share
  share('⇱'),
  link('∞'),
  
  // Edit/Modify
  edit('[✎]'),
  delete('[⌦]'),
  copy('[⊕]'),
  paste('[⊞]'),
  
  // Status
  online('●'),
  offline('○'),
  loading('⟳'),
  sync('⇅'),
  
  // Rating
  star('★'),
  starOutline('☆'),
  heart('♥'),
  heartOutline('♡'),
  
  // Library organization
  artist('[A]'),
  genre('[G]'),
  year('[Y]'),
  
  // Audio quality
  highQuality('[HQ]'),
  lossless('[∞]'),
  exclusive('[⚡]'),
  bitPerfect('[◆]'),
  
  // Other
  lock('[L]'),
  unlock('[U]'),
  key('[K]'),
  bolt('⚡'),
  terminal('\$'),
  graphicEq('▓▒░');

  final String char;
  const AsciiGlyph(this.char);
}

/// Helper widget to easily use ASCII icons in place of Material Icons
class AsciiIconButton extends StatelessWidget {
  final AsciiGlyph glyph;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final EdgeInsets padding;

  const AsciiIconButton({
    super.key,
    required this.glyph,
    required this.onPressed,
    this.size = 24,
    this.color,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: padding,
        child: AsciiIcon(
          glyph,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

/// Extension to easily convert Material Icons to ASCII
extension MaterialToAscii on IconData {
  /// Get ASCII equivalent glyph for common Material Icons
  AsciiGlyph? toAscii() {
    // Map common Material Icons codepoints to ASCII equivalents
    switch (codePoint) {
      // Playback
      case 0xe037: return AsciiGlyph.play; // play_arrow
      case 0xe034: return AsciiGlyph.pause; // pause
      case 0xe047: return AsciiGlyph.stop; // stop
      case 0xe044: return AsciiGlyph.skipNext; // skip_next
      case 0xe045: return AsciiGlyph.skipPrevious; // skip_previous
      
      // Library
      case 0xe019: return AsciiGlyph.album; // album
      case 0xe405: return AsciiGlyph.music; // music_note
      case 0xe2c7: return AsciiGlyph.folder; // folder
      case 0xe2c8: return AsciiGlyph.folderOpen; // folder_open
      case 0xe3a8: return AsciiGlyph.playlist; // playlist_play
      
      // Navigation
      case 0xe88a: return AsciiGlyph.home; // home
      case 0xe8b6: return AsciiGlyph.search; // search
      case 0xe8b8: return AsciiGlyph.settings; // settings
      case 0xe5d2: return AsciiGlyph.menu; // menu
      case 0xe5d4: return AsciiGlyph.more; // more_vert
      
      // Actions
      case 0xe145: return AsciiGlyph.add; // add
      case 0xe15b: return AsciiGlyph.close; // close
      case 0xe5ca: return AsciiGlyph.check; // check
      
      // Arrows
      case 0xe5c8: return AsciiGlyph.chevronRight; // chevron_right
      case 0xe5c4: return AsciiGlyph.chevronLeft; // chevron_left
      
      // Volume
      case 0xe050: return AsciiGlyph.volumeUp; // volume_up
      case 0xe04d: return AsciiGlyph.volumeDown; // volume_down
      
      // Other
      case 0xe8fd: return AsciiGlyph.shuffle; // shuffle
      case 0xe040: return AsciiGlyph.repeat; // repeat
      case 0xe322: return AsciiGlyph.headphones; // headphones
      case 0xe3a3: return AsciiGlyph.queueMusic; // queue_music
      
      default: return null;
    }
  }
}