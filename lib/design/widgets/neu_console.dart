import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neobrutalist System Monitor (Console)
/// Displays a terminal-style log of internal engine events.
class NeuSystemMonitor extends StatelessWidget {
  final List<String> logs;
  final RatholePalette palette;

  const NeuSystemMonitor({
    super.key,
    required this.logs,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Stark terminal background
        border: Border.all(color: palette.border, width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: palette.primary, size: 14),
              const SizedBox(width: 8),
              Text(
                'SYSTEM_CONSOLE_V1.0',
                style: TextStyle(
                  color: palette.primary,
                  fontFamily: 'JetBrains Mono', // Monospace for data [cite: 38]
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '> ${logs[index]}',
                    style: const TextStyle(
                      color: Color(0xFF00FF41), // Classic terminal green
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
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
}