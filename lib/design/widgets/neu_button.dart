import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Button
/// Features:
/// - Hard shadows
/// - Bold borders
/// - Press animation (shadow reduces on tap)
/// - Customizable colors
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final RatholePalette palette;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool enabled;

  const NeuButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.palette,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.enabled = true,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? widget.palette.primary;
    final borderCol = widget.borderColor ?? widget.palette.border;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.enabled
              ? bgColor
              : bgColor.withOpacity(0.5),
          border: Border.all(color: borderCol, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (!_isPressed && widget.enabled)
              BoxShadow(
                color: widget.palette.shadow,
                offset: const Offset(6, 6),
                blurRadius: 0,
              ),
          ],
        ),
        transform: Matrix4.translationValues(
          _isPressed ? 6 : 0,
          _isPressed ? 6 : 0,
          0,
        ),
        child: DefaultTextStyle(
          style: GoogleFonts.robotoCondensed(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: widget.palette.text,
          ),
          textAlign: TextAlign.center,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Icon button variant
class NeuIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final RatholePalette palette;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool enabled;

  const NeuIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.palette,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.enabled = true,
  });

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? widget.palette.primary;
    final icColor = widget.iconColor ?? widget.palette.text;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.enabled ? bgColor : bgColor.withOpacity(0.5),
          border: Border.all(color: widget.palette.border, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (!_isPressed && widget.enabled)
              BoxShadow(
                color: widget.palette.shadow,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
          ],
        ),
        transform: Matrix4.translationValues(
          _isPressed ? 4 : 0,
          _isPressed ? 4 : 0,
          0,
        ),
        child: Icon(
          widget.icon,
          color: icColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
