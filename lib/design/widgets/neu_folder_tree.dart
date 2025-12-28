import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Neubrutalist Folder Tree View
/// Features:
/// - Hierarchical directory navigation
/// - Expandable/collapsible nodes
/// - File count badges
/// - Smart folder detection (album vs folder)
/// - Path breadcrumbs
class NeuFolderTree extends StatefulWidget {
  final List<FolderNode> rootNodes;
  final Function(FolderNode) onFolderSelected;
  final FolderNode? selectedNode;
  final RatholePalette palette;
  final bool showFileCount;

  const NeuFolderTree({
    super.key,
    required this.rootNodes,
    required this.onFolderSelected,
    this.selectedNode,
    required this.palette,
    this.showFileCount = true,
  });

  @override
  State<NeuFolderTree> createState() => _NeuFolderTreeState();
}

class _NeuFolderTreeState extends State<NeuFolderTree> {
  final Set<String> _expandedPaths = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.background,
        border: Border.all(color: widget.palette.border, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: widget.rootNodes
            .map((node) => _buildNode(node, 0))
            .toList(),
      ),
    );
  }
  Widget _buildFolderIcon(bool isExpanded, bool hasChildren) {
  if (!hasChildren) {
    return Text(
      '  /  ',
      style: GoogleFonts.spaceMono(
        fontWeight: FontWeight.bold,
        color: widget.palette.text.withOpacity(0.5),
      ),
    );
  }
  
  return Text(
    isExpanded ? ' [-] ' : ' [+] ',
    style: TextStyle(
      color: widget.palette.primary,
      fontWeight: FontWeight.bold,
      fontFamily: 'JetBrains Mono', // Or GoogleFonts.spaceMono
    ),
  );
}
  Widget _buildNode(FolderNode node, int depth) {
    final isExpanded = _expandedPaths.contains(node.path);
    final isSelected = widget.selectedNode?.path == node.path;
    final hasChildren = node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedPaths.remove(node.path);
                } else {
                  _expandedPaths.add(node.path);
                }
              });
            }
            widget.onFolderSelected(node);
          },
          child: Container(
            margin: EdgeInsets.only(
              left: depth * 16.0,
              bottom: 4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.palette.primary.withOpacity(0.2)
                  : null,
              border: isSelected
                  ? Border.all(color: widget.palette.primary, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Replaced standard Icons with ASCII-style glyphs for Neobrutalist look
                _buildFolderIcon(isExpanded, hasChildren),

                const SizedBox(width: 8),

                // Folder name using SpaceMono to match Neobrutalist measurement-tool aesthetic
                Expanded(
                  child: Text(
                    node.name,
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.palette.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // File count badge
                if (widget.showFileCount && node.trackCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.palette.accent.withOpacity(0.2),
                      border: Border.all(
                        color: widget.palette.border,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${node.trackCount}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: widget.palette.text.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Recursive rendering of child nodes if this folder is expanded
        if (isExpanded && hasChildren)
          ...node.children.map((child) => _buildNode(child, depth + 1)),
      ],
    );
  }
  }

/// Model for folder tree nodes
class FolderNode {
  final String path;
  final String name;
  final List<FolderNode> children;
  final int trackCount;
  final bool isAlbum; // True if folder contains audio files

  const FolderNode({
    required this.path,
    required this.name,
    this.children = const [],
    this.trackCount = 0,
    this.isAlbum = false,
  });
}

/// Path breadcrumbs for navigation
class NeuBreadcrumbs extends StatelessWidget {
  final List<String> pathSegments;
  final Function(int) onSegmentTap;
  final RatholePalette palette;

  const NeuBreadcrumbs({
    super.key,
    required this.pathSegments,
    required this.onSegmentTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.home, size: 16, color: palette.text.withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (int i = 0; i < pathSegments.length; i++) ...[
                  GestureDetector(
                    onTap: () => onSegmentTap(i),
                    child: Text(
                      pathSegments[i],
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: i == pathSegments.length - 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i == pathSegments.length - 1
                            ? palette.text
                            : palette.text.withOpacity(0.6),
                      ),
                    ),
                  ),
                  if (i < pathSegments.length - 1)
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: palette.text.withOpacity(0.4),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// View mode selector (Folders / Artists / Albums / Genres)
class NeuViewModeSelector extends StatelessWidget {
  final ViewMode currentMode;
  final Function(ViewMode) onModeChanged;
  final RatholePalette palette;

  const NeuViewModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ViewMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onModeChanged(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? palette.primary : palette.surface,
                border: Border.all(
                  color: isSelected ? palette.border : palette.border.withOpacity(0.5),
                  width: isSelected ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(4),
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
                  Icon(
                    mode.icon,
                    size: 14,
                    color: palette.text,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mode.label,
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
        );
      }).toList(),
    );
  }
}

/// View modes for library navigation
enum ViewMode {
  folders(Icons.folder, 'Folders'),
  artists(Icons.person, 'Artists'),
  albums(Icons.album, 'Albums'),
  genres(Icons.music_note, 'Genres');

  final IconData icon;
  final String label;

  const ViewMode(this.icon, this.label);
}
