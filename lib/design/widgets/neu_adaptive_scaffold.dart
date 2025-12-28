import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Adaptive scaffold that changes layout based on platform
/// Android: Bottom navigation + mobile-optimized
/// Linux: Sidebar + resizable panels
class NeuAdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? sidebar;
  final Widget? rightPanel;
  final String title;
  final List<NeuNavItem>? navItems;
  final int? selectedNavIndex;
  final Function(int)? onNavSelected;
  final RatholePalette palette;
  final bool isDesktop;

  const NeuAdaptiveScaffold({
    super.key,
    required this.body,
    this.sidebar,
    this.rightPanel,
    required this.title,
    this.navItems,
    this.selectedNavIndex,
    this.onNavSelected,
    required this.palette,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: palette.background,
      body: Row(
        children: [
          // Left sidebar navigation
          if (navItems != null && navItems!.isNotEmpty)
            _buildDesktopSidebar(),

          // Main content area with optional sidebar
          Expanded(
            child: Row(
              children: [
                // Optional left panel (folder tree, playlists, etc.)
                if (sidebar != null)
                  SizedBox(
                    width: 250,
                    child: sidebar!,
                  ),

                // Main body
                Expanded(child: body),

                // Optional right panel (queue, lyrics, etc.)
                if (rightPanel != null)
                  SizedBox(
                    width: 300,
                    child: rightPanel!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          right: BorderSide(color: palette.border, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: palette.border, width: 2),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: navItems!.length,
              itemBuilder: (context, index) {
                final item = navItems![index];
                final isSelected = selectedNavIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => onNavSelected?.call(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.primary.withOpacity(0.2)
                            : null,
                        border: isSelected
                            ? Border.all(color: palette.primary, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 18,
                            color: isSelected
                                ? palette.primary
                                : palette.text.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: palette.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: palette.text,
          ),
        ),
        backgroundColor: palette.surface,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: palette.border, width: 3),
        ),
      ),
      body: body,
      bottomNavigationBar: navItems != null && navItems!.isNotEmpty
          ? _buildMobileBottomNav()
          : null,
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          top: BorderSide(color: palette.border, width: 3),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems!.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = selectedNavIndex == index;

              return GestureDetector(
                onTap: () => onNavSelected?.call(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? palette.primary.withOpacity(0.2)
                        : null,
                    border: isSelected
                        ? Border.all(color: palette.primary, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isSelected
                            ? palette.primary
                            : palette.text.withOpacity(0.6),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? palette.text
                              : palette.text.withOpacity(0.6),
                        ),
                      ),
                    ],
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

/// Navigation item model
class NeuNavItem {
  final IconData icon;
  final String label;
  final String route;

  const NeuNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

/// Preset navigation configurations
class MusicNavItems {
  static List<NeuNavItem> get standard => [
        const NeuNavItem(
          icon: Icons.library_music,
          label: 'Library',
          route: '/library',
        ),
        const NeuNavItem(
          icon: Icons.playlist_play,
          label: 'Playlists',
          route: '/playlists',
        ),
        const NeuNavItem(
          icon: Icons.album,
          label: 'Albums',
          route: '/albums',
        ),
        const NeuNavItem(
          icon: Icons.queue_music,
          label: 'Queue',
          route: '/queue',
        ),
      ];

  static List<NeuNavItem> get compact => [
        const NeuNavItem(
          icon: Icons.folder,
          label: 'Files',
          route: '/files',
        ),
        const NeuNavItem(
          icon: Icons.playlist_play,
          label: 'Playlists',
          route: '/playlists',
        ),
        const NeuNavItem(
          icon: Icons.queue_music,
          label: 'Queue',
          route: '/queue',
        ),
      ];
}

/// Resizable panel container (for Linux multi-pane layouts)
class NeuResizablePanel extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final RatholePalette palette;
  final bool showHandle;

  const NeuResizablePanel({
    super.key,
    required this.child,
    this.initialWidth = 250,
    this.minWidth = 150,
    this.maxWidth = 600,
    required this.palette,
    this.showHandle = true,
  });

  @override
  State<NeuResizablePanel> createState() => _NeuResizablePanelState();
}

class _NeuResizablePanelState extends State<NeuResizablePanel> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _width,
          child: widget.child,
        ),
        if (widget.showHandle)
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _width = (_width + details.delta.dx)
                    .clamp(widget.minWidth, widget.maxWidth);
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(
                width: 6,
                color: widget.palette.border.withOpacity(0.5),
                child: Center(
                  child: Container(
                    width: 2,
                    color: widget.palette.border,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
