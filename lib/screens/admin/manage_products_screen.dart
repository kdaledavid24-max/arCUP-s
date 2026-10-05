import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import 'add_edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final products = prodProv.filteredProducts;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Manage Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.goldAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        ),
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: prodProv.setSearchQuery,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                hintText: 'Search products by name or ingredient...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          prodProv.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: prodProv.categories.map((cat) {
                final isSelected = prodProv.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => prodProv.setCategory(cat),
                    selectedColor: AppTheme.goldAccent,
                    backgroundColor: AppTheme.cardSurface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textWhite,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? AppTheme.goldAccent : AppTheme.cardBorder),
                  ),
                );
              }).toList(),
            ),
          ),

          // Product List
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text('No products found.', style: TextStyle(color: AppTheme.textMuted)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product Thumbnail
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.imageBackdrop,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    item.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textWhite,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.category} • ₱${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppTheme.goldAccent, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: item.available ? AppTheme.successGreen : Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.available ? 'In Stock' : 'Unavailable',
                                          style: TextStyle(
                                            color: item.available ? AppTheme.successGreen : Colors.redAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action Buttons
                              IconButton(
                                icon: Icon(
                                  item.available ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                                  color: item.available ? AppTheme.successGreen : AppTheme.textMuted,
                                  size: 32,
                                ),
                                tooltip: 'Toggle Availability',
                                onPressed: () => prodProv.toggleAvailability(item.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: AppTheme.goldAccent, size: 20),
                                tooltip: 'Edit Product',
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditProductScreen(product: item),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(context, prodProv, item.id, item.name),
                              ),
                            ],
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

  void _confirmDelete(BuildContext context, ProductProvider provider, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Delete Product', style: TextStyle(color: AppTheme.textWhite)),
        content: Text('Are you sure you want to remove "$name" from the menu?', style: const TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProduct(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted'), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
