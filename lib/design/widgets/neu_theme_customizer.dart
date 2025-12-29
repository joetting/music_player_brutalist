import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'ascii_icons.dart';
import 'neu_container.dart';
import 'neu_button.dart';
import 'neu_album_card.dart';
import 'neu_track_tile.dart';

/// Neubrutalist Theme Customizer
/// 
/// Features:
/// - Live theme preview
/// - Color picker for all palette colors
/// - Save/load custom themes
/// - Export theme as Dart code
/// - Reset to defaults

class NeuThemeCustomizer extends StatefulWidget {
  final RatholePalette initialPalette;
  final Function(RatholePalette) onThemeChanged;
  final VoidCallback onClose;

  const NeuThemeCustomizer({
    super.key,
    required this.initialPalette,
    required this.onThemeChanged,
    required this.onClose,
  });

  @override
  State<NeuThemeCustomizer> createState() => _NeuThemeCustomizerState();
}

class _NeuThemeCustomizerState extends State<NeuThemeCustomizer> {
  late RatholePalette _workingPalette;
  int _selectedColorIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  
  final List<_ColorDefinition> _colors = [
    _ColorDefinition('Primary', 'Main accent color for buttons and highlights'),
    _ColorDefinition('Secondary', 'Secondary accent for alternative elements'),
    _ColorDefinition('Tertiary', 'Third accent color for variety'),
    _ColorDefinition('Background', 'Main background color'),
    _ColorDefinition('Surface', 'Card and panel background'),
    _ColorDefinition('Error', 'Error and warning states'),
    _ColorDefinition('Border', 'Border color for all elements'),
    _ColorDefinition('Shadow', 'Shadow color for depth'),
    _ColorDefinition('Text', 'Primary text color'),
    _ColorDefinition('Accent', 'Interactive element highlights'),
  ];

  @override
  void initState() {
    super.initState();
    _workingPalette = widget.initialPalette;
    _nameController.text = 'Custom Theme';
  }

  Color _getColorByIndex(int index) {
    switch (index) {
      case 0: return _workingPalette.primary;
      case 1: return _workingPalette.secondary;
      case 2: return _workingPalette.tertiary;
      case 3: return _workingPalette.background;
      case 4: return _workingPalette.surface;
      case 5: return _workingPalette.error;
      case 6: return _workingPalette.border;
      case 7: return _workingPalette.shadow;
      case 8: return _workingPalette.text;
      case 9: return _workingPalette.accent;
      default: return Colors.black;
    }
  }

  void _setColorByIndex(int index, Color color) {
    setState(() {
      switch (index) {
        case 0: _workingPalette = _copyWith(primary: color); break;
        case 1: _workingPalette = _copyWith(secondary: color); break;
        case 2: _workingPalette = _copyWith(tertiary: color); break;
        case 3: _workingPalette = _copyWith(background: color); break;
        case 4: _workingPalette = _copyWith(surface: color); break;
        case 5: _workingPalette = _copyWith(error: color); break;
        case 6: _workingPalette = _copyWith(border: color); break;
        case 7: _workingPalette = _copyWith(shadow: color); break;
        case 8: _workingPalette = _copyWith(text: color); break;
        case 9: _workingPalette = _copyWith(accent: color); break;
      }
    });
  }

