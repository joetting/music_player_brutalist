import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/../design/theme/app_theme.dart';
import '/../design/widgets/ascii_icons.dart';
import '/../keyboard_shortcuts.dart';

/// Brutalist Keyboard Shortcuts Reference Panel
/// Shows all available shortcuts in a categorized view
class NeuKeyboardShortcutsPanel extends StatelessWidget {
  final KeyboardShortcutManager manager;
  final RatholePalette palette;
  final VoidCallback? onEdit;

  const NeuKeyboardShortcutsPanel({
    super.key,
    required this.manager,
    required this.palette,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final categories = manager.categories;

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(
                bottom: BorderSide(color: palette.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                AsciiIcon(
                  AsciiGlyph.key,
                  size: 20,
                  color: palette.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'KEYBOARD_SHORTCUTS',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: palette.text,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.primary,
                        border: Border.all(color: palette.border, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AsciiIcon(
                            AsciiGlyph.edit,
                            size: 14,
                            color: palette.text,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EDIT',
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: palette.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Shortcuts by category
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategorySection(categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final shortcuts = manager.getByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 24),
          child: Text(
            category.toUpperCase(),
            style: GoogleFonts.robotoCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: palette.text.withValues(alpha: 0.6),
            ),
          ),
        ),

        // Shortcuts in category
        ...shortcuts.map((shortcut) => _buildShortcutRow(shortcut)),
      ],
    );
  }

  Widget _buildShortcutRow(KeyboardShortcut shortcut) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              shortcut.label,
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: palette.text,
              ),
            ),
          ),
          _buildKeyBadge(shortcut.keysString),
        ],
      ),
    );
  }

  Widget _buildKeyBadge(String keys) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.2),
        border: Border.all(color: palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        keys,
        style: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
    );
  }
}

/// Brutalist Keyboard Shortcut Editor Dialog
class NeuKeyboardShortcutEditor extends StatefulWidget {
  final KeyboardShortcutManager manager;
  final RatholePalette palette;
  final Function(KeyboardShortcutManager) onSave;

  const NeuKeyboardShortcutEditor({
    super.key,
    required this.manager,
    required this.palette,
    required this.onSave,
  });

  @override
  State<NeuKeyboardShortcutEditor> createState() => _NeuKeyboardShortcutEditorState();
}

class _NeuKeyboardShortcutEditorState extends State<NeuKeyboardShortcutEditor> {
  String? _editingId;
  final Set<LogicalKeyboardKey> _recordedKeys = {};
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final categories = widget.manager.categories;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        height: 600,
        decoration: BoxDecoration(
          color: widget.palette.background,
          border: Border.all(color: widget.palette.border, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.palette.shadow,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),

            // Shortcuts list
            Expanded(
              child: Focus(
                focusNode: _focusNode,
                onKeyEvent: (node, event) {
                  _handleKeyEvent(event);
                  return KeyEventResult.handled;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategorySection(categories[index]);
                  },
                ),
              ),
            ),

