import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/categorie_model.dart';

import '../utils/color.dart';
import '../view_model.dart/category_view_model.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryViewModel(),
      child: const _CategoryScreenContent(),
    );
  }
}

class _CategoryScreenContent extends StatelessWidget {
  const _CategoryScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CategoryViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
          : _buildCategoryList(context, viewModel),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCategoryForm(context),
        child:  Icon(Icons.add, size: 40, color: AppColors.whitecolor),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoryViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    
    if (viewModel.categories.isEmpty) {
      return const Center(child: Text('No categories available'));
    }

    return ListView.builder(
      itemCount: viewModel.categories.length,
      itemBuilder: (context, index) {
        final category = viewModel.categories[index];
        return CategoryListItem(
          category: category,
          onEdit: () => _showCategoryForm(context, category: category),
          onDelete: () => _confirmDelete(context, category),
        );
      },
    );
  }

  void _showCategoryForm(BuildContext context, {CategorieModel? category}) {
    final viewModel = Provider.of<CategoryViewModel>(context, listen: false);
    
    if (category != null) {
      viewModel.setFormData(category);
    } else {
      viewModel.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: CategoryForm(existingCategory: category),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategorieModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final viewModel = Provider.of<CategoryViewModel>(context, listen: false);
              viewModel.deleteCategory(category.id, imageUrl: category.image);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final CategorieModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListItem({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Priority: ${category.priority}'),
        leading: category.image.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  category.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image, size: 50),
                ),
              )
            : const CircleAvatar(child: Icon(Icons.category)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

class CategoryForm extends StatelessWidget {
  final CategorieModel? existingCategory;

  const CategoryForm({Key? key, this.existingCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CategoryViewModel>(context);
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter category name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.priorityController,
            decoration: const InputDecoration(
              labelText: 'Category Priority',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter category priority';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? photo = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (photo != null) {
                      viewModel.setImage(File(photo.path));
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewModel.selectedImage != null)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange,width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.file(
                viewModel.selectedImage!,
                fit: BoxFit.cover,
              ),
            )
          else if (existingCategory != null && existingCategory!.image.isNotEmpty)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.network(
                existingCategory!.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.broken_image, size: 100),
              ),
            )
          else
            const Text('No image selected'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      if (existingCategory != null) {
                        viewModel.updateCategory(
                          existingCategory!.id,
                          existingImageUrl: existingCategory!.image,
                        );
                      } else {
                        viewModel.addCategory();
                      }
                      Navigator.of(context).pop();
                    }
                  },
            child: Text(
              existingCategory == null ? 'Add Category' : 'Update Category',
            ),
          ),
        ],
      ),
    );
  }
}