import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'neu_data_grid.dart';
import 'ascii_icons.dart';
import 'neu_button.dart';
import 'neu_container.dart';

/// Neubrutalist Column Editor for Data Grid
/// 
/// Features:
/// - Drag and drop reordering
/// - Show/hide columns
/// - Adjust column width (flex values)
/// - Save/load column presets
/// - Reset to defaults

class NeuColumnEditor extends StatefulWidget {
  final List<GridColumn> initialColumns;
  final List<ColumnPreset> presets;
  final Function(List<GridColumn>) onColumnsChanged;
  final VoidCallback onClose;
  final RatholePalette palette;

  const NeuColumnEditor({
    super.key,
    required this.initialColumns,
    required this.presets,
    required this.onColumnsChanged,
    required this.onClose,
    required this.palette,
  });

  @override
  State<NeuColumnEditor> createState() => _NeuColumnEditorState();
}

class _NeuColumnEditorState extends State<NeuColumnEditor> {
  late List<EditableColumn> _columns;
  final TextEditingController _presetNameController = TextEditingController();
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _columns = widget.initialColumns
        .map((col) => EditableColumn.fromGridColumn(col))
        .toList();
  }

  void _applyPreset(ColumnPreset preset) {
    setState(() {
      _columns = preset.columns
          .map((col) => EditableColumn.fromGridColumn(col))
          .toList();
      _selectedPreset = preset.name;
    });
  }

  void _savePreset() {
    if (_presetNameController.text.isEmpty) return;

    final preset = ColumnPreset(
      name: _presetNameController.text,
      columns: _columns.map((col) => col.toGridColumn()).toList(),
    );

    // In real app, save to storage here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset "${preset.name}" saved!'),
        duration: const Duration(seconds: 2),
      ),
    );

    _presetNameController.clear();
  }

  void _resetToDefaults() {
    setState(() {
      _columns = widget.initialColumns
          .map((col) => EditableColumn.fromGridColumn(col))
          .toList();
      _selectedPreset = null;
    });
  }

  void _applyChanges() {
    final gridColumns = _columns
        .where((col) => col.isVisible)
        .map((col) => col.toGridColumn())
        .toList();
    widget.onColumnsChanged(gridColumns);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 900,
          height: 700,
          decoration: BoxDecoration(
            color: widget.palette.background,
            border: Border.all(color: widget.palette.border, width: 4),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.palette.shadow,
                offset: const Offset(12, 12),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildPresetSelector(),
              Expanded(child: _buildColumnList()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          AsciiIcon(
            AsciiGlyph.listView,
            size: 32,
            color: widget.palette.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLUMN EDITOR',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: widget.palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your data grid layout',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: widget.palette.text.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.palette.error.withOpacity(0.2),
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AsciiIcon(
                AsciiGlyph.close,
                size: 20,
                color: widget.palette.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          bottom: BorderSide(color: widget.palette.border, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PRESETS',
            style: GoogleFonts.robotoCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: widget.palette.text.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Preset dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.palette.background,
                    border: Border.all(color: widget.palette.border, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPreset,
                      hint: Text(
                        'Select a preset...',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          color: widget.palette.text.withOpacity(0.5),
                        ),
                      ),
                      items: widget.presets.map((preset) {
                        return DropdownMenuItem(
                          value: preset.name,
                          child: Text(
                            preset.name,
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              color: widget.palette.text,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final preset = widget.presets.firstWhere(
                            (p) => p.name == value,
                          );
                          _applyPreset(preset);
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Save preset button
              Expanded(
                child: TextField(
                  controller: _presetNameController,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: widget.palette.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Preset name...',
                    filled: true,
                    fillColor: widget.palette.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: widget.palette.border,
                        width: 2,
                      ),
                    ),
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              NeuButton(
                onPressed: _savePreset,
                palette: widget.palette,
                backgroundColor: widget.palette.tertiary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AsciiIcon(
                      AsciiGlyph.add,
                      size: 14,
                      color: widget.palette.text,
                    ),
                    const SizedBox(width: 4),
                    const Text('Save'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnList() {
    return Container(
      color: widget.palette.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column list header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.palette.surface,
              border: Border(
                bottom: BorderSide(color: widget.palette.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'VIS',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    'COLUMN NAME',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'KEY',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'WIDTH',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'ALIGN',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.text.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Reorderable column list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _columns.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final column = _columns.removeAt(oldIndex);
                  _columns.insert(newIndex, column);
                });
                HapticFeedback.mediumImpact();
              },
              itemBuilder: (context, index) {
                final column = _columns[index];
                return _buildColumnRow(column, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnRow(EditableColumn column, int index) {
    return Container(
      key: ValueKey(column.key),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(
          color: column.isVisible
              ? widget.palette.border
              : widget.palette.border.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Visibility checkbox
          SizedBox(
            width: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  column.isVisible = !column.isVisible;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: column.isVisible
                      ? widget.palette.primary
                      : widget.palette.background,
                  border: Border.all(color: widget.palette.border, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: column.isVisible
                    ? Center(
                        child: AsciiIcon(
                          AsciiGlyph.check,
                          size: 12,
                          color: widget.palette.text,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Column label
          Expanded(
            flex: 3,
            child: Text(
              column.label,
              style: GoogleFonts.robotoCondensed(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: column.isVisible
                    ? widget.palette.text
                    : widget.palette.text.withOpacity(0.4),
              ),
            ),
          ),

          // Column key
          Expanded(
            flex: 2,
            child: Text(
              column.key,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: column.isVisible
                    ? widget.palette.text.withOpacity(0.7)
                    : widget.palette.text.withOpacity(0.3),
              ),
            ),
          ),

          // Flex slider
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Text(
                  '${column.flex}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.palette.text,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: widget.palette.secondary,
                      inactiveTrackColor: widget.palette.border.withOpacity(0.2),
                      thumbColor: widget.palette.secondary,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: column.flex.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          column.flex = value.round();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alignment selector
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.palette.background,
                border: Border.all(color: widget.palette.border, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Alignment>(
                  value: column.alignment,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(
                      value: Alignment.centerLeft,
                      child: Text('Left'),
                    ),
                    DropdownMenuItem(
                      value: Alignment.center,
                      child: Text('Center'),
                    ),
                    DropdownMenuItem(
                      value: Alignment.centerRight,
                      child: Text('Right'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        column.alignment = value;
                      });
                    }
                  },
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: widget.palette.text,
                  ),
                ),
              ),
            ),
          ),

          // Drag handle
          SizedBox(
            width: 40,
            child: Center(
              child: AsciiIcon(
                AsciiGlyph.menu,
                size: 16,
                color: widget.palette.text.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final visibleCount = _columns.where((col) => col.isVisible).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border(
          top: BorderSide(color: widget.palette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          // Stats
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.palette.primary.withOpacity(0.1),
                border: Border.all(color: widget.palette.border, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  AsciiIcon(
                    AsciiGlyph.info,
                    size: 14,
                    color: widget.palette.text.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$visibleCount / ${_columns.length} columns visible',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      color: widget.palette.text.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Show all button
          NeuButton(
            onPressed: () {
              setState(() {
                for (final col in _columns) {
                  col.isVisible = true;
                }
              });
            },
            palette: widget.palette,
            backgroundColor: widget.palette.tertiary.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text('Show All'),
          ),

          const SizedBox(width: 8),

          // Reset button
          NeuButton(
            onPressed: _resetToDefaults,
            palette: widget.palette,
            backgroundColor: widget.palette.error.withOpacity(0.2),
            borderColor: widget.palette.error,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text('Reset'),
          ),

          const SizedBox(width: 8),

          // Apply button
          NeuButton(
            onPressed: _applyChanges,
            palette: widget.palette,
            backgroundColor: widget.palette.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }
}

// ==================== MODELS ====================

class EditableColumn {
  final String key;
  final String label;
  int flex;
  Alignment alignment;
  bool isVisible;

  EditableColumn({
    required this.key,
    required this.label,
    required this.flex,
    required this.alignment,
    this.isVisible = true,
  });

  factory EditableColumn.fromGridColumn(GridColumn column) {
    return EditableColumn(
      key: column.key,
      label: column.label,
      flex: column.flex,
      alignment: column.alignment,
      isVisible: true,
    );
  }

  GridColumn toGridColumn() {
    return GridColumn(
      key: key,
      label: label,
      flex: flex,
      alignment: alignment,
    );
  }
}

class ColumnPreset {
  final String name;
  final List<GridColumn> columns;

  const ColumnPreset({
    required this.name,
    required this.columns,
  });
}

// ==================== DEFAULT PRESETS ====================

class DefaultColumnPresets {
  static List<ColumnPreset> get all => [
    ColumnPreset(
      name: 'Compact',
      columns: MusicGridColumns.compact,
    ),
    ColumnPreset(
      name: 'Detailed',
      columns: MusicGridColumns.detailed,
    ),
    ColumnPreset(
      name: 'Audiophile',
      columns: MusicGridColumns.audiophile,
    ),
    ColumnPreset(
      name: 'Minimal',
      columns: const [
        GridColumn(key: 'title', label: 'Title', flex: 5),
        GridColumn(key: 'artist', label: 'Artist', flex: 3),
        GridColumn(
          key: 'duration',
          label: 'Time',
          flex: 1,
          alignment: Alignment.centerRight,
        ),
      ],
    ),
    ColumnPreset(
      name: 'Metadata Focus',
      columns: const [
        GridColumn(key: 'track', label: '#', flex: 1),
        GridColumn(key: 'title', label: 'Title', flex: 3),
        GridColumn(key: 'artist', label: 'Artist', flex: 2),
        GridColumn(key: 'album', label: 'Album', flex: 2),
        GridColumn(key: 'year', label: 'Year', flex: 1),
        GridColumn(key: 'genre', label: 'Genre', flex: 2),
        GridColumn(key: 'composer', label: 'Composer', flex: 2),
        GridColumn(key: 'conductor', label: 'Conductor', flex: 2),
      ],
    ),
  ];
}