import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neobrutalist System Tray Context Menu
/// Provides global access to playback and library scanning.
class NeuSystemTrayMenu extends StatelessWidget {
  final bool isPlaying;
  final String currentTrack;
  final RatholePalette palette;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;
  final VoidCallback onQuit;

  const NeuSystemTrayMenu({
    super.key,
    required this.isPlaying,
    required this.currentTrack,
    required this.palette,
    required this.onTogglePlay,
    required this.onNext,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoItem(),
          const Divider(height: 1, thickness: 2, color: Colors.black),
          _buildMenuItem(isPlaying ? 'PAUSE' : 'PLAY', Icons.play_arrow, onTogglePlay),
          _buildMenuItem('NEXT_TRACK', Icons.skip_next, onNext),
          const Divider(height: 1, thickness: 2, color: Colors.black),
          _buildMenuItem('EXIT_PLAYER', Icons.power_settings_new, onQuit, isError: true),
        ],
      ),
    );
  }

  Widget _buildInfoItem() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'NOW_PLAYING:\n$currentTrack',
        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuItem(String label, IconData icon, VoidCallback onTap, {bool isError = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isError ? palette.error : palette.text),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isError ? palette.error : palette.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}