import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_button.dart';
import '../widgets/product_card.dart';

/// Full Menu Screen with real-time search, category pills, and dynamic product grid.
class MenuScreen extends StatefulWidget {
  final String? initialCategory;

  const MenuScreen({super.key, this.initialCategory});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductProvider>().setCategory(widget.initialCategory!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final filtered = prodProv.filteredProducts;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'Menu & Catalog',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppTheme.textWhite,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textWhite),
              onChanged: prodProv.setSearchQuery,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardSurface,
                hintText: 'Search coffee, frappes, pasta...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldAccent, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          prodProv.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1.2),
                ),
              ),
            ),
          ),

          // Horizontal Category Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: prodProv.categories.length,
              itemBuilder: (context, index) {
                final category = prodProv.categories[index];
                return CategoryButton(
                  categoryName: category,
                  isSelected: prodProv.selectedCategory.toLowerCase() == category.toLowerCase(),
                  onTap: () => prodProv.setCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Filter Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      prodProv.selectedCategory == 'All' ? 'ALL PRODUCTS' : prodProv.selectedCategory.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Text(
                        '${filtered.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Product Grid or Empty State
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textWhite,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try searching for another drink or food item.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              prodProv.setSearchQuery('');
                              prodProv.setCategory('All');
                            },
                            child: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final int crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
                      const double childAspectRatio = 0.74;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filtered[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
