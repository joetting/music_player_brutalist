import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neobrutalist Desktop Window Frame.
/// Features:
/// - Custom title bar with Neobrutalist square buttons.
/// - Thick borders (3px+) and hard shadows.
/// - Integrated system status and title metadata.
class NeuWindowFrame extends StatelessWidget {
  final String title;
  final RatholePalette palette;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final VoidCallback onClose;
  final Widget? leading;

  const NeuWindowFrame({
    super.key,
    required this.title,
    required this.palette,
    required this.onMinimize,
    required this.onMaximize,
    required this.onClose,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(color: palette.border, width: 3), // Explicit grid visibility
        ),
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          const SizedBox(width: 12),
          
          // App Title using Monospace for "Measurement Tool" look
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: palette.text,
              ),
            ),
          ),

          // Window Controls: Thick-bordered square buttons
          _buildWindowButton(Icons.remove, onMinimize),
          _buildWindowButton(Icons.crop_square, onMaximize),
          _buildWindowButton(Icons.close, onClose, isClose: true),
        ],
      ),
    );
  }

  Widget _buildWindowButton(IconData icon, VoidCallback onTap, {bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: palette.border, width: 2),
          ),
          // Change color on hover could be added via a Statefull widget logic
        ),
        child: Icon(
          icon,
          size: 16,
          color: isClose ? palette.error : palette.text,
        ),
      ),
    );
  }
}