            // Footer buttons
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          AsciiIcon(
            AsciiGlyph.edit,
            size: 20,
            color: widget.palette.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'EDIT_KEYBOARD_SHORTCUTS',
            style: GoogleFonts.robotoCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: widget.palette.text,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: AsciiIcon(
              AsciiGlyph.close,
              size: 18,
              color: widget.palette.text.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final shortcuts = widget.manager.getByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 16),
          child: Text(
            category.toUpperCase(),
            style: GoogleFonts.robotoCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: widget.palette.text.withValues(alpha: 0.6),
            ),
          ),
        ),
        ...shortcuts.map((shortcut) => _buildEditableRow(shortcut)),
      ],
    );
  }

  Widget _buildEditableRow(KeyboardShortcut shortcut) {
    final isEditing = _editingId == shortcut.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEditing
            ? widget.palette.primary.withValues(alpha: 0.1)
            : widget.palette.surface,
        border: Border.all(
          color: isEditing ? widget.palette.primary : widget.palette.border,
          width: isEditing ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              shortcut.label,
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: widget.palette.text,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _editingId = shortcut.id;
                  _recordedKeys.clear();
                });
                _focusNode.requestFocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isEditing
                      ? widget.palette.accent.withValues(alpha: 0.2)
                      : widget.palette.background,
                  border: Border.all(
                    color: widget.palette.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isEditing
                      ? (_recordedKeys.isEmpty
                          ? 'Press keys...'
                          : _getKeysString(_recordedKeys))
                      : shortcut.keysString,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.palette.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                shortcut.resetToDefault();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.palette.tertiary.withValues(alpha: 0.2),
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: AsciiIcon(
                AsciiGlyph.sync,
                size: 14,
                color: widget.palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          top: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Reset all button
          GestureDetector(
            onTap: () {
              setState(() {
                widget.manager.resetAll();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: widget.palette.error.withValues(alpha: 0.2),
                border: Border.all(color: widget.palette.error, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'RESET_ALL',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.palette.error,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Cancel button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: widget.palette.surface,
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CANCEL',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.palette.text,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save button
          GestureDetector(
            onTap: () {
              widget.onSave(widget.manager);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: widget.palette.primary,
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: widget.palette.shadow,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'SAVE',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.palette.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (_editingId == null) return;
    if (event is! KeyDownEvent) return;

    setState(() {
      // Add modifier keys from HardwareKeyboard
      if (HardwareKeyboard.instance.isControlPressed) {
        _recordedKeys.add(LogicalKeyboardKey.control);
      }
      if (HardwareKeyboard.instance.isShiftPressed) {
        _recordedKeys.add(LogicalKeyboardKey.shift);
      }
      if (HardwareKeyboard.instance.isAltPressed) {
        _recordedKeys.add(LogicalKeyboardKey.alt);
      }
      if (HardwareKeyboard.instance.isMetaPressed) {
        _recordedKeys.add(LogicalKeyboardKey.meta);
      }

      // Add the main key
      final key = event.logicalKey;
      if (key != LogicalKeyboardKey.control &&
          key != LogicalKeyboardKey.shift &&
          key != LogicalKeyboardKey.alt &&
          key != LogicalKeyboardKey.meta) {
        _recordedKeys.add(key);

        // Finalize the binding
        final newKeys = LogicalKeySet.fromSet(_recordedKeys);
        final conflicts = widget.manager.findConflicts(
          newKeys,
          excludeId: _editingId,
        );

        if (conflicts.isEmpty) {
          final shortcut = widget.manager.shortcuts
              .firstWhere((s) => s.id == _editingId);
          shortcut.currentKeys = newKeys;
          _editingId = null;
          _recordedKeys.clear();
        } else {
          // Show conflict warning
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Conflict with: ${conflicts.first.label}',
                style: GoogleFonts.spaceMono(fontSize: 12),
              ),
              backgroundColor: widget.palette.error,
              duration: const Duration(seconds: 2),
            ),
          );
          _recordedKeys.clear();
        }
      }
    });
  }

  String _getKeysString(Set<LogicalKeyboardKey> keys) {
    final parts = <String>[];

    if (keys.contains(LogicalKeyboardKey.control)) {
      parts.add('Ctrl');
    }
    if (keys.contains(LogicalKeyboardKey.shift)) {
      parts.add('Shift');
    }
    if (keys.contains(LogicalKeyboardKey.alt)) {
      parts.add('Alt');
    }
    if (keys.contains(LogicalKeyboardKey.meta)) {
      parts.add('Meta');
    }

    for (final key in keys) {
      if (key != LogicalKeyboardKey.control &&
          key != LogicalKeyboardKey.shift &&
          key != LogicalKeyboardKey.alt &&
          key != LogicalKeyboardKey.meta) {
        parts.add(key.keyLabel.toUpperCase());
      }
    }

    return parts.join(' + ');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}