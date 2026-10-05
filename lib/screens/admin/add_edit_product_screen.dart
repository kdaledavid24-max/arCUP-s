import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/product_data.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late String _selectedCategory;
  late String _imagePath;
  late bool _available;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product != null ? widget.product!.price.toStringAsFixed(2) : '');
    _selectedCategory = widget.product?.category ?? 'Coffee & Espresso';
    _imagePath = widget.product?.image ?? 'assets/images/drinks/americano.jpg';
    _available = widget.product?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final prodProv = context.read<ProductProvider>();

    if (isEditing) {
      final updated = widget.product!.copyWith(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        price: price,
        image: _imagePath,
        available: _available,
      );
      await prodProv.updateProduct(updated);
    } else {
      final newId = 'item_${DateTime.now().millisecondsSinceEpoch}';
      final newProduct = Product(
        id: newId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        price: price,
        image: _imagePath,
        available: _available,
      );
      await prodProv.addProduct(newProduct);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Product updated successfully' : 'Product created successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validCategories = ProductData.categories.where((c) => c != 'All').toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.imageBackdrop,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      _imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => const Icon(Icons.fastfood, size: 50, color: AppTheme.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.label_outline_rounded, color: AppTheme.goldAccent),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, color: AppTheme.goldAccent),
                ),
                items: validCategories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Price (₱)',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.goldAccent),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter price';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined, color: AppTheme.goldAccent),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 14),

              // Asset Path Selector / Preset
              DropdownButtonFormField<String>(
                value: _imagePath,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Food Ordering Image Asset',
                  prefixIcon: Icon(Icons.image_outlined, color: AppTheme.goldAccent),
                ),
                items: ProductData.products.map((p) => p.image).toSet().map((img) {
                  final filename = img.split('/').last;
                  return DropdownMenuItem(value: img, child: Text(filename, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _imagePath = val);
                },
              ),
              const SizedBox(height: 14),

              // Availability Switch
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('Available in Menu', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                subtitle: const Text('Toggle whether customers can order this item', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                value: _available,
                activeThumbColor: AppTheme.goldAccent,
                onChanged: (val) => setState(() => _available = val),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'SAVE CHANGES' : 'CREATE PRODUCT',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
