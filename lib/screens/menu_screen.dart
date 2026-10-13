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
  final ScrollController _categoryScrollController = ScrollController();

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
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(int index) {
    if (_categoryScrollController.hasClients) {
      final target = (index * 110.0) - 40.0;
      _categoryScrollController.animateTo(
        target.clamp(0.0, _categoryScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final filtered = prodProv.filteredProducts;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: prodProv.categories.length,
              itemBuilder: (context, index) {
                final category = prodProv.categories[index];
                final isSelected = prodProv.selectedCategory.toLowerCase() == category.toLowerCase();
                return CategoryButton(
                  categoryName: category,
                  isSelected: isSelected,
                  onTap: () {
                    prodProv.setCategory(category);
                    _scrollToCategory(index);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Filter Info & Reset Button
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
                if (prodProv.selectedCategory != 'All')
                  GestureDetector(
                    onTap: () {
                      prodProv.setCategory('All');
                      _scrollToCategory(0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Show All Menu',
                            style: TextStyle(
                              color: AppTheme.goldAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.close_rounded, size: 13, color: AppTheme.goldAccent),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Product Grid or Empty State
          Expanded(
            child: prodProv.isLoading && filtered.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
                    ),
                  )
                : filtered.isEmpty
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
                                  _scrollToCategory(0);
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
                          final double childAspectRatio = crossAxisCount >= 3 ? 0.74 : 0.66;

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
