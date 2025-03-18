import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../utils/color.dart';
import '../view_model.dart/product_view_model.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: const _ProductPageContent(),
    );
  }
}

class _ProductPageContent extends StatelessWidget {
  const _ProductPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductViewModel>(context);
    
    return Scaffold(
        resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {},
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProductList(context, viewModel),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showProductForm(context),
        child: const Icon(Icons.add, size: 40, color: AppColors.whitecolor),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, ProductViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    
    if (viewModel.products.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    return ListView.builder(
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return ProductListItem(
          product: product,
          onEdit: () => _showProductForm(context, product: product),
          onDelete: () => _confirmDelete(context, product),
        );
      },
    );
  }

  void _showProductForm(BuildContext context, {ProductsModel? product}) {
    final viewModel = Provider.of<ProductViewModel>(context, listen: false);
    
    if (product != null) {
      viewModel.setFormData(product);
    } else {
      // Use the _clearForm method indirectly through the view model
      viewModel.selectedImages = [];
      viewModel.existingImages = [];
      viewModel.imagesToDelete = [];
      viewModel.nameController.clear();
      viewModel.descriptionController.clear();
      viewModel.oldPriceController.clear();
      viewModel.newPriceController.clear();
      viewModel.categoryController.clear();
      viewModel.maxQuantityController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: ProductForm(existingProduct: product),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductsModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final viewModel = Provider.of<ProductViewModel>(context, listen: false);
              viewModel.deleteProduct(product.id, product.images);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final ProductsModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images[0],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.broken_image, size: 80),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${product.newprice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (product.oldprice > 0)
                            Text(
                              '₹${product.oldprice}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Additional info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category: ${product.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Stock: ${product.maxQuantity}',
                  style: TextStyle(
                    fontSize: 14,
                    color: product.maxQuantity > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Multiple images indicators if there are more than one
            if (product.images.length > 1)
              Container(
                height: 30,
                margin: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.network(
                          product.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.broken_image, size: 20),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductForm extends StatelessWidget {
  final ProductsModel? existingProduct;

  const ProductForm({Key? key, this.existingProduct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductViewModel>(context);
    final formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existingProduct == null ? 'Add New Product' : 'Edit Product',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextFormField(
              controller: viewModel.nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: viewModel.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: viewModel.oldPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Original Price',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter original price';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: viewModel.newPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price',
                      border: OutlineInputBorder(),
                      prefixText: '',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter sale price';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: viewModel.categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: viewModel.maxQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Product Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Selected new images grid
            if (viewModel.selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: viewModel.selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(
                            viewModel.selectedImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => viewModel.removeSelectedImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 8),
            // Existing images grid
            if (viewModel.existingImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Images',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: viewModel.existingImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = viewModel.existingImages[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => viewModel.removeExistingImage(imageUrl),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final List<XFile> photos = await picker.pickMultiImage();
                if (photos.isNotEmpty) {
                  for (var photo in photos) {
                    viewModel.addImage(File(photo.path));
                  }
                }
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              if (existingProduct != null) {
                                viewModel.updateProduct(existingProduct!.id);
                              } else {
                                viewModel.addProduct();
                              }
                              Navigator.of(context).pop();
                            }
                          },
                    child: Text(
                      existingProduct == null ? 'Add Product' : 'Update Product',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}