import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable universal image widget supporting assets, network URLs, and base64 data strings.
/// Gracefully falls back to a coffee/food placeholder icon if the image cannot be loaded.
class AppImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ??
        Container(
          width: width,
          height: height,
          color: AppTheme.imageBackdrop,
          child: const Center(
            child: Icon(Icons.fastfood_rounded, color: AppTheme.textMuted, size: 32),
          ),
        );

    final clean = imagePath.trim();
    if (clean.isEmpty) return fallback;

    // 1. Base64 data URI (e.g. data:image/png;base64,...) or raw base64 string
    if (clean.startsWith('data:') ||
        (!clean.startsWith('assets/') &&
            !clean.startsWith('http://') &&
            !clean.startsWith('https://') &&
            clean.length > 80)) {
      try {
        final commaIdx = clean.indexOf(',');
        final base64Data = commaIdx != -1 ? clean.substring(commaIdx + 1) : clean;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, _, _) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    // 2. Web Network URL (http:// or https://)
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppTheme.imageBackdrop,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.goldAccent),
              ),
            ),
          );
        },
      );
    }

    // 3. Local Flutter Asset
    return Image.asset(
      clean,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  /// Helper to get an ImageProvider for contexts requiring ImageProvider (e.g. DecorationImage)
  static ImageProvider provider(String imagePath) {
    final clean = imagePath.trim();
    if (clean.startsWith('data:') ||
        (!clean.startsWith('assets/') &&
            !clean.startsWith('http://') &&
            !clean.startsWith('https://') &&
            clean.length > 80)) {
      try {
        final commaIdx = clean.indexOf(',');
        final base64Data = commaIdx != -1 ? clean.substring(commaIdx + 1) : clean;
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {}
    }
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return NetworkImage(clean);
    }
    return AssetImage(clean);
  }
}
