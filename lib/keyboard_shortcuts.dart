import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Keyboard Shortcuts System for Brutalist Music Player
/// 
/// Provides:
/// - Global keyboard shortcut handling
/// - Customizable key bindings
/// - Visual shortcut reference UI
/// - Conflict detection
/// - Platform-specific defaults (Ctrl vs Cmd)

/// Represents a single keyboard shortcut
class KeyboardShortcut {
  final String id;
  final String label;
  final String category;
  final LogicalKeySet defaultKeys;
  LogicalKeySet currentKeys;
  final VoidCallback action;

  KeyboardShortcut({
    required this.id,
    required this.label,
    required this.category,
    required this.defaultKeys,
    LogicalKeySet? customKeys,
    required this.action,
  }) : currentKeys = customKeys ?? defaultKeys;

  /// Check if this shortcut matches the given key event
  bool matches(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    
    final pressed = <LogicalKeyboardKey>{};
    if (HardwareKeyboard.instance.isControlPressed) pressed.add(LogicalKeyboardKey.control);
    if (HardwareKeyboard.instance.isShiftPressed) pressed.add(LogicalKeyboardKey.shift);
    if (HardwareKeyboard.instance.isAltPressed) pressed.add(LogicalKeyboardKey.alt);
    if (HardwareKeyboard.instance.isMetaPressed) pressed.add(LogicalKeyboardKey.meta);
    
    pressed.add(event.logicalKey);
    
    return currentKeys.keys.length == pressed.length &&
           currentKeys.keys.every((k) => pressed.contains(k));
  }

  /// Reset to default key binding
  void resetToDefault() {
    currentKeys = defaultKeys;
  }

  /// Get human-readable string representation
  String get keysString {
    final parts = <String>[];
    
    for (final key in currentKeys.keys) {
      if (key == LogicalKeyboardKey.control) {
        parts.add('Ctrl');
      } else if (key == LogicalKeyboardKey.shift) {
        parts.add('Shift');
      } else if (key == LogicalKeyboardKey.alt) {
        parts.add('Alt');
      } else if (key == LogicalKeyboardKey.meta) {
        parts.add('Meta');
      } else {
        parts.add(key.keyLabel.toUpperCase());
      }
    }
    
    return parts.join(' + ');
  }
}

/// Manager for all keyboard shortcuts
class KeyboardShortcutManager {
  static final KeyboardShortcutManager _instance = KeyboardShortcutManager._internal();
  factory KeyboardShortcutManager() => _instance;
  KeyboardShortcutManager._internal();

  final Map<String, KeyboardShortcut> _shortcuts = {};
  bool _enabled = true;

  /// Register a new shortcut
  void register(KeyboardShortcut shortcut) {
    _shortcuts[shortcut.id] = shortcut;
  }

  /// Unregister a shortcut
  void unregister(String id) {
    _shortcuts.remove(id);
  }

  /// Handle key event
  bool handleKeyEvent(KeyEvent event) {
    if (!_enabled) return false;
    
    for (final shortcut in _shortcuts.values) {
      if (shortcut.matches(event)) {
        shortcut.action();
        return true;
      }
    }
    
    return false;
  }

  /// Get all shortcuts
  List<KeyboardShortcut> get shortcuts => _shortcuts.values.toList();

  /// Get shortcuts by category
  List<KeyboardShortcut> getByCategory(String category) {
    return _shortcuts.values
        .where((s) => s.category == category)
        .toList();
  }

  /// Get all categories
  List<String> get categories {
    return _shortcuts.values
        .map((s) => s.category)
        .toSet()
        .toList()
      ..sort();
  }

  /// Check for conflicts with a new key binding
  List<KeyboardShortcut> findConflicts(LogicalKeySet keys, {String? excludeId}) {
    return _shortcuts.values
        .where((s) => s.id != excludeId && s.currentKeys == keys)
        .toList();
  }

  /// Reset all shortcuts to defaults
  void resetAll() {
    for (final shortcut in _shortcuts.values) {
      shortcut.resetToDefault();
    }
  }

