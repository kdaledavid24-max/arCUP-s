import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_button.dart';
import '../widgets/product_card.dart';
import '../widgets/animated_marquee.dart';

/// Home Screen designed with the Food Ordering luxury dark aesthetic and dynamic product state.
class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  final Function(String)? onSelectCategory;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
    this.onSelectCategory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();

    final filtered = prodProv.filteredProducts;
    final totalItems = filtered.length;
    const itemsPerPage = 8;
    final totalPages = (totalItems / itemsPerPage).ceil().clamp(1, 99);
    final displayedProducts = filtered.skip((_currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppTheme.darkBackground,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.goldAccent),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.restaurant_rounded,
                    color: AppTheme.goldAccent,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Food Ordering',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.goldAccent),
              tooltip: 'Admin Dashboard',
              onPressed: () => Navigator.pushNamed(context, '/admin'),
            ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.textWhite),
            onPressed: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(1); // Go to Menu tab
              } else {
                Navigator.pushNamed(context, '/menu');
              }
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textWhite),
                    onPressed: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(2); // Go to Cart tab
                      } else {
                        Navigator.pushNamed(context, '/cart');
                      }
                    },
                  ),
                  if (cart.totalItemCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.goldAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            // Top Moving Animated Marquee Ribbon
            const AnimatedMarquee(
              items: [
                'VELVET ESPRESSO ROASTS',
                'HANDCRAFTED ICE-BLENDS',
                'ARTISAN SAUCED PASTAS',
                'CRISP ORGANIC HARVEST',
                'SUNLIT BAKERY COMFORTS',
                'CHILLED INFUSED BREWS',
                'SERVED AT PEAK FRESHNESS',
                'MINDFUL COFFEE MOMENTS',
              ],
            ),
            const SizedBox(height: 28),

            // Hero Brand Opening Hours Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'OPEN DAILY ( MONDAY - SUNDAY )',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'WE ARE OPEN FROM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '8:00 AM TO 11:00 PM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                      color: AppTheme.lightCaramel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Elevating your everyday food ritual with handcrafted coffees, creamy frappes, fresh salads, and authentic Italian pastas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.4,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hero Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          } else {
                            Navigator.pushNamed(context, '/menu');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'EXPLORE MENU',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(4); // Profile
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF2E4566), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'OUR STORY',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Horizontal Category Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...prodProv.categories.map((category) {
                    return CategoryButton(
                      categoryName: category,
                      isSelected: prodProv.selectedCategory.toLowerCase() == category.toLowerCase(),
                      onTap: () {
                        prodProv.setCategory(category);
                        setState(() => _currentPage = 1);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Cards Responsive Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final int crossAxisCount = width >= 1100 ? 4 : (width >= 720 ? 3 : 2);
                  final double childAspectRatio = crossAxisCount >= 3 ? 0.74 : 0.65;

                  if (displayedProducts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No products available in this category.', style: TextStyle(color: AppTheme.textMuted)),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: displayedProducts[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Minimalist Pagination Indicators
            if (totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (i) {
                  final pageNum = i + 1;
                  final isCurrent = pageNum == _currentPage;
                  return GestureDetector(
                    onTap: () => setState(() => _currentPage = pageNum),
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? AppTheme.goldAccent : Colors.transparent,
                        border: Border.all(
                          color: isCurrent ? AppTheme.goldAccent : const Color(0xFF383430),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$pageNum',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.black : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
