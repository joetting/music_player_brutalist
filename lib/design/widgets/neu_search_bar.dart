import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Search Bar
/// Features:
/// - Bold borders
/// - Hard shadow
/// - Clear button
/// - Focus state indication
class NeuSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final RatholePalette palette;
  final FocusNode? focusNode;

  const NeuSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    required this.palette,
    this.focusNode,
  });

  @override
  State<NeuSearchBar> createState() => _NeuSearchBarState();
}

class _NeuSearchBarState extends State<NeuSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _onTextChange() {
    if (mounted) {
      final hasText = widget.controller.text.isNotEmpty;
      if (_hasText != hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(
          color: _isFocused ? widget.palette.primary : widget.palette.border,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? widget.palette.primary
                : widget.palette.shadow,
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Icons.search,
              color: _isFocused
                  ? widget.palette.primary
                  : widget.palette.text.withOpacity(0.5),
              size: 24,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                color: widget.palette.text,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.spaceMono(
                  fontSize: 14,
                  color: widget.palette.text.withOpacity(0.4),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Clear button
          if (_hasText)
            IconButton(
              icon: Icon(
                Icons.close,
                color: widget.palette.text.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                widget.controller.clear();
                if (widget.onClear != null) {
                  widget.onClear!();
                }
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Compact filter chip for genres, years, etc.
class NeuFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final RatholePalette palette;
  final IconData? icon;

  const NeuFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.palette,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary
              : palette.surface,
          border: Border.all(
            color: isSelected ? palette.border : palette.border.withOpacity(0.5),
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: palette.shadow,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: palette.text,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.robotoCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 14,
                color: palette.text,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
