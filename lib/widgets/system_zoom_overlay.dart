import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_zoom_provider.dart';

/// Floating zoom controller matching the exact layout in the user's reference:
/// [ 175%    —    +    ( Reset ) ]
class SystemZoomOverlay extends StatelessWidget {
  const SystemZoomOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final zoomProvider = Provider.of<SystemZoomProvider>(context);
    final percent = (zoomProvider.zoomLevel * 100).round();

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF111923).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF22344A),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Percentage Label (e.g. 100%, 125%, 150%, 175%)
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF1F5F9),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 14),

            // Minus Button
            InkWell(
              onTap: zoomProvider.zoomLevel > 0.50 ? zoomProvider.zoomOut : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: zoomProvider.zoomLevel > 0.50 ? Colors.white : Colors.white38,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Plus Button
            InkWell(
              onTap: zoomProvider.zoomLevel < 2.25 ? zoomProvider.zoomIn : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: zoomProvider.zoomLevel < 2.25 ? Colors.white : Colors.white38,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Outlined "Reset" Pill Button (mint accent matching reference screenshot)
            InkWell(
              onTap: percent != 100 ? zoomProvider.resetZoom : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: percent != 100
                        ? const Color(0xFF34D399)
                        : const Color(0xFF2A423B),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: percent != 100
                        ? const Color(0xFF34D399)
                        : const Color(0xFF558273),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
