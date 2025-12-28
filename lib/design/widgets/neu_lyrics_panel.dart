import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'ascii_icons.dart';

/// Neubrutalist Lyrics Panel
/// Displays synchronized or unsynchronized lyrics with timestamp highlighting
class NeuLyricsPanel extends StatefulWidget {
  final List<LyricLine> lyrics;
  final Duration currentPosition;
  final RatholePalette palette;
  final bool autoScroll;
  final Function(bool)? onAutoScrollToggle;
  final VoidCallback? onClose;
  final LyricsSource source;

  const NeuLyricsPanel({
    super.key,
    required this.lyrics,
    required this.currentPosition,
    required this.palette,
    this.autoScroll = true,
    this.onAutoScrollToggle,
    this.onClose,
    this.source = LyricsSource.none,
  });

  @override
  State<NeuLyricsPanel> createState() => _NeuLyricsPanelState();
}

class _NeuLyricsPanelState extends State<NeuLyricsPanel> {
  final ScrollController _scrollController = ScrollController();
  int? _hoveredLineIndex;
  bool _userScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      if (!_userScrolling) {
        setState(() => _userScrolling = true);
      }
    }
  }

  int? get _currentLineIndex {
    if (widget.lyrics.isEmpty) return null;
    
    for (int i = widget.lyrics.length - 1; i >= 0; i--) {
      if (widget.currentPosition >= widget.lyrics[i].timestamp) {
        return i;
      }
    }
    return null;
  }

  @override
  void didUpdateWidget(NeuLyricsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.autoScroll && 
        !_userScrolling && 
        _currentLineIndex != null &&
        widget.currentPosition != oldWidget.currentPosition) {
      _scrollToCurrentLine();
    }
  }

  void _scrollToCurrentLine() {
    if (_currentLineIndex == null) return;
    
    final targetOffset = _currentLineIndex! * 60.0; // 60 = line height
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _jumpToCurrentLine() {
    setState(() => _userScrolling = false);
    _scrollToCurrentLine();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.background,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildDiagnosticInfo(),
          Expanded(child: _buildLyricsList()),
          if (_userScrolling) _buildJumpButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          AsciiIcon(AsciiGlyph.music, size: 16, color: widget.palette.primary),
          const SizedBox(width: 8),
          Text(
            'LYRICS_VIEWER',
            style: GoogleFonts.robotoCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: widget.palette.text,
            ),
          ),
          const Spacer(),
          // Auto-scroll toggle
          GestureDetector(
            onTap: () => widget.onAutoScrollToggle?.call(!widget.autoScroll),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.autoScroll 
                    ? widget.palette.primary.withOpacity(0.2)
                    : widget.palette.surface,
                border: Border.all(
                  color: widget.autoScroll 
                      ? widget.palette.primary 
                      : widget.palette.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AsciiIcon(
                    widget.autoScroll ? AsciiGlyph.sync : AsciiGlyph.loading,
                    size: 12,
                    color: widget.palette.text,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SYNC',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.palette.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onClose,
              child: AsciiIcon(
                AsciiGlyph.close,
                size: 16,
                color: widget.palette.text.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosticInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.palette.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'SOURCE: ${widget.source.name.toUpperCase()}',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: widget.palette.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${widget.lyrics.length} LINES',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: widget.palette.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.lyrics.any((l) => l.isSynced) ? 'SYNCED' : 'UNSYNCED',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: widget.lyrics.any((l) => l.isSynced)
                  ? widget.palette.accent
                  : widget.palette.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsList() {
    if (widget.lyrics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.lyrics.length,
      itemExtent: 60,
      itemBuilder: (context, index) {
        final line = widget.lyrics[index];
        final isCurrent = _currentLineIndex == index;
        final isHovered = _hoveredLineIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredLineIndex = index),
          onExit: (_) => setState(() => _hoveredLineIndex = null),
          child: GestureDetector(
            onSecondaryTap: () => _copyLine(line.text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isCurrent
                    ? widget.palette.primary.withOpacity(0.3)
                    : isHovered
                        ? widget.palette.surface
                        : Colors.transparent,
                border: isCurrent
                    ? Border.all(color: widget.palette.primary, width: 2)
                    : Border.all(
                        color: widget.palette.border.withOpacity(0.2),
                        width: 1,
                      ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timestamp
                  if (line.isSynced)
                    SizedBox(
                      width: 60,
                      child: Text(
                        '[${_formatTimestamp(line.timestamp)}]',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.palette.text.withOpacity(0.5),
                        ),
                      ),
                    ),
                  
                  // Lyric text
                  Expanded(
                    child: Text(
                      line.text,
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: widget.palette.text,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Current line indicator
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AsciiIcon(
                        AsciiGlyph.chevronRight,
                        size: 16,
                        color: widget.palette.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AsciiIcon(
            AsciiGlyph.music,
            size: 48,
            color: widget.palette.text.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO_LYRICS_AVAILABLE',
            style: GoogleFonts.robotoCondensed(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.palette.text.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add .lrc file or embedded lyrics',
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              color: widget.palette.text.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumpButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          top: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: GestureDetector(
        onTap: _jumpToCurrentLine,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: widget.palette.accent,
            border: Border.all(color: widget.palette.border, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AsciiIcon(
                AsciiGlyph.arrowDown,
                size: 14,
                color: widget.palette.text,
              ),
              const SizedBox(width: 8),
              Text(
                'JUMP_TO_CURRENT',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _copyLine(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Model for a single lyric line
class LyricLine {
  final Duration timestamp;
  final String text;
  final bool isSynced;

  const LyricLine({
    required this.timestamp,
    required this.text,
    this.isSynced = false,
  });

  /// Parse from LRC format: [00:12.34]Lyric text
  factory LyricLine.fromLrc(String line) {
    final regex = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)');
    final match = regex.firstMatch(line);
    
    if (match != null) {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final centiseconds = int.parse(match.group(3)!);
      final text = match.group(4)!.trim();
      
      return LyricLine(
        timestamp: Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: centiseconds * 10,
        ),
        text: text,
        isSynced: true,
      );
    }
    
    // Fallback for unsynchronized lyrics
    return LyricLine(
      timestamp: Duration.zero,
      text: line.trim(),
      isSynced: false,
    );
  }
}

/// Source of lyrics data
enum LyricsSource {
  none,
  lrc,      // .lrc file
  id3,      // Embedded in audio file
  api,      // From online service
  manual,   // User-entered
}