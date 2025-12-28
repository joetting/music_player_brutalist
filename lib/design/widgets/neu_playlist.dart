import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Playlist sidebar for managing multiple playlists
class NeuPlaylistSidebar extends StatelessWidget {
  final List<Playlist> playlists;
  final Playlist? selectedPlaylist;
  final Function(Playlist) onPlaylistSelected;
  final Function() onCreatePlaylist;
  final Function(Playlist)? onDeletePlaylist;
  final RatholePalette palette;

  const NeuPlaylistSidebar({
    super.key,
    required this.playlists,
    this.selectedPlaylist,
    required this.onPlaylistSelected,
    required this.onCreatePlaylist,
    this.onDeletePlaylist,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(
                bottom: BorderSide(color: palette.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'PLAYLISTS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCreatePlaylist,
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: palette.primary,
                  ),
                ),
              ],
            ),
          ),

          // Playlist list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final isSelected = selectedPlaylist?.id == playlist.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => onPlaylistSelected(playlist),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.primary.withOpacity(0.2)
                            : null,
                        border: isSelected
                            ? Border.all(color: palette.primary, width: 2)
                            : Border.all(
                                color: palette.border.withOpacity(0.3),
                                width: 1,
                              ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            playlist.isSmartPlaylist
                                ? Icons.auto_awesome
                                : Icons.playlist_play,
                            size: 16,
                            color: playlist.isSmartPlaylist
                                ? palette.accent
                                : palette.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.name,
                                  style: GoogleFonts.robotoCondensed(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: palette.text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${playlist.trackCount} tracks',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 10,
                                    color: palette.text.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onDeletePlaylist != null && !playlist.isDefault)
                            GestureDetector(
                              onTap: () => onDeletePlaylist!(playlist),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: palette.text.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Queue/Now Playing view
class NeuQueueView extends StatelessWidget {
  final List<QueueTrack> queue;
  final int? currentTrackIndex;
  final Function(int) onTrackTap;
  final Function(int, int) onReorder;
  final RatholePalette palette;

  const NeuQueueView({
    super.key,
    required this.queue,
    this.currentTrackIndex,
    required this.onTrackTap,
    required this.onReorder,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(
                bottom: BorderSide(color: palette.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'QUEUE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: palette.text,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${queue.length} tracks',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: palette.text.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Queue list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: queue.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final track = queue[index];
                final isCurrent = currentTrackIndex == index;

                return Padding(
                  key: ValueKey(track.id),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => onTrackTap(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? palette.primary.withOpacity(0.2)
                            : palette.surface,
                        border: Border.all(
                          color: isCurrent
                              ? palette.primary
                              : palette.border.withOpacity(0.3),
                          width: isCurrent ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          // Position indicator
                          SizedBox(
                            width: 24,
                            child: isCurrent
                                ? Icon(
                                    Icons.graphic_eq,
                                    size: 16,
                                    color: palette.primary,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 11,
                                      color: palette.text.withOpacity(0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),

                          const SizedBox(width: 8),

                          // Track info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: GoogleFonts.robotoCondensed(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: palette.text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  track.artist,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    color: palette.text.withOpacity(0.6),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Duration
                          Text(
                            track.duration,
                            style: GoogleFonts.spaceMono(
                              fontSize: 11,
                              color: palette.text.withOpacity(0.5),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Drag handle
                          Icon(
                            Icons.drag_handle,
                            size: 16,
                            color: palette.text.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Smart playlist builder dialog
class NeuSmartPlaylistBuilder extends StatefulWidget {
  final RatholePalette palette;
  final Function(SmartPlaylistRule) onSave;

  const NeuSmartPlaylistBuilder({
    super.key,
    required this.palette,
    required this.onSave,
  });

  @override
  State<NeuSmartPlaylistBuilder> createState() =>
      _NeuSmartPlaylistBuilderState();
}

class _NeuSmartPlaylistBuilderState extends State<NeuSmartPlaylistBuilder> {
  final List<PlaylistCondition> _conditions = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.palette.background,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'CREATE SMART PLAYLIST',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: widget.palette.text,
            ),
          ),
          const SizedBox(height: 16),

          // Playlist name
          TextField(
            controller: _nameController,
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              color: widget.palette.text,
            ),
            decoration: InputDecoration(
              labelText: 'Playlist Name',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.palette.border,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Conditions
          Text(
            'CONDITIONS:',
            style: GoogleFonts.robotoCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: widget.palette.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),

          // Condition list
          ..._conditions.map((condition) => _buildConditionRow(condition)),

          const SizedBox(height: 8),

          // Add condition button
          GestureDetector(
            onTap: _addCondition,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.palette.border.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: widget.palette.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Condition',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.palette.primary,
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

  Widget _buildConditionRow(PlaylistCondition condition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(color: widget.palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${condition.field} ${condition.operator} ${condition.value}',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: widget.palette.text,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _conditions.remove(condition);
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: widget.palette.error,
            ),
          ),
        ],
      ),
    );
  }

  void _addCondition() {
    setState(() {
      _conditions.add(PlaylistCondition(
        field: 'Genre',
        operator: 'is',
        value: 'Rock',
      ));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

/// Models
class Playlist {
  final String id;
  final String name;
  final int trackCount;
  final bool isSmartPlaylist;
  final bool isDefault;

  const Playlist({
    required this.id,
    required this.name,
    required this.trackCount,
    this.isSmartPlaylist = false,
    this.isDefault = false,
  });
}

class QueueTrack {
  final String id;
  final String title;
  final String artist;
  final String duration;

  const QueueTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
  });
}

class SmartPlaylistRule {
  final String name;
  final List<PlaylistCondition> conditions;

  const SmartPlaylistRule({
    required this.name,
    required this.conditions,
  });
}

class PlaylistCondition {
  final String field;
  final String operator;
  final String value;

  const PlaylistCondition({
    required this.field,
    required this.operator,
    required this.value,
  });
}
