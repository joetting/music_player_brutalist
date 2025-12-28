import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NeuProgressBar extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final RatholePalette palette;
  final Color? progressColor;
  final double height;
  final bool showLabels;
  final String? leftLabel;
  final String? rightLabel;

  const NeuProgressBar({
    super.key,
    required this.value,
    this.onChanged,
    required this.palette,
    this.progressColor,
    this.height = 12,
    this.showLabels = false,
    this.leftLabel,
    this.rightLabel,
  });

  @override
  State<NeuProgressBar> createState() => _NeuProgressBarState();
}

class _NeuProgressBarState extends State<NeuProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final progColor = widget.progressColor ?? widget.palette.primary;
    final currentValue = (_dragValue ?? widget.value).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 0) {
                return const SizedBox.shrink();
              }
              
              return GestureDetector(
                onHorizontalDragUpdate: widget.onChanged != null
                    ? (details) {
                        final RenderBox? box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final localPosition = box.globalToLocal(details.globalPosition);
                        final value = (localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                        setState(() => _dragValue = value);
                      }
                    : null,
                onHorizontalDragEnd: widget.onChanged != null
                    ? (_) {
                        if (_dragValue != null) {
                          widget.onChanged!(_dragValue!);
                          setState(() => _dragValue = null);
                        }
                      }
                    : null,
                onTapDown: widget.onChanged != null
                    ? (details) {
                        final value = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                        widget.onChanged!(value);
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.palette.surface,
                    border: Border.all(color: widget.palette.border, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Row(
                      children: [
                        if (currentValue > 0)
                          Expanded(
                            flex: (currentValue * 1000).toInt(),
                            child: Container(color: progColor),
                          ),
                        if (currentValue < 1)
                          Expanded(
                            flex: ((1 - currentValue) * 1000).toInt(),
                            child: const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showLabels) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.leftLabel ?? '',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: widget.palette.text.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  widget.rightLabel ?? '',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: widget.palette.text.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}