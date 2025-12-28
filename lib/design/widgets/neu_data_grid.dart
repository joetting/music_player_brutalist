import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Audiophile Data Grid
/// 
/// A spreadsheet-style view implementing the "Curated Utility" philosophy.
/// Designed for high information density (28dp rows) and technical transparency.
class NeuDataGrid extends StatefulWidget {
  final List<GridColumn> columns; // Dynamic list of tags/columns
  final List<Map<String, dynamic>> rows;
  final Function(int)? onRowTap;
  final Function(int)? onRowDoubleTap;
  final int? selectedRowIndex;
  final RatholePalette palette;
  final double rowHeight;
  final bool showHeader;
  final Function(String, bool)? onSort;
  final Function(Offset)? onHeaderRightClick; // For customizing tags

  const NeuDataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.onRowDoubleTap,
    this.selectedRowIndex,
    required this.palette,
    this.rowHeight = 28, // foobar2000 standard density [cite: 211]
    this.showHeader = true,
    this.onSort,
    this.onHeaderRightClick,
  });

  @override
  State<NeuDataGrid> createState() => _NeuDataGridState();
}

class _NeuDataGridState extends State<NeuDataGrid> {
  String? _sortColumn;
  bool _sortAscending = true;
  int? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.surface,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: widget.palette.shadow,
            offset: const Offset(6, 6), // Hard shadows [cite: 185]
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          if (widget.showHeader) _buildHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.rows.length,
              itemExtent: widget.rowHeight,
              itemBuilder: (context, index) => _buildRow(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onSecondaryTapDown: (details) => 
          widget.onHeaderRightClick?.call(details.globalPosition),
      child: Container(
        height: widget.rowHeight + 8,
        decoration: BoxDecoration(
          color: widget.palette.background,
          border: Border(
            bottom: BorderSide(color: widget.palette.border, width: 3), // Thick bottom border [cite: 263]
          ),
        ),
        child: Row(
          children: widget.columns.map((column) => _buildHeaderCell(column)).toList(),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(GridColumn column) {
    final isSorted = _sortColumn == column.key;
    return Expanded(
      flex: column.flex,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_sortColumn == column.key) {
              _sortAscending = !_sortAscending;
            } else {
              _sortColumn = column.key;
              _sortAscending = true;
            }
          });
          widget.onSort?.call(column.key, _sortAscending);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: widget.palette.border, width: 2), // Vertical dividers [cite: 262]
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  column.label.toUpperCase(),
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: widget.palette.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSorted)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: widget.palette.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    final row = widget.rows[index];
    final isSelected = widget.selectedRowIndex == index;
    final isHovered = _hoveredRow == index;
    final isEven = index % 2 == 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRow = index),
      onExit: (_) => setState(() => _hoveredRow = null),
      child: GestureDetector(
        onTap: () => widget.onRowTap?.call(index),
        onDoubleTap: () => widget.onRowDoubleTap?.call(index),
        child: Container(
          height: widget.rowHeight,
          decoration: BoxDecoration(
            color: isSelected
                ? widget.palette.primary.withOpacity(0.3)
                : isHovered
                    ? widget.palette.accent.withOpacity(0.15)
                    : isEven
                        ? widget.palette.surface
                        : widget.palette.background.withOpacity(0.2),
            border: isSelected
                ? Border.all(color: widget.palette.primary, width: 2)
                : null,
          ),
          child: Row(
            children: widget.columns.map((column) {
              final value = row[column.key];
              return Expanded(
                flex: column.flex,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: column.alignment,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: widget.palette.border.withOpacity(0.2), 
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    value?.toString() ?? '',
                    style: GoogleFonts.spaceMono( // Monospace for diagnostic data [cite: 185]
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: widget.palette.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Dynamic Column definition
class GridColumn {
  final String key;
  final String label;
  final int flex;
  final Alignment alignment;

  const GridColumn({
    required this.key,
    required this.label,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });
}

/// Implementation of foobar2000 mapping presets [cite: 167, 185]
class MusicGridColumns {
  static List<GridColumn> get compact => [
        const GridColumn(key: 'track', label: '#', flex: 0, alignment: Alignment.centerRight),
        const GridColumn(key: 'title', label: 'Title', flex: 4),
        const GridColumn(key: 'artist', label: 'Artist', flex: 3),
        const GridColumn(key: 'duration', label: 'Time', flex: 1, alignment: Alignment.centerRight),
      ];

  static List<GridColumn> get detailed => [
        const GridColumn(key: 'track', label: '#', flex: 0, alignment: Alignment.centerRight),
        const GridColumn(key: 'title', label: 'Title', flex: 4),
        const GridColumn(key: 'artist', label: 'Artist', flex: 3),
        const GridColumn(key: 'album', label: 'Album', flex: 3),
        const GridColumn(key: 'year', label: 'Year', flex: 1, alignment: Alignment.center),
        const GridColumn(key: 'genre', label: 'Genre', flex: 2),
        const GridColumn(key: 'duration', label: 'Time', flex: 1, alignment: Alignment.centerRight),
      ];

  /// Full diagnostic view with technical metadata [cite: 171, 185]
  static List<GridColumn> get audiophile => [
        const GridColumn(key: 'track', label: '#', flex: 0, alignment: Alignment.centerRight),
        const GridColumn(key: 'title', label: 'Title', flex: 4),
        const GridColumn(key: 'artist', label: 'Artist', flex: 3),
        const GridColumn(key: 'album', label: 'Album', flex: 3),
        const GridColumn(key: 'format', label: 'Format', flex: 1, alignment: Alignment.center),
        const GridColumn(key: 'bitrate', label: 'Bitrate', flex: 2, alignment: Alignment.centerRight),
        const GridColumn(key: 'sampleRate', label: 'Sample', flex: 2, alignment: Alignment.centerRight),
        const GridColumn(key: 'duration', label: 'Time', flex: 1, alignment: Alignment.centerRight),
        const GridColumn(key: 'path', label: 'Path', flex: 5),
      ];
}