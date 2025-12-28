import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Adaptive scaffold implementing the "Curated Utility" philosophy[cite: 19].
/// Android: Bottom navigation + touch-friendly Comfortable Mode[cite: 52, 70].
/// Linux: Multi-pane "Dashboard" layout with resizable panels[cite: 60, 61].
class NeuAdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? sidebar;
  final Widget? rightPanel;
  final Widget? bottomPane; // Added to support Linux playback controls 
  final String title;
  final List<NeuNavItem>? navItems;
  final int? selectedNavIndex;
  final Function(int)? onNavSelected;
  final RatholePalette palette;
  final bool isDesktop;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const NeuAdaptiveScaffold({
    super.key,
    required this.body,
    this.sidebar,
    this.rightPanel,
    this.bottomPane,
    required this.title,
    this.navItems,
    this.selectedNavIndex,
    this.onNavSelected,
    required this.palette,
    this.isDesktop = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context);
  }

  /// Implements the Linux "Dashboard" Layout.
  /// Mimics foobar2000's panels architecture with resizable panes[cite: 60, 61].
  Widget _buildDesktopLayout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: palette.background,
      body: Column( // Main Column for Top/Dashboard/Bottom split 
        children: [
          Expanded(
            child: Row(
              children: [
                // Navigation Sidebar (Left Pane) [cite: 61]
                if (navItems != null && navItems!.isNotEmpty)
                  _buildDesktopSidebar(textTheme),

                // Multi-pane Dashboard
                Expanded(
                  child: Row(
                    children: [
                      // Library Tree Panel (Left/Center Pane) [cite: 61]
                      if (sidebar != null)
                        NeuResizablePanel(
                          initialWidth: 250,
                          minWidth: 180,
                          maxWidth: 450,
                          palette: palette,
                          child: sidebar!,
                        ),

                      // Main Track List (Center Pane - Flex: 1) 
                      Expanded(child: body),

                      // Diagnostics/Queue Panel (Right Pane) 
                      if (rightPanel != null)
                        NeuResizablePanel(
                          initialWidth: 300,
                          minWidth: 200,
                          maxWidth: 500,
                          palette: palette,
                          showHandle: true,
                          isRightPanel: true,
                          child: rightPanel!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Playback Control Panel (Bottom Pane) 
          if (bottomPane != null)
            NeuResizablePanel(
              initialHeight: 120,
              minHeight: 80,
              maxHeight: 250,
              isVertical: true, // Vertical resize for bottom controls [cite: 21]
              palette: palette,
              child: bottomPane!,
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(TextTheme textTheme) {
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
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 18,
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
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                              style: textTheme.titleSmall?.copyWith(
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
                  ),
                );
              },
            ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
  return Scaffold(
    backgroundColor: palette.background,
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      backgroundColor: palette.surface,
      elevation: 0,
      shape: Border(bottom: BorderSide(color: palette.border, width: 3)),
    ),
    // Android uses a Navigation Stack for folders 
    body: Column(
      children: [
        Expanded(child: body),
        // Persistent Footer: Mini Player sits above navigation 
        if (floatingActionButton != null) 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: floatingActionButton!,
          ),
      ],
    ),
    bottomNavigationBar: _buildMobileBottomNav(Theme.of(context).textTheme),
  );
}

  Widget _buildMobileBottomNav(TextTheme textTheme) {
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
                        style: textTheme.labelSmall?.copyWith(
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
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final bool isVertical;
  final RatholePalette palette;
  final bool showHandle;
  final bool isRightPanel;

  const NeuResizablePanel({
    super.key,
    required this.child,
    this.initialWidth = 250,
    this.minWidth = 150,
    this.maxWidth = 600,
    this.initialHeight = 100,
    this.minHeight = 60,
    this.maxHeight = 300,
    this.isVertical = false,
    required this.palette,
    this.showHandle = true,
    this.isRightPanel = false,
  });

  @override
  State<NeuResizablePanel> createState() => _NeuResizablePanelState();
}

class _NeuResizablePanelState extends State<NeuResizablePanel> {
  late double _dimension;

  @override
  void initState() {
    super.initState();
    _dimension = widget.isVertical ? widget.initialHeight : widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Column(
        children: [
          // Vertical Resizing Handle [cite: 21, 38]
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _dimension = (_dimension - details.delta.dy)
                    .clamp(widget.minHeight, widget.maxHeight);
              });
            },
            child: _buildHandle(true),
          ),
          SizedBox(height: _dimension, child: widget.child),
        ],
      );
    }

    // ... (Keep horizontal logic, but update handle with _buildHandle)
    return Row(
      children: [
        if (widget.isRightPanel && widget.showHandle)
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dimension = (_dimension - details.delta.dx)
                    .clamp(widget.minWidth, widget.maxWidth);
              });
            },
            child: _buildHandle(false),
          ),
        SizedBox(width: _dimension, child: widget.child),
        if (!widget.isRightPanel && widget.showHandle)
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dimension = (_dimension + details.delta.dx)
                    .clamp(widget.minWidth, widget.maxWidth);
              });
            },
            child: _buildHandle(false),
          ),
      ],
    );
  }

  Widget _buildHandle(bool vertical) {
    return MouseRegion(
      cursor: vertical ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
      child: Container(
        width: vertical ? double.infinity : 6,
        height: vertical ? 6 : double.infinity,
        decoration: BoxDecoration(
          color: widget.palette.surface,
          border: Border(
            top: vertical ? BorderSide(color: widget.palette.border, width: 3) : BorderSide.none,
            left: !vertical ? BorderSide(color: widget.palette.border, width: 3) : BorderSide.none,
          ),
        ),
        child: Center(
          child: Container(
            width: vertical ? 40 : 2,
            height: vertical ? 2 : 40,
            color: widget.palette.border.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}