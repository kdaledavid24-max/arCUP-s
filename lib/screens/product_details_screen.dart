import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../data/product_data.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

/// Product details modal matching the modern luxury drink menu design (Image 2).
/// Displays a clean studio beverage photograph, breadcrumbs, centered title and description,
/// "You might also like" recommendations, and sticky bottom bar with quantity stepper,
/// Buy Now, and Add To Cart buttons.
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product _currentProduct;
  int _quantity = 1;
  final TransformationController _zoomController = TransformationController();
  double _currentScale = 1.0;

  final List<Product> _history = [];
  int _historyIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _history.add(widget.product);
    _historyIndex = 0;
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

  IconData _getCategoryIcon(String category) {
    if (category.contains('Coffee')) return Icons.coffee_rounded;
    if (category.contains('Frappe')) return Icons.icecream_rounded;
    if (category.contains('Salad')) return Icons.eco_rounded;
    if (category.contains('Pasta')) return Icons.dinner_dining_rounded;
    return Icons.restaurant_rounded;
  }

  void _toggleDoubleTapZoom() {
    setState(() {
      if (_currentScale > 1.2) {
        _zoomController.value = Matrix4.identity();
        _currentScale = 1.0;
      } else {
        _zoomController.value = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
        _currentScale = 2.0;
      }
    });
  }

  List<Product> get _categoryProducts => ProductData.products
      .where((p) => p.category == _currentProduct.category)
      .toList();

  int get _categoryIndex {
    final list = _categoryProducts;
    return list.indexWhere((p) => p.id == _currentProduct.id);
  }

  bool get _canGoBack {
    if (_historyIndex > 0) return true;
    if (_categoryIndex > 0) return true;
    return Navigator.of(context).canPop();
  }

  bool get _canGoForward {
    if (_historyIndex < _history.length - 1) return true;
    final catList = _categoryProducts;
    final idx = _categoryIndex;
    return idx >= 0 && idx < catList.length - 1;
  }

  void _goBack() {
    if (!_canGoBack) return;
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _currentProduct = _history[_historyIndex];
        _quantity = 1;
        _zoomController.value = Matrix4.identity();
        _currentScale = 1.0;
      });
      return;
    }
    final catList = _categoryProducts;
    final idx = _categoryIndex;
    if (idx > 0) {
      _selectProduct(catList[idx - 1]);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _goForward() {
    if (!_canGoForward) return;
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _currentProduct = _history[_historyIndex];
        _quantity = 1;
        _zoomController.value = Matrix4.identity();
        _currentScale = 1.0;
      });
      return;
    }
    final catList = _categoryProducts;
    final idx = _categoryIndex;
    if (idx >= 0 && idx < catList.length - 1) {
      _selectProduct(catList[idx + 1]);
    }
  }

  void _selectProduct(Product newProduct) {
    if (newProduct.id == _currentProduct.id) return;
    setState(() {
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(newProduct);
      _historyIndex = _history.length - 1;
      _currentProduct = newProduct;
      _quantity = 1;
      _zoomController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 520;

    // Category-specific recommendations for "You might also like"
    // Rules:
    // - Pasta -> ONLY Pasta
    // - Salad -> ONLY Salad
    // - Drinks (Coffee & Espresso / Frappe) -> ONLY Drinks
    final currentCat = _currentProduct.category;
    final bool isDrinkCategory =
        currentCat.contains('Coffee') || currentCat.contains('Frappe');

    final recommendations = ProductData.products.where((p) {
      if (p.id == _currentProduct.id) return false;
      if (currentCat == 'Pasta') {
        return p.category == 'Pasta';
      }
      if (currentCat == 'Salad') {
        return p.category == 'Salad';
      }
      if (isDrinkCategory) {
        return p.category.contains('Coffee') || p.category.contains('Frappe');
      }
      return p.category == currentCat;
    }).toList();

    if (isDrinkCategory) {
      // Prioritize same drink sub-category first (e.g. coffee with coffee, frappe with frappe)
      recommendations.sort((a, b) {
        final aSame = a.category == currentCat ? 0 : 1;
        final bSame = b.category == currentCat ? 0 : 1;
        return aSame.compareTo(bSame);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: isMobile ? 1.0 : 0.88),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // Prevent taps inside the card from closing
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              margin: isMobile
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(24),
                border: isMobile
                    ? null
                    : Border.all(color: const Color(0xFF262626), width: 1),
                boxShadow: isMobile
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.65),
                          blurRadius: 36,
                          offset: const Offset(0, 12),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Scrollable Body Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Drink Photo Container with Floating Back & Close Circles
                          Stack(
                            children: [
                              // Studio Minimalist Light Gray/Blue Backdrop
                              GestureDetector(
                                onDoubleTap: _toggleDoubleTapZoom,
                                child: Container(
                                  width: double.infinity,
                                  height: 330,
                                  color: const Color(0xFFE2E8F0),
                                  child: InteractiveViewer(
                                    transformationController: _zoomController,
                                    minScale: 1.0,
                                    maxScale: 3.5,
                                    child: Center(
                                      child: AppImage(
                                        imagePath: _currentProduct.image,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: 330,
                                        placeholder: Center(
                                          child: Icon(
                                            _getCategoryIcon(_currentProduct.category),
                                            size: 72,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Top-Left Navigation Arrows (Left = Back, Right = Forward)
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Left Arrow Button (Go back to previous screen)
                                    InkWell(
                                      onTap: _canGoBack ? _goBack : null,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: _canGoBack
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.35),
                                          shape: BoxShape.circle,
                                          boxShadow: _canGoBack
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.25),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_rounded,
                                          size: 20,
                                          color: _canGoBack ? Colors.black : Colors.black26,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Right Arrow Button (Go forward to next screen)
                                    InkWell(
                                      onTap: _canGoForward ? _goForward : null,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: _canGoForward
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.35),
                                          shape: BoxShape.circle,
                                          boxShadow: _canGoForward
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.25),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: _canGoForward ? Colors.black : Colors.black26,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Top-Right Floating Circle (Close)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Breadcrumbs: Home / Menu / Category / Name
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                            child: Row(
                              children: [
                                const Text(
                                  'Home',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Text(
                                  '  /  ',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 12,
                                  ),
                                ),
                                const Text(
                                  'Menu',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Text(
                                  '  /  ',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _currentProduct.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '  /  ',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _currentProduct.name,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Product Name (Bold, Large, Centered)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            child: Center(
                              child: Text(
                                _currentProduct.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),

                          if (_currentProduct.isSpecial)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 4, bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldAccent.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.goldAccent, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars_rounded, size: 14, color: AppTheme.goldAccent),
                                    const SizedBox(width: 5),
                                    Text(
                                      _currentProduct.specialNote?.isNotEmpty == true
                                          ? _currentProduct.specialNote!
                                          : 'SPECIAL DAY EXCLUSIVE',
                                      style: const TextStyle(
                                        color: AppTheme.goldAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Product Description (Muted, Centered)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 6, 24, 18),
                            child: Center(
                              child: Text(
                                _currentProduct.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white70,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),

                          // Subtle Divider Line
                          const Divider(
                            color: Color(0xFF262626),
                            height: 1,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),

                          // "You might also like" Section
                          // "You might also like" Section (Filtered strictly to matching category)
                          if (recommendations.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                              child: Text(
                                'You might also like',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            // Horizontal Recommendation Carousel
                            SizedBox(
                              height: 104,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendations.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final item = recommendations[index];
                                  return InkWell(
                                    onTap: () => _selectProduct(item),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 82,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDDE3EA),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFF262626),
                                          width: 1,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: AppImage(
                                        imagePath: item.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Sticky Bottom Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF141414),
                      border: Border(
                        top: BorderSide(color: Color(0xFF262626), width: 1),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row 1: Standard & Price on left, Quantity Stepper Pill on right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Standard',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₱${_currentProduct.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),

                              // Quantity Stepper Pill (White pill with black minus / count / plus)
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove,
                                          size: 18, color: Colors.black),
                                      splashRadius: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                      onPressed: _decrement,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          size: 18, color: Colors.black),
                                      splashRadius: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                      onPressed: _increment,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Row 2: Buy Now (Outlined) & Add To Cart (Solid White)
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      final cart = Provider.of<CartProvider>(context,
                                          listen: false);
                                      cart.addItem(_currentProduct, quantity: _quantity);
                                      Navigator.pushNamed(context, '/checkout');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.white, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: const Text(
                                      'Buy Now',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final cart = Provider.of<CartProvider>(context,
                                          listen: false);
                                      cart.addItem(_currentProduct, quantity: _quantity);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added $_quantity x ${_currentProduct.name} to cart!',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          action: SnackBarAction(
                                            label: 'View Cart',
                                            textColor: AppTheme.goldAccent,
                                            onPressed: () {
                                              Navigator.pushNamed(context, '/cart');
                                            },
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color(0xFF1E1E1E),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: const BorderSide(
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add To Cart',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
