import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/product_data.dart';
import '../../widgets/app_image.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _specialNoteController;
  late String _selectedCategory;
  late String _imagePath;
  late bool _available;
  late bool _isSpecial;
  String? _attachedFileName;
  String? _attachedFileSize;
  bool _isPickingFile = false;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toStringAsFixed(2) : '',
    );
    _specialNoteController = TextEditingController(text: widget.product?.specialNote ?? '');
    _selectedCategory = widget.product?.category ?? 'Coffee & Espresso';
    // When creating a new product, start with empty image so only placeholder icon is shown
    _imagePath = widget.product?.image ?? '';
    _available = widget.product?.available ?? true;
    _isSpecial = widget.product?.isSpecial ?? false;

    if (_imagePath.startsWith('data:')) {
      _attachedFileName = 'Attached Photo';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _specialNoteController.dispose();
    super.dispose();
  }

  /// Primary image picker using ImagePicker (works seamlessly on Chrome/Web and mobile)
  Future<void> _pickImage() async {
    setState(() => _isPickingFile = true);
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 75,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final ext = (image.name.split('.').last).toLowerCase();
        final mime = (ext == 'png') ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
        final base64String = 'data:image/$mime;base64,${base64Encode(bytes)}';
        final sizeKb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);

        setState(() {
          _imagePath = base64String;
          _attachedFileName = image.name;
          _attachedFileSize = '$sizeKb KB';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Photo Attached: ${image.name} ($sizeKb KB)',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.goldAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('ImagePicker failed, trying FilePicker: $e');
      await _pickImageWithFilePicker();
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  /// Fallback picker using FilePicker
  Future<void> _pickImageWithFilePicker() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);

      if (file != null) {
        final bytes = await file.xFile.readAsBytes();
        final ext = (file.extension ?? 'jpg').toLowerCase();
        final mime = (ext == 'png') ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
        final base64String = 'data:image/$mime;base64,${base64Encode(bytes)}';
        final sizeKb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);

        setState(() {
          _imagePath = base64String;
          _attachedFileName = file.name;
          _attachedFileSize = '$sizeKb KB';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo Attached: ${file.name} ($sizeKb KB)'),
              backgroundColor: AppTheme.goldAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Reset image back to placeholder icon
  void _clearImage() {
    setState(() {
      _imagePath = '';
      _attachedFileName = null;
      _attachedFileSize = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo cleared.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Dialog allowing admin to enter an external web URL for the image
  void _showUrlInputDialog() {
    final urlController = TextEditingController(
      text: (_imagePath.startsWith('http://') || _imagePath.startsWith('https://')) ? _imagePath : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.link_rounded, color: AppTheme.goldAccent),
            SizedBox(width: 8),
            Text('Enter Image Web URL', style: TextStyle(color: AppTheme.textWhite, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste a direct URL to a food or drink photo from the web (JPG, PNG, WebP):',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                hintText: 'https://images.unsplash.com/...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                prefixIcon: Icon(Icons.http_rounded, color: AppTheme.goldAccent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                setState(() {
                  _imagePath = url;
                  _attachedFileName = 'Web Image Link';
                  _attachedFileSize = null;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image URL applied successfully!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Apply URL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Please enter the food/drink name.',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.goldAccent,
        ),
      );
      return;
    }

    final rawPrice = _priceController.text.replaceAll(RegExp(r'[^\d.]'), '').trim();
    final price = double.tryParse(rawPrice);
    if (price == null || price <= 0) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Please enter a valid price (e.g. 150).',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.goldAccent,
        ),
      );
      return;
    }

    final desc = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'Freshly prepared $name handcrafted with premium ingredients at arCUPs.';

    // If no custom image attached, assign category standard image
    String finalImage = _imagePath;
    if (finalImage.isEmpty) {
      if (_selectedCategory.contains('Frappe')) {
        finalImage = 'assets/images/frappe/caramel_frappuccino.jpg';
      } else if (_selectedCategory.contains('Pasta')) {
        finalImage = 'assets/images/pasta/creamy_carbonara.jpg';
      } else if (_selectedCategory.contains('Salad')) {
        finalImage = 'assets/images/salad/caesar_salad.jpg';
      } else {
        finalImage = 'assets/images/drinks/americano.jpg';
      }
    }

    setState(() => _isSaving = true);
    try {
      final prodProv = context.read<ProductProvider>();
      if (isEditing) {
        final updated = widget.product!.copyWith(
          name: name,
          category: _selectedCategory,
          description: desc,
          price: price,
          image: finalImage,
          available: _available,
          isSpecial: _isSpecial,
          specialNote: _isSpecial && _specialNoteController.text.trim().isNotEmpty
              ? _specialNoteController.text.trim()
              : null,
        );
        await prodProv.updateProduct(updated);
      } else {
        final newId = 'item_${DateTime.now().millisecondsSinceEpoch}';
        final newProduct = Product(
          id: newId,
          name: name,
          category: _selectedCategory,
          description: desc,
          price: price,
          image: finalImage,
          available: _available,
          isSpecial: _isSpecial,
          specialNote: _isSpecial && _specialNoteController.text.trim().isNotEmpty
              ? _specialNoteController.text.trim()
              : null,
        );
        await prodProv.addProduct(newProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEditing
                        ? 'Updated "$name" in menu!'
                        : 'Added "$name" to menu successfully!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final validCategories = ProductData.categories.where((c) => c != 'All').toList();
    final hasAttachedImage = _imagePath.isNotEmpty;
    final isCustomAttached = _imagePath.startsWith('data:');
    final isUrl = _imagePath.startsWith('http://') || _imagePath.startsWith('https://');

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Food / Drink' : 'Add New Food / Drink'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= PHOTO ATTACHMENT & PREVIEW SECTION =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    // Section Title
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, color: AppTheme.goldAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'FOOD / DRINK PHOTO',
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Preview Box: If no image attached, only show image placeholder icon!
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 190,
                          decoration: BoxDecoration(
                            color: AppTheme.imageBackdrop,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: hasAttachedImage
                                  ? (_isSpecial ? AppTheme.goldAccent : AppTheme.cardBorder)
                                  : AppTheme.cardBorder,
                              width: hasAttachedImage && _isSpecial ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: hasAttachedImage
                                ? AppImage(
                                    imagePath: _imagePath,
                                    fit: BoxFit.cover,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.cardSurface,
                                          border: Border.all(
                                            color: AppTheme.goldAccent.withValues(alpha: 0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 48,
                                          color: AppTheme.goldAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No Image Attached',
                                        style: TextStyle(
                                          color: AppTheme.textWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Attach a photo of the food/drink',
                                        style: TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // Special Badge if active
                        if (hasAttachedImage && _isSpecial)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.goldAccent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 13, color: Colors.black),
                                  SizedBox(width: 3),
                                  Text(
                                    'SPECIAL DAY',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Remove attached image button
                        if (hasAttachedImage)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: _clearImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30, width: 1),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),

                        // Attachment Status Chip
                        if (hasAttachedImage)
                          Positioned(
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isCustomAttached
                                        ? Icons.attach_file_rounded
                                        : isUrl
                                            ? Icons.link_rounded
                                            : Icons.photo_library_outlined,
                                    size: 13,
                                    color: AppTheme.goldAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isCustomAttached
                                        ? (_attachedFileName ?? 'Custom File Attached')
                                        : isUrl
                                            ? 'Web Image Link'
                                            : 'Preset Asset',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (_attachedFileSize != null && hasAttachedImage) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Size: $_attachedFileSize',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Primary Button: Attach Photo from Device
                    ElevatedButton.icon(
                      onPressed: _isPickingFile ? null : _pickImage,
                      icon: _isPickingFile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.file_upload_outlined, color: Colors.black),
                      label: Text(
                        _isPickingFile
                            ? 'OPENING FILE BROWSER...'
                            : (hasAttachedImage ? 'CHANGE / ATTACH NEW PHOTO' : 'ATTACH / UPLOAD PHOTO'),
                        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Secondary: Image Web Link Option
                    OutlinedButton.icon(
                      onPressed: _showUrlInputDialog,
                      icon: const Icon(Icons.link_rounded, size: 16, color: AppTheme.textWhite),
                      label: const Text(
                        'Or Paste Image Web Link',
                        style: TextStyle(color: AppTheme.textWhite, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= SPECIAL DAY FEATURE SECTION =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: _isSpecial
                      ? LinearGradient(
                          colors: [
                            AppTheme.goldAccent.withValues(alpha: 0.15),
                            AppTheme.cardSurface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _isSpecial ? null : AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSpecial ? AppTheme.goldAccent : AppTheme.cardBorder,
                    width: _isSpecial ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          color: _isSpecial ? AppTheme.goldAccent : AppTheme.textMuted,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Special Day & Promo Offering',
                                style: TextStyle(
                                  color: AppTheme.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Highlight this food/drink for special days, holidays, or events',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isSpecial,
                          activeThumbColor: AppTheme.goldAccent,
                          activeTrackColor: AppTheme.goldAccent.withValues(alpha: 0.4),
                          onChanged: (val) {
                            setState(() {
                              _isSpecial = val;
                            });
                          },
                        ),
                      ],
                    ),

                    if (_isSpecial) ...[
                      const Divider(color: AppTheme.cardBorder, height: 24),
                      TextFormField(
                        controller: _specialNoteController,
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Special Day Promo Note / Tag (Optional)',
                          hintText: 'e.g. Valentine\'s Exclusive, Weekend Chef\'s Special',
                          prefixIcon: Icon(Icons.stars_rounded, color: AppTheme.goldAccent),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppTheme.goldAccent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tip: You can also categorize this under "Special Day Specials" in the category dropdown below.',
                              style: TextStyle(
                                color: AppTheme.textWhite.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'Special Day Specials';
                              });
                            },
                            child: const Text(
                              'Set Category',
                              style: TextStyle(color: AppTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ================= BASIC PRODUCT INFORMATION =================
              // Product Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g. Strawberry Velvet Frappe',
                  prefixIcon: Icon(Icons.label_outline_rounded, color: AppTheme.goldAccent),
                ),
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: validCategories.contains(_selectedCategory) ? _selectedCategory : validCategories.first,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, color: AppTheme.goldAccent),
                ),
                items: validCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        if (cat == 'Special Day Specials') ...[
                          const Icon(Icons.stars_rounded, size: 16, color: AppTheme.goldAccent),
                          const SizedBox(width: 8),
                        ],
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      if (val == 'Special Day Specials') {
                        _isSpecial = true;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Price (₱) *',
                  hintText: 'e.g. 175.00',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.goldAccent),
                ),
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Describe ingredients, flavor profile, and recipe...',
                  prefixIcon: Icon(Icons.description_outlined, color: AppTheme.goldAccent),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),

              // Availability Switch
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('Available in Menu', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                subtitle: const Text('Toggle whether customers can order this item right now', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                value: _available,
                activeThumbColor: AppTheme.goldAccent,
                onChanged: (val) => setState(() => _available = val),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'SAVING PRODUCT...',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                          ),
                        ],
                      )
                    : Text(
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
