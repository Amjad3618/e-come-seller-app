import 'package:e_come_seller_1/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/product_provider.dart';
import '../widgets/toast.dart';

class ProductTile extends StatelessWidget {
  final dynamic product;
  final BuildContext context;

  const ProductTile({
    Key? key,
    required this.product,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Details Row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: product.images.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.images.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: product.images.isEmpty 
                          ? Colors.grey[300] 
                          : null,
                    ),
                    child: product.images.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported, 
                              size: 40, 
                              color: Colors.grey,
                            ),
                          )
                        : null,
                  ),

                  // Product Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Category and Image Count
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.category,
                                style: TextStyle(
                                  color: AppColors.whitecolor,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${product.images.length} image(s)',
                                style: TextStyle(
                                  color: AppColors.whitecolor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Price
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // New Price
                              Text(
                                '\$${product.newprice}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.whitecolor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Old Price (if exists)
                              if (product.oldprice > 0)
                                Text(
                                  '\$${product.oldprice}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.scaffold,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          // Image Gallery
                          const SizedBox(height: 8),
                          if (product.images.length > 1)
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: product.images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(product.images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Button
                  ElevatedButton.icon(
                    onPressed: () {
                      CustomToast2.showError(
                        'Edit not implemented',
                        context,
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Delete Button
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                            'Are you sure you want to delete this product?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final provider = Provider.of<ProductProvider>(context, listen: false);
                                await provider.deleteProduct(product.id);
                                Navigator.pop(context);
                                CustomToast2.showSuccess(
                                  'Product deleted',
                                  context,
                                );
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
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}