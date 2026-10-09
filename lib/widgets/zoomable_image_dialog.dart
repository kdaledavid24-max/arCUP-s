import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

/// Full-featured interactive zoom viewer for product images.
/// Supports pinch-to-zoom, mouse wheel, double tap, and on-screen +/- zoom controls.
class ZoomableImageDialog extends StatefulWidget {
  final Product product;

  const ZoomableImageDialog({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) => ZoomableImageDialog(product: product),
    );
  }

  @override
  State<ZoomableImageDialog> createState() => _ZoomableImageDialogState();
}

class _ZoomableImageDialogState extends State<ZoomableImageDialog> {
  final TransformationController _controller = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.02) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _zoomIn() {
    final newScale = (_currentScale + 0.4).clamp(1.0, 4.5);
    _animateScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale - 0.4).clamp(1.0, 4.5);
    _animateScale(newScale);
  }

  void _resetZoom() {
    _animateScale(1.0);
  }

  void _animateScale(double targetScale) {
    setState(() {
      _controller.value = Matrix4.diagonal3Values(targetScale, targetScale, 1.0);
      _currentScale = targetScale;
    });
  }

  void _handleDoubleTap() {
    if (_currentScale > 1.2) {
      _resetZoom();
    } else {
      _animateScale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Product Name + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              widget.product.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.caramelAccent,
                              ),
                            ),
                            const Text(
                              ' · ',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                            Text(
                              '₱${widget.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.lightCaramel,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Zoomable Canvas
            Expanded(
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: Center(
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.8,
                    maxScale: 5.0,
                    boundaryMargin: const EdgeInsets.all(80),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.imageBackdrop,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppImage(
                        imagePath: widget.product.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom On-Screen Zoom Controls & Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1917).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Zoom Out Button
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: Colors.white,
                    iconSize: 26,
                    tooltip: 'Zoom Out',
                    onPressed: _zoomOut,
                  ),

                  // Zoom Percentage Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2825),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${(_currentScale * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightCaramel,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Zoom In Button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: Colors.white,
                    iconSize: 26,
                    tooltip: 'Zoom In',
                    onPressed: _zoomIn,
                  ),

                  // Reset Button
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded),
                    color: AppTheme.caramelAccent,
                    iconSize: 24,
                    tooltip: 'Reset Zoom (100%)',
                    onPressed: _resetZoom,
                  ),
                ],
              ),
            ),

            // Pinch / Double tap instruction tip
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Pinch to zoom in/out • Double-tap to toggle zoom • Drag to pan',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
