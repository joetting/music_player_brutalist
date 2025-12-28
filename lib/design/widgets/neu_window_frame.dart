import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neobrutalist Desktop Window Frame with ASCII controls
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
          bottom: BorderSide(color: palette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          const SizedBox(width: 12),
          
          // App Title using Monospace
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: palette.text,
              ),
            ),
          ),

          // Window Controls: ASCII buttons
          _buildWindowButton('_', onMinimize), // Minimize
          _buildWindowButton('□', onMaximize), // Maximize
          _buildWindowButton('×', onClose, isClose: true), // Close
        ],
      ),
    );
  }

  Widget _buildWindowButton(String glyph, VoidCallback onTap, {bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: palette.border, width: 2),
          ),
        ),
        child: Center(
          child: Text(
            glyph,
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isClose ? palette.error : palette.text,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}