  /// Enable/disable all shortcuts
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Load custom bindings from storage (placeholder)
  Future<void> loadCustomBindings() async {
    // TODO: Implement persistent storage
  }

  /// Save custom bindings to storage (placeholder)
  Future<void> saveCustomBindings() async {
    // TODO: Implement persistent storage
  }
}

/// Widget that handles keyboard shortcuts for its descendants
class KeyboardShortcutHandler extends StatefulWidget {
  final Widget child;
  final KeyboardShortcutManager? manager;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    this.manager,
  });

  @override
  State<KeyboardShortcutHandler> createState() => _KeyboardShortcutHandlerState();
}

class _KeyboardShortcutHandlerState extends State<KeyboardShortcutHandler> {
  late final KeyboardShortcutManager _manager;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _manager = widget.manager ?? KeyboardShortcutManager();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (_manager.handleKeyEvent(event)) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

/// Helper to create default shortcuts for music player
class MusicPlayerShortcuts {
  static void registerDefaults(KeyboardShortcutManager manager, {
    required VoidCallback onPlayPause,
    required VoidCallback onNext,
    required VoidCallback onPrevious,
    required VoidCallback onVolumeUp,
    required VoidCallback onVolumeDown,
    required VoidCallback onMute,
    required VoidCallback onShuffle,
    required VoidCallback onRepeat,
    required VoidCallback onSearch,
    required VoidCallback onQueue,
    required VoidCallback onDiagnostics,
    required VoidCallback onSettings,
  }) {
    // Playback
    manager.register(KeyboardShortcut(
      id: 'play_pause',
      label: 'Play/Pause',
      category: 'Playback',
      defaultKeys: LogicalKeySet(LogicalKeyboardKey.space),
      action: onPlayPause,
    ));

    manager.register(KeyboardShortcut(
      id: 'next_track',
      label: 'Next Track',
      category: 'Playback',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.arrowRight,
      ),
      action: onNext,
    ));

    manager.register(KeyboardShortcut(
      id: 'previous_track',
      label: 'Previous Track',
      category: 'Playback',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.arrowLeft,
      ),
      action: onPrevious,
    ));

    // Volume
    manager.register(KeyboardShortcut(
      id: 'volume_up',
      label: 'Volume Up',
      category: 'Volume',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.arrowUp,
      ),
      action: onVolumeUp,
    ));

    manager.register(KeyboardShortcut(
      id: 'volume_down',
      label: 'Volume Down',
      category: 'Volume',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.arrowDown,
      ),
      action: onVolumeDown,
    ));

    manager.register(KeyboardShortcut(
      id: 'mute',
      label: 'Mute',
      category: 'Volume',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyM,
      ),
      action: onMute,
    ));

    // Playback modes
    manager.register(KeyboardShortcut(
      id: 'shuffle',
      label: 'Toggle Shuffle',
      category: 'Playback',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyS,
      ),
      action: onShuffle,
    ));

    manager.register(KeyboardShortcut(
      id: 'repeat',
      label: 'Toggle Repeat',
      category: 'Playback',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyR,
      ),
      action: onRepeat,
    ));

    // Navigation
    manager.register(KeyboardShortcut(
      id: 'search',
      label: 'Search Library',
      category: 'Navigation',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyF,
      ),
      action: onSearch,
    ));

    manager.register(KeyboardShortcut(
      id: 'queue',
      label: 'Show Queue',
      category: 'Navigation',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyQ,
      ),
      action: onQueue,
    ));

    manager.register(KeyboardShortcut(
      id: 'diagnostics',
      label: 'Audio Diagnostics',
      category: 'Navigation',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyD,
      ),
      action: onDiagnostics,
    ));

    manager.register(KeyboardShortcut(
      id: 'settings',
      label: 'Settings',
      category: 'Navigation',
      defaultKeys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.comma,
      ),
      action: onSettings,
    ));
  }
}