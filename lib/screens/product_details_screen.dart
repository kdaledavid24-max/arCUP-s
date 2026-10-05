import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/zoomable_image_dialog.dart';

/// Screen displaying detailed product information with interactive pinch/scroll zoom
/// and dedicated Zoom In / Zoom Out controls matching the luxury dark aesthetic.
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  final TransformationController _zoomController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _zoomController.addListener(_onScaleChanged);
  }

  @override
  void dispose() {
    _zoomController.removeListener(_onScaleChanged);
    _zoomController.dispose();
    super.dispose();
  }

  void _onScaleChanged() {
    final scale = _zoomController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.02) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _zoomIn() {
    final newScale = (_currentScale + 0.4).clamp(1.0, 4.0);
    _setScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale - 0.4).clamp(1.0, 4.0);
    _setScale(newScale);
  }

  void _resetZoom() {
    _setScale(1.0);
  }

  void _setScale(double scale) {
    setState(() {
      _zoomController.value = Matrix4.diagonal3Values(scale, scale, 1.0);
      _currentScale = scale;
    });
  }

  void _toggleDoubleTapZoom() {
    if (_currentScale > 1.2) {
      _resetZoom();
    } else {
      _setScale(2.2);
    }
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Coffee')) return Icons.coffee_rounded;
    if (category.contains('Frappe')) return Icons.icecream_rounded;
    if (category.contains('Salad')) return Icons.eco_rounded;
    if (category.contains('Pasta')) return Icons.dinner_dining_rounded;
    return Icons.restaurant_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.product.price * _quantity;
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppTheme.textWhite,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textWhite),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.totalItemCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.totalItemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Interactive Zoomable Container
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: BoxDecoration(
                      color: AppTheme.imageBackdrop,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Interactive Zoom Area
                        GestureDetector(
                          onDoubleTap: _toggleDoubleTapZoom,
                          child: SizedBox(
                            height: 320,
                            width: double.infinity,
                            child: InteractiveViewer(
                              transformationController: _zoomController,
                              minScale: 1.0,
                              maxScale: 4.5,
                              clipBehavior: Clip.none,
                              child: Center(
                                child: Image.asset(
                                  widget.product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Icon(
                                      _getCategoryIcon(widget.product.category),
                                      size: 64,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Top Category Pill Badge
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(widget.product.category),
                                  size: 14,
                                  color: AppTheme.lightCaramel,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.product.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Top-Right Fullscreen Zoom Button
                        Positioned(
                          top: 14,
                          right: 14,
                          child: InkWell(
                            onTap: () => ZoomableImageDialog.show(context, widget.product),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Bottom Floating Zoom Control Pill (Zoom In, Zoom Out, Reset, Indicator)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141312).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppTheme.cardBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    color: Colors.white,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    tooltip: 'Zoom Out',
                                    onPressed: _zoomOut,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${(_currentScale * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.lightCaramel,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    color: Colors.white,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    tooltip: 'Zoom In',
                                    onPressed: _zoomIn,
                                  ),
                                  if (_currentScale > 1.05) ...[
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      color: AppTheme.caramelAccent,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      tooltip: 'Reset Zoom',
                                      onPressed: _resetZoom,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pinch-to-zoom helper tip
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tip: Pinch or double-tap image to zoom in & out',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Details Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textWhite,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '₱${widget.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.lightCaramel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'DESCRIPTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppTheme.caramelAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Perks Row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141312),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.coffee, color: AppTheme.caramelAccent, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Freshly Brewed',
                                      style: TextStyle(fontSize: 11.5, color: AppTheme.textWhite, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined, color: AppTheme.caramelAccent, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      '15-20 Min Prep',
                                      style: TextStyle(fontSize: 11.5, color: AppTheme.textWhite, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Quantity Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141312),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: _decrement,
                                      splashRadius: 18,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textWhite,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: _increment,
                                      splashRadius: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              border: const Border(
                top: BorderSide(color: AppTheme.cardBorder, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₱${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addItem(widget.product, quantity: _quantity);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $_quantity x ${widget.product.name} to cart!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: AppTheme.lightCaramel,
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF252320),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppTheme.cardBorder),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
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
}
