import 'dart:io';
import 'package:e_come_seller_1/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/product_provider.dart';
import '../widgets/product_tile.dart';
import '../widgets/toast.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _newPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  // Selected category and images
  String? _selectedCategory;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    // Initialize products and categories when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).initialize();
    });
  }

  // Image picker method
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        // Limit to 5 images
        final newImages = images.take(5 - _selectedImages.length)
            .map((image) => File(image.path))
            .toList();
        
        // Add new images
        _selectedImages.addAll(newImages);

        // Show a message if user tries to add more than 5 images
        if (images.length > newImages.length) {
          CustomToast2.showError('Maximum 5 images allowed', context);
        }
      });
    }
  }

  // Remove image method
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Show add product dialog
  void _showAddProductDialog() {
    // Reset all controllers and selections
    _nameController.clear();
    _descriptionController.clear();
    _oldPriceController.clear();
    _newPriceController.clear();
    _quantityController.clear();
    _selectedCategory = null;
    _selectedImages.clear();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name TextField
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Description TextField
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Product Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Dropdown
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: _selectedCategory,
                      items: provider.categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Price TextFields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _oldPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Old Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _newPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'New Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quantity TextField
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Max Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Image Picker
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _pickImages,
                        icon: const Icon(Icons.image),
                        label: const Text(
                          'Select Images',
                          style: TextStyle(
                            color: AppColors.whitecolor,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedImages.length}/5 images',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                // Enhanced Image Preview
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(right: 8, top: 8),
                        width: 100,
                        height: 100,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close, 
                                    color: Colors.white, 
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          // Validate inputs
                          if (_validateInputs()) {
                            final success = await provider.uploadProduct(
                              name: _nameController.text.trim(),
                              description: _descriptionController.text.trim(),
                              images: _selectedImages,
                              oldPrice: int.tryParse(_oldPriceController.text) ?? 0,
                              newPrice: int.tryParse(_newPriceController.text) ?? 0,
                              category: _selectedCategory!,
                              maxQuantity: int.tryParse(_quantityController.text) ?? 0,
                            );

                            if (success) {
                              Navigator.pop(context);
                              CustomToast2.showSuccess(
                                'Product uploaded successfully',
                                context,
                              );
                            }
                          }
                        },
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Upload',
                          style: TextStyle(
                            color: AppColors.whitecolor,
                            fontSize: 17,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Input validation method
  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      CustomToast2.showError('Please enter product name', context);
      return false;
    }
    if (_selectedCategory == null) {
      CustomToast2.showError('Please select a category', context);
      return false;
    }
    if (_selectedImages.isEmpty) {
      CustomToast2.showError('Please select at least one image', context);
      return false;
    }
    if (_selectedImages.length > 5) {
      CustomToast2.showError('Maximum 5 images allowed', context);
      return false;
    }
    return true;
  }

  // Rest of the build method remains the same as in your original code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text('Products'),backgroundColor: AppColors.primaryDark,),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.products.isEmpty) {
            return const Center(child: Text('No products found',style: TextStyle(color: AppColors.whitecolor),));
          }

          // Products list
            // Products list
          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return ProductTile(
                product: product,
                context: context,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add_circle_outline,color: AppColors.whitecolor,size: 40,),
      ),
    );
  }
}