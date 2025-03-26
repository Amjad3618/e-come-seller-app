// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:e_come_seller_1/utils/color.dart';
import 'package:e_come_seller_1/widgets/email_form.dart';
import 'package:e_come_seller_1/widgets/password_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/categories_providers.dart';
import '../widgets/toast.dart';

class CategoriePage extends StatefulWidget {
  const CategoriePage({Key? key}) : super(key: key);

  @override
  State<CategoriePage> createState() => _CategoriePageState();
}

class _CategoriePageState extends State<CategoriePage> {
  final titleController = TextEditingController();
  final priorityController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Load categories when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  void _showAddCategoryDialog() {
    // Reset form fields
    titleController.clear();
    priorityController.clear();
    setState(() {
      _selectedImage = null; // Reset selected image
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmailTextField(
                  controller: titleController,
                  hintText: "Enter category name",
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  controller: priorityController,
                  hintText: "Enter priority (number)",
                ),
                const SizedBox(height: 16),
                // Image picker button
                OutlinedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image'),
                ),
                const SizedBox(height: 8),
                // Preview selected image
                if (_selectedImage != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      _selectedImage!, 
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          // Input validation
                          if (titleController.text.trim().isEmpty) {
                            CustomToast2.showError(
                              "Category name cannot be empty",
                              context,
                            );
                            return;
                          }

                          if (priorityController.text.trim().isEmpty) {
                            CustomToast2.showError(
                              "Priority cannot be empty",
                              context,
                            );
                            return;
                          }

                          if (_selectedImage == null) {
                            CustomToast2.showError(
                              "Please select an image",
                              context,
                            );
                            return;
                          }

                          final parsedPriority = int.tryParse(priorityController.text.trim());
                          if (parsedPriority == null) {
                            CustomToast2.showError(
                              "Priority must be a valid number",
                              context,
                            );
                            return;
                          }

                          final success = await provider.addCategory(
                            titleController.text.trim(),
                            parsedPriority,
                            _selectedImage!,
                          );

                          if (success) {
                            Navigator.pop(context);
                            CustomToast2.showSuccess(
                              "Successfully Uploaded!",
                              context,
                            );
                          } else {
                            CustomToast2.showError(
                              'Error: ${provider.error}',
                              context,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Upload',
                          style: TextStyle(color: Colors.white),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.loadCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.categories.isEmpty) {
            return const Center(
              child: Text('No categories found. Add a new category!'),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
            child: ListView.builder(
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(35),
                    bottomRight: const Radius.circular(35),
                  ),
                  child: Card(
                    child: ListTile(
                      tileColor: AppColors.primaryDark,
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(category.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(color: AppColors.whitecolor),
                      ),
                      subtitle: Text(
                        'Priority: ${category.priority}',
                        style: TextStyle(color: AppColors.whitecolor),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              // TODO: Implement edit category functionality
                              CustomToast2.showError(
                                "Edit functionality not implemented yet",
                                context,
                              );
                            },
                          ),
                          IconButton(
                            color: AppColors.whitecolor,
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Show delete confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Category'),
                                  content: Text(
                                    'Are you sure you want to delete "${category.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final success = await provider.deleteCategory(
                                          category.id,
                                          category.image,
                                        );

                                        Navigator.pop(context); // Close the dialog

                                        if (success) {
                                          CustomToast2.showSuccess(
                                            "Category deleted successfully",
                                            context,
                                          );
                                        } else {
                                          CustomToast2.showError(
                                            "Failed to delete category!",
                                            context,
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add_circle, size: 40, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priorityController.dispose();
    super.dispose();
  }
}