  RatholePalette _copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    Color? surface,
    Color? error,
    Color? border,
    Color? shadow,
    Color? text,
    Color? accent,
  }) {
    return RatholePalette(
      primary: primary ?? _workingPalette.primary,
      secondary: secondary ?? _workingPalette.secondary,
      tertiary: tertiary ?? _workingPalette.tertiary,
      background: background ?? _workingPalette.background,
      surface: surface ?? _workingPalette.surface,
      error: error ?? _workingPalette.error,
      border: border ?? _workingPalette.border,
      shadow: shadow ?? _workingPalette.shadow,
      text: text ?? _workingPalette.text,
      accent: accent ?? _workingPalette.accent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 1200,
          height: 800,
          decoration: BoxDecoration(
            color: _workingPalette.background,
            border: Border.all(color: _workingPalette.border, width: 4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _workingPalette.shadow,
                offset: const Offset(16, 16),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 300, child: _buildColorPicker()),
                    const VerticalDivider(width: 1, thickness: 3),
                    Expanded(child: _buildPreviewPanel()),
                  ],
                ),
              ),
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
        color: _workingPalette.surface,
        border: Border(
          bottom: BorderSide(color: _workingPalette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          AsciiIcon(
            AsciiGlyph.settings,
            size: 32,
            color: _workingPalette.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THEME CUSTOMIZER',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _workingPalette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Design your perfect neobrutalist color scheme',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: _workingPalette.text.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Preset themes dropdown
          _buildPresetSelector(),
          const SizedBox(width: 12),
          // Close button
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _workingPalette.error.withOpacity(0.2),
                border: Border.all(color: _workingPalette.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AsciiIcon(
                AsciiGlyph.close,
                size: 20,
                color: _workingPalette.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _workingPalette.tertiary.withOpacity(0.2),
          border: Border.all(color: _workingPalette.border, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AsciiIcon(
              AsciiGlyph.folder,
              size: 16,
              color: _workingPalette.text,
            ),
            const SizedBox(width: 8),
            Text(
              'Load Preset',
              style: GoogleFonts.robotoCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _workingPalette.text,
              ),
            ),
          ],
        ),
      ),
      onSelected: (name) {
        setState(() {
          _workingPalette = RatholeTheme.allPalettes[name]!;
          _nameController.text = name;
        });
      },
      itemBuilder: (context) {
        return RatholeTheme.allPalettes.keys.map((name) {
          return PopupMenuItem(
            value: name,
            child: Text(name),
          );
        }).toList();
      },
    );
  }

  Widget _buildColorPicker() {
    return Container(
      color: _workingPalette.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Color list header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _workingPalette.background,
              border: Border(
                bottom: BorderSide(color: _workingPalette.border, width: 2),
              ),
            ),
            child: Text(
              'COLOR PALETTE',
              style: GoogleFonts.robotoCondensed(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: _workingPalette.text,
              ),
            ),
          ),

          // Color slots
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final colorDef = _colors[index];
                final isSelected = _selectedColorIndex == index;
                final color = _getColorByIndex(index);

                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _workingPalette.primary.withOpacity(0.2)
                          : _workingPalette.background,
                      border: Border.all(
                        color: isSelected
                            ? _workingPalette.primary
                            : _workingPalette.border,
                        width: isSelected ? 3 : 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Color swatch
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: _workingPalette.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Color info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                colorDef.name.toUpperCase(),
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: _workingPalette.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _colorToHex(color),
                                style: GoogleFonts.spaceMono(
                                  fontSize: 11,
                                  color: _workingPalette.text.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                colorDef.description,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 9,
                                  color: _workingPalette.text.withOpacity(0.5),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Edit indicator
                        if (isSelected)
                          AsciiIcon(
                            AsciiGlyph.edit,
                            size: 16,
                            color: _workingPalette.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Color editor
          _buildColorEditor(),
        ],
      ),
    );
  }

  Widget _buildColorEditor() {
    final color = _getColorByIndex(_selectedColorIndex);
    final hsv = HSVColor.fromColor(color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _workingPalette.background,
        border: Border(
          top: BorderSide(color: _workingPalette.border, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'EDIT ${_colors[_selectedColorIndex].name.toUpperCase()}',
            style: GoogleFonts.robotoCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: _workingPalette.text.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),

          // Hue slider
          _buildSlider(
            'HUE',
            hsv.hue,
            0,
            360,
            (value) {
              _setColorByIndex(
                _selectedColorIndex,
                hsv.withHue(value).toColor(),
              );
            },
            _workingPalette.primary,
          ),

          const SizedBox(height: 8),

          // Saturation slider
          _buildSlider(
            'SATURATION',
            hsv.saturation,
            0,
            1,
            (value) {
              _setColorByIndex(
                _selectedColorIndex,
                hsv.withSaturation(value).toColor(),
              );
            },
            _workingPalette.secondary,
          ),

          const SizedBox(height: 8),

          // Value slider
          _buildSlider(
            'VALUE',
            hsv.value,
            0,
            1,
            (value) {
              _setColorByIndex(
                _selectedColorIndex,
                hsv.withValue(value).toColor(),
              );
            },
            _workingPalette.tertiary,
          ),

          const SizedBox(height: 12),

          // Hex input
          _buildHexInput(color),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    Color activeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _workingPalette.text.withOpacity(0.6),
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _workingPalette.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: _workingPalette.border.withOpacity(0.2),
            thumbColor: activeColor,
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildHexInput(Color color) {
    final hexController = TextEditingController(text: _colorToHex(color));
    
    return TextField(
      controller: hexController,
      style: GoogleFonts.spaceMono(
        fontSize: 12,
        color: _workingPalette.text,
      ),
      decoration: InputDecoration(
        labelText: 'HEX CODE',
        labelStyle: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _workingPalette.text.withOpacity(0.6),
        ),
        filled: true,
        fillColor: _workingPalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: _workingPalette.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: _workingPalette.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: _workingPalette.primary, width: 2),
        ),
        isDense: true,
      ),
      onSubmitted: (value) {
        try {
          final newColor = _hexToColor(value);
          _setColorByIndex(_selectedColorIndex, newColor);
        } catch (e) {
          // Invalid hex
        }
      },
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      color: _workingPalette.background,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview header
          Text(
            'LIVE PREVIEW',
            style: GoogleFonts.robotoCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: _workingPalette.text,
            ),
          ),
          const SizedBox(height: 16),

          // Preview content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Buttons preview
                  _buildPreviewSection(
                    'BUTTONS',
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        NeuButton(
                          onPressed: () {},
                          palette: _workingPalette,
                          child: const Text('Primary'),
                        ),
                        NeuButton(
                          onPressed: () {},
                          palette: _workingPalette,
                          backgroundColor: _workingPalette.secondary,
                          child: const Text('Secondary'),
                        ),
                        NeuIconButton(
                          icon: Icons.play_arrow,
                          onPressed: () {},
                          palette: _workingPalette,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Album card preview
                  _buildPreviewSection(
                    'ALBUM CARD',
                    SizedBox(
                      width: 240,
                      child: NeuAlbumCard(
                        albumTitle: 'Geogaddi',
                        artistName: 'Boards of Canada',
                        trackCount: 23,
                        year: 2002,
                        sampleRate: 96000,
                        bitDepth: 24,
                        hasMusicBrainzId: true,
                        onTap: () {},
                        palette: _workingPalette,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Track tile preview
                  _buildPreviewSection(
                    'TRACK TILE',
                    NeuTrackTile(
                      trackNumber: 1,
                      title: 'Music Is Math',
                      artist: 'Boards of Canada',
                      duration: const Duration(minutes: 5, seconds: 21),
                      sampleRate: 96000,
                      bitDepth: 24,
                      format: 'FLAC',
                      isPlaying: true,
                      onTap: () {},
                      palette: _workingPalette,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Container preview
                  _buildPreviewSection(
                    'CONTAINERS',
                    Row(
                      children: [
                        Expanded(
                          child: NeuContainer(
                            palette: _workingPalette,
                            child: Text(
                              'Standard Container',
                              style: TextStyle(
                                fontSize: 12,
                                color: _workingPalette.text,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeuContainer(
                            palette: _workingPalette,
                            asymmetricCorners: true,
                            child: Text(
                              'Asymmetric',
                              style: TextStyle(
                                fontSize: 12,
                                color: _workingPalette.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _workingPalette.text.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _workingPalette.surface,
        border: Border(
          top: BorderSide(color: _workingPalette.border, width: 3),
        ),
      ),
      child: Row(
        children: [
          // Theme name input
          Expanded(
            child: TextField(
              controller: _nameController,
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                color: _workingPalette.text,
              ),
              decoration: InputDecoration(
                labelText: 'Theme Name',
                filled: true,
                fillColor: _workingPalette.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: _workingPalette.border, width: 2),
                ),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Export button
          NeuButton(
            onPressed: _exportTheme,
            palette: _workingPalette,
            backgroundColor: _workingPalette.tertiary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AsciiIcon(
                  AsciiGlyph.copy,
                  size: 14,
                  color: _workingPalette.text,
                ),
                const SizedBox(width: 8),
                const Text('Export'),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Reset button
          NeuButton(
            onPressed: () {
              setState(() {
                _workingPalette = widget.initialPalette;
              });
            },
            palette: _workingPalette,
            backgroundColor: _workingPalette.error.withOpacity(0.2),
            borderColor: _workingPalette.error,
            child: const Text('Reset'),
          ),

          const SizedBox(width: 8),

          // Apply button
          NeuButton(
            onPressed: () {
              widget.onThemeChanged(_workingPalette);
              widget.onClose();
            },
            palette: _workingPalette,
            backgroundColor: _workingPalette.primary,
            child: const Text('Apply Theme'),
          ),
        ],
      ),
    );
  }

  void _exportTheme() {
    final code = '''
static const ${_nameController.text.replaceAll(' ', '')} = RatholePalette(
  primary: Color(${_colorToHexInt(_workingPalette.primary)}),
  secondary: Color(${_colorToHexInt(_workingPalette.secondary)}),
  tertiary: Color(${_colorToHexInt(_workingPalette.tertiary)}),
  background: Color(${_colorToHexInt(_workingPalette.background)}),
  surface: Color(${_colorToHexInt(_workingPalette.surface)}),
  error: Color(${_colorToHexInt(_workingPalette.error)}),
  border: Color(${_colorToHexInt(_workingPalette.border)}),
  shadow: Color(${_colorToHexInt(_workingPalette.shadow)}),
  text: Color(${_colorToHexInt(_workingPalette.text)}),
  accent: Color(${_colorToHexInt(_workingPalette.accent)}),
);
''';

    Clipboard.setData(ClipboardData(text: code));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme code copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _colorToHexInt(Color color) {
    return '0x${color.value.toRadixString(16).toUpperCase()}';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class _ColorDefinition {
  final String name;
  final String description;

  _ColorDefinition(this.name, this.description);
}